import type { ReactNode } from 'react';

interface ErrorAlertProps {
  message: string | ReactNode;
  className?: string;
}

export default function ErrorAlert({
  message,
  className = '',
}: ErrorAlertProps) {
  return (
    <div
      className={`bg-error/10 border border-error/20 rounded-lg p-4 text-error-200 text-sm ${className}`}
      role="alert"
    >
      {message}
    </div>
  );
}
