import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { createSupabaseBrowserClient } from '../../lib/auth';
import Button from './Button';
import ErrorAlert from './ErrorAlert';

const signupSchema = z.object({
  inviteCode: z
    .string()
    .length(8, 'Invite code must be 8 characters')
    .regex(/^[A-Z0-9]+$/, 'Invalid invite code format'),
  email: z.string().email('Please enter a valid email address'),
});

type SignupFormData = z.infer<typeof signupSchema>;

export default function SignupForm() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<SignupFormData>({
    resolver: zodResolver(signupSchema),
  });

  const onSubmit = async (data: SignupFormData) => {
    setIsLoading(true);
    setError(null);

    try {
      const supabase = createSupabaseBrowserClient();

      // First, validate the invite code by fetching it
      const { data: inviteData, error: inviteError } = await supabase
        .from('invite')
        .select('invite_code, name, used_at, revoked_at')
        .eq('invite_code', data.inviteCode.toUpperCase())
        .single();

      if (inviteError || !inviteData) {
        setError('Invalid invite code. Please check and try again.');
        return;
      }

      if (inviteData.used_at) {
        setError('This invite code has already been used.');
        return;
      }

      if (inviteData.revoked_at) {
        setError('This invite code has been revoked.');
        return;
      }

      // Valid invite code! Now send OTP
      const { error: signInError } = await supabase.auth.signInWithOtp({
        email: data.email,
        options: {
          shouldCreateUser: true,
        },
      });

      if (signInError) {
        console.error('Sign in error:', signInError.code, signInError.message);
        setError('Unable to send verification code. Please try again.');
        return;
      }

      // Store invite code and invitee name for the welcome page
      sessionStorage.setItem('invite_code', data.inviteCode.toUpperCase());
      sessionStorage.setItem('invitee_name', inviteData.name);
      sessionStorage.setItem('auth_email', data.email);
      sessionStorage.setItem('signup_flow', 'true');

      // Redirect to verification page
      window.location.href = '/auth/verify';
    } catch (err) {
      setError('An unexpected error occurred. Please try again.');
      console.error('Signup error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-neutral-50 mb-2">
          Create Your Account
        </h2>
        <p className="text-neutral-300 text-sm">
          You&apos;ll need an invite code to sign up
        </p>
      </div>

      {error && <ErrorAlert message={error} />}

      <div>
        <label
          htmlFor="inviteCode"
          className="block text-sm font-medium text-neutral-200 mb-2"
        >
          Invite Code
        </label>
        <input
          id="inviteCode"
          type="text"
          maxLength={8}
          {...register('inviteCode')}
          className="w-full px-4 py-3 bg-surface border border-surface-border rounded-lg text-neutral-50 placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all uppercase font-mono tracking-wider"
          placeholder="ABC12345"
          style={{ textTransform: 'uppercase' }}
        />
        {errors.inviteCode && (
          <p className="mt-2 text-sm text-error-200">
            {errors.inviteCode.message}
          </p>
        )}
      </div>

      <div>
        <label
          htmlFor="email"
          className="block text-sm font-medium text-neutral-200 mb-2"
        >
          Email address
        </label>
        <input
          id="email"
          type="email"
          autoComplete="email"
          {...register('email')}
          className="w-full px-4 py-3 bg-surface border border-surface-border rounded-lg text-neutral-50 placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
          placeholder="you@example.com"
        />
        {errors.email && (
          <p className="mt-2 text-sm text-error-200">{errors.email.message}</p>
        )}
      </div>

      <Button type="submit" fullWidth disabled={isLoading}>
        {isLoading ? 'Validating...' : 'Continue'}
      </Button>

      <p className="text-center text-sm text-neutral-400">
        Already have an account?{' '}
        <a
          href="/auth/login"
          className="text-primary hover:text-primary-400 transition-colors"
        >
          Sign in
        </a>
      </p>
    </form>
  );
}
