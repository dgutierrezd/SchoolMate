import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { authMiddleware, AuthRequest } from "../middleware/auth.middleware";
import { generateFlashcards } from "../services/claude.service";

const router = Router();
router.use(authMiddleware);

// GET /flashcards/decks?childId=
router.get("/decks", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { childId } = req.query;

  if (!childId) {
    res.status(400).json({ error: "childId is required" });
    return;
  }

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

    const { data, error } = await supabaseAdmin
      .from("flashcard_decks")
      .select("*, subjects(name, color, icon)")
      .eq("child_id", childId)
      .order("created_at", { ascending: false });

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /flashcards/generate — AI-generate flashcards
router.post("/generate", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { child_id, subject_id, topic, count } = req.body;

  if (!child_id || !topic) {
    res.status(400).json({ error: "child_id and topic are required" });
    return;
  }

  try {
    // Verify ownership and get child info
    const { data: child } = await supabaseAdmin
      .from("children")
      .select("id, grade, parent_id")
      .eq("id", child_id)
      .eq("parent_id", authReq.user.id)
      .single();

    if (!child) {
      res.status(404).json({ error: "Child not found" });
      return;
    }

    // Get subject name if provided
    let subjectName = "General";
    if (subject_id) {
      const { data: subject } = await supabaseAdmin
        .from("subjects")
        .select("name")
        .eq("id", subject_id)
        .single();
      if (subject) subjectName = subject.name;
    }

    // Get parent's language preference
    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("language")
      .eq("id", authReq.user.id)
      .single();

    const language = (profile?.language as "en" | "es") || "en";

    // Generate flashcards via Claude
    const cards = await generateFlashcards(
      subjectName,
      topic,
      child.grade,
      count || 10,
      language
    );

    // Create deck
    const { data: deck, error: deckError } = await supabaseAdmin
      .from("flashcard_decks")
      .insert({
        child_id,
        subject_id,
        title: topic,
        description: `AI-generated flashcards about ${topic}`,
        total_cards: cards.length,
      })
      .select()
      .single();

    if (deckError) {
      res.status(400).json({ error: deckError.message });
      return;
    }

    // Insert cards
    const cardInserts = cards.map((card) => ({
      deck_id: deck.id,
      front: card.front,
      back: card.back,
      hint: card.hint,
      difficulty: card.difficulty,
    }));

    const { data: insertedCards, error: cardsError } = await supabaseAdmin
      .from("flashcards")
      .insert(cardInserts)
      .select();

    if (cardsError) {
      res.status(400).json({ error: cardsError.message });
      return;
    }

    res.status(201).json({ deck, cards: insertedCards });
  } catch (err) {
    console.error("Flashcard generation error:", err);
    res.status(500).json({ error: "Failed to generate flashcards" });
  }
});

// POST /flashcards/decks — Create manual deck
router.post("/decks", async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const { child_id, subject_id, title, description } = req.body;

  if (!child_id || !title) {
    res.status(400).json({ error: "child_id and title are required" });
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
      .from("flashcard_decks")
      .insert({ child_id, subject_id, title, description })
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

// POST /flashcards/decks/:id/cards — Add card to deck
router.post("/decks/:id/cards", async (req: Request, res: Response) => {
  const { id } = req.params;
  const { front, back, hint, difficulty } = req.body;

  if (!front || !back) {
    res.status(400).json({ error: "front and back are required" });
    return;
  }

  try {
    const { data, error } = await supabaseAdmin
      .from("flashcards")
      .insert({
        deck_id: id,
        front,
        back,
        hint,
        difficulty: difficulty || "medium",
      })
      .select()
      .single();

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    // Update total_cards count
    await supabaseAdmin.rpc("increment_deck_cards", { deck_id: id });

    res.status(201).json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /flashcards/decks/:id/cards — Get cards in a deck
router.get("/decks/:id/cards", async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    const { data, error } = await supabaseAdmin
      .from("flashcards")
      .select("*")
      .eq("deck_id", id)
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

// PATCH /flashcards/:id/master — Mark card as mastered
router.patch("/:id/master", async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    // First get current review_count
    const { data: current } = await supabaseAdmin
      .from("flashcards")
      .select("review_count")
      .eq("id", id)
      .single();

    const { data, error } = await supabaseAdmin
      .from("flashcards")
      .update({
        mastered: true,
        last_reviewed: new Date().toISOString(),
        review_count: (current?.review_count || 0) + 1,
      })
      .eq("id", id)
      .select()
      .single();

    if (error) {
      res.status(400).json({ error: error.message });
      return;
    }

    // Update mastered_cards count on deck
    if (data) {
      const { data: counts } = await supabaseAdmin
        .from("flashcards")
        .select("id", { count: "exact" })
        .eq("deck_id", data.deck_id)
        .eq("mastered", true);

      await supabaseAdmin
        .from("flashcard_decks")
        .update({ mastered_cards: counts?.length || 0 })
        .eq("id", data.deck_id);
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
