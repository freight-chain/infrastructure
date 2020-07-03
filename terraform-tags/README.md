# Terraform

> freighttrust.com

> security@freighttrust.com


## Overivew

Standard Terraform Boilerplate for Corporate Use.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.14 |

## Providers

No provider.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Moniker to apply to all resources in the module | `string` | n/a | yes |
| tags | User-Defined tags | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| tags\_module | Tags Module in it's entirety |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Packages

- [pre-commit](- pre-commit.com/)
- [tfutils](github.com/tfutils/tfenv)
- [tflint](https://github.com/terraform-linters/tflint)
- [other-pkgs]



### Basic Example

[main.tf](./main.tf)


```terraform

module "example" {
  source = "../.."

  name = "test"
}

output "example" {
  value = module.example
}
```

#### Applying

```bash
$  terraform apply
```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

```terraform
example = {
  "tags_module" = {
    "name" = "TEST"
    "name32" = "TEST"
    "name6" = "TEST"
    "namenosymbols" = "TEST"
    "tags" = {
      "Name" = "TEST"
      "terraform_managed" = true
      "terraform_module" = "terraform-terraform-tags-1.0.0"
      "terraform_root_module" = "."
      "terraform_workspace" = "default"
    }
    "tags_as_list_of_maps" = [
      {
        "key" = "Name"
        "value" = "TEST"
      },
      {
        "key" = "terraform_managed"
        "value" = true
      },
      {
        "key" = "terraform_module"
        "value" = "terraform-terraform-tags-1.0.0"
      },
      {
        "key" = "terraform_root_module"
        "value" = "."
      },
      {
        "key" = "terraform_workspace"
        "value" = "default"
      },
    ]
    "tags_no_name" = {
      "terraform_managed" = true
      "terraform_module" = "terraform-terraform-tags-1.0.0"
      "terraform_root_module" = "."
      "terraform_workspace" = "default"
    }
  }
}
```