# Regnal

> Certificate Managment Microservice 

* AWS to host the service
* Puppet for machine-level provisioning
* Terraform to configure the infrastructure
* Envoy to handle TLS termination
* step certificates & step SDS for certificate management

## Microservices Deployment Architecture


```
          +--------------+
          |    BROWSER   |
          +------+-------+
                 |
                 |TLS
                 |
          +------+-------+
          |    ENVOY     |
          |      |       |                 +------------+
          |     WEB      |                 |            |
          |      |       |    TLS+mTLS     |     CA     |
          |    ENVOY--SDS+-----------------+            |
          +------+-------+                 +-----+------+
                 |                               |
                 |                               |
                 |                               |TLS+mTLS
         mTLS    |   mTLS                        |
      +----------+----------+                    |
      |                     |                    |
      |                     |                    |
+-----+-------+       +-----+--------+           |
|   ENVOY     |       |   ENVOY      |           |
|     |       |       |              |           |
|   EMOJI--SDS|       |   VOTING--SDS+-----------+
+-----------+-+       +--------------+           |
            |                                    |
            |                                    |
            |                                    |
            +------------------------------------+
```

* Every service in the diagram above will run on its own dedicated VM (EC2 instance) in AWS.
* An Envoy sidecar proxy (ingress & egress) per service will handle mutual TLS (authentication & encryption).
* Envoy sidecars obtain certificates through the *[secret discovery service](https://www.envoyproxy.io/docs/envoy/latest/configuration/secret)* (step SDS) exposed via a local UNIX domain socket.
* Step SDS will fetch a certificate, as well as the trust bundle (root certificate), from the internal Certificate Authority (learn more at [step certificates](https://github.com/smallstep/certificates)) on behalf of each service/sidecar pair.
* Step SDS will handle renewals for certificates that are nearing the end of their lifetimes.


### AWS CLI

Install and configure the AWS CLI. Make sure the credentials granted the IAM policies `AmazonEC2FullAccess`, `AmazonVPCFullAccess`, and `AmazonRoute53FullAccess` (broad permissions) or at the minimum permissions as per the [policy file included in the repo](policy.json).

### Terraform

Terraform uses a backend (hosted by [Hashicorp](https://app.terraform.io/session)) to store state information about managed infrastrucutre as well as manage concurrency locks to allow only one team member to perform changes at a time. The CLI needs a user configuration as outlined below. Create a user account and org at [app.terraform.io](https://app.terraform.io/session) and grab a user token. For more details please see [Hashicorp's Terraform CLI docs](https://www.terraform.io/docs/commands/cli-config.html).

> Note: Terraform won't strictly require a backend when being used by a single developer/operator

```bash
$ cat ~/.terraformrc
credentials "app.terraform.io" {
  token = "<terraform user token goes here>"
}
```

Once the `~/.terraformrc` is in place the Terraform backends needs to be initialized. Before running the `init` command Terraform needs to be configured with the proper workplace, org, and ssh public key.

```bash
diff --git a/aws-regnal/regnal.tf b/aws-regnal/regnal.tf
index b510dcb..33ff92d 100644
--- a/aws-regnal/regnal.tf
+++ b/aws-regnal/regnal.tf
@@ -1,9 +1,9 @@
 terraform {
   backend "remote" {
-    organization = "Smallstep"
+    organization = "<my org>"

     workspaces {
-      name = "Emojivoto"
+      name = "<my workspace: e.g. Step-AWS-Integration>"
     }
   }
 }
@@ -17,7 +17,7 @@ provider "aws" {
 # Create an SSH key pair to connect to our instances
 resource "aws_key_pair" "terraform" {
   key_name   = "terraform-key"
-  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVEhUwiAivgdFuu5rOv8ArAMqTA6N56yd5RA+uHdaC0e4MM3TYhUOwox0fV+opE3OKLYdG2+mF/6Z4k8PgsBxLpJxdQ9XHut3A9WoqCEANVfZ7dQ0mgJs1MijIAbVg1kXgYTg/2iFN6FCO74ewAJAL2e8GqBDRkwIueKbphmO5U0mK3d/nnLK0QSFYgQGFGFHvXkeQKus+625IHifat/GTZZmhCxZBcAKzaAWB8dSaZGslaKsixy3EGiY5Gqdi5tQvt+obxZ59o4Jk352YlxhlUSxoxpeOyCiBZkexZgm+0MbeBrDuOMwg/tpcUiJ0/lVomx+dQuIX6ciKIuwnvDhx"
+  public_key = "<SSH Public Key, as in ~/.ssh/terraform.pub>"
 }

 variable "ami" {
```

Once AWS CLI and Terraform CLI & definitions are in place, we can initialize the workspace on the Terraform backend:

```bash
$ terraform init
Initializing the backend...
Backend configuration changed!

Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.


Successfully configured the backend "remote"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...

Terraform has been successfully initialized!
[...]
```

Now Terraform is ready to go. The `apply` command will print out a long execution plan of all the infrastructure that will be created. Terraform will prompt for a confirmation (type `yes`) before executing on the plan. Please note: The completion of this process can take some time.

```bash
$ terraform apply
Acquiring state lock. This may take a few moments...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
Acquiring state lock. This may take a few moments...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
Acquiring state lock. This may take a few moments...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.ca will be created
  + resource "aws_instance" "ca" {
      + ami                          = "ami-068670db424b01e9a"
      + arn                          = (known after apply)
      + associate_public_ip_address  = true
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "terraform-key"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name" = "regnal-ca"
        }
      + tenancy                      = (known after apply)

  [...]
    }

Plan: 21 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

Outputs

```bash
[...]
aws_instance.web (remote-exec): Info: Creating state file /var/cache/puppet/state/state.yaml
aws_instance.web (remote-exec): Notice: Applied catalog in 39.59 seconds
aws_instance.web (remote-exec): + sudo puppet agent --server puppet.regnal.local
aws_instance.web: Creation complete after 2m6s [id=i-0481e26a14f8f74b8]
aws_route53_record.web: Creating...
aws_route53_record.web: Still creating... [10s elapsed]
aws_route53_record.web: Still creating... [20s elapsed]
aws_route53_record.web: Still creating... [30s elapsed]
aws_route53_record.web: Still creating... [40s elapsed]
aws_route53_record.web: Creation complete after 47s [id=ZIAUV5309R860_web.regnal.local_A]

Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:

ca_ip = 13.57.209.0
emoji_ip = 54.183.41.170
puppet_ip = 54.183.255.218
voting_ip = 54.153.37.230
web_ip = 13.52.182.175
```

## Operations

Regnal will use internal DNS records to resolve hosts for inter-service communication. All TLS certificates are issued for (SANs) the respective DNS name, e.g. `web.regnal.local` or `voting.regnal.local` (please see [dns.tf](dns.tf) for details).

For this to work on machines without managed external DNS the hostname/IP address mapping needs to be added to `/etc/hosts` so that hostnames can be verified against server certificates.

```bash
$ cat /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
169.254.169.254 metadata.google.internal  # Added by Google

13.52.182.175    web.regnal.local
```

Regnal leverages an internal CA to secure communication between services so every client must specify the root certificate (`root_ca.crt`) of the internal CA to trust it explicitly.

### Using Step CLI

```
$ step certificate inspect --roots root_ca.crt --short https://web.regnal.local
X.509v3 TLS Certificate (ECDSA P-256) [Serial: 1993...2666]
  Subject:     web.regnal.local
  Issuer:      Smallstep Test Intermediate CA
  Provisioner: step-sds [ID: Z2S-...gK6U]
  Valid from:  2019-07-25T21:13:35Z
          to:  2019-07-26T21:13:35Z
```

### Using cURL

```bash
$ curl -I --cacert root_ca.crt https://web.regnal.local
HTTP/1.1 200 OK
content-type: text/html
date: Fri, 26 Jul 2019 00:27:02 GMT
content-length: 560
x-envoy-upstream-service-time: 0
server: envoy

# without --cacert specifying the root cert it will fail (expected)
$ curl -I root_ca.crt https://web.regnal.local
curl: (6) Could not resolve host: root_ca.crt
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl performs SSL certificate verification by default, using a "bundle"
 of Certificate Authority (CA) public keys (CA certs). If the default
 bundle file isn't adequate, you can specify an alternate file
 using the --cacert option.
[...]
```

### Using a browser

Navigating a browser to [`https://web.regnal.local/`](https://web.regnal.local/) will result in a big alert warning that **`Your connection is not private`**. The reason for the alert is `NET::ERR_CERT_AUTHORITY_INVALID` which a TLS error code. The error code means that the certificate path validation could not be verified against the locally known root certificates in the trust store. Since the TLS cert for the internal web service is **not** using `Public Web PKI` this is expected. Beware of these warnings. In this particular case where we're using an internal CA it's safe to `Proceed to web.regnal.local` under the `Advanced` menu.

It is possible to avoid the TLS warning by installing the internal CA's root certificate into your local trust store. The step CLI has a command to do exactly that:

```bash
$ sudo step certificate install root_ca.crt
Certificate root_ca.crt has been installed.
X.509v3 Root CA Certificate (ECDSA P-256) [Serial: 1038...4951]
  Subject:     Smallstep Test Root CA
  Issuer:      Smallstep Test Root CA
  Valid from:  2019-07-12T22:14:14Z
          to:  2029-07-09T22:14:14Z
# Navigate browser to https://web.regnal.local without warning
$ sudo step certificate uninstall root_ca.crt
Certificate root_ca.crt has been removed.
X.509v3 Root CA Certificate (ECDSA P-256) [Serial: 1038...4951]
  Subject:     Smallstep Test Root CA
  Issuer:      Smallstep Test Root CA
  Valid from:  2019-07-12T22:14:14Z
          to:  2029-07-09T22:14:14Z
# Remove root cert from local trust store. Warning will reappear
```

## Imprint
Many thanks to  [small step](https://github.com/smallstep) for producing parts of this imlpementation.

### License 

Apache 2.0 - (C) 2020 Freight Trust and Clearing