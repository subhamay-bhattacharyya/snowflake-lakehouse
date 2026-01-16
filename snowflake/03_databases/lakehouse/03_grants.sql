-- ============================================================================
-- Analytics Database Grants
-- Description: Grant permissions on analytics database
-- ============================================================================

-- Failsafe: Ensure database exists before granting permissions
CREATE DATABASE IF NOT EXISTS LAKEHOUSE_DB
    COMMENT = 'Lakehouse database following medallion architecture for analytics workloads';

-- Transfer ownership to SYSADMIN role
-- This ensures SYSADMIN has full control over the database and can grant privileges
GRANT OWNERSHIP ON DATABASE LAKEHOUSE_DB TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- Failsafe: Ensure schemas exist before granting permissions
USE DATABASE LAKEHOUSE_DB;

CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Raw data layer - unprocessed data from source systems';

CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Cleansed data layer - validated and standardized data';

CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Curated data layer - business-ready aggregates and analytics';

CREATE SCHEMA IF NOT EXISTS STREAMLIT
    COMMENT = 'Application layer - objects for Streamlit dashboards and apps';

-- Transfer ownership of all schemas to SYSADMIN
GRANT OWNERSHIP ON SCHEMA BRONZE TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA SILVER TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA GOLD TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON SCHEMA STREAMLIT TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- ============================================================================
-- PUBLIC Role Grants
-- Description: Grant read-only access to PUBLIC role for analytics consumption
-- ============================================================================

-- Grant database access to PUBLIC role
-- Allows all users to see and access the lakehouse database
GRANT USAGE ON DATABASE LAKEHOUSE_DB TO ROLE PUBLIC;

-- Grant schema access to PUBLIC role
-- Allows all users to see and access all schemas (Bronze, Silver, Gold, Streamlit)
GRANT USAGE ON ALL SCHEMAS IN DATABASE LAKEHOUSE_DB TO ROLE PUBLIC;

-- Grant read access on existing tables to PUBLIC role
-- Allows all users to query all current tables across all schemas
GRANT SELECT ON ALL TABLES IN DATABASE LAKEHOUSE_DB TO ROLE PUBLIC;

-- Grant read access on future tables to PUBLIC role
-- Automatically grants SELECT on any new tables created in the future
-- Ensures consistent read access without manual grant management
GRANT SELECT ON FUTURE TABLES IN DATABASE LAKEHOUSE_DB TO ROLE PUBLIC; 