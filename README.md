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

ed the policy and then I needed to create the set with the policy.  Now it should work.  


### Test Results located in Documentation/Evidence. 