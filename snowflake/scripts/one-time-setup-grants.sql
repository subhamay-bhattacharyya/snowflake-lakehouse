-- ============================================================================
-- ONE-TIME SETUP: Database Ownership Transfer
-- Description: Run this ONCE as ACCOUNTADMIN to transfer ownership to SYSADMIN
-- ============================================================================
-- 
-- INSTRUCTIONS:
-- 1. Log into Snowflake as ACCOUNTADMIN
-- 2. Run this entire script
-- 3. After this, your GitHub Actions workflow will work with SYSADMIN role
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Transfer database ownership to SYSADMIN
GRANT OWNERSHIP ON DATABASE LAKEHOUSE_DB TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- Transfer all schema ownership to SYSADMIN
GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE LAKEHOUSE_DB TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- Verify ownership transfer
SHOW GRANTS ON DATABASE LAKEHOUSE_DB;
SHOW GRANTS ON SCHEMA LAKEHOUSE_DB.BRONZE;
SHOW GRANTS ON SCHEMA LAKEHOUSE_DB.SILVER;
SHOW GRANTS ON SCHEMA LAKEHOUSE_DB.GOLD;
SHOW GRANTS ON SCHEMA LAKEHOUSE_DB.STREAMLIT;

-- Confirm SYSADMIN now owns the database
SELECT 'Ownership transfer complete - SYSADMIN now owns LAKEHOUSE_DB' AS status;
