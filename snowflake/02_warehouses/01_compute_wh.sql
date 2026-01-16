-- ============================================================================
-- Compute Warehouse
-- Description: General purpose compute warehouse
-- ============================================================================

CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH_1
  WITH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 2
  SCALING_POLICY = 'STANDARD'
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'General purpose compute warehouse for queries and analysis';
