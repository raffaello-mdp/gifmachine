#!/bin/bash
sudo yum install -y ecs-init
sudo echo ECS_CLUSTER="${cluster_name}"                 >> /etc/ecs/ecs.config
sudo echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=2m"    >> /etc/ecs/ecs.config
sudo echo "ECS_IMAGE_CLEANUP_INTERVAL=10m"              >> /etc/ecs/ecs.config
sudo echo "ECS_IMAGE_MINIMUM_CLEANUP_AGE=15m"           >> /etc/ecs/ecs.config
sudo echo "ECS_NUM_IMAGES_DELETE_PER_CYCLE=20"          >> /etc/ecs/ecs.config
sudo echo "ECS_ENABLE_CONTAINER_METADATA=true"          >> /etc/ecs/ecs.config
sudo service docker start
sudo service start ecs
sudo chkconfig docker on
sudo chkconfig ecs on
sudo mkdir -p /ecs/data
exit
