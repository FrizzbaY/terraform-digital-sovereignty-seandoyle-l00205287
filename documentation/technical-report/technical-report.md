# Technical Report - Terraform Digital Sovereignty Assignment


## Limitations

- Digital Sovereignty - The region policy can control where we create our resources are created, but it cannot control who can legally access the data. With AWS being rooted in the United States, US legal requests could still reach data in EU regions. 


- When Sentinel checks the plan, it cannot see the changes made outside of Terraform such as in the AWS console.  The execution of the plan happens late into the execution chain and Sentinel is fundamentally unable to serve as a security boundary against malicious or compromised Terraform providers. 


- Sentinel cannot verify provider integrity. The hashes in `.terraform.lock.hcl` do that during `terraform init`. Sentinel runs after plan, and init runs before the plan, so malicious code from a compromised provider has a window in which it can run.


- Terraform's lock file `terraform.lock.hcl` pins what was accepted on the first install and will throw errors when the hash changes, however, it cannot tell you whether the provider was ever trustworthy in the first place.   

## What I learned and what I would do differently
- I merged the policies into one script because I believed the free plan allowed only one policy. HashiCorp documentation says the Free edition includes one policy set of up to five policies, so separate policies in one set were probably possible. I should have checked the documentation before building the workaround.

- Instead of needing to alter the variables in the code for compliance testing, it would have been much easier and more efficient to change workspace variables on Terraform, which I did figure out eventually.


- The AWS free plan region could not be changed, so I could not test from the Irish region.  


- I would write Sentinel test mocks from the start, so each policy has a pass case and a fail case that can be run locally. I completely forgot about the test mocks until I was going through the checklist for this assignment and I really wish I had started with them. It would have been much easier for me to comprehend the concepts being introduced from a local setup and I would of progressed muchc more quickly, both in terms of the assignment and my understanding of the concepts.  

## Recommendations

 - Keeping the policies in GitHub for every change made through a pull request has to be the standard practice or else you risk fighting an uphill battle when it comes to versioning and technical drift.   I would run the `sentinel test` against the mocks on each pull request to make sure that the policy is always matching the resources. 


- Add a second control outside Terraform for changes made in the AWS console, covering what sentinel cannot.  


- Don't solely rely on Sentinel.  Sentinel checks the plans before apply, the lock file and pull request review can cover provider integrity, but they can only do so much.  They have gaps that need to be filled with control outside of Terraform. Sentinel doesn't see changes made to the AWS console, so we can block actions outside approved regions with AWS Organizations service control policy (SCP). Scheduled `terraform plan` can detect drift which is the difference between the real environment and the code.` Provider code will run before Sentinel can stop it, so we introduce minimum permission and short-lived AWS credentials. 