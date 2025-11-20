export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never;
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      graphql: {
        Args: {
          extensions?: Json;
          operationName?: string;
          query?: string;
          variables?: Json;
        };
        Returns: Json;
      };
    };
    Enums: {
      [_ in never]: never;
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
  public: {
    Tables: {
      category: {
        Row: {
          created_at: string;
          description: string | null;
          id: string;
          name: string;
        };
        Insert: {
          created_at?: string;
          description?: string | null;
          id: string;
          name: string;
        };
        Update: {
          created_at?: string;
          description?: string | null;
          id?: string;
          name?: string;
        };
        Relationships: [];
      };
      connection: {
        Row: {
          created_at: string;
          id: string;
          status: Database['public']['Enums']['connection_status'];
          user_a: string;
          user_b: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          status?: Database['public']['Enums']['connection_status'];
          user_a: string;
          user_b: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          status?: Database['public']['Enums']['connection_status'];
          user_a?: string;
          user_b?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'connection_user_a_fkey';
            columns: ['user_a'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'connection_user_b_fkey';
            columns: ['user_b'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
      contact_info: {
        Row: {
          contact_type: Database['public']['Enums']['contact_type'];
          created_at: string;
          id: string;
          user_id: string;
          value: string;
          visibility: Database['public']['Enums']['visibility'];
        };
        Insert: {
          contact_type: Database['public']['Enums']['contact_type'];
          created_at?: string;
          id?: string;
          user_id: string;
          value: string;
          visibility?: Database['public']['Enums']['visibility'];
        };
        Update: {
          contact_type?: Database['public']['Enums']['contact_type'];
          created_at?: string;
          id?: string;
          user_id?: string;
          value?: string;
          visibility?: Database['public']['Enums']['visibility'];
        };
        Relationships: [
          {
            foreignKeyName: 'contact_info_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
      invite: {
        Row: {
          created_at: string;
          id: string;
          invite_code: string;
          inviter_id: string;
          revoked_at: string | null;
          used_at: string | null;
          used_by: string | null;
        };
        Insert: {
          created_at?: string;
          id?: string;
          invite_code: string;
          inviter_id: string;
          revoked_at?: string | null;
          used_at?: string | null;
          used_by?: string | null;
        };
        Update: {
          created_at?: string;
          id?: string;
          invite_code?: string;
          inviter_id?: string;
          revoked_at?: string | null;
          used_at?: string | null;
          used_by?: string | null;
        };
        Relationships: [
          {
            foreignKeyName: 'invite_inviter_id_fkey';
            columns: ['inviter_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'invite_used_by_fkey';
            columns: ['used_by'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
      item: {
        Row: {
          category_id: string;
          created_at: string;
          description: string | null;
          id: string;
          price_string: string | null;
          status: Database['public']['Enums']['item_status'];
          title: string;
          type: Database['public']['Enums']['item_type'];
          updated_at: string;
          user_id: string;
          visibility: Database['public']['Enums']['visibility'];
        };
        Insert: {
          category_id: string;
          created_at?: string;
          description?: string | null;
          id?: string;
          price_string?: string | null;
          status?: Database['public']['Enums']['item_status'];
          title: string;
          type: Database['public']['Enums']['item_type'];
          updated_at?: string;
          user_id: string;
          visibility?: Database['public']['Enums']['visibility'];
        };
        Update: {
          category_id?: string;
          created_at?: string;
          description?: string | null;
          id?: string;
          price_string?: string | null;
          status?: Database['public']['Enums']['item_status'];
          title?: string;
          type?: Database['public']['Enums']['item_type'];
          updated_at?: string;
          user_id?: string;
          visibility?: Database['public']['Enums']['visibility'];
        };
        Relationships: [
          {
            foreignKeyName: 'item_category_id_fkey';
            columns: ['category_id'];
            isOneToOne: false;
            referencedRelation: 'category';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'item_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
      item_image: {
        Row: {
          alt_text: string | null;
          created_at: string;
          id: string;
          item_id: string;
          order_index: number;
          url: string;
        };
        Insert: {
          alt_text?: string | null;
          created_at?: string;
          id?: string;
          item_id: string;
          order_index?: number;
          url: string;
        };
        Update: {
          alt_text?: string | null;
          created_at?: string;
          id?: string;
          item_id?: string;
          order_index?: number;
          url?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'item_image_item_id_fkey';
            columns: ['item_id'];
            isOneToOne: false;
            referencedRelation: 'item';
            referencedColumns: ['id'];
          },
        ];
      };
      message: {
        Row: {
          content: string;
          created_at: string;
          id: string;
          read: boolean;
          sender_id: string;
          thread_id: string;
        };
        Insert: {
          content: string;
          created_at?: string;
          id?: string;
          read?: boolean;
          sender_id: string;
          thread_id: string;
        };
        Update: {
          content?: string;
          created_at?: string;
          id?: string;
          read?: boolean;
          sender_id?: string;
          thread_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'message_sender_id_fkey';
            columns: ['sender_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'message_thread_id_fkey';
            columns: ['thread_id'];
            isOneToOne: false;
            referencedRelation: 'thread';
            referencedColumns: ['id'];
          },
        ];
      };
      message_image: {
        Row: {
          created_at: string;
          id: string;
          message_id: string;
          order_index: number;
          url: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          message_id: string;
          order_index?: number;
          url: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          message_id?: string;
          order_index?: number;
          url?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'message_image_message_id_fkey';
            columns: ['message_id'];
            isOneToOne: false;
            referencedRelation: 'message';
            referencedColumns: ['id'];
          },
        ];
      };
      thread: {
        Row: {
          created_at: string;
          creator_id: string;
          id: string;
          item_id: string;
          responder_id: string;
        };
        Insert: {
          created_at?: string;
          creator_id: string;
          id?: string;
          item_id: string;
          responder_id: string;
        };
        Update: {
          created_at?: string;
          creator_id?: string;
          id?: string;
          item_id?: string;
          responder_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'thread_creator_id_fkey';
            columns: ['creator_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'thread_item_id_fkey';
            columns: ['item_id'];
            isOneToOne: false;
            referencedRelation: 'item';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'thread_responder_id_fkey';
            columns: ['responder_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
      user: {
        Row: {
          about: string | null;
          avatar_url: string | null;
          created_at: string;
          display_name: string;
          id: string;
          invited_by: string | null;
          vendor_id: string | null;
        };
        Insert: {
          about?: string | null;
          avatar_url?: string | null;
          created_at?: string;
          display_name: string;
          id?: string;
          invited_by?: string | null;
          vendor_id?: string | null;
        };
        Update: {
          about?: string | null;
          avatar_url?: string | null;
          created_at?: string;
          display_name?: string;
          id?: string;
          invited_by?: string | null;
          vendor_id?: string | null;
        };
        Relationships: [
          {
            foreignKeyName: 'user_invited_by_fkey';
            columns: ['invited_by'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
      user_settings: {
        Row: {
          created_at: string;
          id: string;
          setting_key: string;
          setting_value: Json;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          setting_key: string;
          setting_value?: Json;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          setting_key?: string;
          setting_value?: Json;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'user_settings_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
      watch: {
        Row: {
          created_at: string;
          id: string;
          name: string;
          notify: string | null;
          query_params: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          name: string;
          notify?: string | null;
          query_params: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          name?: string;
          notify?: string | null;
          query_params?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'watch_notify_fkey';
            columns: ['notify'];
            isOneToOne: false;
            referencedRelation: 'contact_info';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'watch_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: false;
            referencedRelation: 'user';
            referencedColumns: ['id'];
          },
        ];
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      [_ in never]: never;
    };
    Enums: {
      connection_status: 'pending' | 'accepted' | 'declined';
      contact_type: 'email' | 'phone';
      item_status: 'active' | 'archived' | 'deleted';
      item_type: 'buy' | 'sell';
      visibility: 'hidden' | 'connections-only' | 'public';
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
};

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>;

type DefaultSchema = DatabaseWithoutInternals[Extract<
  keyof Database,
  'public'
>];

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema['Tables'] & DefaultSchema['Views'])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])[TableName] extends {
      Row: infer R;
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema['Tables'] &
        DefaultSchema['Views'])
    ? (DefaultSchema['Tables'] &
        DefaultSchema['Views'])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R;
      }
      ? R
      : never
    : never;

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema['Tables']
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Insert: infer I;
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I;
      }
      ? I
      : never
    : never;

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema['Tables']
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Update: infer U;
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U;
      }
      ? U
      : never
    : never;

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema['Enums']
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums']
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums'][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema['Enums']
    ? DefaultSchema['Enums'][DefaultSchemaEnumNameOrOptions]
    : never;

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema['CompositeTypes']
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes']
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes'][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema['CompositeTypes']
    ? DefaultSchema['CompositeTypes'][PublicCompositeTypeNameOrOptions]
    : never;

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      connection_status: ['pending', 'accepted', 'declined'],
      contact_type: ['email', 'phone'],
      item_status: ['active', 'archived', 'deleted'],
      item_type: ['buy', 'sell'],
      visibility: ['hidden', 'connections-only', 'public'],
    },
  },
} as const;
