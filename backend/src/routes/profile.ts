import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";

const router = Router();
router.use(authMiddleware);

// GET /profile
router.get("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;

  try {
    const { data, error } = await supabaseAdmin
      .from("profiles")
      .select("*")
      .eq("id", authReq.user.id)
      .single();

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    // Also get email from auth
    const { data: authData } = await supabaseAdmin.auth.admin.getUserById(
      authReq.user.id
    );

    res.json({
      ...data,
      email: authData?.user?.email || data.email,
    });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// PUT /profile
router.put("/", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { full_name, language } = req.body;

  try {
    const updates: Record<string, string> = {
      updated_at: new Date().toISOString(),
    };
    if (full_name !== undefined) updates.full_name = full_name;
    if (language !== undefined) updates.language = language;

    const { data, error } = await supabaseAdmin
      .from("profiles")
      .update(updates)
      .eq("id", authReq.user.id)
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

export default router;
