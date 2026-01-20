# Example usage of the Snowflake nested module structure

warehouses = {
  load_wh = {
    name         = "LOAD_WH"
    size         = "Small"
    auto_suspend = 60
    auto_resume  = true
    comment      = "Warehouse for data loading operations"
  }
  transform_wh = {
    name         = "TRANSFORM_WH"
    size         = "Medium"
    auto_suspend = 120
    auto_resume  = true
    comment      = "Warehouse for data transformation"
  }
}

databases = {
  lakehouse = {
    name    = "LAKEHOUSE"
    comment = "Main lakehouse database"
    schemas = [
      {
        name    = "RAW"
        comment = "Raw data layer"
      },
      {
        name    = "STAGING"
        comment = "Staging data layer"
      },
      {
        name    = "ANALYTICS"
        comment = "Analytics data layer"
      }
    ]
  }
}

storage_integrations = {
  s3_integration = {
    name                      = "S3_INTEGRATION"
    storage_provider          = "S3"
    storage_allowed_locations = ["s3://my-bucket/data/"]
    storage_aws_role_arn      = "arn:aws:iam::123456789012:role/snowflake-s3-role"
    comment                   = "S3 storage integration for data ingestion"
  }
}

stages = {
  sales_stage = {
    name                     = "SALES_STAGE"
    database                 = "LAKEHOUSE"
    schema                   = "RAW"
    url                      = "s3://my-bucket/data/sales/"
    storage_integration_name = "S3_INTEGRATION"
    comment                  = "External stage for sales data"
  }
}

pipes = {
  sales_pipe = {
    name           = "SALES_PIPE"
    database       = "LAKEHOUSE"
    schema         = "RAW"
    copy_statement = "COPY INTO LAKEHOUSE.RAW.SALES_TABLE FROM @LAKEHOUSE.RAW.SALES_STAGE FILE_FORMAT = (TYPE = 'CSV')"
    auto_ingest    = true
    comment        = "Auto-ingest pipe for sales data"
  }
}
