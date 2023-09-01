# Firstly create a random generated password to use in secrets.
 
resource "random_password" "postgress_serverless_db_password" {
  length           = 16
  special          = true
  override_special = "_%@#"
}
 
# Creating a AWS secret for database master account (Masteraccoundb)
 
resource "aws_secretsmanager_secret" "secretmasterDB" {
   name = "${local.name}-postgress-db"
   description = "${local.name}-postgress-db secret"
}
 
# Creating a AWS secret versions for database master account (Masteraccoundb)
 
resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.secretmasterDB.id
  secret_string = <<EOF
   {
    "username": "root",
    "password": "${random_password.postgress_serverless_db_password.result}"
   }
EOF
}
# Importing the AWS secrets created previously using arn.
 
data "aws_secretsmanager_secret" "secretmasterDB" {
  arn = aws_secretsmanager_secret.secretmasterDB.arn
}
 
# Importing the AWS secret version created previously using arn.
 
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.secretmasterDB.arn
}
 
# After importing the secrets storing into Locals
 
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

resource "kubernetes_secret" "my_secret" {
  metadata {
    name = "database-secrets"
  }

  data = {
    username = local.db_creds.username
    password = local.db_creds.password
  }

  type = "Opaque"
}



#  username             = jsondecode(data.aws_secretsmanager_secret_version.secret_credentials.secret_string)["db_username"]
#  password             = jsondecode(data.aws_secretsmanager_secret_version.secret_credentials.secret_string)["db_password"]