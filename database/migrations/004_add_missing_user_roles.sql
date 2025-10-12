-- Migration: Add missing user roles
-- Add KANRININSHA and CONTRACT_WORKER to user_role enum

-- Add new enum values
ALTER TYPE user_role ADD VALUE 'KANRININSHA';
ALTER TYPE user_role ADD VALUE 'CONTRACT_WORKER';

-- Verify the enum values
-- SELECT unnest(enum_range(NULL::user_role));