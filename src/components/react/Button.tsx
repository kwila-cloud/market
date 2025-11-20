import type {
  ButtonHTMLAttributes,
  AnchorHTMLAttributes,
  ReactNode,
} from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'neutral' | 'danger';

type BaseProps = {
  variant?: ButtonVariant;
  fullWidth?: boolean;
  children: ReactNode;
  className?: string;
};

type ButtonAsButton = BaseProps &
  Omit<ButtonHTMLAttributes<HTMLButtonElement>, keyof BaseProps> & {
    href?: never;
  };

type ButtonAsLink = BaseProps &
  Omit<AnchorHTMLAttributes<HTMLAnchorElement>, keyof BaseProps> & {
    href: string;
  };

type ButtonProps = ButtonAsButton | ButtonAsLink;

const variantStyles: Record<ButtonVariant, string> = {
  primary:
    'bg-primary hover:bg-primary-600 text-white focus:ring-primary focus:ring-offset-surface-elevated',
  secondary:
    'bg-secondary hover:bg-secondary-600 text-white focus:ring-secondary focus:ring-offset-surface-elevated',
  neutral:
    'bg-surface-border hover:bg-surface-elevated text-neutral-200 focus:ring-neutral-500 focus:ring-offset-surface',
  danger:
    'bg-error hover:bg-error-600 text-white focus:ring-error focus:ring-offset-surface',
};

export default function Button(props: ButtonProps) {
  const {
    variant = 'primary',
    fullWidth = false,
    children,
    className = '',
    ...rest
  } = props;

  const baseClassName = `cursor-pointer px-4 py-2 text-sm font-bold rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed ${variantStyles[variant]} ${fullWidth ? 'w-full' : ''} ${className}`;

  if ('href' in props && props.href) {
    const { href, ...linkProps } = rest as Omit<ButtonAsLink, keyof BaseProps>;
    return (
      <a href={href} className={baseClassName} {...linkProps}>
        {children}
      </a>
    );
  }

  const { disabled, ...buttonProps } = rest as Omit<
    ButtonAsButton,
    keyof BaseProps
  >;
  return (
    <button className={baseClassName} disabled={disabled} {...buttonProps}>
      {children}
    </button>
  );
}
