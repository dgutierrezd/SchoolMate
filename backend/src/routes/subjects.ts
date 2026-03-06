import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";

const router = Router();
router.use(authMiddleware);

// GET /subjects?childId=
router.get("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { childId } = req.query;

  if (!childId) {
    res.status(400).json({ error: "childId is required" });
    return;
  }

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
      .from("subjects")
      .select("*")
      .eq("child_id", childId)
      .order("name", { ascending: true });

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /subjects
router.post("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { child_id, name, teacher_name, color, icon, notes } = req.body;

  if (!child_id || !name) {
    res.status(400).json({ error: "child_id and name are required" });
    return;
  }

  try {
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

    const { data, error } = await supabaseAdmin
      .from("subjects")
      .insert({
        child_id,
        name,
        teacher_name,
        color: color || "#6366F1",
        icon: icon || "📚",
        notes,
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

// PUT /subjects/:id
router.put("/:id", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;
  const { name, teacher_name, color, icon, notes } = req.body;

  try {
    // Verify ownership through child
    const { data: subject } = await supabaseAdmin
      .from("subjects")
      .select("child_id")
      .eq("id", id)
      .single();

    if (!subject) {
      res.status(404).json({ error: "Subject not found" });
      return;
    }

    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", subject.child_id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(403).json({ error: "Unauthorized" });
      return;
    }

    const { data, error } = await supabaseAdmin
      .from("subjects")
      .update({ name, teacher_name, color, icon, notes })
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

// DELETE /subjects/:id
router.delete("/:id", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { id } = req.params;

  try {
    const { data: subject } = await supabaseAdmin
      .from("subjects")
      .select("child_id")
      .eq("id", id)
      .single();

    if (!subject) {
      res.status(404).json({ error: "Subject not found" });
      return;
    }

    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id")
      .eq("id", subject.child_id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(403).json({ error: "Unauthorized" });
      return;
    }

    const { error } = await supabaseAdmin
      .from("subjects")
      .delete()
      .eq("id", id);

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json({ message: "Subject deleted" });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
