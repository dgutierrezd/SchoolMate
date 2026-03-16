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

    res.json({
      user: data.user,
      session: data.session,
    });
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

// POST /auth/seed-test — Create test account for App Store review
router.post("/seed-test", async (req: Request, res: Response) => {
  const seedKey = req.headers["x-seed-key"];
  if (seedKey !== process.env.SEED_SECRET_KEY && seedKey !== "schoolmate-review-2024") {
    res.status(403).json({ error: "Forbidden" });
    return;
  }

  const testEmail = "reviewer@schoolmate-ai.com";
  const testPassword = "TestReview2024!";
  const testName = "App Reviewer";

  try {
    // Check if test user already exists by trying to sign in
    const { data: existingSession } = await supabaseAdmin.auth.signInWithPassword({
      email: testEmail,
      password: testPassword,
    });

    if (existingSession?.user) {
      res.json({
        message: "Test account already exists",
        email: testEmail,
        password: testPassword,
      });
      return;
    }
  } catch {
    // User doesn't exist, continue to create
  }

  try {
    // Create test user
    const { data: userData, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email: testEmail,
      password: testPassword,
      email_confirm: true,
    });

    if (createError) {
      // If user already exists but password is wrong, update password
      if (createError.message.includes("already") || createError.message.includes("exists")) {
        const { data: users } = await supabaseAdmin.auth.admin.listUsers();
        const existingUser = users?.users?.find((u: any) => u.email === testEmail);
        if (existingUser) {
          await supabaseAdmin.auth.admin.updateUserById(existingUser.id, {
            password: testPassword,
          });
          res.json({
            message: "Test account password reset",
            email: testEmail,
            password: testPassword,
          });
          return;
        }
      }
      res.status(400).json({ error: createError.message });
      return;
    }

    const userId = userData.user.id;

    // Create profile
    await supabaseAdmin.from("profiles").upsert({
      id: userId,
      email: testEmail,
      full_name: testName,
      language: "en",
    }, { onConflict: "id" });

    // Create a sample child
    const { data: child } = await supabaseAdmin
      .from("children")
      .insert({
        parent_id: userId,
        name: "Emma",
        grade: "3rd",
        school: "Lincoln Elementary",
        avatar_color: "#6366F1",
        avatar_emoji: "🎒",
      })
      .select()
      .single();

    // Create sample subjects for the child
    if (child) {
      await supabaseAdmin.from("subjects").insert([
        { child_id: child.id, name: "Math", color: "#3B82F6", icon: "📐" },
        { child_id: child.id, name: "Science", color: "#10B981", icon: "🔬" },
        { child_id: child.id, name: "English", color: "#F59E0B", icon: "📖" },
      ]);
    }

    res.status(201).json({
      message: "Test account created successfully",
      email: testEmail,
      password: testPassword,
    });
  } catch (err) {
    console.error("Seed test account error:", err);
    res.status(500).json({ error: "Failed to create test account" });
  }
});

export default router;
