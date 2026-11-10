# Terraform Digital Sovereignty Assignment - Sean Doyle(L00205287)
Policy-as-Code solution using Terraform and HashiCorp Sentinel to enforce digital sovereignty and IaC supply chain security.

### Test Results located in Documentation/Evidence.
### tfplan.txt output located in /terraform and /documentation/evidence.
## Digital Sovereignty

AWS free plan region defaults to "eu-north-1" and cannot be changed. I allowed eu-west-1 as well because it is the Irish region.

A region restriction does not give full Digital Sovereignty. AWS is a US-headquartered company, so data in an EU region can still be subject to US legal requests. AWS also holds the encryption key for the disk. This policy does not cover backups, replication or administrative access by AWS.


## Policies implemented

All of our policies are hard mandatory in `sentinel/sentinel.hcl` which gives no override option for our complaince tests. On a failed check, the run is stopped before the apply and no resource will be created. These policies only check the plan, so they do not see changes made outside Terraform, such as in the AWS console.

### Region

The sovereignty policy fails the plan if any resource being created or updated is outside eu-north-1. This is the Digital Sovereignty policy that makes sure that infrastructure is kept in the approved regions. I tested the failing case by setting the aws_region workspace variable to us-east-1, and the compliant set used eu-north-1. Given the aws free tier limitations, I could not test from the closest region.  

Policy-as-Code is effective at enforcing a rule consistently, but the region rule is only a baseline. It controls where infrastructure is created but not necessarily the access or what laws can reach the data.

### Network

The network sentinel policy fails if the plan inbound security group rule is open to 0.0.0.0/0 for IPv4 or ::/0 for IPv6. It is named for SSH but applies to every port to block unrestricted inbound SSH access and is stricter overall. I tested the failing case by changing a workspace variable instead of the code.

### Instance Type
The policy allowed for t3.micro and only t3.micro as the approved instance type and would fail if  the plan did not meet the criteria.  

## Policies not implemented

The three policies I chose not to implement were:

Encryption, IMDSv2 and supply chain.

### Encrypted EBS 
Elastic Block Store root_block_device.encrypted is true in the plan	Hardcoded as true in main.tf, so it won't fail without a change to the code. The encryption uses an AWS-managed key, so AWS still holds the key material, which is a jurisdictional limit.
A customer-managed key (AWS Key Management Service) gives you more control but AWS still hosts it so the limit is reduced but not removed entirely.

### Mandatory IMDSv2 (Instance Metadata Service version 2)
metadata_options.http_tokens is "required"	Hardcoded in main.tf, also won't fail without a change to the code. 

In main.tf I changed http_tokens = "required" from "optional".  "optional" allows IMDSv2 and IMDSv1, whereas "required" enforces IMDSv2. IMDSv1 is more exposed to server side request forgery.

IMDSv2 makes the instance's internal info service require a token before it answers, which stops an attacker who can only send simple requests from stealing the server's credentials.

### supply chain integrity. 
The plan data Sentinel reads (tfplan) does not include provider or module sources. Instead, versions.tf pins Terraform to version 1.16.6 and the AWS to hashicorp/aws version ~> 6.0.  .terraform.lock.hcl stores the exact version and a hash so terraform init rejects a provider package that does not match. Sentinel can't verify provider integrity so you would instead want to review any changes made to the lock files in a pull request. Any change to the hash should be checked to protect against this supply chain risk.  

## How I tested

Created an IAM user AWS with no AWS Management Console Access permissions granted as this user was used for Terraform. The credentials are a requirement for running the plan.
They were not used to launch any instances.

sentinel test with per-policy folders is the standard way to test Sentinel policies locally, but we used Terraform runs in HCP instead, because the HCP Terraform free plan only allowed to paste code and use a single policy through the web interface and test them against runs there.

I have to paste the Sentinel policy code as individually managed policies as I cannot use policy sets on the free tier which would link directly to GitHub.
I can still test the plan against the pasted Sentinel policies though.

I had to create an individually managed policy and add that policy to a policy set. 

I combined my separate policies into a single script to run on the free tier plan for Terraform.  There is a single block for which to paste code, so if I want to run multiple policy compliance checks on the Terraform website app, it has to be done this way.  I have included `merged-policies-for-terraform.sentinel` file in the sentinel folder. This is a workaround for a limitation and not the preferred method.  





