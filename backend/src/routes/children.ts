import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";
import { buildChildAIContext } from "../services/claude.service";

const router = Router();
router.use(authMiddleware);

// GET /children
router.get("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;

  try {
    const { data, error } = await supabaseAdmin
      .from("children")
      .select("*, subjects(*)")
      .eq("parent_id", authReq.user.id)
      .order("created_at", { ascending: true });

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /children
router.post("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { name, grade, school, avatar_color, avatar_emoji } = req.body;

  if (!name || !grade) {
    res.status(400).json({ error: "Name and grade are required" });
    return;
  }

  try {
    // Ensure profile exists before inserting child (safety net for FK constraint)
    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("id")
      .eq("id", authReq.user.id)
      .single();

    if (!profile) {
      const { error: profileError } = await supabaseAdmin.from("profiles").insert({
        id: authReq.user.id,
        email: authReq.user.email,
        full_name: authReq.user.email || "User",
      });

      if (profileError) {
        await supabaseAdmin.from("profiles").insert({
          id: authReq.user.id,
          full_name: authReq.user.email || "User",
        });
      }
    }

    const { data, error } = await supabaseAdmin
      .from("children")
      .insert({
        parent_id: authReq.user.id,
        name,
        grade,
        school,
        avatar_color: avatar_color || "#6366F1",
        avatar_emoji: avatar_emoji || "🎒",
      })
      .select()
      .single();

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.status(201).json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// PUT /children/:id
router.put("/:id", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;
  const { name, grade, school, avatar_color, avatar_emoji } = req.body;

  try {
    // Verify ownership
    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(404).json({ error: "Child not found" });
      return;
    }

    const { data, error } = await supabaseAdmin
      .from("children")
      .update({
        name,
        grade,
        school,
        avatar_color,
        avatar_emoji,
        updated_at: new Date().toISOString(),
      })
      .eq("id", id)
      .select()
      .single();

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// DELETE /children/:id
router.delete("/:id", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;

  try {
    const { error } = await supabaseAdmin
      .from("children")
      .delete()
      .eq("id", id)
      .eq("parent_id", authReq.user.id);

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json({ message: "Child removed successfully" });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /children/:id/ai-context — Regenerate AI context
router.post("/:id/ai-context", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;

  try {
    // Fetch child with subjects and recent homework
    const { data: child, error: childError } = await supabaseAdmin
      .from("children")
      .select("*, subjects(*)")
      .eq("id", id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (childError || !child) {
      res.status(404).json({ error: "Child not found" });
      return;
    }

    const { data: recentHomework } = await supabaseAdmin
      .from("homework")
      .select("title")
      .eq("child_id", id)
      .order("created_at", { ascending: false })
      .limit(10);

    const aiContext = await buildChildAIContext({
      ...child,
      recentHomework: recentHomework || [],
    });

    await supabaseAdmin
      .from("children")
      .update({ ai_context: aiContext, updated_at: new Date().toISOString() })
      .eq("id", id);

    res.json({ ai_context: aiContext });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
