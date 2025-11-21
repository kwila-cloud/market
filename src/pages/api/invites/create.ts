import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../lib/auth';

export const POST: APIRoute = async ({ cookies, request }) => {
  const authHeader = request.headers.get('Authorization');
  const supabase = createSupabaseServerClient(cookies, undefined, authHeader);

  // Get current user
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
    });
  }

  try {
    const body = await request.json();
    const { name } = body;

    // Validate required fields
    if (!name) {
      return new Response(
        JSON.stringify({
          error: 'Invite name is required',
        }),
        {
          status: 400,
        }
      );
    }

    // Check for invites created in the last 24 hours
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

    const { data: recentInvites, error: queryError } = await supabase
      .from('invite')
      .select('created_at')
      .eq('inviter_id', user.id)
      .gte('created_at', oneDayAgo)
      .limit(1);

    if (queryError) {
      return new Response(JSON.stringify({ error: 'Database error' }), {
        status: 500,
      });
    }

    if (recentInvites && recentInvites.length > 0) {
      return new Response(
        JSON.stringify({
          error: 'You can only create one invite code every 24 hours.',
        }),
        { status: 429 }
      );
    }

    // Generate random 8-char code with retries
    // Using ambiguous-safe alphanumeric characters (excluding I, L, O, 0, 1)
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    const maxRetries = 3;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      let code = '';
      for (let i = 0; i < 8; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      // Insert new invite
      const { data: newInvite, error: insertError } = await supabase
        .from('invite')
        .insert({
          inviter_id: user.id,
          invite_code: code,
          name: name,
        })
        .select()
        .single();

      if (insertError) {
        // Handle potential collision
        if (insertError.code === '23505') {
          // Unique violation, try again
          continue;
        }
        // Other errors are fatal
        return new Response(JSON.stringify({ error: insertError.message }), {
          status: 500,
        });
      }

      // Success
      return new Response(JSON.stringify(newInvite), {
        status: 201,
      });
    }

    // If we exhausted all retries
    return new Response(
      JSON.stringify({
        error: 'Failed to generate a unique invite code. Please try again.',
      }),
      { status: 500 }
    );
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid request' }), {
      status: 400,
    });
  }
};
