import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = "https://nurkwzfiflrupqobgzvt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51cmt3emZpZmxydXBxb2JnenZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwMTMzOTIsImV4cCI6MjA4OTU4OTM5Mn0.5Z_qyv5BhLPVXdPp-cD7Oy-VYzAKKYjKN4dpYGqVpcE";

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
