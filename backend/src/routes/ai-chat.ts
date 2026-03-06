import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";
import { aiChatLimiter } from "../middleware/rateLimiter";
import {
  streamChatCompletion,
  buildSystemPrompt,
} from "../services/openai.service";

const router = Router();
router.use(authMiddleware);

// POST /ai/chat — Send AI chat message (SSE stream)
router.post("/chat", aiChatLimiter, async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { childId, message, language } = req.body;

  if (!childId || !message) {
    res.status(400).json({ error: "childId and message are required" });
    return;
  }

  try {
    // Fetch child profile with subjects
    const { data: child, error: childError } = await supabaseAdmin
      .from("children")
      .select("*, subjects(*)")
      .eq("id", childId)
      .eq("parent_id", authReq.user.id)
      .single();

    if (childError || !child) {
      res.status(404).json({ error: "Child not found" });
      return;
    }

    // Get parent's language preference
    const userLanguage = language || "en";

    // Fetch last 20 messages for context
    const { data: history } = await supabaseAdmin
      .from("chat_messages")
      .select("*")
      .eq("child_id", childId)
      .eq("parent_id", authReq.user.id)
      .order("created_at", { ascending: false })
      .limit(20);

    const systemPrompt = buildSystemPrompt(child, userLanguage);

    const messages = [
      { role: "system" as const, content: systemPrompt },
      ...(history || []).reverse().map((m: any) => ({
        role: m.role as "user" | "assistant",
        content: m.content,
      })),
      { role: "user" as const, content: message },
    ];

    // Set up SSE
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");

    let fullResponse = "";

    for await (const delta of streamChatCompletion(messages)) {
      fullResponse += delta;
      res.write(`data: ${JSON.stringify({ delta })}\n\n`);
    }

    res.write(`data: ${JSON.stringify({ done: true })}\n\n`);
    res.end();

    // Save messages to DB
    await supabaseAdmin.from("chat_messages").insert([
      {
        child_id: childId,
        parent_id: authReq.user.id,
        role: "user",
        content: message,
      },
      {
        child_id: childId,
        parent_id: authReq.user.id,
        role: "assistant",
        content: fullResponse,
      },
    ]);
  } catch (err) {
    console.error("AI chat error:", err);
    if (!res.headersSent) {
      res.status(500).json({ error: "AI chat failed" });
    }
  }
});

// GET /ai/chat/history/:childId
router.get("/chat/history/:childId", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { childId } = req.params;
  const { limit } = req.query;

  try {
    // Verify ownership
    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", childId)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(404).json({ error: "Child not found" });
      return;
    }

    const { data, error } = await supabaseAdmin
      .from("chat_messages")
      .select("*")
      .eq("child_id", childId)
      .eq("parent_id", authReq.user.id)
      .order("created_at", { ascending: true })
      .limit(Number(limit) || 100);

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// DELETE /ai/chat/history/:childId — Clear chat history (new conversation)
router.delete(
  "/chat/history/:childId",
  async (req: Request, res: Response) => {
    const authReq = req as AuthRequest;
    const { childId } = req.params;

    try {
      const { data: child } = await supabaseAdmin
        .from("children")
        .select("id")
        .eq("id", childId)
        .eq("parent_id", authReq.user.id)
        .single();

      if (!child) {
        res.status(404).json({ error: "Child not found" });
        return;
      }

      const { error } = await supabaseAdmin
        .from("chat_messages")
        .delete()
        .eq("child_id", childId)
        .eq("parent_id", authReq.user.id);

      if (error) {
        res.status(400).json({ error: error.message });
        return;
      }

      res.json({ message: "Chat history cleared" });
    } catch (err) {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
