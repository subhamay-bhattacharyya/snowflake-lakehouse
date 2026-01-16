-- ============================================================================
-- Raw Database Schemas
-- Description: Create schemas within raw database
-- ============================================================================

USE DATABASE RAW_DB;

CREATE SCHEMA IF NOT EXISTS sales
  COMMENT = 'Raw sales data from source systems';

CREATE SCHEMA IF NOT EXISTS marketing
  COMMENT = 'Raw marketing data from source systems';

CREATE SCHEMA IF NOT EXISTS finance
  COMMENT = 'Raw finance data from source systems';
