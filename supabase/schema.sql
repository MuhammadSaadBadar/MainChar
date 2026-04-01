-- Profile table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  campus_email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Votes table
CREATE TABLE votes (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  voter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  is_recognized BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT unique_vote UNIQUE (voter_id, target_id)
);

-- Analytics & Rankings
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Policies for users table
CREATE POLICY "Public profiles are viewable by everyone" ON users
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Policies for votes table
-- Users can only insert their own votes
CREATE POLICY "Users can cast votes" ON votes
  FOR INSERT WITH CHECK (auth.uid() = voter_id);

-- Only target can read their counts (restricted)
-- Note: During "Reveal Hour", we'll likely use a more specific logic/view.
CREATE POLICY "View own vote count summary" ON votes
  FOR SELECT USING (auth.uid() = target_id);

-- Simple RPC for getting rank during Reveal Hour
-- This is a placeholder for logic
CREATE OR REPLACE FUNCTION get_current_rankings()
RETURNS TABLE (username TEXT, recognize_count BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT u.username, COUNT(v.id) as recognize_count
  FROM users u
  JOIN votes v ON u.id = v.target_id
  WHERE v.is_recognized = TRUE
  GROUP BY u.username
  ORDER BY recognize_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
