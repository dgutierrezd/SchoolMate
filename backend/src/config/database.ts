import { supabaseAdmin } from "./supabase";

export async function checkDatabaseConnection(): Promise<boolean> {
  try {
    const { error } = await supabaseAdmin.from("profiles").select("id").limit(1);
    if (error) {
      console.error("Database connection check failed:", error.message);
      return false;
    }
    console.log("Database connection established successfully");
    return true;
  } catch (err) {
    console.error("Database connection error:", err);
    return false;
  }
}

export { supabaseAdmin };
