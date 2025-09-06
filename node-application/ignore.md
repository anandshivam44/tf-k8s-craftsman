- Dockerize https://github.com/swimlane/devops-practical
- MongoDB should also be deployed as a docker container
- Create a Kubernetes cluster to deploy the application into

- Create a Helm chart for the application and use Helm (v3) to deploy it
- Use terraform to create as much of the Kubernetes cluster and required infrastructure as possible
- Eliminate as many single points of failure for your Kubernetes cluster deployment as possible

Bonus points for the following:

 - Security
 - Scalability
   - Using Ansible to ensure NTP is installed and running on the worker nodes
 - As well any dependencies needed for Kubernetes if not using EKS/GKE/AKS prebuilt images
 - Using Packer to create the worker node images and applying the Ansible playbook

Access the app running in Kubernetes, register for an account, and add a record.

To deliver your work, create a public Github repository with the following (at a minimum):

- Information about how you set up the Kubernetes cluster
- Readme with the commands used to deploy the application and Terraform
- Either the Helm chart or the Kustomize templates, manifests, and overlays used to deploy the application
- Terraform files
- Dockerfiles
- Screenshot of the running application with a new record added
