import "dotenv/config";
import express from "express";
import cors from "cors";
import { generalLimiter } from "./middleware/rateLimiter";
import { checkDatabaseConnection } from "./config/database";

// Import routes
import authRoutes from "./routes/auth";
import childrenRoutes from "./routes/children";
import homeworkRoutes from "./routes/homework";
import subjectsRoutes from "./routes/subjects";
import flashcardsRoutes from "./routes/flashcards";
import aiChatRoutes from "./routes/ai-chat";
import notificationsRoutes from "./routes/notifications";
import profileRoutes from "./routes/profile";
import legalRoutes from "./routes/legal";

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(",") || "*",
    credentials: true,
  })
);
app.use(express.json({ limit: "10mb" }));
app.use(generalLimiter);

// Health check
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Routes
app.use("/auth", authRoutes);
app.use("/children", childrenRoutes);
app.use("/homework", homeworkRoutes);
app.use("/subjects", subjectsRoutes);
app.use("/flashcards", flashcardsRoutes);
app.use("/ai", aiChatRoutes);
app.use("/notifications", notificationsRoutes);
app.use("/profile", profileRoutes);
app.use("/legal", legalRoutes);

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ error: "Not found" });
});

// Error handler
app.use(
  (
    err: Error,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction
  ) => {
    console.error("Unhandled error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
);

// Start server
async function start() {
  await checkDatabaseConnection();

  app.listen(Number(PORT), "0.0.0.0", () => {
    console.log(`SchoolMate AI backend running on 0.0.0.0:${PORT}`);
  });
}

start();
