import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";
import { summarizeHomework } from "../services/claude.service";

const router = Router();
router.use(authMiddleware);

// GET /homework?childId=
router.get("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { childId, status } = req.query;

  if (!childId) {
    res.status(400).json({ error: "childId is required" });
    return;
  }

  try {
    // Verify parent owns this child
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

    let query = supabaseAdmin
      .from("homework")
      .select("*, subjects(name, color, icon)")
      .eq("child_id", childId)
      .order("due_date", { ascending: true });

    if (status && typeof status === "string") {
      query = query.eq("status", status);
    }

    const { data, error } = await query;

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /homework
router.post("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const {
    child_id,
    subject_id,
    title,
    description,
    due_date,
    priority,
    attachment_url,
  } = req.body;

  if (!child_id || !title || !due_date) {
    res
      .status(400)
      .json({ error: "child_id, title, and due_date are required" });
    return;
  }

  try {
    // Verify ownership
    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", child_id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(404).json({ error: "Child not found" });
      return;
    }

    // Generate AI summary if description provided
    let ai_summary: string | undefined;
    if (description) {
      try {
        // Get parent's language preference
        const { data: profile } = await supabaseAdmin
          .from("profiles")
          .select("language")
          .eq("id", authReq.user.id)
          .single();
        ai_summary = await summarizeHomework(
          title,
          description,
          profile?.language || "en"
        );
      } catch {
        // Don't fail if AI summary fails
      }
    }

    const { data, error } = await supabaseAdmin
      .from("homework")
      .insert({
        child_id,
        subject_id,
        title,
        description,
        due_date,
        priority: priority || "medium",
        attachment_url,
        ai_summary,
      })
      .select("*, subjects(name, color, icon)")
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

// PUT /homework/:id
router.put("/:id", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;
  const updates = req.body;

  try {
    // Verify ownership through child
    const { data: homework } = await supabaseAdmin
      .from("homework")
      .select("child_id")
      .eq("id", id)
      .single();

    if (!homework) {
      res.status(404).json({ error: "Homework not found" });
      return;
    }

    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", homework.child_id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(403).json({ error: "Unauthorized" });
      return;
    }

    const { data, error } = await supabaseAdmin
      .from("homework")
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq("id", id)
      .select("*, subjects(name, color, icon)")
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

// DELETE /homework/:id
router.delete("/:id", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;

  try {
    const { data: homework } = await supabaseAdmin
      .from("homework")
      .select("child_id")
      .eq("id", id)
      .single();

    if (!homework) {
      res.status(404).json({ error: "Homework not found" });
      return;
    }

    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", homework.child_id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(403).json({ error: "Unauthorized" });
      return;
    }

    const { error } = await supabaseAdmin
      .from("homework")
      .delete()
      .eq("id", id);

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json({ message: "Homework deleted" });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// PATCH /homework/:id/complete
router.patch("/:id/complete", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;

  try {
    const { data: homework } = await supabaseAdmin
      .from("homework")
      .select("child_id")
      .eq("id", id)
      .single();

    if (!homework) {
      res.status(404).json({ error: "Homework not found" });
      return;
    }

    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", homework.child_id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(403).json({ error: "Unauthorized" });
      return;
    }

    const { data, error } = await supabaseAdmin
      .from("homework")
      .update({
        status: "completed",
        updated_at: new Date().toISOString(),
      })
      .eq("id", id)
      .select("*, subjects(name, color, icon)")
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

export default router;
