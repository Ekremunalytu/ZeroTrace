-- ZeroTrace Database Initialization Script
-- This script creates the initial database schema

\c zerotrace;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =============================================================================
-- EVENTS TABLE - Core event storage
-- =============================================================================
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    source_service VARCHAR(100) NOT NULL,
    hostname VARCHAR(255) NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_source ON events(source_service);
CREATE INDEX IF NOT EXISTS idx_events_hostname ON events(hostname);
CREATE INDEX IF NOT EXISTS idx_events_data_gin ON events USING GIN(data);

-- =============================================================================
-- MALWARE HASHES TABLE - 800K hash database
-- =============================================================================
CREATE TABLE IF NOT EXISTS malware_hashes (
    id SERIAL PRIMARY KEY,
    hash_value VARCHAR(64) UNIQUE NOT NULL,
    hash_type VARCHAR(10) NOT NULL CHECK (hash_type IN ('md5', 'sha1', 'sha256')),
    threat_name VARCHAR(255),
    family VARCHAR(100),
    severity VARCHAR(20) DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    source VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for hash lookup performance
CREATE UNIQUE INDEX IF NOT EXISTS idx_malware_hash_value ON malware_hashes(hash_value);
CREATE INDEX IF NOT EXISTS idx_malware_hash_type ON malware_hashes(hash_type);
CREATE INDEX IF NOT EXISTS idx_malware_family ON malware_hashes(family);
CREATE INDEX IF NOT EXISTS idx_malware_severity ON malware_hashes(severity);

-- =============================================================================
-- ALERTS TABLE - Analysis results and alerts
-- =============================================================================
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    source_event_id UUID REFERENCES events(id),
    hostname VARCHAR(255) NOT NULL,
    data JSONB NOT NULL,
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'investigating', 'resolved', 'false_positive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for alert management
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON alerts(severity);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alerts_created ON alerts(created_at);
CREATE INDEX IF NOT EXISTS idx_alerts_hostname ON alerts(hostname);
CREATE INDEX IF NOT EXISTS idx_alerts_type ON alerts(alert_type);

-- =============================================================================
-- YARA MATCHES TABLE - YARA scan results
-- =============================================================================
CREATE TABLE IF NOT EXISTS yara_matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rule_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_hash VARCHAR(64),
    match_data JSONB,
    hostname VARCHAR(255) NOT NULL,
    scan_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    event_id UUID REFERENCES events(id)
);

-- Indexes for YARA matches
CREATE INDEX IF NOT EXISTS idx_yara_rule_name ON yara_matches(rule_name);
CREATE INDEX IF NOT EXISTS idx_yara_file_hash ON yara_matches(file_hash);
CREATE INDEX IF NOT EXISTS idx_yara_hostname ON yara_matches(hostname);
CREATE INDEX IF NOT EXISTS idx_yara_timestamp ON yara_matches(scan_timestamp);

-- =============================================================================
-- VIRUSTOTAL RESULTS TABLE - VirusTotal API results
-- =============================================================================
CREATE TABLE IF NOT EXISTS virustotal_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_hash VARCHAR(64) UNIQUE NOT NULL,
    scan_result JSONB NOT NULL,
    positives INTEGER,
    total_scans INTEGER,
    scan_date TIMESTAMP WITH TIME ZONE,
    permalink VARCHAR(500),
    cached_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '7 days'
);

-- Indexes for VirusTotal results
CREATE UNIQUE INDEX IF NOT EXISTS idx_vt_file_hash ON virustotal_results(file_hash);
CREATE INDEX IF NOT EXISTS idx_vt_positives ON virustotal_results(positives);
CREATE INDEX IF NOT EXISTS idx_vt_cached_at ON virustotal_results(cached_at);
CREATE INDEX IF NOT EXISTS idx_vt_expires_at ON virustotal_results(expires_at);

-- =============================================================================
-- SYSTEM INFO TABLE - Host information
-- =============================================================================
CREATE TABLE IF NOT EXISTS system_info (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hostname VARCHAR(255) UNIQUE NOT NULL,
    os_name VARCHAR(100),
    os_version VARCHAR(100),
    architecture VARCHAR(50),
    cpu_info JSONB,
    memory_info JSONB,
    network_info JSONB,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    first_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for system info
CREATE UNIQUE INDEX IF NOT EXISTS idx_system_hostname ON system_info(hostname);
CREATE INDEX IF NOT EXISTS idx_system_os ON system_info(os_name);
CREATE INDEX IF NOT EXISTS idx_system_last_seen ON system_info(last_seen);

-- =============================================================================
-- TRIGGERS FOR AUTO-UPDATE
-- =============================================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to malware_hashes table
CREATE TRIGGER update_malware_hashes_updated_at 
    BEFORE UPDATE ON malware_hashes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update last_seen trigger for system_info
CREATE OR REPLACE FUNCTION update_last_seen()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_seen = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_system_info_last_seen 
    BEFORE UPDATE ON system_info 
    FOR EACH ROW EXECUTE FUNCTION update_last_seen();

-- =============================================================================
-- SAMPLE DATA FOR DEVELOPMENT
-- =============================================================================

-- Insert some sample malware hashes for testing
INSERT INTO malware_hashes (hash_value, hash_type, threat_name, family, severity, source) VALUES
('d41d8cd98f00b204e9800998ecf8427e', 'md5', 'Empty File', 'Test', 'low', 'manual'),
('adc83b19e793491b1c6ea0fd8b46cd9f32e592fc', 'sha1', 'Hello World', 'Test', 'low', 'manual'),
('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'sha256', 'Empty SHA256', 'Test', 'low', 'manual')
ON CONFLICT (hash_value) DO NOTHING;

-- Insert sample system info
INSERT INTO system_info (hostname, os_name, os_version, architecture) VALUES
('dev-machine', 'Ubuntu', '22.04', 'x86_64')
ON CONFLICT (hostname) DO UPDATE SET 
    last_seen = NOW();

COMMIT;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO zerotrace;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO zerotrace;
