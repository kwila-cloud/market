import type { ReactNode } from 'react';

interface CardProps {
  title: string;
  children: ReactNode;
  className?: string;
}

export default function Card({ title, children, className = '' }: CardProps) {
  return (
    <div
      className={`bg-surface-elevated border border-surface-border rounded-xl p-6 ${className}`}
    >
      <h2 className="text-xl font-semibold text-neutral-50 mb-4">{title}</h2>
      {children}
    </div>
  );
}
