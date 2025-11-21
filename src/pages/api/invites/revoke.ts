import type { APIRoute } from 'astro';
import { createSupabaseWithJWT } from '../../../lib/auth';

export const POST: APIRoute = async ({ request }) => {
  const authHeader = request.headers.get('Authorization');

  // Extract token from Authorization header
  const token = authHeader?.replace('Bearer ', '');

  if (!token) {
    console.error('[API] No token found in Authorization header');
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
    });
  }

  // Create a Supabase client with the JWT token for authentication and RLS context
  const supabase = createSupabaseWithJWT(token);

  // Validate the token and get current user
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser(token);

  if (userError) {
    console.error('[API] Auth error:', userError.message);
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
    });
  }

  if (!user) {
    console.error('[API] No user found after authentication');
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
    });
  }

  try {
    const body = await request.json();
    const { inviteId } = body;

    if (!inviteId) {
      return new Response(JSON.stringify({ error: 'Invite ID is required' }), {
        status: 400,
      });
    }

    // Update the invite to set revoked_at
    // RLS policy "Users can update invites" ensures they can only update their own
    const { data, error } = await supabase
      .from('invite')
      .update({ revoked_at: new Date().toISOString() })
      .eq('id', inviteId)
      .eq('inviter_id', user.id) // Double check ownership though RLS covers it
      .select()
      .single();

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
      });
    }

    return new Response(JSON.stringify(data), {
      status: 200,
    });
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid request' }), {
      status: 400,
    });
  }
};
