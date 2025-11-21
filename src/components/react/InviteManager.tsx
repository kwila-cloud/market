import React, { useState } from 'react';
import Button from './Button';
import Card from './Card';
import ErrorAlert from './ErrorAlert';
import type { Tables } from '../../lib/database.types';
import { createSupabaseBrowserClient } from '../../lib/auth';
import { platformName } from '../../lib/globals';

type Invite = Tables<'invite'>;

interface InviteManagerProps {
  initialInvites: Invite[];
}

export default function InviteManager({ initialInvites }: InviteManagerProps) {
  const [invites, setInvites] = useState<Invite[]>(initialInvites);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Form state
  const [name, setName] = useState('');
  const [metInPerson, setMetInPerson] = useState(false);
  const [allowContactAccess, setAllowContactAccess] = useState(false);
  const [showForm, setShowForm] = useState(false);

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

    // Validate form
    if (!name.trim()) {
      setError("Please enter the invitee's name");
      setLoading(false);
      return;
    }

    if (!metInPerson) {
      setError(
        'You must confirm that you have met this person in person multiple times'
      );
      setLoading(false);
      return;
    }

    if (!allowContactAccess) {
      setError(
        'You must agree to allow this person to have access to your Contacts-Only information'
      );
      setLoading(false);
      return;
    }

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
          'Content-Type': 'application/json',
          Authorization: `Bearer ${session.access_token}`,
        },
        body: JSON.stringify({ name: name.trim() }),
      });

      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.error || 'Failed to create invite');
      }

      const newInvite = await res.json();
      setInvites((prev) => [newInvite, ...prev]);

      // Reset form
      setName('');
      setMetInPerson(false);
      setAllowContactAccess(false);
      setShowForm(false);
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
      setInvites((prev) =>
        prev.map((inv) => (inv.id === updatedInvite.id ? updatedInvite : inv))
      );
    } catch (err) {
      if (err instanceof Error) {
        alert(err.message);
      } else {
        alert('An unexpected error occurred');
      }
    }
  };

  const copyCode = async (code: string) => {
    try {
      await navigator.clipboard.writeText(code);
      alert('Invite code copied to clipboard!');
    } catch (err) {
      console.error('Failed to copy invite code:', err);
      alert('Failed to copy invite code. Please try again.');
    }
  };

  const shareCode = async (code: string) => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: `Join ${platformName}`,
          text: `Join me on ${platformName}! Use my invite code: ${code}`,
          url: window.location.origin + '/auth/login',
        });
      } catch (err) {
        console.error('Error sharing:', err);
      }
    } else {
      await copyCode(code);
    }
  };

  return (
    <div className="space-y-8">
      <Card title="Create New Invite">
        <div className="space-y-6">
          {/* Trust Warning */}
          <div className="border border-error-600/30 rounded-lg p-4">
            <div className="flex items-start space-x-3">
              <div>
                <h3 className="text-sm font-medium text-error-200">
                  Important Trust Notice
                </h3>
                <p className="text-sm text-error-300 mt-1">
                  Only invite people you trust and have met in person multiple
                  times. This person will automatically be connected to you.
                </p>
              </div>
            </div>
          </div>

          {!showForm ? (
            <Button onClick={() => setShowForm(true)} className="w-full">
              Create New Invite
            </Button>
          ) : (
            <div className="space-y-4">
              <div>
                <label
                  htmlFor="name"
                  className="block text-sm font-medium text-neutral-300 mb-2"
                >
                  Invitee Name *
                </label>
                <input
                  id="name"
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full px-3 py-2 bg-surface-base border border-surface-border rounded-lg text-neutral-100 placeholder-neutral-500 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  placeholder="Enter the person's full name"
                  required
                />
              </div>

              <div className="space-y-3">
                <div className="flex items-start space-x-3">
                  <input
                    id="metInPerson"
                    type="checkbox"
                    checked={metInPerson}
                    onChange={(e) => setMetInPerson(e.target.checked)}
                    className="mt-1 h-4 w-4 text-primary-600 focus:ring-primary-500 border-surface-border rounded bg-surface-base"
                    required
                  />
                  <label
                    htmlFor="metInPerson"
                    className="text-sm text-neutral-300"
                  >
                    I have met this person in person multiple times and know
                    them well *
                  </label>
                </div>

                <div className="flex items-start space-x-3">
                  <input
                    id="allowContactAccess"
                    type="checkbox"
                    checked={allowContactAccess}
                    onChange={(e) => setAllowContactAccess(e.target.checked)}
                    className="mt-1 h-4 w-4 text-primary-600 focus:ring-primary-500 border-surface-border rounded bg-surface-base"
                    required
                  />
                  <label
                    htmlFor="allowContactAccess"
                    className="text-sm text-neutral-300"
                  >
                    I agree to allow this person to have access to my
                    Contacts-Only information *
                  </label>
                </div>
              </div>

              {error && <ErrorAlert message={error} />}

              <div className="flex space-x-3">
                <Button
                  onClick={createInvite}
                  disabled={loading}
                  className="flex-1"
                >
                  {loading ? 'Creating...' : 'Create Invite'}
                </Button>
                <Button
                  variant="neutral"
                  onClick={() => {
                    setShowForm(false);
                    setName('');
                    setMetInPerson(false);
                    setAllowContactAccess(false);
                    setError(null);
                  }}
                  className="px-4"
                >
                  Cancel
                </Button>
              </div>
            </div>
          )}
        </div>
      </Card>

      <Card title="Active Invites">
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
                  <div className="text-sm text-neutral-400 mt-1">
                    For: {invite.name}
                  </div>
                  <div className="text-xs text-neutral-500 mt-1">
                    Created: {new Date(invite.created_at).toLocaleDateString()}
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button
                    variant="neutral"
                    onClick={() => copyCode(invite.invite_code)}
                    className="px-3 py-1.5"
                  >
                    Copy
                  </Button>
                  <Button
                    variant="primary"
                    onClick={() => shareCode(invite.invite_code)}
                    className="px-3 py-1.5"
                  >
                    Share
                  </Button>
                  <Button
                    variant="danger"
                    onClick={() => revokeInvite(invite.id)}
                    className="px-3 py-1.5"
                  >
                    Revoke
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>

      <Card title="History">
        {pastInvites.length === 0 ? (
          <p className="text-neutral-400">No past invites.</p>
        ) : (
          <div className="rounded-lg overflow-hidden border border-surface-border/60">
            <table className="w-full text-left text-sm bg-surface-base">
              <thead className="bg-surface-base text-neutral-400">
                <tr>
                  <th className="px-6 py-3 font-medium">Code</th>
                  <th className="px-6 py-3 font-medium">Name</th>
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
                      <td className="px-6 py-4 text-neutral-300">
                        {invite.name}
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={`inline-flex items-center px-4 py-1 rounded-full text-xs font-bold border ${
                            status === 'Used'
                              ? 'border-primary-700 text-primary-400'
                              : 'border-neutral-500 text-neutral-400'
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
      </Card>
    </div>
  );
}
