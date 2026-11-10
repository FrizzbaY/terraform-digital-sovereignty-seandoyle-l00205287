# Terraform Digital Sovereignty Assignment - Sean Doyle(L00205287)
Policy-as-Code solution using Terraform and HashiCorp Sentinel to enforce digital sovereignty and IaC supply chain security.


## Temporary Heading

In main.tf I changed http_token = "required" from "optional".  "optional" allows IMDSv2, whereas "required" enforces IMDSv2.
IMDSv1 is more exposed to server side request forgery.  


## Notes to self

### Potential Limiting factors

- The key material is still stored and processed by AWS, a US-headquartered company, so jurisdictional exposure to foreign legal requests is not fully removed.

- Check if customer-managed keys have a monthly cost per key plus usage fees.

- Sentinel 

IMDSv2 makes the instance’s internal info service require a token before it answers, which stops an attacker who can only send simple requests from stealing the server’s credentials.

Chose hard mandatory on the first policy as it has no override option for our complaince tests.  Advisory only logs a warning, and soft allows for override.  

Created an IAM user AWS with no AWS Management Console Access permissions granted as this user will only be using Terraform. The credentials are a requirement for running the plan.  
They will not be used to launch any instances. 

Created a readable version of the tfplan and put that in the repository.  

Have a look at the pre written Sentinel Policies on Terraform app. 

I have to paste the Sentinel policy code as individually managed policies as I cannot use policy sets on the free tier which would link directly to GitHub.  
I can still test the plan against the pasted Sentinel policies though.  

I had to create an individually managed policy and add that policy to a policy set.  Now it should work.  

I combined my seperate policies into a single script to run on the free tier plan for Terraform.  There is a single block for which to paste code, so
if I want to run multiple policy compliance checks on the Terraform website app, it has to be done this way.   

Created a combined Sentinel 


### Test Results located in Documentation/Evidence. 

The three policies I chose not to implement were: 

Encryption, IMDSv2 and supply chain.

Encrypted EBS (Elastic Block Store, the disk)	root_block_device.encrypted is true in the plan	Hardcoded as true in main.tf, so it 
could not fail without changing the code. Also, encryption uses an AWS-managed key, so AWS still holds the key material, which you already noted as a jurisdictional limit.

Mandatory IMDSv2 (Instance Metadata Service version 2)	metadata_options.http_tokens is "required"	Hardcoded in main.tf, same reason. Your existing README note on why 
required matters (server side request forgery) belongs here.

Supply chain integrity	Provider source, provider version, module sources and pinned versions	Plan resource data does not include provider or module sources. required_version and the ~> 6.0 constraint in versions.tf and .terraform.lock.hcl hash checks provide the controls instead. Sentinel alone cannot verify provider integrity or module provenance, which the brief asks you to identify.