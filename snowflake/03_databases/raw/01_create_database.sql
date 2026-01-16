-- ============================================================================
-- Raw Database
-- Description: Raw data ingested from source systems
-- ============================================================================

CREATE DATABASE IF NOT EXISTS RAW_DB
  DATA_RETENTION_TIME_IN_DAYS = 7
  COMMENT = 'Raw data ingested from source systems';

USE DATABASE RAW_DB;
