import Anthropic from "@anthropic-ai/sdk";

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

export interface ChatCompletionMessage {
  role: "system" | "user" | "assistant";
  content: string;
}

export async function* streamChatCompletion(
  messages: ChatCompletionMessage[]
): AsyncGenerator<string> {
  const systemMessage = messages.find((m) => m.role === "system");
  const conversationMessages = messages
    .filter((m) => m.role !== "system")
    .map((m) => ({
      role: m.role as "user" | "assistant",
      content: m.content,
    }));

  const stream = anthropic.messages.stream({
    model: "claude-sonnet-4-20250514",
    max_tokens: 800,
    system: systemMessage?.content || "",
    messages: conversationMessages,
  });

  for await (const event of stream) {
    if (
      event.type === "content_block_delta" &&
      event.delta.type === "text_delta"
    ) {
      yield event.delta.text;
    }
  }
}

export function buildSystemPrompt(
  child: {
    name: string;
    grade: string;
    school?: string;
    ai_context?: string;
    subjects: { name: string }[];
  },
  language: "en" | "es"
): string {
  if (language === "es") {
    return `Eres un asistente educativo para padres. Conoces muy bien a este estudiante:
Nombre: ${child.name}, Grado: ${child.grade}, Escuela: ${child.school || "No especificada"}
Contexto académico: ${child.ai_context || "No disponible aún"}
Materias actuales: ${child.subjects.map((s) => s.name).join(", ")}

Ayuda al padre/madre con preguntas sobre el desempeño escolar, tareas, técnicas de estudio y estrategias de aprendizaje.
Sé empático, práctico y conciso. Responde siempre en español.`;
  }

  return `You are an educational assistant for parents. You know this student well:
Name: ${child.name}, Grade: ${child.grade}, School: ${child.school || "Not specified"}
Academic context: ${child.ai_context || "Not available yet"}
Current subjects: ${child.subjects.map((s) => s.name).join(", ")}

Help the parent with questions about school performance, homework, study techniques and learning strategies.
Be empathetic, practical and concise.`;
}
