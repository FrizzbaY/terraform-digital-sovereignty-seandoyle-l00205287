# Terraform Digital Sovereignty Assignment - Sean Doyle(L00205287)
Policy-as-Code solution using Terraform and HashiCorp Sentinel to enforce digital sovereignty and IaC supply chain security.

## Digital Sovereignty

I defaulted to eu-north-1 because my AWS account would not let me change region on the free plan. I allowed eu-west-1 as well because it is the Irish region.

A region restriction does not give full Digital Sovereignty. AWS is a US-headquartered company, so data in an EU region can still be subject to US legal requests. AWS also holds the encryption key for the disk. This policy does not cover backups, replication or administrative access by AWS.

The key material is still stored and processed by AWS, a US-headquartered company, so jurisdictional exposure to foreign legal requests is not fully removed.

## Policies implemented

Chose hard mandatory on the first policy as it has no override option for our complaince tests.  Advisory only logs a warning, and soft allows for override.

sentinel/network.sentinel fails the plan if the inbound security group rule is open to 0.0.0.0/0 for IPv4 or ::/0 for IPv6. It is named for SSH but applies to every port to allow unrestricted inbound SSH access and is stricter overall. I tested the failing case by changing a workspace variable instead of the code.

## Policies not implemented

The three policies I chose not to implement were:

Encryption, IMDSv2 and supply chain.

Encrypted EBS (Elastic Block Store) root_block_device.encrypted is true in the plan	Hardcoded as true in main.tf, so won't fail without a change to the code. The encryption uses an AWS-managed key, so AWS still holds the key material, which is a jurisdictional limit.

Mandatory IMDSv2 (Instance Metadata Service version 2) metadata_options.http_tokens is "required"	Hardcoded in main.tf, same reason. 

In main.tf I changed http_token = "required" from "optional".  "optional" allows IMDSv2 and IMDSv2, whereas "required" enforces IMDSv2. IMDSv1 is more exposed to server side request forgery.

IMDSv2 makes the instance's internal info service require a token before it answers, which stops an attacker who can only send simple requests from stealing the server's credentials.

Supply chain integrity	Provider source, provider version, module sources and pinned versions	Plan resource data does not include provider or module sources. required_version and the ~> 6.0 constraint in versions.tf and .terraform.lock.hcl hash checks provide the controls instead. Sentinel alone cannot verify provider integrity or module provenance, which the brief asks you to identify.

## How I tested

sentinel test with per-policy folders is the standard way to test Sentinel policies locally, but we used Terraform runs in HCP instead, because the HCP Terraform free plan only allowed to paste code and use a single policy through the web interface and test them against runs there.

I have to paste the Sentinel policy code as individually managed policies as I cannot use policy sets on the free tier which would link directly to GitHub.
I can still test the plan against the pasted Sentinel policies though.

I had to create an individually managed policy and add that policy to a policy set.  Now it should work.

I combined my separate policies into a single script to run on the free tier plan for Terraform.  There is a single block for which to paste code, so
if I want to run multiple policy compliance checks on the Terraform website app, it has to be done this way.

Created an IAM user AWS with no AWS Management Console Access permissions granted as this user will only be using Terraform. The credentials are a requirement for running the plan.
They will not be used to launch any instances.

Created a readable version of the tfplan and put that in the repository.

### Test Results located in Documentation/Evidence.

## Notes to self (delete before submitting)

- Check if customer-managed keys have a monthly cost per key plus usage fees.
- Sentinel (empty bullet, nothing written)
- Have a look at the pre written Sentinel Policies on Terraform app.