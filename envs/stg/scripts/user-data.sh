#!/bin/bash
sudo yum update -y
sudo yum install unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "ECS_CLUSTER=${ecs_cluster_name}" >> /etc/ecs/ecs.config

#ssm agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm 
sudo systemctl status amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Install Cloudwatch Agent 

sudo yum install amazon-cloudwatch-agent -y
sudo rm /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo tee -a /opt/aws/amazon-cloudwatch-agent/bin/config.json <<EOF
{ 
   "agent": { 
      "run_as_user": "root" 
   }, 
   "metrics":{ 
      "namespace":"CwAgent", 
      "append_dimensions": { 

          "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
          "InstanceId": "$${aws:InstanceId}"
      },  
      "aggregation_dimensions" : [["AutoScalingGroupName"]], 
      "metrics_collected":{ 
         "mem":{ 
            "measurement":[ 
               "mem_used_percent" 
            ] 
         }, 
         "disk":{ 
            "measurement":[ 
               "disk_used_percent" 
            ], 
            "resources":[ 
               "/" 
            ] 
         } 
      } 
   }
} 
EOF

# Start Cloudwatch agent 

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s 

sudo amazon-cloudwatch-agent-ctl -a status 

