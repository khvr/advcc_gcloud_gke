# k8s

Kubernetes infrastructure

Setup/Teardown of Kubernetes Cluster.

## Team Information

| Name                           | NEU ID    | Email Address                    |
| ------------------------------ | --------- | -------------------------------- |
| Viraj Rajopadhye               | 001373609 | rajopadhye.v@northeastern.edu    |
| Pranali Ninawe                 | 001377887 | ninawe.p@northeastern.edu        |
| Harsha vardhanram kalyanaraman | 001472407 | kalyanaraman.ha@northeastern.edu |

## 1. Useful Commands

### 1. PIP3 AND BOTO3 INSTALLATION (ANSIBLE PRERQ)
```bash
$ sudo apt install python3-pip
$ pip3 install boto3
$ pip3 show boto3
$ pip3 install boto
```


### 2. Ansible Host-key checking and ansible python interpreter
* Ansible has host key checking enabled by default.

* If a host is reinstalled and has a different key in ‘known_hosts’, this will result in an error message until corrected. If a host is not initially in ‘known_hosts’ this will result in prompting for confirmation of the key, which results in an interactive experience if using Ansible, from say, cron. You might not want this.

* If you understand the implications and wish to disable this behavior, you can do so by editing /etc/ansible/ansible.cfg or ~/.ansible.cfg:

  [defaults]<br/>
  host_key_checking = False<br/>

  Alternatively this can be set by the ANSIBLE_HOST_KEY_CHECKING environment variable:<br/>
  $ export ANSIBLE_HOST_KEY_CHECKING=False

* If ansible fails to recognise the python interpreter:
can do so by editing /etc/ansible/ansible.cfg or ~/.ansible.cfg:

  [localhost]<br/>
  ansible_python_interpreter=/usr/bin/python3
  <br/>

  Alternatively this can be set by the  -e command line option to manually set the python interpreter when you run a command<br/>
  $ ansible-playbook sample-playbook.yml -e 'ansible_python_interpreter=/usr/bin/python3'

### 3. To start from a task in ansible
Include  --start-at-task="task_name" while executing the playbook


## 2. Cluster Setup
```bash
ansible-playbook setup-k8s-cluster.yml -e"cluster_name=<gke-cluster-name> \
region=<cluster-region> \
google_project_name=<gcloud-project-name> \
webapp_domain=<full-webapp-domain> \
dns_zone=<dns-zone-name> \
credentials_path=<path-to-credentials.json> \
service_account_email=<service-account-email-created-for-infrastructure-provisioning> \
terraform_project=<terraform-project-path>" -vvvv
```

## Delete Cluster

```bash
$ ansible-playbook -i <path_to_inventory> delete-k8s-cluster.yml -e \ "clustername=<cluster-name>
profile=<aws-profile>
region=<aws-region>" -vvv

$ ansible-playbook delete-k8s-cluster.yml -e"terraform_project=<path-to-terraform-project>" -vvvv
```
