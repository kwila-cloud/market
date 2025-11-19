// eslint-disable-next-line @typescript-eslint/triple-slash-reference
/// <reference path="../.astro/types.d.ts" />

import type { User } from '@supabase/supabase-js';

declare global {
  namespace App {
    interface Locals {
      user: User | null;
    }
  }
}

export {};
