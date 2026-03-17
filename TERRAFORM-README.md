# AWS DevOps EC2 Stack (Jenkins + Docker + k3s)

This Terraform stack provisions one Ubuntu EC2 instance and bootstraps:

- Jenkins (port 8080)
- Java 17 runtime for Jenkins
- Docker Engine + Buildx
- k3s Kubernetes cluster (single-node)

The app is expected to be built into a Docker image, pushed to Docker Hub, then deployed to k3s from Jenkins.
This active profile is optimized for the current static site.

## Files

- `providers.tf`: Terraform + AWS provider config
- `variables.tf`: tunable inputs
- `main.tf`: EC2 + security group
- `templates/user_data.sh.tftpl`: first-boot installation script
- `outputs.tf`: endpoint URLs and helper outputs
- `terraform.tfvars.example`: sample variable values

## Prerequisites

1. AWS account and credentials configured locally.
2. Terraform 1.5+.

An existing EC2 key pair is no longer required by default. Terraform can generate one automatically and save the PEM file in this workspace.

## Deploy

```bash
# Run from the health workspace root
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars for your preferred CIDRs and generated_key_name if needed

terraform init
terraform plan
terraform apply -auto-approve
```

PowerShell alternative for the copy step:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

## Access After Apply

Use Terraform outputs:

- `jenkins_url`
- `k8s_app_url`
- `ssh_command`
- `generated_private_key_file`
- `key_pair_name`

Get initial Jenkins admin password on the instance:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Jenkins Configuration

Create this Jenkins credential:

1. `dockerhub-creds` as Username with password.

Then create a Pipeline job from SCM using repository `Jenkinsfile`.

## App Build and Deploy Flow

1. Jenkins validates that the static-site deployment files exist.
2. Jenkins builds the Docker image and pushes it to Docker Hub.
3. Jenkins applies `k8s/health-app.yaml` to k3s and rolls out pods.

## Future Java CI Profile

If you later deploy a Java app with `pom.xml`, use the preserved example files instead of this lean profile:

- `templates/user_data.java-ci.sh.tftpl`
- `Jenkinsfile.java-ci.example`

Those files retain the heavier toolchain with JDK, Maven, SonarQube, Docker, and k3s.

## Notes

- This repository is a static web app template, so the active deployment intentionally excludes Maven and SonarQube to keep instance cost lower.
- Restrict `allowed_ssh_cidr` and `allowed_ingress_cidr` for production use.
- `t2.medium` is a reasonable low-cost starting point for the current static-site stack.
- If you switch to the future Java CI profile, increase instance size and storage again before provisioning.
- When `create_key_pair = true`, Terraform writes a PEM file to this workspace. Keep that file private and do not share it.