import React, { useState } from 'react';
import type { Tables } from '../../lib/database.types';
import { createSupabaseBrowserClient } from '../../lib/auth';

type Invite = Tables<'invite'>;

interface InviteManagerProps {
  initialInvites: Invite[];
}

export default function InviteManager({ initialInvites }: InviteManagerProps) {
  const [invites, setInvites] = useState<Invite[]>(initialInvites);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const activeInvites = invites.filter(
    (invite) => !invite.used_at && !invite.revoked_at
  );

  const pastInvites = invites.filter(
    (invite) => invite.used_at || invite.revoked_at
  );

  // Sort past invites by creation date desc
  pastInvites.sort(
    (a, b) =>
      new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  );

  const createInvite = async () => {
    setLoading(true);
    setError(null);
    try {
      const supabase = createSupabaseBrowserClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session) {
        throw new Error('You must be logged in to create invites');
      }

      const res = await fetch('/api/invites/create', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${session.access_token}`,
        },
      });

      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.error || 'Failed to create invite');
      }

      const newInvite = await res.json();
      setInvites([newInvite, ...invites]);
    } catch (err) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('An unexpected error occurred');
      }
    } finally {
      setLoading(false);
    }
  };

  const revokeInvite = async (inviteId: string) => {
    if (!confirm('Are you sure you want to revoke this invite code?')) return;

    try {
      const supabase = createSupabaseBrowserClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session) {
        throw new Error('You must be logged in to revoke invites');
      }

      const res = await fetch('/api/invites/revoke', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${session.access_token}`,
        },
        body: JSON.stringify({ inviteId }),
      });

      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.error || 'Failed to revoke invite');
      }

      const updatedInvite = await res.json();
      setInvites(
        invites.map((inv) =>
          inv.id === updatedInvite.id ? updatedInvite : inv
        )
      );
    } catch (err) {
      if (err instanceof Error) {
        alert(err.message);
      } else {
        alert('An unexpected error occurred');
      }
    }
  };

  const copyCode = (code: string) => {
    navigator.clipboard.writeText(code);
    alert('Invite code copied to clipboard!');
  };

  const shareCode = async (code: string) => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Join Market',
          text: `Join me on Market! Use my invite code: ${code}`,
          url: window.location.origin + '/auth/login', // Or a signup specific page if it existed
        });
      } catch (err) {
        console.error('Error sharing:', err);
      }
    } else {
      copyCode(code);
    }
  };

  return (
    <div className="space-y-8">
      <div className="flex flex-col items-start gap-4">
        <div className="bg-surface-elevated border border-surface-border rounded-xl p-6 w-full">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold text-neutral-50">
              Active Invites
            </h2>
            <button
              onClick={createInvite}
              disabled={loading}
              className="bg-primary-600 hover:bg-primary-700 text-white font-medium py-2 px-4 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Creating...' : 'Create Invite'}
            </button>
          </div>

          {error && (
            <div className="bg-red-900/30 border border-red-800 text-red-200 p-4 rounded-lg mb-4">
              {error}
            </div>
          )}

          {activeInvites.length === 0 ? (
            <p className="text-neutral-400">No active invite codes.</p>
          ) : (
            <div className="grid gap-4">
              {activeInvites.map((invite) => (
                <div
                  key={invite.id}
                  className="bg-surface-base border border-surface-border rounded-lg p-4 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4"
                >
                  <div>
                    <div className="text-2xl font-mono font-bold text-primary-400 tracking-wider">
                      {invite.invite_code}
                    </div>
                    <div className="text-xs text-neutral-400 mt-1">
                      Created:{' '}
                      {new Date(invite.created_at).toLocaleDateString()}
                    </div>
                  </div>

                  <div className="flex gap-2">
                    <button
                      onClick={() => copyCode(invite.invite_code)}
                      className="px-3 py-1.5 text-sm font-medium text-neutral-300 bg-neutral-800 hover:bg-neutral-700 rounded-md transition-colors"
                    >
                      Copy
                    </button>
                    <button
                      onClick={() => shareCode(invite.invite_code)}
                      className="px-3 py-1.5 text-sm font-medium text-neutral-300 bg-neutral-800 hover:bg-neutral-700 rounded-md transition-colors"
                    >
                      Share
                    </button>
                    <button
                      onClick={() => revokeInvite(invite.id)}
                      className="px-3 py-1.5 text-sm font-medium text-red-400 bg-red-900/20 hover:bg-red-900/40 rounded-md transition-colors"
                    >
                      Revoke
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="bg-surface-elevated border border-surface-border rounded-xl p-6 w-full">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold text-neutral-50">History</h2>
          </div>
          {pastInvites.length === 0 ? (
            <p className="text-neutral-400">No past invites.</p>
          ) : (
            <div className="rounded-lg overflow-hidden border border-surface-border/60">
              <table className="w-full text-left text-sm bg-surface-base">
                <thead className="bg-surface-base text-neutral-400">
                  <tr>
                    <th className="px-6 py-3 font-medium">Code</th>
                    <th className="px-6 py-3 font-medium">Status</th>
                    <th className="px-6 py-3 font-medium">Date</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-surface-border">
                  {pastInvites.map((invite) => {
                    let status = 'Unknown';
                    let date = invite.created_at;

                    if (invite.revoked_at) {
                      status = 'Revoked';
                      date = invite.revoked_at;
                    } else if (invite.used_at) {
                      status = 'Used';
                      date = invite.used_at;
                    }

                    return (
                      <tr
                        key={invite.id}
                        className="hover:bg-surface-base/50 transition-colors"
                      >
                        <td className="px-6 py-4 font-mono text-neutral-300">
                          {invite.invite_code}
                        </td>
                        <td className="px-6 py-4">
                          <span
                            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                              status === 'Used'
                                ? 'bg-green-900/30 text-green-400'
                                : 'bg-neutral-700 text-neutral-300'
                            }`}
                          >
                            {status}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-neutral-400">
                          {new Date(date).toLocaleDateString()}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
