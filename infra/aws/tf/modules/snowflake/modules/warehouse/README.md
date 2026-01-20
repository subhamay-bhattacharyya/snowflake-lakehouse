# Snowflake Warehouse Sub-Module

This sub-module creates and manages Snowflake warehouses with full configuration support.

## Features

- Configurable warehouse size (X-SMALL to 6X-LARGE)
- Auto-suspend and auto-resume settings
- Query acceleration support
- Multi-cluster warehouse configuration
- Scaling policies (STANDARD or ECONOMY)
- Initially suspended option

## Usage

This module is typically called from the parent Snowflake module, but can be used standalone:

```hcl
module "warehouse" {
  source = "./modules/warehouse"

  name                      = "LOAD_WH"
  warehouse_size            = "X-SMALL"
  auto_suspend              = 60
  auto_resume               = true
  warehouse_type            = "STANDARD"
  comment                   = "Warehouse for data loading"
  enable_query_acceleration = false
  min_cluster_count         = 1
  max_cluster_count         = 1
  scaling_policy            = "STANDARD"
  initially_suspended       = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the warehouse | string | - | yes |
| warehouse_size | Size of the warehouse | string | "X-SMALL" | no |
| auto_suspend | Seconds of inactivity before suspension | number | 60 | no |
| auto_resume | Auto-resume on query submission | bool | true | no |
| warehouse_type | Type (STANDARD or SNOWPARK-OPTIMIZED) | string | "STANDARD" | no |
| comment | Comment for the warehouse | string | "" | no |
| enable_query_acceleration | Enable query acceleration | bool | false | no |
| min_cluster_count | Minimum cluster count | number | 1 | no |
| max_cluster_count | Maximum cluster count | number | 1 | no |
| scaling_policy | Scaling policy (STANDARD or ECONOMY) | string | "STANDARD" | no |
| initially_suspended | Initially suspended state | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| name | Name of the warehouse |
| id | ID of the warehouse |

## Warehouse Sizes

- X-SMALL
- SMALL
- MEDIUM
- LARGE
- X-LARGE
- 2X-LARGE
- 3X-LARGE
- 4X-LARGE
- 5X-LARGE
- 6X-LARGE

## Multi-Cluster Warehouses

For multi-cluster warehouses, set:
- `min_cluster_count` > 1
- `max_cluster_count` >= `min_cluster_count`
- `scaling_policy` = "STANDARD" or "ECONOMY"
