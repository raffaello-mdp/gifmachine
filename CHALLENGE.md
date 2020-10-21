# Challenge notes

Few notes about the challenge resolution. Let's consider the point as per the [devops coding exercise repository](https://github.com/salsify/devops_coding_exercise/blob/master/README.md).

## What to Submit
The result of the exercise is versioned in this repository that is a fork of [salsify/gifmachine](https://github.com/salsify/gifmachine).

## Folder structure
To the forked repository the following resources have been added:
 - `.github`: with the instruction to automate the deploy;
 - build
    - `api`: with the Dockerfile and resources to containerize the project;
    - `deploy`: with the task definition to deploy the service;
    - `infra`: with the code to create the infrastructure
 - `tests`: with a minimal test to check the deployed service
 - `.dockerignore`: to avoid copying unnecessary resources in the container ;
 - `docker-compose.yaml`: to build a local environment;
 - `Makefile`: to standardize the actions.
---
## Containerization
The project is containerized using Docker, from an official ruby image with alpine flavor. To the base image, it adds rvm, postgres and the project dependencies installing the bundles.
It defines an entry point which runs the migrations and starts the server.

I've decided to serve the application directly with Sinatra without a reverse proxy such as Nginx. I feel that this is questionable and I would have placed that in the real life.

> I'm running migration at deploy time, this may start many discussions as it may affect deploy performance or even make it fails due to timeout. I'm an apologist of small changes and that the migration should only affect the structure of the database without impacting the service itself. Inserts and updates should leave in isolated commands that, again, do not impact the application;
to avoid impacting the application the code must be prepared for the transition from the old structure to the new one.

The parameters needed by the application are defined in the docker-compose file for local usage and fetched from Parameter Store (for database URL and API password) at deploy time for the live application.

> The injection of the credentials at deploy time may start a discussion about how the service needs a redeploy to reflect changes in the parameters. An alternative would be to deploy a sidecar container with a process that fetches the parameters and cache it or directly do that in the application.
The inject is for sure the fastest solution and cover the security issue of maintaining secrets the parameters that shouldn't be exposed.

---

## Runtime environment
The live service runs in an AWS account using only free tier components. To prepare the environment I've created an account and I've manually (in the console) created my user (without any permission) and a GlobalAdmin role with the administration permission and trust policy for my user.
Starting from that everything has been created using terraform to create IaC.

> Note that as my user has no permissions, the `~/.aws/config` file defines a profile with the GlobalAdmin role and my user as source profile. All the resources appear as created by me assuming the role.

Terraform uses an S3 remote state except for the creation of the state bucket. In the IaCthe resources are isolated by service and by scope.
It creates:
- An S3 bucket to store the remote state;
- A dynamoDb table to store the resources locks;
- A vpc with 3 private subnets (in separate AZ), 3 public subnets (in separate AZ), a routing table and a NAT gateway;
- A route53 zone with the records to serve the application, a cname to validate SSL certificate, a cname for the database (so that the applications do not depend on the name given by AWS, this simplify restores and migrations);
- IAM Roles and Users;
- An ACM to serve requests over TLS;
- An RDS instance living in a private subnet without redundancy;
- A public application load balancer;
- A ECS cluster based on EC2, the instances live in the private subnets and accept traffic only from the alb security group;
- A gifmachine service (with task redundancy) with target group and parameter (SSM Parameter Store);

> I've decided to create a cluster on EC2 instead of simply using Fargate to show some hands-on in creating resources.

> The database has been created manually, instead of creating a VPN I've created an EC2 instance in the same VPC with ssh access and a public IP. Once in the instance, I've installed a postgres client and performed the actions in [init-postgres.sql](gifmachine/build/infra/rds/main/resources/init-postgres.sql)

> To serve the application using a domain I've register for a free domain at [freenom.com](https://my.freenom.com/) and, to be able to manage records on AWS, I've registered there the NS records from route53.

> Last, and least, I've created all the infrastructure in the `eu-west-1` region.

---

## Tests
To test the application I wrote a basic test using js and jest, I've tested:
- the connection to the WebSocket and the receiving of events;
- the failure of the `POST - /gif` API call with a wrong password.

To run the tests use:

`bash
$ make test
`

---

## Running the service locally
The Makefile contains the recipes to build and start the container locally and to destroy all the resources.

To start the server locally run:
`bash
$ make
`

To clean up run:

`bash
$ make down
`

To populate the local environment, from the host run:
`bash
$ curl \
  --data 'url=https://media.giphy.com/media/l41JMXnXn4E7WQR8s/giphy.gif&who=raffo&meme_top=ALL&meme_bottom=DONE&secret=gif-magic' \
'https://0.0.0.0:8080/gif'
`

and visit the https://0.0.0.0:8080 in the browser.

> The first time you'll build the application locally it will fail to start the container as it will try to apply the migrations too soon. The API container has a dependency on the database one but the ready state of the container is triggered before the database can start receiving commands.

## Running the live service

Well the service is there up and running, or at least I hope so, I did not place any observability layer and I don't receive any alarm if it crashes.
Anyway repeat the actions done locally changing the host and the password:

`bash
$ curl \
  --data 'url=https://media.giphy.com/media/l41JMXnXn4E7WQR8s/giphy.gif&who=raffo&meme_top=ALL&meme_bottom=DONE&secret=too_secret_to_guess' \
'https://gifmachine.rmdp.tk/gif'
`

Visit https://gifmachine.rmdp.tk in the browser.

## Bibliography
Besides the link you've shared about how to install the RVM I've consulted:
-  [Terraform documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) to recall definitions of resources and data;
- [ALB](https://github.com/terraform-aws-modules/terraform-aws-alb) terraform module definition;
- [VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc) terraform module definition;
- [RDS](https://github.com/terraform-aws-modules/terraform-aws-rds/tree/master/examples/complete-postgres) terraform module definition;
- [AWS Free Tier](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&all-free-tier.q=vpn&all-free-tier.q_operator=AND) documentation;
- [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) documentation to recall concepts;
- [Amazon ECS Container Instance IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html) documentation to check needed permissions;
---
## Feedback and notes
I enjoyed this challenge, I wanted to create my account for a while but I never prioritized it in my life.

I know zero about ruby but I didn't feel that this was an obstacle, probably the docker image could have been some smaller knowing more details on dependencies.

I think I've spent around 16 to 20 hours on the exercise.
I've spent more time on:
- I've created the cluster security group accepting traffic only from itself, my bad, but I've spent some time debugging;
- Once deployed, the service was failing in upgrading the request;
It came out that the alb lowercase the headers (as by the [doc](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html)) and the e-websocket dependency is expecting the header to `Upgrade` and note `upgrade` (see [code](https://github.com/igrigorik/em-websocket/blob/04b0770657b9ab8c5fca524301ebb7218cee2bb5/lib/em-websocket/handler_factory.rb)). That has been tricky to find and I solved fixing the header name (when passed) in the application. I wanted to create an issue to track the tech debt but I wasn't able to do that. In the real-life anyway I would have created a ticket on jira or clickup or whatever.
- Looking for gifs.
