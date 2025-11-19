import { useState } from 'react';
import { createSupabaseBrowserClient } from '../../lib/auth';

export default function LogoutButton() {
  const [isLoading, setIsLoading] = useState(false);

  const handleLogout = async () => {
    setIsLoading(true);

    try {
      const supabase = createSupabaseBrowserClient();
      await supabase.auth.signOut();
      window.location.href = '/';
    } catch (err) {
      console.error('Logout error:', err);
      setIsLoading(false);
    }
  };

  return (
    <button
      onClick={handleLogout}
      disabled={isLoading}
      className="px-4 py-2 bg-surface-border hover:bg-surface-elevated text-neutral-200 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {isLoading ? 'Signing out...' : 'Sign out'}
    </button>
  );
}
