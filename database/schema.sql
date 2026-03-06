-- SchoolMate AI Database Schema
-- PostgreSQL via Supabase

-- Users (managed by Supabase Auth, extended with profiles)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  language TEXT DEFAULT 'en' CHECK (language IN ('en', 'es')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Children profiles
CREATE TABLE children (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  parent_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  grade TEXT NOT NULL,
  school TEXT,
  avatar_color TEXT DEFAULT '#6366F1',
  avatar_emoji TEXT DEFAULT '🎒',
  ai_context TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subjects per child
CREATE TABLE subjects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  child_id UUID REFERENCES children(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  teacher_name TEXT,
  color TEXT DEFAULT '#6366F1',
  icon TEXT DEFAULT '📚',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Homework assignments
CREATE TABLE homework (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  child_id UUID REFERENCES children(id) ON DELETE CASCADE,
  subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'overdue')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  attachment_url TEXT,
  ai_summary TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Flashcard decks
CREATE TABLE flashcard_decks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  child_id UUID REFERENCES children(id) ON DELETE CASCADE,
  subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  total_cards INT DEFAULT 0,
  mastered_cards INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Individual flashcards
CREATE TABLE flashcards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  deck_id UUID REFERENCES flashcard_decks(id) ON DELETE CASCADE,
  front TEXT NOT NULL,
  back TEXT NOT NULL,
  hint TEXT,
  difficulty TEXT DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
  last_reviewed TIMESTAMPTZ,
  mastered BOOLEAN DEFAULT FALSE,
  review_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Chat history per child
CREATE TABLE chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  child_id UUID REFERENCES children(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Push notification tokens
CREATE TABLE device_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform TEXT DEFAULT 'ios',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- Row Level Security
-- =============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE homework ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcard_decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Profiles: users can only access their own profile
CREATE POLICY "Users own data" ON profiles
  FOR ALL USING (auth.uid() = id);

-- Children: parents can only access their own children
CREATE POLICY "Parents own children" ON children
  FOR ALL USING (auth.uid() = parent_id);

-- Subjects: parents can access subjects of their children
CREATE POLICY "Parents own subjects" ON subjects
  FOR ALL USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
  );

-- Homework: parents can access homework of their children
CREATE POLICY "Parents own homework" ON homework
  FOR ALL USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
  );

-- Flashcard decks: parents can access decks of their children
CREATE POLICY "Parents own flashcard decks" ON flashcard_decks
  FOR ALL USING (
    child_id IN (SELECT id FROM children WHERE parent_id = auth.uid())
  );

-- Flashcards: parents can access cards in decks of their children
CREATE POLICY "Parents own flashcards" ON flashcards
  FOR ALL USING (
    deck_id IN (
      SELECT fd.id FROM flashcard_decks fd
      JOIN children c ON fd.child_id = c.id
      WHERE c.parent_id = auth.uid()
    )
  );

-- Chat messages: parents can access their own chat messages
CREATE POLICY "Parents own chat messages" ON chat_messages
  FOR ALL USING (parent_id = auth.uid());

-- Device tokens: users can manage their own tokens
CREATE POLICY "Users own device tokens" ON device_tokens
  FOR ALL USING (user_id = auth.uid());

-- =============================================
-- Indexes for performance
-- =============================================

CREATE INDEX idx_children_parent_id ON children(parent_id);
CREATE INDEX idx_subjects_child_id ON subjects(child_id);
CREATE INDEX idx_homework_child_id ON homework(child_id);
CREATE INDEX idx_homework_due_date ON homework(due_date);
CREATE INDEX idx_homework_status ON homework(status);
CREATE INDEX idx_flashcard_decks_child_id ON flashcard_decks(child_id);
CREATE INDEX idx_flashcards_deck_id ON flashcards(deck_id);
CREATE INDEX idx_chat_messages_child_id ON chat_messages(child_id);
CREATE INDEX idx_chat_messages_parent_id ON chat_messages(parent_id);
CREATE INDEX idx_device_tokens_user_id ON device_tokens(user_id);

-- =============================================
-- Helper function for incrementing deck card count
-- =============================================

CREATE OR REPLACE FUNCTION increment_deck_cards(deck_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE flashcard_decks
  SET total_cards = total_cards + 1
  WHERE id = deck_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
