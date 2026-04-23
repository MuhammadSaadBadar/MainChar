-- Profile table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  campus_email TEXT UNIQUE NOT NULL,
  last_announcement_check TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
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

-- Event Requests table
CREATE TABLE event_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  banner_url TEXT,
  event_date TEXT,
  location TEXT,
  event_time TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  rules TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE event_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view approved events" ON event_requests
  FOR SELECT USING (status = 'approved');

CREATE POLICY "Admin can view all events" ON event_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND campus_email = 'sp24-bse-082@cuilahore.edu.pk'
    )
  );

CREATE POLICY "Admin can update events" ON event_requests
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND campus_email = 'sp24-bse-082@cuilahore.edu.pk'
    )
  );

CREATE POLICY "Users can create events" ON event_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);
