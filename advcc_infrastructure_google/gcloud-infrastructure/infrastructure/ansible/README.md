# k8s

Kubernetes infrastructure

Setup/Teardown of Kubernetes Cluster.

## Team Information

| Name                           | NEU ID    | Email Address                    |
| ------------------------------ | --------- | -------------------------------- |
| Viraj Rajopadhye               | 001373609 | rajopadhye.v@northeastern.edu    |
| Pranali Ninawe                 | 001377887 | ninawe.p@northeastern.edu        |
| Harsha vardhanram kalyanaraman | 001472407 | kalyanaraman.ha@northeastern.edu |

## Setup Cluster

```bash


ansible-playbook -i <path_to_inventory> setup-k8s-cluster.yml -e \
"clustername=<cluster-name> \
state_store=<s3://subdomain.domain> \
node_count=<compute-node-count> \
node_size=<compute-node-instance-type> \
master_size=<master-node-instance-type> \
dns_zone_id=<zone-id/zone-domain-name> \
profile=<aws-profile> \
k8s_version=<kubernetes-version> \
ssh_path=<ssh-public-key-path> \
region=<aws-region> \"
db_username=<db(RDS)-user-name> \
db_password=<db(RDS)-password>  -vvv
```

## Delete Cluster

```bash
ansible-playbook -i <path_to_inventory> delete-k8s-cluster.yml -e "clustername=<cluster-name> profile=<aws-profile> region=<aws-region>" -vvv
```
