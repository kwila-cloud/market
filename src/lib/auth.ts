import {
  createServerClient,
  createBrowserClient,
  parseCookieHeader,
} from '@supabase/ssr';
import type { AstroCookies } from 'astro';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

/**
 * Create a Supabase client for server-side operations (SSR).
 * Handles cookie management for session persistence.
 */
export function createSupabaseServerClient(
  cookies: AstroCookies,
  cookieHeader?: string | null
) {
  return createServerClient(supabaseUrl, supabaseAnonKey, {
    cookies: {
      getAll() {
        const parsed = parseCookieHeader(cookieHeader ?? '');
        // Filter out cookies without values and ensure type safety
        return parsed
          .filter(
            (cookie): cookie is { name: string; value: string } =>
              cookie.value !== undefined
          )
          .map((cookie) => ({ name: cookie.name, value: cookie.value }));
      },
      setAll(cookiesToSet) {
        for (const { name, value, options } of cookiesToSet) {
          cookies.set(name, value, {
            path: '/',
            secure: import.meta.env.PROD,
            httpOnly: true,
            sameSite: 'lax',
            ...options,
          });
        }
      },
    },
  });
}

/**
 * Create a Supabase client for client-side operations (browser).
 * Uses browser cookies for session management.
 */
export function createSupabaseBrowserClient() {
  return createBrowserClient(supabaseUrl, supabaseAnonKey);
}

/**
 * Get the current session from a server-side Supabase client.
 */
export async function getSession(
  cookies: AstroCookies,
  cookieHeader?: string | null
) {
  const supabase = createSupabaseServerClient(cookies, cookieHeader);
  const {
    data: { session },
    error,
  } = await supabase.auth.getSession();

  if (error) {
    console.error('Error getting session:', error.message);
    return null;
  }

  return session;
}

/**
 * Get the current user from a server-side Supabase client.
 * Uses getUser() for secure server-side validation.
 */
export async function getUser(
  cookies: AstroCookies,
  cookieHeader?: string | null
) {
  const supabase = createSupabaseServerClient(cookies, cookieHeader);
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error) {
    console.error('Error getting user:', error.message);
    return null;
  }

  return user;
}

/**
 * Public routes that don't require authentication.
 * All other routes are protected by default.
 */
export const publicRoutes = [
  '/',
  '/about',
  '/content-policy',
  '/auth/login',
  '/auth/verify',
];

/**
 * Auth routes that should redirect to dashboard if already authenticated.
 */
export const authRoutes = ['/auth/login', '/auth/verify'];
