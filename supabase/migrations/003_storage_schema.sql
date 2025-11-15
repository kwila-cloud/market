-- Create Supabase Storage schema tables
-- Required by the storage-api service

-- Create storage buckets table
CREATE TABLE IF NOT EXISTS storage.buckets (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    owner UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    public BOOLEAN DEFAULT FALSE,
    avif_autodetection BOOLEAN DEFAULT FALSE,
    file_size_limit BIGINT,
    allowed_mime_types TEXT[]
);

-- Create storage objects table
CREATE TABLE IF NOT EXISTS storage.objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bucket_id TEXT REFERENCES storage.buckets(id),
    name TEXT NOT NULL,
    owner UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB,
    path_tokens TEXT[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED,
    version TEXT,
    UNIQUE(bucket_id, name)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_buckets_name ON storage.buckets(name);
CREATE INDEX IF NOT EXISTS idx_objects_bucket_id ON storage.objects(bucket_id);
CREATE INDEX IF NOT EXISTS idx_objects_name ON storage.objects(name);
CREATE INDEX IF NOT EXISTS idx_objects_path_tokens ON storage.objects USING gin(path_tokens);

-- Set table owners
ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;
ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

-- Grant permissions
GRANT ALL ON storage.buckets TO supabase_storage_admin, postgres;
GRANT ALL ON storage.objects TO supabase_storage_admin, postgres;

-- Create default bucket for marketplace images
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('images', 'images', true, 52428800) -- 50MB limit
ON CONFLICT (id) DO NOTHING;
