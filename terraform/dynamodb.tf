resource "aws_dynamodb_table" "product_catalog_table" {
  name         = "ce-grp-2-product-catalog-tf"
  billing_mode = "PAY_PER_REQUEST" # Or "PROVISIONED"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Name        = "ce-grp-2-product-catalog-table-tf"
  }
}

resource "aws_dynamodb_table" "product_orders_table" {
  name         = "ce-grp-2-product-orders-tf"
  billing_mode = "PAY_PER_REQUEST" # Or "PROVISIONED"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Name        = "ce-grp-2-product_orders-table-tf"
  }
}
