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

-- Grant MANAGE GRANTS privilege to SYSADMIN
-- This allows SYSADMIN to grant privileges to other roles like PUBLIC
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE SYSADMIN;

-- Transfer database ownership to SYSADMIN (if database already exists)
GRANT OWNERSHIP ON DATABASE LAKEHOUSE_DB TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- Transfer all schema ownership to SYSADMIN (if schemas already exist)
GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE LAKEHOUSE_DB TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- Verify grants
SHOW GRANTS TO ROLE SYSADMIN;

-- Verify ownership transfer
SHOW GRANTS ON DATABASE LAKEHOUSE_DB;

-- Confirm SYSADMIN now has proper privileges
SELECT 'Setup complete - SYSADMIN can now manage grants and owns LAKEHOUSE_DB' AS status;
