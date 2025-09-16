terraform {
  required_version = ">= 1.0"
#без явного указания версии aws-библиотеки не работает через гитхаб  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
