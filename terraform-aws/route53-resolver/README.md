# Route 53 Resolver & Rules

> Resolve and Forward to Specific Resources


## Overview

```
module "route53-resolver-ftcorp" {
  source            = "git::https://github.com/freight-trust/infra/terraform-route53-infra"
  associated_vpcs   = ["vpc-1234567"]
  forward_domain    = "proxy.freight.sh."
  forward_ips       = ["192.168.100.10", "192.168.100.11"]
  resolver_endpoint = module.route53-outbound.endpoint_id
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Terraform Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| associated\_vpcs | List of VPC IDs to associate rule to | list(string) | n/a | yes |
| forward\_domain | Domain name to forward requests for | string | n/a | yes |
| forward\_ips | List of IPs to forward DNS requests to | list(string) | n/a | yes |
| resolver\_endpoint | Resolver Endpoint ID | string | n/a | yes |
| resource\_share\_accounts | List of account IDs to share this resolver rule with | list(string) | `[]` | no |
| tags | Map of tags to apply to supported resources | map(string) | `{}` | no |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
