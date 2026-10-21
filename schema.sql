-- =================================────────────────===========================
-- SYSTEM ARCHITECTURE: INDUSTRIAL FIELD OPERATIONS & DATA GOVERNANCE SCHEMA
-- PLATFORM TARGET: POSTGRESQL (COMPATIBLE WITH GCP BIGQUERY / ENTERPRISE CLOUD)
-- ARCHITECT: ANGELIQUE GREYLING (PRINCIPAL SOLUTIONS ENGINEER)
-- DESIGN PATTERN: HIGH-PERFORMANCE FAULT-TOLERANT DIMENSIONAL STAR SCHEMA
-- =================================────────────────===========================

-- ----------------------------------------------------------------------------
-- 1. DIMENSION TABLES (SHARED MODEL SEMANTIC LAYER)
-- ----------------------------------------------------------------------------

-- dim_employees: Stores immutable identity profiles, organizational teams, and labor rates.
CREATE TABLE dim_employees (
    employee_key SERIAL PRIMARY KEY,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    operational_team VARCHAR(100) NOT NULL,
    specialist_role VARCHAR(100) NOT NULL,
    employment_tier VARCHAR(50) NOT NULL,
    hourly_rate_zar NUMERIC(10, 2) NOT NULL,
    is_active_status BOOLEAN DEFAULT TRUE,
    record_created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_employees IS 'Master dimension table storing verified field technician master profiles and core billing rates.';

-- ----------------------------------------------------------------------------
-- 2. FACT TABLES (DECOUPLED LOGISTICS TRANSACTIONAL LAYERS)
-- ----------------------------------------------------------------------------

-- fact_time_logs: Stores chronological clock-in/out records with geographic verification flags.
CREATE TABLE fact_time_logs (
    time_log_key SERIAL PRIMARY KEY,
    time_log_id VARCHAR(50) UNIQUE NOT NULL,
    employee_id VARCHAR(50) REFERENCES dim_employees(employee_id),
    clock_in_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    clock_out_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    raw_hours_worked NUMERIC(6, 2) NOT NULL,
    is_geo_verified BOOLEAN NOT NULL DEFAULT FALSE,
    ingestion_source VARCHAR(50) DEFAULT 'Connecteam_API_Export',
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_hours_integrity CHECK (raw_hours_worked >= 0 AND raw_hours_worked <= 24)
);

COMMENT ON TABLE fact_time_logs IS 'Fact table capturing transactional clock metrics used to feed workforce compliance and overtime calculations.';

-- fact_asset_checklists: Stores automated daily equipment inspection data maps from staging containers.
CREATE TABLE fact_asset_checklists (
    checklist_key SERIAL PRIMARY KEY,
    submission_id VARCHAR(50) UNIQUE NOT NULL,
    employee_id VARCHAR(50) REFERENCES dim_employees(employee_id),
    inspection_date DATE NOT NULL,
    asset_tag_identifier VARCHAR(50) NOT NULL,
    asset_type_classification VARCHAR(100) NOT NULL,
    is_system_issue_found BOOLEAN NOT NULL DEFAULT FALSE,
    photo_evidence_count INT NOT NULL DEFAULT 0,
    staging_proxy_source VARCHAR(100) DEFAULT 'Async_Apps_Script_Sandbox',
    inserted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_photo_count CHECK (photo_evidence_count >= 0)
);

COMMENT ON TABLE fact_asset_checklists IS 'Fact table capturing structured asset compliance states. Populated asynchronously via scripting perimeters.';

-- fact_quick_tasks: Stores ad-hoc work orders and tracks operational throughput against SLAs.
CREATE TABLE fact_quick_tasks (
    task_key SERIAL PRIMARY KEY,
    task_identifier VARCHAR(50) UNIQUE NOT NULL,
    assigned_employee_id VARCHAR(50) REFERENCES dim_employees(employee_id),
    created_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_timestamp TIMESTAMP WITH TIME ZONE,
    task_priority_tier VARCHAR(30) NOT NULL,
    operational_site_label VARCHAR(150) NOT NULL,
    current_status VARCHAR(50) NOT NULL DEFAULT 'Open',
    last_modified_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE fact_quick_tasks IS 'Fact table monitoring task closure velocity, backlogs, and structural SLA response windows.';

-- ----------------────────────────────────────────────────────────------------
-- 3. ARCHITECTURAL PERFORMANCE TUNING & DirectQuery OPTIMIZATION INDEXES
-- ----------------------------------------------------------------------------

-- Indexes designed to enforce instant filtering for Power BI composite model aggregations,
-- ensuring DirectQuery lookups hit optimized B-Tree parameters instead of raw table scans.

CREATE INDEX idx_timelogs_employee ON fact_time_logs(employee_id);
CREATE INDEX idx_timelogs_dates ON fact_time_logs(clock_in_timestamp);

CREATE INDEX idx_checklists_asset ON fact_asset_checklists(asset_type_classification);
CREATE INDEX idx_checklists_date ON fact_asset_checklists(inspection_date);

CREATE INDEX idx_tasks_status ON fact_quick_tasks(current_status);
CREATE INDEX idx_tasks_dates ON fact_quick_tasks(created_timestamp);

-- ============================================================================
-- END OF STORAGE GOVERNANCE SCHEMA SCRIPT
-- ============================================================================
