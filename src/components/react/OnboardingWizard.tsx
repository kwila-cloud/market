import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { createSupabaseBrowserClient } from '../../lib/auth';
import Button from './Button';
import Card from './Card';
import ErrorAlert from './ErrorAlert';

const onboardingSchema = z.object({
  invite_code: z
    .string()
    .length(8, 'Invite code must be 8 characters')
    .regex(/^[A-Z0-9]+$/, 'Invalid invite code format'),
  display_name: z
    .string()
    .min(1, 'Display name is required')
    .max(100, 'Display name must be less than 100 characters'),
  about: z
    .string()
    .max(500, 'About must be less than 500 characters')
    .optional(),
  contact_visibility: z.enum(['hidden', 'connections-only', 'public']),
});

type OnboardingFormData = z.infer<typeof onboardingSchema>;

export default function OnboardingWizard() {
  const [step, setStep] = useState(1);
  const [isLoading, setIsLoading] = useState(false);
  const [isValidatingInvite, setIsValidatingInvite] = useState(false);
  const [isSigningOut, setIsSigningOut] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSignOut = async () => {
    setIsSigningOut(true);
    try {
      const supabase = createSupabaseBrowserClient();
      await supabase.auth.signOut();
      window.location.href = '/';
    } catch (err) {
      console.error('Sign out error:', err);
      setIsSigningOut(false);
    }
  };

  const {
    register,
    handleSubmit,
    formState: { errors },
    watch,
    setValue,
  } = useForm<OnboardingFormData>({
    resolver: zodResolver(onboardingSchema),
    defaultValues: {
      contact_visibility: 'hidden',
    },
  });

  const formValues = watch();

  const onSubmit = async (data: OnboardingFormData) => {
    setIsLoading(true);
    setError(null);

    try {
      const supabase = createSupabaseBrowserClient();

      // Call the complete_signup RPC function
      const { data: result, error: signupError } = await supabase.rpc(
        'complete_signup',
        {
          p_invite_code: data.invite_code.toUpperCase(),
          p_display_name: data.display_name,
          p_about: data.about || '',
          p_contact_visibility: data.contact_visibility,
        }
      );

      if (signupError) {
        console.error('Signup error:', signupError);
        setError('Failed to complete signup. Please try again.');
        return;
      }

      if (!result?.success) {
        setError('Failed to complete signup. Please try again.');
        return;
      }

      // Redirect to dashboard
      window.location.href = '/dashboard';
    } catch (err) {
      console.error('Unexpected error:', err);
      setError('An unexpected error occurred. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleNext = async () => {
    setError(null);

    // If moving from step 1 (invite code), validate it first
    if (step === 1) {
      const inviteCode = formValues.invite_code?.toUpperCase();

      if (!inviteCode || inviteCode.length !== 8) {
        setError('Please enter a valid 8-character invite code');
        return;
      }

      setIsValidatingInvite(true);

      try {
        const supabase = createSupabaseBrowserClient();

        // Validate the invite code using RPC (bypasses RLS for new users)
        const { data, error: rpcError } = await supabase.rpc(
          'validate_invite_code',
          {
            p_invite_code: inviteCode,
          }
        );

        if (rpcError) {
          console.error('RPC error:', rpcError);
          setError('Failed to validate invite code. Please try again.');
          return;
        }

        if (!data?.valid) {
          setError(
            data?.error || 'Invalid invite code. Please check and try again.'
          );
          return;
        }

        // Valid invite! Pre-fill display name with invitee name
        setValue('display_name', data.name);
      } catch (err) {
        console.error('Invite validation error:', err);
        setError('Failed to validate invite code. Please try again.');
        return;
      } finally {
        setIsValidatingInvite(false);
      }
    }

    setStep(step + 1);
  };

  const handleBack = () => {
    setError(null);
    setStep(step - 1);
  };

  // Generate avatar preview URL
  const avatarUrl = formValues.display_name
    ? `https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(formValues.display_name)}`
    : '';

  return (
    <div className="w-full max-w-2xl mx-auto">
      <Card title="Complete Your Profile">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          {/* Progress indicator */}
          <div className="space-y-2">
            <div className="flex justify-between items-center text-sm text-neutral-400">
              <span>Step {step} of 4</span>
              <button
                type="button"
                onClick={handleSignOut}
                disabled={isSigningOut || isValidatingInvite}
                className="text-neutral-400 hover:text-neutral-300 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSigningOut ? 'Signing out...' : 'Wrong account? Sign out'}
              </button>
            </div>
            <div className="w-full bg-surface-border rounded-full h-2">
              <div
                className="bg-primary rounded-full h-2 transition-all duration-300"
                style={{ width: `${(step / 4) * 100}%` }}
              />
            </div>
          </div>

          {error && <ErrorAlert message={error} />}

          {/* Step 1: Invite Code */}
          {step === 1 && (
            <div className="space-y-4">
              <div>
                <h3 className="text-lg font-semibold text-neutral-50 mb-2">
                  Enter Your Invite Code
                </h3>
                <p className="text-sm text-neutral-300 mb-4">
                  You need an invite code from an existing member to join
                </p>
              </div>

              <div>
                <label
                  htmlFor="invite_code"
                  className="block text-sm font-medium text-neutral-200 mb-2"
                >
                  Invite Code *
                </label>
                <input
                  id="invite_code"
                  type="text"
                  maxLength={8}
                  {...register('invite_code')}
                  disabled={isValidatingInvite}
                  className="w-full px-4 py-3 bg-surface border border-surface-border rounded-lg text-neutral-50 placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all uppercase font-mono tracking-wider text-center text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                  placeholder="ABC12345"
                  style={{ textTransform: 'uppercase' }}
                />
                {errors.invite_code && (
                  <p className="mt-2 text-sm text-error-200">
                    {errors.invite_code.message}
                  </p>
                )}
                {isValidatingInvite && (
                  <p className="mt-2 text-sm text-neutral-400">
                    Validating invite code... (this may take a few seconds)
                  </p>
                )}
              </div>

              <div className="flex justify-end pt-4">
                <Button
                  type="button"
                  onClick={handleNext}
                  disabled={isValidatingInvite}
                >
                  {isValidatingInvite ? 'Validating...' : 'Next Step →'}
                </Button>
              </div>
            </div>
          )}

          {/* Step 2: Contact Visibility */}
          {step === 2 && (
            <div className="space-y-4">
              <div>
                <h3 className="text-lg font-semibold text-neutral-50 mb-2">
                  Contact Information Visibility
                </h3>
                <p className="text-sm text-neutral-300 mb-4">
                  Choose who can see your contact information (email/phone)
                </p>
              </div>

              <div className="space-y-3">
                <label className="block">
                  <input
                    type="radio"
                    value="hidden"
                    {...register('contact_visibility')}
                    className="sr-only peer"
                  />
                  <div className="p-4 border-2 border-surface-border rounded-lg cursor-pointer peer-checked:border-primary peer-checked:bg-primary/5 hover:border-primary/50 transition-all">
                    <div className="flex items-start">
                      <div className="flex-1">
                        <div className="font-semibold text-neutral-50">
                          Hidden
                        </div>
                        <div className="text-sm text-neutral-300 mt-1">
                          Only you can see your contact information. Others can
                          message you through the platform.
                        </div>
                      </div>
                    </div>
                  </div>
                </label>

                <label className="block">
                  <input
                    type="radio"
                    value="connections-only"
                    {...register('contact_visibility')}
                    className="sr-only peer"
                  />
                  <div className="p-4 border-2 border-surface-border rounded-lg cursor-pointer peer-checked:border-primary peer-checked:bg-primary/5 hover:border-primary/50 transition-all">
                    <div className="flex items-start">
                      <div className="flex-1">
                        <div className="font-semibold text-neutral-50">
                          Connections Only
                        </div>
                        <div className="text-sm text-neutral-300 mt-1">
                          Your direct connections can see your contact
                          information. Recommended for most users.
                        </div>
                      </div>
                    </div>
                  </div>
                </label>

                <label className="block">
                  <input
                    type="radio"
                    value="public"
                    {...register('contact_visibility')}
                    className="sr-only peer"
                  />
                  <div className="p-4 border-2 border-surface-border rounded-lg cursor-pointer peer-checked:border-primary peer-checked:bg-primary/5 hover:border-primary/50 transition-all">
                    <div className="flex items-start">
                      <div className="flex-1">
                        <div className="font-semibold text-neutral-50">
                          Public
                        </div>
                        <div className="text-sm text-neutral-300 mt-1">
                          Anyone on the platform can see your contact
                          information. Best for vendors and service providers.
                        </div>
                      </div>
                    </div>
                  </div>
                </label>
              </div>

              <div className="flex justify-end pt-4">
                <Button type="button" onClick={handleNext}>
                  Next Step →
                </Button>
              </div>
            </div>
          )}

          {/* Step 3: Display Name & Bio */}
          {step === 3 && (
            <div className="space-y-4">
              <div>
                <h3 className="text-lg font-semibold text-neutral-50 mb-2">
                  Tell Us About Yourself
                </h3>
                <p className="text-sm text-neutral-300 mb-4">
                  This information will be visible on your profile
                </p>
              </div>

              <div>
                <label
                  htmlFor="display_name"
                  className="block text-sm font-medium text-neutral-200 mb-2"
                >
                  Display Name *
                </label>
                <input
                  id="display_name"
                  type="text"
                  {...register('display_name')}
                  className="w-full px-4 py-3 bg-surface border border-surface-border rounded-lg text-neutral-50 placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                  placeholder="Your name"
                />
                {errors.display_name && (
                  <p className="mt-2 text-sm text-error-200">
                    {errors.display_name.message}
                  </p>
                )}
              </div>

              <div>
                <label
                  htmlFor="about"
                  className="block text-sm font-medium text-neutral-200 mb-2"
                >
                  About (Optional)
                </label>
                <textarea
                  id="about"
                  rows={4}
                  {...register('about')}
                  className="w-full px-4 py-3 bg-surface border border-surface-border rounded-lg text-neutral-50 placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all resize-none"
                  placeholder="Tell others about yourself, your interests, or what you're looking for..."
                />
                {errors.about && (
                  <p className="mt-2 text-sm text-error-200">
                    {errors.about.message}
                  </p>
                )}
                <p className="mt-2 text-xs text-neutral-400">
                  {formValues.about?.length || 0} / 500 characters
                </p>
              </div>

              <div className="flex justify-between pt-4">
                <Button type="button" variant="neutral" onClick={handleBack}>
                  ← Back
                </Button>
                <Button type="button" onClick={handleNext}>
                  Next Step →
                </Button>
              </div>
            </div>
          )}

          {/* Step 4: Review & Complete */}
          {step === 4 && (
            <div className="space-y-4">
              <div>
                <h3 className="text-lg font-semibold text-neutral-50 mb-2">
                  Review Your Profile
                </h3>
                <p className="text-sm text-neutral-300 mb-4">
                  Make sure everything looks good before completing signup
                </p>
              </div>

              <div className="bg-surface-base border border-surface-border rounded-lg p-6 space-y-4">
                {/* Avatar preview */}
                <div className="flex items-center space-x-4">
                  <img
                    src={avatarUrl}
                    alt="Avatar preview"
                    className="w-16 h-16 rounded-full bg-surface-elevated"
                  />
                  <div>
                    <div className="font-semibold text-neutral-50">
                      {formValues.display_name}
                    </div>
                    <div className="text-sm text-neutral-400">
                      Your avatar is auto-generated
                    </div>
                  </div>
                </div>

                {/* About */}
                {formValues.about && (
                  <div>
                    <div className="text-sm font-medium text-neutral-300 mb-1">
                      About
                    </div>
                    <div className="text-sm text-neutral-400">
                      {formValues.about}
                    </div>
                  </div>
                )}

                {/* Contact visibility */}
                <div>
                  <div className="text-sm font-medium text-neutral-300 mb-1">
                    Contact Visibility
                  </div>
                  <div className="text-sm text-neutral-400 capitalize">
                    {formValues.contact_visibility.replace('-', ' ')}
                  </div>
                </div>
              </div>

              <div className="flex justify-between pt-4">
                <Button type="button" variant="neutral" onClick={handleBack}>
                  ← Back
                </Button>
                <Button type="submit" disabled={isLoading}>
                  {isLoading ? 'Completing...' : 'Complete Signup'}
                </Button>
              </div>
            </div>
          )}
        </form>
      </Card>
    </div>
  );
}
