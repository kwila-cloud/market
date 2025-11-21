import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { createSupabaseBrowserClient } from '../../lib/auth';
import Button from './Button';
import ErrorAlert from './ErrorAlert';

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export default function LoginForm() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true);
    setError(null);

    try {
      const supabase = createSupabaseBrowserClient();
      const { error: signInError } = await supabase.auth.signInWithOtp({
        email: data.email,
        options: {
          shouldCreateUser: false,
        },
      });

      if (signInError) {
        // Log the actual error for debugging, but don't expose to user
        console.error('Sign in error:', signInError.code, signInError.message);

        // Show generic error message to prevent user enumeration attacks
        // All auth errors should look the same to the user
        setError(
          'Unable to sign in. Please check your email address and try again.'
        );
        return;
      }

      // Store email for verification page
      sessionStorage.setItem('auth_email', data.email);

      // Redirect to verification page
      window.location.href = '/auth/verify';
    } catch (err) {
      setError('An unexpected error occurred. Please try again.');
      console.error('Login error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-neutral-50 mb-2">Welcome</h2>
        <p className="text-neutral-300 text-sm">
          Enter your email to receive a one-time password
        </p>
      </div>

      {error && <ErrorAlert message={error} />}

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
          <p className="mt-2 text-sm text-red-400">{errors.email.message}</p>
        )}
      </div>

      <Button type="submit" fullWidth disabled={isLoading}>
        {isLoading ? 'Sending...' : 'Continue with email'}
      </Button>

      <p className="text-center text-sm text-neutral-400">
        Don&apos;t have an account?{' '}
        <a
          href="/auth/signup"
          className="text-primary hover:text-primary-400 transition-colors"
        >
          Sign up with an invite code
        </a>
      </p>
    </form>
  );
}
