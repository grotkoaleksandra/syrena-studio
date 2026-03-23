-- Core tables for Syrena Studio (studiomiguel)
-- Creates: app_users, people, property_config, brand_config, media,
--          email_templates, inbound_emails, page_display_config, thoughts
-- Enables RLS on all tables, creates storage buckets for photos and documents

-- ============================================================
-- Extensions
-- ============================================================
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================================
-- 1. app_users — user accounts linked to Supabase Auth
-- ============================================================
CREATE TABLE IF NOT EXISTS app_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
  email TEXT NOT NULL,
  display_name TEXT,
  role TEXT NOT NULL DEFAULT 'resident' CHECK (role IN ('oracle','admin','staff','resident','associate','demo')),
  avatar_url TEXT,
  person_id UUID,
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read app_users" ON app_users
  FOR SELECT USING (true);
CREATE POLICY "Authenticated insert app_users" ON app_users
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update app_users" ON app_users
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- ============================================================
-- 2. people — contacts, tenants, associates
-- ============================================================
CREATE TABLE IF NOT EXISTS people (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  phone TEXT,
  type TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE people ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read people" ON people
  FOR SELECT USING (true);
CREATE POLICY "Authenticated insert people" ON people
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update people" ON people
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated delete people" ON people
  FOR DELETE TO authenticated USING (true);

-- Link app_users.person_id → people.id
ALTER TABLE app_users
  ADD CONSTRAINT app_users_person_id_fkey FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE SET NULL;

-- ============================================================
-- 3. property_config — singleton JSONB configuration
-- ============================================================
CREATE TABLE IF NOT EXISTS property_config (
  id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  config JSONB DEFAULT '{}'
);

ALTER TABLE property_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read property_config" ON property_config
  FOR SELECT USING (true);
CREATE POLICY "Authenticated update property_config" ON property_config
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated insert property_config" ON property_config
  FOR INSERT TO authenticated WITH CHECK (true);

INSERT INTO property_config (id, config) VALUES (1, '{}') ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 4. brand_config — singleton JSONB brand styling
-- ============================================================
CREATE TABLE IF NOT EXISTS brand_config (
  id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  config JSONB DEFAULT '{}'
);

ALTER TABLE brand_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read brand_config" ON brand_config
  FOR SELECT USING (true);
CREATE POLICY "Authenticated update brand_config" ON brand_config
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated insert brand_config" ON brand_config
  FOR INSERT TO authenticated WITH CHECK (true);

INSERT INTO brand_config (id, config) VALUES (1, '{}') ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 5. media — all uploaded files
-- ============================================================
CREATE TABLE IF NOT EXISTS media (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  url TEXT NOT NULL,
  filename TEXT,
  mime_type TEXT,
  width INTEGER,
  height INTEGER,
  caption TEXT,
  category TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE media ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read media" ON media
  FOR SELECT USING (true);
CREATE POLICY "Authenticated insert media" ON media
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update media" ON media
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated delete media" ON media
  FOR DELETE TO authenticated USING (true);

-- ============================================================
-- 6. email_templates
-- ============================================================
CREATE TABLE IF NOT EXISTS email_templates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  subject TEXT NOT NULL,
  body TEXT NOT NULL,
  category TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read email_templates" ON email_templates
  FOR SELECT USING (true);
CREATE POLICY "Authenticated insert email_templates" ON email_templates
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update email_templates" ON email_templates
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated delete email_templates" ON email_templates
  FOR DELETE TO authenticated USING (true);

-- ============================================================
-- 7. inbound_emails
-- ============================================================
CREATE TABLE IF NOT EXISTS inbound_emails (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  from_email TEXT,
  to_email TEXT,
  subject TEXT,
  body_text TEXT,
  body_html TEXT,
  received_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE inbound_emails ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read inbound_emails" ON inbound_emails
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service insert inbound_emails" ON inbound_emails
  FOR INSERT WITH CHECK (true);

-- ============================================================
-- 8. page_display_config
-- ============================================================
CREATE TABLE IF NOT EXISTS page_display_config (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  section TEXT NOT NULL,
  tab_key TEXT NOT NULL,
  tab_label TEXT NOT NULL,
  is_visible BOOLEAN NOT NULL DEFAULT false,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(section, tab_key)
);

ALTER TABLE page_display_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read page_display_config" ON page_display_config
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated update page_display_config" ON page_display_config
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated insert page_display_config" ON page_display_config
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE OR REPLACE FUNCTION update_page_display_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'update_page_display_config_updated_at'
  ) THEN
    CREATE TRIGGER update_page_display_config_updated_at
      BEFORE UPDATE ON page_display_config
      FOR EACH ROW
      EXECUTE FUNCTION update_page_display_updated_at();
  END IF;
END;
$$;

INSERT INTO page_display_config (section, tab_key, tab_label, is_visible, sort_order) VALUES
  ('admin', 'users', 'Users', true, 1),
  ('admin', 'passwords', 'Passwords', false, 2),
  ('admin', 'settings', 'Settings', false, 3),
  ('admin', 'releases', 'Releases', true, 4),
  ('admin', 'templates', 'Templates', false, 5),
  ('admin', 'brand', 'Brand', true, 6),
  ('admin', 'accounting', 'Accounting', false, 7),
  ('admin', 'life-of-pai', 'Life of PAI', false, 8),
  ('devices', 'inventory', 'Inventory', true, 1),
  ('devices', 'assignments', 'Assignments', true, 2),
  ('devices', 'maintenance', 'Maintenance', false, 3),
  ('devices', 'procurement', 'Procurement', false, 4),
  ('residents', 'directory', 'Directory', true, 1),
  ('residents', 'rooms', 'Rooms', true, 2),
  ('residents', 'check-in-out', 'Check In/Out', false, 3),
  ('residents', 'requests', 'Requests', false, 4),
  ('associates', 'directory', 'Directory', true, 1),
  ('associates', 'organizations', 'Organizations', true, 2),
  ('associates', 'donations', 'Donations', false, 3),
  ('associates', 'communications', 'Communications', false, 4),
  ('staff', 'directory', 'Directory', true, 1),
  ('staff', 'schedules', 'Schedules', true, 2),
  ('staff', 'roles', 'Roles', false, 3),
  ('staff', 'attendance', 'Attendance', false, 4)
ON CONFLICT (section, tab_key) DO NOTHING;

-- ============================================================
-- 9. thoughts — semantic AI memory (Open Brain)
-- ============================================================
CREATE TABLE IF NOT EXISTS thoughts (
  id BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
  content TEXT NOT NULL,
  embedding vector(768),
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS thoughts_embedding_idx ON thoughts
  USING hnsw (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS thoughts_created_at_idx ON thoughts (created_at DESC);

CREATE OR REPLACE FUNCTION match_thoughts(
  query_embedding vector(768),
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 10
) RETURNS TABLE (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
) LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.id,
    t.content,
    t.metadata,
    1 - (t.embedding <=> query_embedding) AS similarity
  FROM thoughts t
  WHERE 1 - (t.embedding <=> query_embedding) > match_threshold
  ORDER BY t.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

ALTER TABLE thoughts ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'thoughts' AND policyname = 'Service role only'
  ) THEN
    CREATE POLICY "Service role only" ON thoughts
      FOR ALL USING (auth.role() = 'service_role');
  END IF;
END;
$$;

-- ============================================================
-- 10. Storage buckets — photos and documents
-- ============================================================
INSERT INTO storage.buckets (id, name, public) VALUES ('photos', 'photos', true)
  ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', false)
  ON CONFLICT (id) DO NOTHING;

-- Photos bucket: public read, authenticated upload
CREATE POLICY "Public read photos" ON storage.objects
  FOR SELECT USING (bucket_id = 'photos');
CREATE POLICY "Authenticated upload photos" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'photos');
CREATE POLICY "Authenticated update photos" ON storage.objects
  FOR UPDATE TO authenticated USING (bucket_id = 'photos');
CREATE POLICY "Authenticated delete photos" ON storage.objects
  FOR DELETE TO authenticated USING (bucket_id = 'photos');

-- Documents bucket: authenticated only
CREATE POLICY "Authenticated read documents" ON storage.objects
  FOR SELECT TO authenticated USING (bucket_id = 'documents');
CREATE POLICY "Authenticated upload documents" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'documents');
CREATE POLICY "Authenticated update documents" ON storage.objects
  FOR UPDATE TO authenticated USING (bucket_id = 'documents');
CREATE POLICY "Authenticated delete documents" ON storage.objects
  FOR DELETE TO authenticated USING (bucket_id = 'documents');
