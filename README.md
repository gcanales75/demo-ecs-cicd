# Lab-CodeServices-ECS-Fargate

CloudFormation

Crea un repositorio en CodeCommit para la página web
Parametro URI de un channel de Slack
Crea funcion Lambda que envia mensajes a Slack

SSH to the instance
cd environment/
cd website/

docker build -t stp/website .
docker run --rm --name web -d --network host stp/website


AWS CodeCommit setup

$ ssh-keygen
Enter file in which to save the key (/home/ec2-user/.ssh/id_rsa): <hit enter>
Enter passphrase (empty for no passphrase): <hit enter>
Enter same passphrase again: <hit enter>
Copy content of:
$ cat /home/ec2-user/.ssh/id_rsa.pub
In the IAM console, in the navigation pane, choose Users, and from the list of users, choose your IAM user. 
On the user details page, choose the Security Credentials tab, and then choose Upload SSH public key. 
Paste the contents of your SSH public key into the field, and then choose Upload SSH public key. 
Copy or save the information in SSH Key ID
On your local machine, use a text editor to create a config file in the ~/.ssh directory, and then add the following lines to the file, where the value for User is the SSH key ID you copied earlier: 

$ sudo nano ~/.ssh/config

Paste the below content:

Host git-codecommit.*.amazonaws.com
  User APKAXTAS4XY5W534YD4E
  IdentityFile ~/.ssh/id_rsa.pub

Save and name this file config

From the terminal, run the following command to change the permissions for the config file: 

Change permissions
$ sudo chmod 600 config

Test your connection
$ ssh APKAXTAS4XY5W534YD4E@git-codecommit.us-east-1.amazonaws.com

You shouls see
You have successfully authenticated over SSH. You can use Git to interact with AWS CodeCommit.

Your initial push to CodeCommit repo
git init
git add .
git commit -m "v2 commit"
git remote add codecommit1 ssh://APKAXTAS4XY5W534YD4E@git-codecommit.us-east-1.amazonaws.com/v1/repos/stpWebsite
git push -u codecommit1 master

-------
AWS CodeBuild

Create Proyect

Name: stpWebsite
Source provider: AWS CodeCommit
Repository: stpWebsite
Reference type: Branch
Branch: master

Envirenment
Environment image: Managed image
Operating system: Ubuntu
Runtime(s): Standard
Image: aws/codebuild/standard:2.0
[x] Enable this flag if you want to build Docker images or want your builds to get elevated privileges
Service role: New service role

EDIT POLICY: CodeBuildBasePolicy-stpWebsite-us-east-1 

{
  "Statement": [
    ### BEGIN ADDING STATEMENT HERE ###
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    ### END ADDING STATEMENT HERE ###
    ...
  ],
  "Version": "2012-10-17"
}

Detailed instructions: https://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html


Buildspec
Build specifications: Use a buildspec file

Logs
[x] CloudWatch logs - optional

Create build project <hit enter>


------
ECS

EC2 Prerequisites
Security Groups
    ALB seecurity group
        alb-stpwebsite-sb (sg-04377210a9dc35652)
            Inbound rules
                80,8080 (from 0.0.0.0/0)
    Containers security group
        containers-stpwebsite-sg
            Inbound rules
                sg-04377210a9dc35652 (all trafic)

IAM Prerequisites
    Service role for CodeDeploy: ecsCodeDeployRole (intentar borrar)
        (The IAM role the service uses to make API requests to authorized AWS services. Create a service role for CodeDeploy in the IAM console. )

Aplication Load Balancer
    Fargate load balancer
        Name: stpwebsite-alb
        Listeners: HTTP (8080)

ECS Configuration
Clusters
    stpwebsite cluster
        Cluster template: Networking only
        Cluster name: stpwebsite-cluster
    Create<hit enter>

Task Definitions
    stpwebsite task definition
        Select launch type compatibility: Fargate
        Task Definition Name: stpwebsite-td
        Task Role: none
        Task execution IAM role: Create new role
        Task size: 0.5 GB
        Task CPU (vCPU): 0.25 vCPU
        Container Definitions: Add container
            Container name: stpwebsite-container
            Image: <ECR container image:version>
            Port mappings: 80
            Add<hit enter>

Clusters
    stpwebsite-cluster
        Services <Create>
            Launch type: Fargate
            Task Definition: stpwebsite-td
            Service name: stpwebsite-service
            Number of tasks: 6
            Deployments
                Deployment type: Blue/green deployment (powered by AWS CodeDeploy)
                Service role for CodeDeploy: ecsCodeDeployRole
            Next step<hit enter>
            Configure network
                Cluster VPC: <project VPC>
                Subnets: <private subnets (2)>
                Security groups: containers-stpwebsite-sg
                Auto-assign public IP: DISABLE
            Load balancing
                Load balancer type: Application Load Balancer
                    Load balancer name: stpwebsite-alb
                Container to load balance
                    Container name : port: Add to load balancer
                        Production listener port: 8080:HTTP
                        Test listerer [ ] (uncheck)
            Additional configuration
                Target group 1 name: stpwebsite-tg-1
                Target group 2 name: stpwebsite-tg-2
            Service discovery (optional)
                Enable service discovery integration: [ ] (uncheck)
             Next step<hit enter>
             Set Auto Scaling (optional)
                Service Auto Scaling: Do not adjust the service’s desired count
            Next step<hit enter>
            Create Service<hit enter>

Update Deployment group with appspec.json

--------
CodePipeline

Pipeline settings
    Pipeline name: stpwebsite-pipeline
    Service role: New service role
    <hit Next>
    Add source stage
        Source
            Source provider: AWS CodeCommit
            Repository name: stpWebsite
            Branch name: master
            Change detection options: mazon CloudWatch Events (recommended)
    <hit Next>
    Add build stage
        Build - optional
            Build provider: AWS CodeBuild
            Region: US East (N. Virginia)
            Project name: 






https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-ecs-ecr-codedeploy.html


Get registry IDs
aws ecr describe-repositories --query 'repositories[*].[registryId,repositoryUri]' --region us-east-1

Registry authentication
$(aws ecr get-login --registry-ids 521878158907 --no-include-email --region us-east-1)

Tag Image
docker tag stp/website:latest ${ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com/stp/website:latest
docker tag stp/website:latest 521878158907.dkr.ecr.us-east-1.amazonaws.com/stp/website:latest

Push image to ECR
docker push 521878158907.dkr.ecr.us-east-1.amazonaws.com/stp/website:latest

Crear ECS Task Definition
Crear ECS Service

Create CodeDepoy application

Compute platform -> Amazon ECS
Create deployment group

[Crear service rol]


