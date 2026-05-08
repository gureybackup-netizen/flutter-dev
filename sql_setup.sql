-- Run this in Supabase SQL Editor to create remaining tables

-- 1. Create USERNAMES table
CREATE TABLE IF NOT EXISTS public.usernames (
  username TEXT PRIMARY KEY,
  uid UUID REFERENCES public.users(id) ON DELETE CASCADE
);

-- 2. Create CONVERSATIONS table
CREATE TABLE IF NOT EXISTS public.conversations (
  id TEXT PRIMARY KEY,
  participant_uids UUID[] NOT NULL,
  participant_usernames JSONB DEFAULT '{}',
  participant_display_names JSONB DEFAULT '{}',
  last_message_at TIMESTAMPTZ,
  unread_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create MESSAGES table
CREATE TABLE IF NOT EXISTS public.messages (
  id TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  sender_uid UUID NOT NULL,
  encrypted_content TEXT NOT NULL,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  is_read BOOLEAN DEFAULT false,
  is_deleted_by_sender BOOLEAN DEFAULT false,
  delivered_at TIMESTAMPTZ
);

-- 4. Create CALLS table
CREATE TABLE IF NOT EXISTS public.calls (
  id TEXT PRIMARY KEY,
  caller_id UUID NOT NULL,
  caller_username TEXT,
  callee_uid UUID NOT NULL,
  status TEXT DEFAULT 'ringing',
  type TEXT DEFAULT 'voice',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  duration_seconds INTEGER
);

-- Enable RLS on all tables
ALTER TABLE public.usernames ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calls ENABLE ROW LEVEL SECURITY;

-- Create policies allowing all operations (for development/testing)
DROP POLICY IF EXISTS "Allow all usernames" ON public.usernames;
CREATE POLICY "Allow all usernames" ON public.usernames FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all conversations" ON public.conversations;
CREATE POLICY "Allow all conversations" ON public.conversations FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all messages" ON public.messages;
CREATE POLICY "Allow all messages" ON public.messages FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all calls" ON public.calls;
CREATE POLICY "Allow all calls" ON public.calls FOR ALL USING (true) WITH CHECK (true);