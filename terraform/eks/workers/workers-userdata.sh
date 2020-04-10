#!/bin/bash

# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
# See: https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh

set -o xtrace

# Install security updates
yum -y --security update

/etc/eks/bootstrap.sh \
    --apiserver-endpoint "${apiserver_endpoint}" \
    --b64-cluster-ca "${cluster_ca}" \
    --kubelet-extra-args "--kube-reserved memory=0.5Gi,cpu=200m,ephemeral-storage=1Gi --system-reserved memory=0.2Gi,ephemeral-storage=1Gi --eviction-hard memory.available<5%,nodefs.available<10%,nodefs.inodesFree<5%,imagefs.available<10%,imagefs.inodesFree<5% --eviction-soft memory.available<10% --eviction-soft-grace-period memory.available=5m" \
    "${cluster_name}"

# Install AWS SSM agent
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
systemctl status amazon-ssm-agent
