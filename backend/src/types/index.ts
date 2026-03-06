export interface UserProfile {
  id: string;
  email?: string;
  full_name: string;
  avatar_url?: string;
  language: "en" | "es";
  created_at: string;
  updated_at: string;
}

export interface Child {
  id: string;
  parent_id: string;
  name: string;
  grade: string;
  school?: string;
  avatar_color: string;
  avatar_emoji: string;
  ai_context?: string;
  created_at: string;
  updated_at: string;
}

export interface ChildProfile extends Child {
  subjects: Subject[];
  recentHomework: Homework[];
}

export interface Subject {
  id: string;
  child_id: string;
  name: string;
  teacher_name?: string;
  color: string;
  icon: string;
  notes?: string;
  created_at: string;
}

export interface Homework {
  id: string;
  child_id: string;
  subject_id?: string;
  title: string;
  description?: string;
  due_date: string;
  status: "pending" | "in_progress" | "completed" | "overdue";
  priority: "low" | "medium" | "high";
  attachment_url?: string;
  ai_summary?: string;
  created_at: string;
  updated_at: string;
}

export interface FlashcardDeck {
  id: string;
  child_id: string;
  subject_id?: string;
  title: string;
  description?: string;
  total_cards: number;
  mastered_cards: number;
  created_at: string;
}

export interface Flashcard {
  id: string;
  deck_id: string;
  front: string;
  back: string;
  hint?: string;
  difficulty: "easy" | "medium" | "hard";
  last_reviewed?: string;
  mastered: boolean;
  review_count: number;
  created_at: string;
}

export interface FlashcardData {
  front: string;
  back: string;
  hint?: string;
  difficulty: "easy" | "medium" | "hard";
}

export interface ChatMessage {
  id: string;
  child_id: string;
  parent_id: string;
  role: "user" | "assistant";
  content: string;
  created_at: string;
}

export interface DeviceToken {
  id: string;
  user_id: string;
  token: string;
  platform: string;
  created_at: string;
}

export interface AuthenticatedRequest extends Express.Request {
  user: {
    id: string;
    email: string;
  };
}
