import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY!;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!;

// Service client — bypasses RLS, used for server-side operations
export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

// Anon client — respects RLS, used when acting on behalf of a user
export function createUserClient(accessToken: string) {
  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  });
}

export { supabaseUrl, supabaseAnonKey };
