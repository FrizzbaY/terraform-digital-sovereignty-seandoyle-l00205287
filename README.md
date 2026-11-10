# Terraform Digital Sovereignty Assignment - Sean Doyle(L00205287)
Policy-as-Code solution using Terraform and HashiCorp Sentinel to enforce digital sovereignty and IaC supply chain security.

### Test Results and Screenshots are located in `documentation/evidence/`. 
### sentinel-mock-tests.txt and Screenshot in `documentation/evidence/`. 
### tfplan.txt output located in `/terraform/` and `/documentation/evidence/`
### tfplan located at `/terraform/`.


## Digital Sovereignty

AWS free plan region defaults to "eu-north-1" and cannot be changed. I allowed eu-west-1 as well because it is the Irish region.

A region restriction does not give full Digital Sovereignty. AWS is a US-headquartered company, so data in an EU region can still be subject to US legal requests. AWS also holds the encryption key for the disk. This policy does not cover backups, replication or administrative access by AWS.  


## Policies implemented

All of our policies are hard mandatory in `sentinel/sentinel.hcl` which gives no override option for our complaince tests. On a failed check, the run is stopped before the apply and no resource will be created. These policies only check the plan, so they do not see changes made outside Terraform, such as in the AWS console. Sentinel is great for enforcing configuration standards and preventing misconfiguration, but it does not act as security against supply chain attacks.  Measures should be taken prior to execution, such as using isolated environments with only the strictly necessary credentials.  

### Region

The sovereignty policy fails the plan if any resource being created or updated is outside eu-north-1. This is the Digital Sovereignty policy that makes sure that infrastructure is kept in the approved regions. I tested the failing case by setting the aws_region workspace variable to us-east-1, and the compliant set used eu-north-1. Given the aws free tier limitations, I could not test from the closest region.  

Policy-as-Code is effective at enforcing a rule consistently, but the region rule is only a baseline. It controls where infrastructure is created but not necessarily the access or what laws can reach the data.  

### Network

The network sentinel policy fails if the plan inbound security group rule is open to 0.0.0.0/0 for IPv4 or ::/0 for IPv6. It is named for SSH but applies to every port to block unrestricted inbound SSH access and is stricter overall. I tested the failing case by changing a workspace variable instead of the code.  

### Instance Type
The policy allowed for t3.micro and only t3.micro as the approved instance type and would fail if the plan did not meet the criteria.  An instance type policy is a safety net against automated systems or developers, accidentally or intentionally, launching an improper instance type, such as an under-optimized, insecure, or oversized instance.  

Difference instances could have different security considerations, for example: Legacy hardware that could have security vulnerabilities, or enforcing instance types that have modern features, such as having IMDSv2 by default etc. 

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

### Supply chain integrity. 
The plan data Sentinel reads (tfplan) does not include provider or module sources. Instead, versions.tf pins Terraform to version 1.16.6 and the AWS to hashicorp/aws version ~> 6.0.  .terraform.lock.hcl stores the exact version and a hash so terraform init rejects a provider package that does not match. Sentinel can't verify provider integrity so you would instead want to review any changes made to the lock files in a pull request. Any change to the hash should be checked to protect against this supply chain risk.  

Supply chain integrity is about ensuring that every step taken in a produces manufacturing and delivery is completely safe, secure, and trustworthy.  By denying unverified or compromised parts to enter the system, you reduce the risk of cyberthreat, hardware tampering, and counterfeit failueres.  Data is better protected and companies can prove the origin or their materials and how they handle them.  

## How I tested

Created an IAM user AWS with no AWS Management Console Access permissions granted as this user was used for Terraform. The credentials are a requirement for running the plan.
They were not used to launch any instances.

sentinel test with per-policy folders is the standard way to test Sentinel policies locally, but we used Terraform runs in HCP instead, because the HCP Terraform free plan only allowed to paste code and use a single policy through the web interface and test them against runs there.

I have to paste the Sentinel policy code as individually managed policies as I cannot use policy sets on the free tier which would link directly to GitHub.
I can still test the plan against the pasted Sentinel policies though.

I had to create an individually managed policy and add that policy to a policy set. 

I combined my separate policies into a single script to run on the free tier plan for Terraform.  There is a single block for which to paste code, so if I want to run multiple policy compliance checks on the Terraform website app, it has to be done this way.  I have included `merged-policies-for-terraform.sentinel` file in the sentinel folder. This is a workaround for a limitation and not the preferred method.  

## Sentinel mock testing


Each policy has mock plan data in sentinel/test/<policy>/, with a passing and a failing case.
Run with `sentinel test` from the sentinel/ folder (Sentinel v0.41.0).
The failing mocks use the same values as the live HCP runs: instance type m5.large,
region us-east-1, and SSH source 0.0.0.0/0. Output is saved in
documentation/evidence/sentinel-mock-tests.txt.


### Prompts for Terraform Sentinel Assignment. 

## LLM: Claude Sonnet 5.5, Medium Effort.

# Questions

1. Create this folder structure and fix any errors.  Suggest improvements and explain your reasoning.
2. Explain the purpose for each folder in relation to this assignment
3. What should our first step be?
4. What is versions.tf? Why is it needed?
5. What is .terraform.lock.hcl for? It was created with the terraform init. And the versions.tf does not do this already?
6. What is terraform/providers.tf? Why is it needed?
7. On the AWS free-tier I will only be able to deploy to eu-north-1, will this restrict our testing?
8. What does variables.tf do here?
9. How does the terraform validate command differ functionally to something like CloudFormations validate template command?
10. What formatting is being checked with terraform fmt -check?
11. How do I build a Sentinel Policy?
12. Tell what each line of code is doing in main.tf.
13. What is IMDSv2? What is IMDSv1?
14. Tell me about Customer managed KMS.
15. What is meant by "Restrictions on unrestricted inbound SSH access"?
16. How do we set up network security for an EC2 instance in Terraform?
17. Do we need to configure a key pair?
18. Comment this code for me please.
19. How does this code know where to pull the variables from?
20. I want to create a simple Sentinel Policy that checks the instance type. How do we go about that setting that up?
21. One type of instance for compliant and then everything else non-compliant would be simplest no?
22. What is sentinal.hcl?
23. So will the sentinal.hcl contain a list of all of our files we want to run policy checks on?
24. How does a soft mandatory user with permissions override the failure?
25. So the policy is the sentinel file itself?
26. Would it not make more sense to create the tfplan first?
27. Do I need to do anything else to this policy or can I go onto tfplan now?
28. I will finish anything policy related after the plan is at least bare-bones. It will make more sense to me that way.
29. Help me to create the Terraform plan.
30. I should provide the AWS credentials outside the plan no?
31. Can we use dummy credentials?
32. What is ReadOnlyAccess, type: job function? Is it just a non app specific permission?
33. Would it not be wiser to limit the permissions given the context of the assignment?
34. I have an error that says trying to run the terraform plan command. The user doesn't have the policy ssm:GetParameter.
35. False alarm.  I assigned a boundary, rather than a policy.  Should work this time.
36. The plan says '4 to add, 0 to change, 0 to destroy', what does this mean?
37. And what specifically does applying the plan do?
38. Once we have the plan, how do we proceed with the policy check?
39. Is Terraform necessary to do policy checks with sentinel or are there other ways?
40. I have created the Terraform project. I assume I match the versions?
41. I'm about to try the first run on Terraform, any thing I should know before I test the first run?
42. The Terraform needs my AWS credentials as environment variables, is that correct? What is best practice here?
43. How does it know to check against the policy from here?
44. Okay so how do we attach the policy?
45. Okay ive started the plan without the apply, what is happening currently behind the scenes?
46. What types of variables are present in a typical Terraform workspaces?
47. What are Sentinel mocks?
48. Let me make sure I am fully understanding everthing so far: Let me just understand where we are at.
    We have our project linked to Terraform.  Terraform makes the plan for our infrastructure to deploy from our .tf files.
    Using Terraform, the plan is checked against Sentinel policy, and if compliant or non-compliant, deployment can be
    blocked or proceed. But we are simply running the Sentinel policy checks without going as far as deployment, correct?
49. Whats the functional difference between the different types of policy sets listed on Terraform?
50. Do I need to change anything in the policy set configurations or am I good to go?
51. Do I need to add the policies prior to creating the set?
52. What is the default execution mode? Whats the difference between local, remote, and default?
53. I need to use individually managed policies on the free tier for Terraform. I'll just go ahead and paste individual Sentinel Policies instead?
54. Compiant and non compliant policy checks worked for instance type, I can just add the rest of the policies and check all passes and fails together now right?
55. We don't need to check every single policy so we can ignore the hardcoded pass/fail checks instead of changing the repository and making a new branch.
56. Am I good to merge these policies into a single script? The free plan means I can only use one individually managed policy, which is just pasted code.  I can combine both scripts and everything works the same right?
57. Any changes needed to this script?
58. Show me the network policy draft.
59. Would you typically block both inbound and outbound rules?
60. Are my pull requests being checked automitcally on Terraform? One of my pull request said check failed.
61. Combine these sentinel policy scripts for me please.
62. Should I add 0.0.0.0/0 to the workspace variable or change the script default?



