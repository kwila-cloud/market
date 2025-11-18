import { createClient } from '@supabase/supabase-js';

// These are available at runtime because of PUBLIC_ prefix
const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

console.log('supabase URL:', supabaseUrl);
export const supabase = createClient(supabaseUrl, supabaseAnonKey);
