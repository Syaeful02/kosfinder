-- ====================================================================
-- Migration: 001_init.sql
-- Description: Inisialisasi tabel listings dan Row Level Security (RLS)
-- ====================================================================

-- 1. Buat Tabel Listings
CREATE TABLE IF NOT EXISTS public.listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    price_per_month BIGINT NOT NULL CHECK (price_per_month > 0),
    type VARCHAR(20) NOT NULL CHECK (type IN ('Putra', 'Putri', 'Campur')),
    address TEXT NOT NULL,
    facilities VARCHAR(200) NOT NULL CHECK (char_length(facilities) >= 1 AND char_length(facilities) <= 200),
    whatsapp_number VARCHAR(20) NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Buat Indeks untuk Optimasi Query Pencarian, Filter Harga, dan Sorting
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON public.listings (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_listings_price ON public.listings (price_per_month);
CREATE INDEX IF NOT EXISTS idx_listings_owner_id ON public.listings (owner_id);

-- 3. Aktifkan Row Level Security (RLS)
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;

-- 4. Definisi Kebijakan Akses (RLS Policies)

-- A. SELECT: Terbuka untuk umum (guest maupun authenticated)
CREATE POLICY "Public read access for listings"
ON public.listings
FOR SELECT
TO public
USING (true);

-- B. INSERT: Hanya pemilik akun terautentikasi yang dapat menambah kos miliknya
CREATE POLICY "Authenticated owners can insert listings"
ON public.listings
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

-- C. UPDATE: Hanya pemilik kos yang dapat mengubah kos miliknya
CREATE POLICY "Owners can update their own listings"
ON public.listings
FOR UPDATE
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- D. DELETE: Hanya pemilik kos yang dapat menghapus kos miliknya
CREATE POLICY "Owners can delete their own listings"
ON public.listings
FOR DELETE
TO authenticated
USING (auth.uid() = owner_id);

-- 5. Trigger Pembaruan Otomatis Kolom updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_listings_updated_at ON public.listings;
CREATE TRIGGER trigger_listings_updated_at
BEFORE UPDATE ON public.listings
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();
