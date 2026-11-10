# Technical Report - Terraform Digital Sovereignty Assignment

###Things I could have done better:

I merged the policies into one sentinel file to test all of them at the same time which was actually unnecessary in hindsight. I misunderstood that free tier Terraform policy limitations and following the instructions of AI might have been to my detriment a little bit here.  

I was having trouble linking my github repository sentinel folder, which was actually a free tier limitation, but not to the extent I thought. I couldn't make a policy set without a policy, and I couldn't search my GitHub repository through the Terraform website app, so I had to a individually managed policy, which allowed me to make a policy set.  Pretty standard.  However, I assumed/misread/misundertood the policy limitatations.  I could have one policy set, not just one policy.  I thought I was limited to a single policy in a single set and thus merged the policies into a single script for testing purposes, while also acknowledging this is not best practice.  We live and we learn.  

### 

## Limitations

- Digital Sovereignty - The region policy can control where we create our resources are created, but it cannot control who can legally access the data. With AWS being rooted in the United States, US legal requests could still reach data in EU regions. 


- When Sentinel checks the plan, it cannot see the changes made outside of Terraform such as in the AWS console.  The execution of the plan happens late into the execution chain and Sentinel is fundamentally unable to serve as a security boundary against malicious or compromised Terraform providers. 


- Sentinel cannot verify provider integrity. The hashes in `.terraform.lock.hcl` do that during `terraform init`. Sentinel runs after plan, and init runs before the plan, so malicious code from a compromised provider has a window in which it can run.


- `Terraform's lock file `terraform.lock.hcl` pins what was accepted on the first install and will throw errors when the hash changes, however, it cannot tell you whether the provider was ever trustworthy in the first place.   

## What I learned and what I would do differently
- I merged the policies into one script because I believed the free plan allowed only one policy. HashiCorp documentation says the Free edition includes one policy set of up to five policies, so separate policies in one set were probably possible. I should have checked the documentation before building the workaround.

- Instead of needing to alter the variables in the code for compliance testing, it would have been much easier and more efficient to change workspace variables on Terraform, which I did figure out eventually.


- The AWS free plan region could not be changed, so I could not test from the Irish region.  

 