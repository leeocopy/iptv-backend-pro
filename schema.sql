-- SQL Script to create the users table for Vercel Postgres

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    device_id TEXT UNIQUE NOT NULL,
    trial_start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_paid BOOLEAN DEFAULT FALSE
);

-- Optional: Index on device_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_device_id ON users(device_id);
