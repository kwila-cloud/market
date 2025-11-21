import { defineMiddleware } from 'astro:middleware';
import {
  getUser,
  publicRoutes,
  authRoutes,
  createSupabaseServerClient,
} from './lib/auth';

export const onRequest = defineMiddleware(async (context, next) => {
  const { pathname } = context.url;

  // Skip static assets and API routes
  if (pathname.startsWith('/_') || pathname.includes('.')) {
    return next();
  }

  // Check route type
  const isPublicRoute = publicRoutes.some(
    (route) => pathname === route || pathname.startsWith(`${route}/`)
  );
  const isAuthRoute = authRoutes.some(
    (route) => pathname === route || pathname.startsWith(`${route}/`)
  );

  // Always get user for navbar state
  const cookieHeader = context.request.headers.get('cookie');
  const user = await getUser(context.cookies, cookieHeader);

  // Store user in locals for access in pages
  context.locals.user = user;

  // Check if authenticated user has completed signup (has public user record)
  if (user && pathname !== '/auth/welcome') {
    const supabase = createSupabaseServerClient(context.cookies, cookieHeader);

    // Call the get_user_by_auth_id RPC to check if user profile exists
    const { data: userId, error } = await supabase.rpc('get_user_by_auth_id', {
      p_auth_user_id: user.id,
    });

    if (error) {
      console.error('Error checking user profile:', error);
    }

    // If no user profile exists, redirect to welcome/onboarding page
    if (!userId) {
      return context.redirect('/auth/welcome');
    }
  }

  // Redirect to login if accessing protected route without auth
  if (!isPublicRoute && !user) {
    return context.redirect('/auth/login');
  }

  // Redirect to dashboard if accessing auth routes while authenticated
  if (isAuthRoute && user) {
    return context.redirect('/dashboard');
  }

  // Redirect to dashboard if accessing home page while authenticated
  if (pathname === '/' && user) {
    return context.redirect('/dashboard');
  }

  return next();
});
