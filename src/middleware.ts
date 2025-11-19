import { defineMiddleware } from 'astro:middleware';
import { getUser, publicRoutes, authRoutes } from './lib/auth';

export const onRequest = defineMiddleware(async (context, next) => {
  const { pathname } = context.url;

  // Check route type
  const isPublicRoute = publicRoutes.some(
    (route) => pathname === route || pathname.startsWith(`${route}/`)
  );
  const isAuthRoute = authRoutes.some(
    (route) => pathname === route || pathname.startsWith(`${route}/`)
  );

  // Skip static assets and API routes
  if (pathname.startsWith('/_') || pathname.includes('.')) {
    return next();
  }

  // Get user for all non-public routes or auth routes
  if (!isPublicRoute || isAuthRoute) {
    const cookieHeader = context.request.headers.get('cookie');
    const user = await getUser(context.cookies, cookieHeader);

    // Store user in locals for access in pages
    context.locals.user = user;

    // Redirect to login if accessing protected route without auth
    if (!isPublicRoute && !user) {
      return context.redirect('/auth/login');
    }

    // Redirect to dashboard if accessing auth routes while authenticated
    if (isAuthRoute && user) {
      return context.redirect('/dashboard');
    }
  }

  return next();
});
