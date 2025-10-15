-- Migration: Add detailed address fields to candidates table
-- Date: 2025-10-15
-- Purpose: Add separate fields for address components (banchi, building)

-- Add new address fields to candidates table
ALTER TABLE candidates 
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS address_banchi VARCHAR(100),
ADD COLUMN IF NOT EXISTS address_building VARCHAR(100);

-- Add index for postal code lookup
CREATE INDEX IF NOT EXISTS idx_candidates_postal_code ON candidates(postal_code);

-- Add comment for documentation
COMMENT ON COLUMN candidates.address IS 'Main address (from postal code lookup)';
COMMENT ON COLUMN candidates.address_banchi IS 'Address number/banchi (番地)';
COMMENT ON COLUMN candidates.address_building IS 'Building/apartment name (アパートなど)';

-- Update existing records to populate address field from current_address
UPDATE candidates 
SET address = current_address 
WHERE address IS NULL AND current_address IS NOT NULL;