import React, { useState, useEffect, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { createSupabaseBrowserClient } from '../../lib/auth';
import Button from './Button';
import ErrorAlert from './ErrorAlert';

const otpSchema = z.object({
  code: z
    .string()
    .length(6, 'Code must be 6 digits')
    .regex(/^\d+$/, 'Code must contain only numbers'),
});

type OTPFormData = z.infer<typeof otpSchema>;

export default function OTPForm() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [email, setEmail] = useState<string | null>(null);
  const [resendCooldown, setResendCooldown] = useState(0);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  const {
    setValue,
    handleSubmit,
    formState: { errors },
    watch,
  } = useForm<OTPFormData>({
    resolver: zodResolver(otpSchema),
    defaultValues: { code: '' },
  });

  const codeValue = watch('code');

  useEffect(() => {
    // Get email from session storage
    const storedEmail = sessionStorage.getItem('auth_email');
    if (!storedEmail) {
      window.location.href = '/auth/login';
      return;
    }
    setEmail(storedEmail);
  }, []);

  useEffect(() => {
    // Cooldown timer for resend
    if (resendCooldown > 0) {
      const timer = setTimeout(
        () => setResendCooldown(resendCooldown - 1),
        1000
      );
      return () => clearTimeout(timer);
    }
  }, [resendCooldown]);

  const handleCodeChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return;

    const arr = codeValue.split('');
    while (arr.length < 6) arr.push('');
    arr[index] = value.slice(-1);
    const updatedCode = arr.join('').slice(0, 6);
    setValue('code', updatedCode);

    // Auto-focus next input
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (
    index: number,
    e: React.KeyboardEvent<HTMLInputElement>
  ) => {
    if (e.key === 'Backspace' && !codeValue[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault();
    const pastedData = e.clipboardData
      .getData('text')
      .replace(/\D/g, '')
      .slice(0, 6);
    setValue('code', pastedData);

    // Focus the appropriate input after paste
    const focusIndex = Math.min(pastedData.length, 5);
    inputRefs.current[focusIndex]?.focus();
  };

  const onSubmit = async (data: OTPFormData) => {
    if (!email) return;

    setIsLoading(true);
    setError(null);

    try {
      const supabase = createSupabaseBrowserClient();
      const { error: verifyError } = await supabase.auth.verifyOtp({
        email,
        token: data.code,
        type: 'email',
      });

      if (verifyError) {
        setError(verifyError.message);
        return;
      }

      // Check if this is a signup flow
      const isSignupFlow = sessionStorage.getItem('signup_flow') === 'true';

      // Clear auth_email (but keep signup data if it's a signup flow)
      sessionStorage.removeItem('auth_email');

      // Redirect based on flow type
      if (isSignupFlow) {
        // Keep invite_code and invitee_name in sessionStorage for welcome page
        sessionStorage.removeItem('signup_flow');
        window.location.href = '/auth/welcome';
      } else {
        // Regular login - redirect to dashboard
        window.location.href = '/dashboard';
      }
    } catch (err) {
      setError('An unexpected error occurred. Please try again.');
      console.error('Verification error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleResend = async () => {
    if (!email || resendCooldown > 0) return;

    setIsLoading(true);
    setError(null);

    try {
      const supabase = createSupabaseBrowserClient();
      const { error: resendError } = await supabase.auth.signInWithOtp({
        email,
      });

      if (resendError) {
        setError(resendError.message);
        return;
      }

      setResendCooldown(60);
    } catch (err) {
      setError('Failed to resend code. Please try again.');
      console.error('Resend error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  if (!email) {
    return null;
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-neutral-50 mb-2">
          Check your email
        </h2>
        <p className="text-neutral-300 text-sm">
          We sent a 6-digit code to{' '}
          <span className="font-medium text-neutral-100">{email}</span>
        </p>
      </div>

      {error && <ErrorAlert message={error} />}

      <div>
        <label
          htmlFor="otp-input-0"
          className="block text-sm font-medium text-neutral-200 mb-3"
        >
          Verification code
        </label>
        <div className="flex gap-2 justify-center" onPaste={handlePaste}>
          {[0, 1, 2, 3, 4, 5].map((index) => (
            <input
              key={index}
              id={`otp-input-${index}`}
              ref={(el) => {
                inputRefs.current[index] = el;
              }}
              type="text"
              inputMode="numeric"
              maxLength={1}
              value={codeValue[index] || ''}
              onChange={(e) => handleCodeChange(index, e.target.value)}
              onKeyDown={(e) => handleKeyDown(index, e)}
              className="w-12 h-14 text-center text-xl font-mono bg-surface border border-surface-border rounded-lg text-neutral-50 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
              aria-label={`Digit ${index + 1} of 6`}
              // eslint-disable-next-line jsx-a11y/no-autofocus
              autoFocus={index === 0}
            />
          ))}
        </div>
        {errors.code && (
          <p className="mt-2 text-sm text-red-400 text-center">
            {errors.code.message}
          </p>
        )}
      </div>

      <Button
        type="submit"
        fullWidth
        disabled={isLoading || codeValue.length !== 6}
      >
        {isLoading ? 'Verifying...' : 'Verify code'}
      </Button>

      <div className="text-center">
        <button
          type="button"
          onClick={handleResend}
          disabled={resendCooldown > 0 || isLoading}
          className="text-sm text-primary hover:text-primary-400 disabled:text-neutral-500 disabled:cursor-not-allowed transition-colors"
        >
          {resendCooldown > 0
            ? `Resend code in ${resendCooldown}s`
            : "Didn't receive code? Resend"}
        </button>
      </div>

      <div className="text-center">
        <a
          href="/auth/login"
          className="text-sm text-neutral-400 hover:text-neutral-300 transition-colors"
        >
          Use a different email
        </a>
      </div>
    </form>
  );
}
