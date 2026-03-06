import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";
import { authLimiter } from "../middleware/rateLimiter";

const router = Router();

// POST /auth/signup
router.post("/signup", authLimiter, async (req: Request, res: Response) => {
  const { email, password, fullName } = req.body;

  if (!email || !password || !fullName) {
    res.status(400).json({ error: "Email, password, and full name are required" });
    return;
  }

  try {
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    // Create profile (upsert to handle edge cases)
    const { error: profileError } = await supabaseAdmin.from("profiles").upsert({
      id: data.user.id,
      email,
      full_name: fullName,
    }, { onConflict: "id" });

    // Retry without email if column doesn't exist yet
    if (profileError) {
      await supabaseAdmin.from("profiles").upsert({
        id: data.user.id,
        full_name: fullName,
      }, { onConflict: "id" });
    }

    // Sign in to get session
    const { data: session, error: signInError } =
      await supabaseAdmin.auth.signInWithPassword({ email, password });

    if (signInError) {
      res.status(400).json({ error: signInError.message });
      return;
    }

    res.status(201).json({
      user: data.user,
      session: session.session,
    });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /auth/signin
router.post("/signin", authLimiter, async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ error: "Email and password are required" });
    return;
  }

  try {
    const { data, error } = await supabaseAdmin.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      res.status(401).json({ error: error.message });
      return;
    }

    // Ensure profile exists (may be missing if signup profile creation failed)
    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("id")
      .eq("id", data.user.id)
      .single();

    if (!profile) {
      const { error: profileError } = await supabaseAdmin.from("profiles").insert({
        id: data.user.id,
        email: data.user.email,
        full_name: data.user.user_metadata?.full_name || data.user.email || "User",
      });

      // Retry without email if column doesn't exist yet
      if (profileError) {
        await supabaseAdmin.from("profiles").insert({
          id: data.user.id,
          full_name: data.user.user_metadata?.full_name || data.user.email || "User",
        });
      }
    }

    res.json({
      user: data.user,
      session: data.session,
    });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /auth/apple
router.post("/apple", authLimiter, async (req: Request, res: Response) => {
  const { idToken, nonce } = req.body;

  if (!idToken) {
    res.status(400).json({ error: "ID token is required" });
    return;
  }

  try {
    const { data, error } = await supabaseAdmin.auth.signInWithIdToken({
      provider: "apple",
      token: idToken,
      nonce,
    });

    if (error) {
      res.status(401).json({ error: error.message });
      return;
    }

    // Ensure profile exists
    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("id")
      .eq("id", data.user.id)
      .single();

    if (!profile) {
      const { error: profileError } = await supabaseAdmin.from("profiles").insert({
        id: data.user.id,
        email: data.user.email,
        full_name: data.user.user_metadata?.full_name || "User",
      });

      // Retry without email if column doesn't exist yet
      if (profileError) {
        await supabaseAdmin.from("profiles").insert({
          id: data.user.id,
          full_name: data.user.user_metadata?.full_name || "User",
        });
      }
    }

    res.json({
      user: data.user,
      session: data.session,
    });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /auth/refresh
router.post("/refresh", async (req: Request, res: Response) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    res.status(400).json({ error: "Refresh token is required" });
    return;
  }

  try {
    const { data, error } = await supabaseAdmin.auth.refreshSession({
      refresh_token: refreshToken,
    });

    if (error) {
      res.status(401).json({ error: error.message });
      return;
    }

    res.json({ session: data.session });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// DELETE /auth/signout
router.delete(
  "/signout",
  authMiddleware,
  async (req: Request, res: Response) => {
    try {
      const authReq = req as AuthRequest;
      await supabaseAdmin.auth.admin.signOut(authReq.user.id);
      res.json({ message: "Signed out successfully" });
    } catch (err) {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
