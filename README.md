# Elite Dangerous: Commander Check
This lambda function uses the [EDSM](https://www.edsm.net) public API to 
retrieve a commander's last known position, and returns it in a HTML response.

### Why?
A good friend of mine who I play ED with wanted to know if I was currently 
*in space* without having to bug me. I use EDSM to track my pilot logs, and 
decided to use it to satisfy his need.

### Requirements
The function uses the [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)
 to keep the API key for EDSM, so the lambda requires read only access to 
 SSM, in addition to the basic lambda execution role.
 
 sam.yaml is a [AWS Serverless Application Model](https://docs.aws.amazon.com/lambda/latest/dg/serverless_app.html) 
  template so that I could test the code locally using [AWS SAM CLI](https://github.com/awslabs/aws-sam-cli)
  during development. The template *can* be packaged and deployed through the
   CLI, but does not currently contain the specific permissions or 
   customizations to the API gateway resources.

### TODO
Right now, this list is enormous, and is currently maintained in my head. 
I'll add it here when I have a few minutes.
