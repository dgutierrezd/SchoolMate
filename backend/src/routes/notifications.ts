import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";

const router = Router();
router.use(authMiddleware);

// POST /notifications/register
router.post("/register", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { token, platform } = req.body;

  if (!token) {
    res.status(400).json({ error: "Device token is required" });
    return;
  }

  try {
    const { data, error } = await supabaseAdmin
      .from("device_tokens")
      .upsert(
        {
          user_id: authReq.user.id,
          token,
          platform: platform || "ios",
        },
        { onConflict: "token" }
      )
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

// DELETE /notifications/unregister
router.delete("/unregister", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { token } = req.body;

  if (!token) {
    res.status(400).json({ error: "Device token is required" });
    return;
  }

  try {
    const { error } = await supabaseAdmin
      .from("device_tokens")
      .delete()
      .eq("user_id", authReq.user.id)
      .eq("token", token);

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json({ message: "Device token removed" });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
