# Head First !

A lot of things need to be done before we can create an application. 

1. Start with logging into the GCP
```shell
# Authenticate terraform via ADC
gcloud auth application-default login             # opens browser
gcloud config set project $(your_project_id)
```
2. Enable all related APIs
```shell
# Enables Required APIs (Make sure that you have linked w ur billing account)
gcloud services enable compute.googleapis.com container.googleapis.com 
```

3. Now we can use tf
```shell
cd provision
terraform init
terraform apply
```

4. Moving to Ansible, at the start:
```shell
ansible-galaxy collection install community.docker
```

5. Remember to create a SSH key as well
```shell
# Create the key with this command
ssh-keygen -t rsa -f ~/.ssh/demandforecasting-vm -C jenkins-vm
# Add the key to the account
gcloud compute os-login ssh-keys add \
    --key-file=/home/nhatquang/.ssh/demandforecasting-vm.pub
```

6. After that, let check if we can ping to all the VM and install it
```shell
ansible -i inventory all -m ping
ansible-playbook -i inventory jenkins.yml
```

7. Then, access the VM and open Jenkins (remmember to allow Http Traffic on this VM as well)

8. After that, install all required plugins, including:
- Kubernetes
- Discord notifier

## Now moving to the Kubernetes cluster
gke-gcloud-auth-plugin is required for running remote GKE. Therefore we need to install it first.

```shell
# Install the plugin
sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin
# Now check it's version
gke-gcloud-auth-plugin --version
```

After that, we need to connect with GKE cluster via CLI
```shell
# Now we can connect via cli
gcloud container clusters get-credentials demandforecasting-gke --region us-central1 --project global-phalanx-449403-d2
```