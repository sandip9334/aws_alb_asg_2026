

# AWS Application Load Balancer + Auto Scaling Group

This repository provisions an **AWS Application Load Balancer (ALB)** in front of an **Auto Scaling Group (ASG)** running Amazon Linux 2 web servers.

The infrastructure is deployed across **two default subnets** in the **default VPC**. Each EC2 instance runs Apache and serves a custom HTML page containing live EC2 instance metadata retrieved using **IMDSv2**.

## Architecture

```text
                         Internet
                            |
                            | HTTP :80
                            v
                  +---------------------+
                  | Application Load    |
                  | Balancer            |
                  +----------+----------+
                             |
                             | HTTP :80
                             v
                  +---------------------+
                  | Target Group        |
                  | Health Check: /     |
                  +----------+----------+
                             |
                +------------+------------+
                |                         |
                v                         v
        +---------------+         +---------------+
        | EC2 Instance  |         | EC2 Instance  |
        | Amazon Linux 2|         | Amazon Linux 2|
        | Apache        |         | Apache        |
        +---------------+         +---------------+
                ^                         ^
                |                         |
                +-----------+-------------+
                            |
                    Auto Scaling Group
                    Min: 2 | Desired: 2
```

---

## What Gets Created

Terraform creates the following AWS resources:

* 🌐 Internet-facing **Application Load Balancer**
* 🔀 **ALB Listener** on HTTP port `80`
* 🎯 **Target Group** with HTTP health checks
* ⚖️ **Auto Scaling Group**
* 🖥️ **Amazon Linux 2 EC2 instances**
* 🚀 **EC2 Launch Template**
* 🔐 **ALB Security Group**
* 🔐 **Web Server Security Group**
* 📈 **CPU-based Auto Scaling Policy**
* 📄 Apache web server using `user_data.sh`

### Security Model

The traffic flow is:

```text
Internet
   |
   | HTTP :80
   v
ALB Security Group
   |
   | HTTP :80
   v
EC2/Web Security Group
   |
   v
Apache
```

The EC2 instances **do not allow HTTP traffic directly from the internet**. Port `80` is allowed only from the ALB security group.

---

# Prerequisites

Before deploying this project, install:

* [Terraform](https://developer.hashicorp.com/terraform/install)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* An AWS account
* AWS credentials with appropriate permissions
* A default VPC
* At least two default subnets in the selected AWS region

---

# 1. Install Terraform

## macOS

Using Homebrew:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Verify:

```bash
terraform version
```

---

## Windows

Using Winget:

```powershell
winget install Hashicorp.Terraform
```

Verify:

```powershell
terraform version
```

---

## Ubuntu / Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```bash
sudo apt update
sudo apt install terraform
```

Verify:

```bash
terraform version
```

This project requires:

```text
Terraform >= 1.5
```

---

# 2. Install AWS CLI

## macOS

```bash
brew install awscli
```

## Windows

```powershell
winget install Amazon.AWSCLI
```

## Ubuntu / Debian

```bash
sudo apt update
sudo apt install awscli
```

Verify:

```bash
aws --version
```

---

# 3. Configure AWS Credentials

Configure the AWS CLI:

```bash
aws configure
```

Provide:

```text
AWS Access Key ID:
AWS Secret Access Key:
Default region name:
Default output format:
```

For example:

```text
Default region name: us-east-1
Default output format: json
```

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

Example:

```json
{
  "UserId": "XXXXXXXXXXXX",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

> **Security:** Never commit AWS access keys, secret keys, or other credentials to GitHub.

---

# 4. Clone the Repository

```bash
git clone https://github.com/sandip9334/aws_alb_asg_2026.git
```

Move into the project:

```bash
cd aws_alb_asg_2026
```

---

# 5. Configure Terraform Variables

Copy the sample variables file:

```bash
cp terraform.tfvars.sample terraform.tfvars
```

Example:

```hcl
region        = "us-east-1"
instance_type = "t2.micro"
```

Adjust the values according to your AWS environment.

---

# 6. Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

Terraform will download the required AWS provider and initialize the project.

---

# 7. Format and Validate

Format the Terraform files:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

# 8. Review the Deployment Plan

Before creating resources, review the Terraform plan:

```bash
terraform plan
```

Check the resources Terraform plans to create.

---

# 9. Deploy the Infrastructure

Deploy the infrastructure:

```bash
terraform apply
```

Enter:

```text
yes
```

when prompted.

For automated deployment:

```bash
terraform apply -auto-approve
```

Terraform will create:

```text
ALB
   ↓
Target Group
   ↓
Auto Scaling Group
   ↓
EC2 Instances
   ↓
Apache
```

---

# 10. Access the Application

After Terraform completes, retrieve the ALB DNS name:

```bash
terraform output
```

You should see an output similar to:

```text
alb_dns_name = "app-alb-123456789.us-east-1.elb.amazonaws.com"
```

Open:

```text
http://app-alb-123456789.us-east-1.elb.amazonaws.com
```

You can also test from the command line:

```bash
curl http://<ALB-DNS-NAME>
```

The application displays information about the EC2 instance serving the request.

---

# 11. Instance Metadata

The web page retrieves EC2 metadata using **IMDSv2**.

The page can display:

* Instance ID
* AMI ID
* Instance type
* Hostname
* Public IP address

The metadata is retrieved dynamically when the instance is initialized.

Example:

```bash
TOKEN=$(curl -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
```

Then the token is used to retrieve metadata securely through IMDSv2.

---

# 12. Auto Scaling

The Auto Scaling Group is configured with:

```text
Minimum: 2
Desired: 2
Maximum: 2
```

The instances are distributed across two subnets.

The project also includes CPU-based target tracking.

Example:

```text
Target CPU utilization: 50%
```

When additional capacity is required, the Auto Scaling Group can launch additional instances, subject to the configured maximum.

---

# 13. Target Group Health Check

The ALB Target Group performs HTTP health checks against:

```text
/
```

Configuration:

```text
Protocol: HTTP
Port: 80
Path: /
Healthy codes: 200-399
```

Check target health using AWS CLI:

```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET-GROUP-ARN> \
  --region us-east-1
```

Healthy targets should report:

```text
State: healthy
```

---

# 14. Troubleshooting

## ALB DNS Name Does Not Load

Check the ALB state:

```bash
aws elbv2 describe-load-balancers \
  --names app-alb \
  --region us-east-1 \
  --query 'LoadBalancers[0].[DNSName,State.Code,State.Reason]'
```

The expected state is:

```text
active
```

---

## Target Is Unhealthy

Check:

```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET-GROUP-ARN> \
  --region us-east-1
```

If the target is `unhealthy`, connect to the EC2 instance and check Apache:

```bash
sudo systemctl status httpd
```

Check whether Apache is listening on port 80:

```bash
sudo ss -lntp | grep :80
```

Test locally:

```bash
curl http://localhost
```

---

## Check User Data

The EC2 user-data script is:

```text
user_data.sh
```

Check cloud-init output:

```bash
sudo cat /var/log/cloud-init-output.log
```

You can also check:

```bash
sudo cat /var/log/cloud-init.log
```

---

## Website Displays the Bash Script

If the browser displays:

```text
#!/bin/bash
yum install -y httpd
...
```

instead of the HTML page, check `user_data.sh`.

The HTML must be created using a single heredoc:

```bash
cat > /var/www/html/index.html <<EOF

<!DOCTYPE html>
<html>
...
</html>

EOF
```

Do **not** place another `#!/bin/bash` or another `cat <<EOF` inside the HTML heredoc.

---

# 15. Updating User Data

The Launch Template uses:

```hcl
user_data = filebase64("${path.module}/user_data.sh")
```

User data normally runs when a new EC2 instance is launched.

If you modify `user_data.sh`, existing EC2 instances may not automatically execute the new script.

You can update the infrastructure with:

```bash
terraform plan
```

```bash
terraform apply
```

If necessary, replace the existing ASG instances so they launch using the updated Launch Template.

---

# 16. Useful Terraform Commands

| Command                | Description                    |
| ---------------------- | ------------------------------ |
| `terraform init`       | Initialize Terraform           |
| `terraform fmt`        | Format Terraform files         |
| `terraform validate`   | Validate configuration         |
| `terraform plan`       | Preview infrastructure changes |
| `terraform apply`      | Create/update infrastructure   |
| `terraform output`     | Display Terraform outputs      |
| `terraform state list` | List managed resources         |
| `terraform show`       | Display Terraform state        |
| `terraform destroy`    | Delete infrastructure          |

---

# 17. Cleanup

To remove all resources created by this project:

```bash
terraform destroy
```

Or:

```bash
terraform destroy -auto-approve
```

> **Warning:** `terraform destroy` deletes the AWS resources managed by this Terraform configuration.

---

# Repository Layout

```text
.
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
├── terraform.tfvars.sample
├── .gitignore
└── README.md
```

---

# Technologies Used

* **Terraform**
* **AWS EC2**
* **Amazon Linux 2**
* **Application Load Balancer**
* **Auto Scaling Group**
* **Elastic Load Balancing**
* **AWS Security Groups**
* **AWS CLI**
* **Apache HTTP Server**
* **EC2 Instance Metadata Service v2 (IMDSv2)**

---

# Learning Objectives

This project demonstrates practical Infrastructure as Code and AWS architecture concepts:

* Infrastructure as Code using Terraform
* Terraform providers and resources
* AWS networking fundamentals
* Application Load Balancing
* Auto Scaling Groups
* EC2 Launch Templates
* Target Groups and health checks
* Security Group design
* EC2 user data
* IMDSv2
* Apache web server deployment
* CPU-based Auto Scaling
* Infrastructure troubleshooting
* Terraform lifecycle and state management

---



Built as a hands-on AWS and Terraform demonstration for learning, workshops, and cloud infrastructure practice.
