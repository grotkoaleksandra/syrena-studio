import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = "https://cpyfckwfwbqyvwblaftv.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNweWZja3dmd2JxeXZ3YmxhZnR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNjk0MTUsImV4cCI6MjA4OTg0NTQxNX0.UOu_axTNMDCXCwZaMf9FY81WwcPyp_Ac_E1nMxKWGVE";

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
