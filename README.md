
PROJECT_FOLDER=$(pwd)

Generate a Key Pair for Bastion Host and Managed Nodes, also upload it to aws
```
FILENAME=innovation_hub_ssh_key
ssh-keygen -t ed25519 -a 100 -C $FILENAME -f ./01-eks-cluster/private-key/$FILENAME -N ''
aws ec2 import-key-pair --key-name $FILENAME --public-key-material fileb://./01-eks-cluster/private-key/$FILENAME.pub
```

Create an s3 bucket for s3 Remote Backend
```
BUCKET_NAME=terraform-backend-s3-remote-state-storage-$(date +%s)
aws s3 mb s3://$BUCKET_NAME
```


Replace in the entire directory with your own bucket name
``` ####This should not work, test it before
find $PROJECT_FOLDER -type f -exec sed -i "" -e 's/terraform-backend-personal/$BUCKET_NAME/g' {} \;
```



Create DynamoDb Table for s3 state lock
```
TABLE_NAME=01-eks-cluster
aws dynamodb create-table \
    --table-name $TABLE_NAME  \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD
```




#Apply Folder 01-eks-cluster
```
DIR=01-eks-cluster
terraform -chdir=$DIR init 
terraform -chdir=$DIR validate
terraform -chdir=$DIR plan -out plan.txt
terraform -chdir=$DIR apply plan.txt

```

Configure kubectl 
echo >> ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name infra-dev-innovation-hub

Stop Bastion because we don't need it 
```bash
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=infra-dev-BastionHost" --query "Reservations[].Instances[].InstanceId" --output text)

# aws ec2 start-instances --instance-id $INSTANCE_ID

aws ec2 stop-instances --instance-id $INSTANCE_ID
```



Create DynamoDb Table for s3 state lock
```
TABLE_NAME=02-loadbalancer-controller-add-on
aws dynamodb create-table \
    --table-name $TABLE_NAME  \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD
```


```
DIR=02-loadbalancer-controller-add-on
terraform -chdir=$DIR init 
terraform -chdir=$DIR validate
terraform -chdir=$DIR plan -out plan.txt
terraform -chdir=$DIR apply plan.txt
```



Create ACM Certificate
Create DynamoDb Table for s3 state lock
```
TABLE_NAME=03-lbc-install-terraform-manifests
aws dynamodb create-table \
    --table-name $TABLE_NAME  \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD
```


```
DIR=03-lbc-install-terraform-manifests
terraform -chdir=$DIR init 
terraform -chdir=$DIR validate
terraform -chdir=$DIR plan -out plan.txt
terraform -chdir=$DIR apply plan.txt
```






Create Hosted Zone and Import your domain name
This is a manual task



Create DynamoDb Table for s3 state lock
```
TABLE_NAME=04-externaldns-plugin
aws dynamodb create-table \
    --table-name $TABLE_NAME  \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD
```


Run the Template
```
DIR=04-externaldns-plugin
terraform -chdir=$DIR init 
terraform -chdir=$DIR validate
terraform -chdir=$DIR plan -out plan.txt
terraform -chdir=$DIR apply plan.txt
```



Replace my domain name with your own domain name
```
find . -type f -exec sed -i "" -e 's/.k8.shivamanand.com/.k8.shivamanand.com/g' {} \;
```





Create EFS Driver 

Create DynamoDb Table for s3 state lock Section 4
```
TABLE_NAME=05-efs-csi-drivers
aws dynamodb create-table \
    --table-name $TABLE_NAME  \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD
```


Run the Template and create ACM Certificate
```
DIR=05-efs-csi-drivers
terraform -chdir=$DIR init 
terraform -chdir=$DIR validate
terraform -chdir=$DIR plan -out plan.txt
terraform -chdir=$DIR apply plan.txt
```







Create DynamoDb Table for s3 state lock Section 4
```
TABLE_NAME=06-kubernetes-apps
aws dynamodb create-table \
    --table-name $TABLE_NAME  \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD
```


<!-- Run the Template and create ACM Certificate
```
DIR=06-kubernetes-apps/acm_certificate
terraform -chdir=$DIR init 
terraform -chdir=$DIR validate
terraform -chdir=$DIR plan -out plan.txt
terraform -chdir=$DIR apply plan.txt
``` -->

Now Goto AWS Console > ACM > Choose the Certificate we just created > Create Records in Route 53
[IMAGE]


Launch your Apps
```
kubectl apply -R -f 06-kubernetes-apps/
```

Now Access your Apps 
https://ingress-groups-demo601.k8.shivamanand.com/
https://ingress-groups-demo601.k8.shivamanand.com/app1/
https://ingress-groups-demo601.k8.shivamanand.com/app2/

Also by default we have http to https redirect at the LoadBalancer Level configured with LB Controller
http://ingress-groups-demo601.k8.shivamanand.com/
http://ingress-groups-demo601.k8.shivamanand.com/app1/
http://ingress-groups-demo601.k8.shivamanand.com/app2/









Create DynamoDb Table for s3 state lock Section 4
```
TABLE_NAME=07-efs-app
aws dynamodb create-table \
    --table-name $TABLE_NAME  \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD
```


Run the Template and create ACM Certificate
```
DIR=07-efs-app
terraform -chdir=$DIR init 
terraform -chdir=$DIR validate
terraform -chdir=$DIR plan -out plan.txt
terraform -chdir=$DIR apply plan.txt
```
Complete steps from here













kubectl get events -n kube-system







































































































































































































Cleaning Up

terraform -chdir=07-efs-app plan -destroy -out destroy-plan.txt
terraform -chdir=07-efs-app apply destroy-plan.txt
TABLE_NAME=07-efs-app
aws dynamodb delete-table --table-name $TABLE_NAME 

kubectl delete -R -f 06-kubernetes-apps/
terraform -chdir=06-kubernetes-apps plan -destroy -out destroy-plan.txt
terraform -chdir=06-kubernetes-apps apply destroy-plan.txt
TABLE_NAME=06-kubernetes-apps
aws dynamodb delete-table --table-name $TABLE_NAME 

terraform -chdir=05-efs-csi-drivers plan -destroy -out destroy-plan.txt
terraform -chdir=05-efs-csi-drivers apply destroy-plan.txt
TABLE_NAME=05-efs-csi-drivers
aws dynamodb delete-table --table-name $TABLE_NAME 

terraform -chdir=04-externaldns-plugin plan -destroy -out destroy-plan.txt
terraform -chdir=04-externaldns-plugin apply destroy-plan.txt
TABLE_NAME=04-externaldns-plugin
aws dynamodb delete-table --table-name $TABLE_NAME 


terraform -chdir=03-acm-ssl-certificate plan -destroy -out destroy-plan.txt
terraform -chdir=03-create-acm-certificate apply destroy-plan.txt
TABLE_NAME=03-create-acm-certificate
aws dynamodb delete-table --table-name $TABLE_NAME 


terraform -chdir=02-loadbalancer-controller-add-on plan -destroy -out destroy-plan.txt
terraform -chdir=02-loadbalancer-controller-add-on apply destroy-plan.txt
TABLE_NAME=02-loadbalancer-controller-add-on
aws dynamodb delete-table --table-name $TABLE_NAME 


terraform -chdir=01-eks-cluster plan -destroy -out destroy-plan.txt
terraform -chdir=01-eks-cluster apply destroy-plan.txt
TABLE_NAME=01-eks-cluster
aws dynamodb delete-table --table-name $TABLE_NAME 



Remove Terraform s3 Remote Backend
```
aws s3 rm s3://$BUCKET_NAME/ --recursive
aws s3 rb s3://$BUCKET_NAME
```


Delete the SSH Public Key which was manually uploaded
```
```























Common Errors

Show Image Also

helm_release.external_dns: Creating...
╷
│ Error: cannot re-use a name that is still in use
│ 
│   with helm_release.external_dns,
│   on 7-externaldns-install.tf line 2, in resource "helm_release" "external_dns":
│    2: resource "helm_release" "external_dns" {
│ 
╵
Releasing state lock. This may take a few moments...
shivam.anand@H9RF7QWXQ5 kubernetes-innovation-hub % k get secrets
NAME                                 TYPE                 DATA   AGE
sh.helm.release.v1.external-dns.v1   helm.sh/release.v1   1      2m43s
shivam.anand@H9RF7QWXQ5 kubernetes-innovation-hub % k delete secret sh.helm.release.v1.external-dns.v1
secret "sh.helm.release.v1.external-dns.v1" deleted





Terraform Destroy unable to delete ACM Certificate 
Because the Certificate is still in use by a Load Balancer









Importing your domain name


