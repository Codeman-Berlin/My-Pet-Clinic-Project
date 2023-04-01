#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum update -y
sudo yum install python3-pip -y
sudo -E pip3 install pexpect
sudo pip3 install boto boto3 botocore 
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo yum update -y 
sudo yum install git python python-devel python-pip ansible -y
sudo touch /etc/ansible/stage_hosts
sudo echo "[STAGE_Server]" >> /etc/ansible/stage_hosts
sudo chown ec2-user:ec2-user /etc/ansible/hosts
sudo chown -R ec2-user:ec2-user /etc/ansible && chmod +x /etc/ansible
sudo chmod 777 /etc/ansible/hosts
sudo chmod 777 /etc/ansible/stage_hosts
sudo echo "[PROD_Server]" >> /etc/ansible/hosts
sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
mkdir /home/ec2-user/playbooks
touch /home/ec2-user/playbooks/STAGEConsoleIP.yml
touch /home/ec2-user/playbooks/PRODConsoleIP.yml
echo "admin" > /home/ec2-user/playbooks/vault_password.yml
sudo chmod 666 /home/ec2-user/playbooks/STAGEConsoleIP.yml
sudo chmod 666 /home/ec2-user/playbooks/PRODConsoleIP.yml
sudo chown -R ec2-user:ec2-user /home/ec2-user/playbooks/
echo "${file(STAGEcontainer)}" >> /home/ec2-user/playbooks/STAGEcontainer.yml
echo "${file(PRODcontainer)}" >> /home/ec2-user/playbooks/PRODcontainer.yml  
sudo chmod 400 /home/ec2-user/Codeman   
echo "license_key: ${new_relic_key}" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y --nobest
echo "${file(keypair)}" >> /home/ec2-user/Codeman
sudo chown ec2-user:ec2-user /home/ec2-user/Codeman
chmod 400 /home/ec2-user/Codeman
sudo hostnamectl set-hostname ansible
echo "${file(PROD_Auto_Discovery)}" >> /home/ec2-user/playbooks/PROD_Auto_discovery.yml
echo "${file(stage_auto_discovery)}" >> /home/ec2-user/playbooks/stage_auto_discovery.yml