import Anthropic from "@anthropic-ai/sdk";
import { FlashcardData, ChildProfile } from "../types";

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

export async function generateFlashcards(
  subject: string,
  topic: string,
  childGrade: string,
  count: number = 10,
  language: "en" | "es" = "en"
): Promise<FlashcardData[]> {
  const prompt =
    language === "es"
      ? `Genera ${count} tarjetas de estudio (flashcards) para un estudiante de ${childGrade} sobre el tema "${topic}" en la materia de "${subject}".
         Responde SOLO con un JSON válido con este formato:
         [{"front": "pregunta", "back": "respuesta", "hint": "pista opcional", "difficulty": "easy|medium|hard"}]`
      : `Generate ${count} study flashcards for a ${childGrade} grade student about "${topic}" in "${subject}".
         Respond ONLY with valid JSON in this format:
         [{"front": "question", "back": "answer", "hint": "optional hint", "difficulty": "easy|medium|hard"}]`;

  const message = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 2048,
    messages: [{ role: "user", content: prompt }],
  });

  const text =
    message.content[0].type === "text" ? message.content[0].text : "";

  // Extract JSON from response (handle potential markdown code blocks)
  const jsonMatch = text.match(/\[[\s\S]*\]/);
  if (!jsonMatch) {
    throw new Error("Failed to parse flashcard response");
  }
  return JSON.parse(jsonMatch[0]);
}

export async function buildChildAIContext(
  child: ChildProfile
): Promise<string> {
  const prompt = `Create a concise academic profile summary for an AI assistant to better help parents support this child:
    Name: ${child.name}
    Grade: ${child.grade}
    School: ${child.school || "Not specified"}
    Subjects: ${child.subjects.map((s) => s.name).join(", ")}
    Recent homework topics: ${child.recentHomework.map((h) => h.title).join(", ")}

    Create a 2-3 sentence context that helps an AI understand this child's academic situation.`;

  const message = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 300,
    messages: [{ role: "user", content: prompt }],
  });

  return message.content[0].type === "text" ? message.content[0].text : "";
}

export async function summarizeHomework(
  title: string,
  description: string,
  language: "en" | "es" = "en"
): Promise<string> {
  const prompt =
    language === "es"
      ? `Resume esta tarea escolar en 1-2 oraciones concisas:
         Título: ${title}
         Descripción: ${description}`
      : `Summarize this homework assignment in 1-2 concise sentences:
         Title: ${title}
         Description: ${description}`;

  const message = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 150,
    messages: [{ role: "user", content: prompt }],
  });

  return message.content[0].type === "text" ? message.content[0].text : "";
}
