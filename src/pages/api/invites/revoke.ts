import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../lib/auth';

export const POST: APIRoute = async ({ request, cookies }) => {
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
