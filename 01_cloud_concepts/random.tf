# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer
# You need to create a random integer below this comment
resource "random_integer" "random" {
  min = 10
  max = 20
}

# You need to create a Terraform output of the result of your random integer below this comment
output "random_integer" {
  value = random_integer.random.result
}

