SETUP_PROJECT_ID="scorpion-233719"
SETUP_REGION="europe-west2"
SETUP_ZONE="europe-west2-c"
SETUP_NAME="scorpion"

FS_VM_DISK_SIZE="200GB"
FS_VM_INTERNAL_IP_NAME="$SETUP_NAME-fs-vm-internal-ip"
FS_VM_EXTERNAL_IP_NAME="$SETUP_NAME-fs-vm-external-ip"

FS_VM_BACKUP_SCHEDULE_NAME="$SETUP_NAME-fs-vm-daily-backup-schedule"
FS_VM_PERSISTENT_DISK_NAME="$SETUP_NAME-fs-vm-data-disk"

FS_VM_NAME="$SETUP_NAME-fs-vm"


CLOUD_SQL_VM_NAME="$SETUP_NAME-mysql-vm"
CLOUD_SQL_ADMIN_USER="admin"
CLOUD_SQL_ADMIN_PASS="london247*"

INSTANCE_TEMPLATE_NAME="$SETUP_NAME-instance-template-v1"
LATEST_DEBIAN_OS_NAME=$(gcloud compute images list --project debian-cloud --no-standard-images --format="value(NAME)")

HTTP_HEALTH_CHECK_NAME="$SETUP_NAME-web-health-check"
TCP_HEALTH_CHECK_NAME="$SETUP_NAME-tcp-health-check"

INSTANCE_GROUP_NAME_PRODUCTION="$SETUP_NAME-instance-group-prd"
INSTANCE_GROUP_NAME_DEV="$SETUP_NAME-instance-group-dev"

LOAD_BALANCER_TCP="$SETUP_NAME-load-balancer-tcp"
LOAD_BALANCER_TCP_BACKEND="$SETUP_NAME-load-balancer-tcp-backend"


LOAD_BALANCER_HTTP="$SETUP_NAME-load-balancer-http"
LOAD_BALANCER_HTTP_BACKEND="$SETUP_NAME-load-balancer-http-backend"


TCP_LOAD_BALANCER_IPV4_NAME="$SETUP_NAME-tcp-lb-ipv4"
TCP_LOAD_BALANCER_IPV6_NAME="$SETUP_NAME-tcp-lb-ipv6"

FS_SERVER_HOSTING_FOLDER="/mnt/hosting"
PUBSUB_TOPIC="$SETUP_NAME-topic-cron"
PUBSUB_SUBSCRIPTION="$SETUP_NAME-subscription-cron"
SETUP_DOMAIN="<domain.com>"
SETUP_DOMAIN_FOLDER="<domain.com>/scorpion"
PUBSUB_RECEIVER_URL="cron-app/pubsub"
PUBSUB_PUSH_URL="https://$SETUP_DOMAIN/$PUBSUB_RECEIVER_URL/receive_message"

PHP_VERSION="7.2"

IFS='' read -r -d '' PUBSUB_SETUP_CMD <<-EOF
	mkdir -p $FS_SERVER_HOSTING_FOLDER/$SETUP_DOMAIN/$PUBSUB_RECEIVER_URL
	cd  $FS_SERVER_HOSTING_FOLDER/$SETUP_DOMAIN/$PUBSUB_RECEIVER_URL

	git clone https://github.com/scriptburn/pub-sub-target.git .
	composer install

	mkdir -p $FS_SERVER_HOSTING_FOLDER/$SETUP_DOMAIN/cron-app/cron-job-runner
	cd $FS_SERVER_HOSTING_FOLDER/$SETUP_DOMAIN/cron-app/cron-job-runner
	git clone https://github.com/scriptburn/cron-job-runner.git .

EOF

 IFS='' read -r -d '' VM_TEMPLATE_STARTUP_SCRIPT <<-EOF
    export DEBIAN_FRONTEND=noninteractive




    echo "updated-1"


    sudo apt install -y apt-transport-https lsb-release ca-certificates && sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && sudo sh -c 'echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list' && echo "php 7.2 repo added"


 	sudo apt-get update -y && echo "updated-2"
    sudo apt-get upgrade -yq && echo "upgrade-1"

    sudo  apt -y install zip unzip nfs-common && sudo mount -t nfs $FS_VM_NAME:/data /mnt && echo "drive mounted"
    sudo usermod -a -G www-data rajneeshojha123

    sudo chgrp -R www-data /mnt/hosting
    sudo chmod -R 2774 /mnt/hosting


    sudo chgrp -R www-data /mnt/www
    sudo chmod -R 2774 /mnt/www


    sudo  apt -y install mc apache2 mysql-client &&  echo "apache and mysql installed"

    sudo mv /etc/apache2 /etc/apache2.bak && sudo ln -s /mnt/etc/apache2 /etc/apache2

    phpv="$PHP_VERSION"
    sudo apt  -y  install php\$phpv php\$phpv-mbstring  php\$phpv-gd php\$phpv-gettext php\$phpv-curl  php\$phpv-bcmath php\$phpv-xdebug composer git-flow certbot python-certbot-apache php\$phpv-zip php\$phpv-memcache php\$phpv-apcu redis-server php\$phpv-redis php\$phpv-mysql libapache2-mod-php\$phpv php\$phpv-xml && echo "php installed \$phpv"

    sudo update-alternatives --set php /usr/bin/php\$phpv
    sudo update-alternatives --set phar /usr/bin/phar\$phpv
    sudo update-alternatives --set phar.phar /usr/bin/phar.phar\$phpv
    sudo update-alternatives --set phpize /usr/bin/phpize\$phpv
    sudo update-alternatives --set php-config /usr/bin/php-config\$phpv



    sudo mv /etc/php/\$phpv/apache2 /etc/php/\$phpv/apache2.bak && sudo ln -s /mnt/etc/php/\$phpv/apache2 /etc/php/\$phpv/apache2



    sudo apt -y install php\$phpv-dev && sudo apt -y install libmcrypt-dev && echo -e "" | sudo pecl install mcrypt-1.0.1 && echo "mcrypt installed"
    echo 'extension=mcrypt.so' | sudo tee --append /etc/php/\$phpv/mods-available/mcrypt.ini > /dev/null && sudo ln -s  /etc/php/\$phpv/mods-available/mcrypt.ini /etc/php/\$phpv/apache2/conf.d/mcrypt.ini && echo "mcrypt enabled"


    cd /tmp && wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && tar xfz ioncube_loaders_lin_x86-64.tar.gz && sudo cp /tmp/ioncube/ioncube_loader_lin_7.2.so /usr/lib/php/20170718/ &&  echo  "zend_extension = /usr/lib/php/20170718/ioncube_loader_lin_7.2.so"  | sudo tee --append  /etc/php/\$phpv/cli/php.ini && echo  "zend_extension = /usr/lib/php/20170718/ioncube_loader_lin_7.2.so" | sudo tee --append  /etc/php/\$phpv/apache2/php.ini && echo "ioncube installed"


    echo "date.timezone=Europe/London"| sudo tee --append /etc/php/\$phpv/apache2/php.ini  && echo " time zone set to Europe/London"
    echo "date.timezone=Europe/London"| sudo tee --append /etc/php/\$phpv/cli/php.ini  && echo " time zone set to Europe/London"

    nohup /mnt/tools/cloud_sql_proxy -instances=$SETUP_PROJECT_ID:$SETUP_REGION:$CLOUD_SQL_VM_NAME=tcp:3306 &


    sudo /usr/sbin/a2enmod ssl
    sudo /usr/sbin/a2enmod rewrite
    sudo /usr/sbin/a2enmod headers
    sudo a2enmod dir
    sudo a2enmod authz_core

	sudo mv /etc/letsencrypt /etc/letsencrypt.bak

	sudo ln -s /mnt/etc/letsencrypt /etc/letsencrypt

    sudo service apache2 restart  && echo "apache started"
    sudo systemctl  start redis-server && echo "redis started"


    curl -sS "https://dl.google.com/cloudagents/install-logging-agent.sh" |sudo bash
    sudo mkdir -p  /etc/google-fluentd/config.d
    sudo cp -f  /mnt/etc/google-fluentd/config.d/apache.conf  /etc/google-fluentd/config.d/  && echo "Custom config file is copied"

    echo "all done"
EOF


function enable_apis()
{
    # enable compute engine
    gcloud services enable compute.googleapis.com
    
    # enable cloud sql
    gcloud services enable sql-component.googleapis.com
    
    # enable Compute Engine Instance Group Manager API
    gcloud services enable replicapool.googleapis.com
    
    # enable Compute Engine Instance Group Updater API
    gcloud services enable replicapoolupdater.googleapis.com
    
    #Compute Engine Instance Groups API
    gcloud services enable resourceviews.googleapis.com
    
    # enable Cloud Pub/Sub API
    gcloud services enable pubsub.googleapis.com
    
    # enable Cloud OS Login API
    gcloud services enable oslogin.googleapis.com
    
    # enable Stackdriver Monitoring API
    gcloud services enable monitoring.googleapis.com
    
    # enable Identity and Access Management (IAM) API
    gcloud services enable logging.googleapis.com
    
    # enable Identity and Access Management (IAM) API
    gcloud services enable iam.googleapis.com
    
    #IAM Service Account Credentials API
    gcloud services enable iamcredentials.googleapis.com
    
}

#login to appropriate account
gcloud auth login
#list active projects in that account
gcloud projects list

#set active project
gcloud config set project $SETUP_PROJECT_ID

#set default zone/region for project in remote ,init command will set local client zone and local client region from this
gcloud compute project-info add-metadata --metadata google-compute-default-region=$SETUP_REGION,google-compute-default-zone=$SETUP_ZONE


#init the setting
gcloud init

#reset zone and region env variable as they take higher precedence to metadata server, the local client setting
export CLOUDSDK_COMPUTE_ZONE=""
export CLOUDSDK_COMPUTE_REGION=""

#set active region for local gcloud client , already set by init command but just in case
gcloud config set compute/region $SETUP_REGION

#set active zone for local gcloud client, already set by init command but just in case
gcloud config set compute/zone $SETUP_ZONE

#et a list of services that you can enable in your project:
gcloud services list --available




## create a backup schedule for fs vm

gcloud beta compute resource-policies create-snapshot-schedule $FS_VM_BACKUP_SCHEDULE_NAME \
--description "Daily schedule to backup scorpion fs vm daily at 3am " \
--max-retention-days 15 \
--start-time 03:00 \
--daily-schedule \
--on-source-disk-delete keep-auto-snapshots \
--snapshot-labels env=dev,media=images \
--storage-location US

# see list of  snapshot schedules
#gcloud beta compute resource-policies describe $FS_VM_BACKUP_SCHEDULE_NAME


##create fs vm persistent boot disk

gcloud beta compute disks create $FS_VM_PERSISTENT_DISK_NAME --type=pd-standard \
--zone=$SETUP_ZONE \
--size=$FS_VM_DISK_SIZE --resource-policies=projects/$SETUP_PROJECT_ID/regions/$SETUP_REGION/resourcePolicies/$FS_VM_BACKUP_SCHEDULE_NAME \
--physical-block-size=4096


## reserve a static internal/private ip for fs vm


gcloud compute addresses create $FS_VM_INTERNAL_IP_NAME --region  $SETUP_REGION --subnet default

## get last created internal ip
FS_VM_INTERNAL_IP_ADDRESS=$(gcloud compute addresses describe $FS_VM_INTERNAL_IP_NAME --region  $SETUP_REGION --format='value(address)')


## reserve a static external/public ip for fs vm
gcloud compute addresses create $FS_VM_EXTERNAL_IP_NAME --region  $SETUP_REGION
FS_VM_EXTERNAL_IP_ADDRESS=$(gcloud compute addresses describe $FS_VM_EXTERNAL_IP_NAME --region  $SETUP_REGION --format='value(address)')



##  create storage vm
gcloud compute --project=$SETUP_PROJECT_ID instances create $SETUP_NAME-fs-vm \
--zone=$SETUP_ZONE --machine-type=n1-standard-1 \
--subnet=default --private-network-ip=$FS_VM_INTERNAL_IP_ADDRESS \
--address=$FS_VM_EXTERNAL_IP_ADDRESS --network-tier=PREMIUM \
--metadata=startup-script=\#\!/bin/sh --maintenance-policy=MIGRATE \
--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.readonly,https://www.googleapis.com/auth/devstorage.read_write \
--image=debian-9-stretch-v20190213 --image-project=debian-cloud \
--boot-disk-size=10GB --no-boot-disk-auto-delete --boot-disk-type=pd-standard --boot-disk-device-name=$SETUP_NAME-fs-vm \
--disk=name=$FS_VM_PERSISTENT_DISK_NAME,device-name=$FS_VM_PERSISTENT_DISK_NAME,mode=rw,boot=no \
--deletion-protection \
--tags=singlefs


## create cloud sql vm
gcloud sql instances create $CLOUD_SQL_VM_NAME --tier=db-n1-standard-1 --zone=$SETUP_ZONE \
--storage-auto-increase \
--storage-size	10 \
--storage-type SSD \
--enable-bin-log	\
--backup-start-time 03:00

## set mysql root user password

gcloud sql users set-password root --host % --instance $CLOUD_SQL_VM_NAME --password $CLOUD_SQL_ADMIN_PASS

## create mysql user
gcloud sql users create $CLOUD_SQL_ADMIN_USER --host % --instance $CLOUD_SQL_VM_NAME --password $CLOUD_SQL_ADMIN_PASS



## create instance template


gcloud compute --project=$SETUP_PROJECT_ID instance-templates create $INSTANCE_TEMPLATE_NAME \
--machine-type=n1-standard-1 \--network=projects/$SETUP_PROJECT_ID/global/networks/default \
--network-tier=PREMIUM \
--metadata=startup-script="$VM_TEMPLATE_STARTUP_SCRIPT" \
--maintenance-policy=MIGRATE \
--scopes=https://www.googleapis.com/auth/pubsub,https://www.googleapis.com/auth/sqlservice.admin,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
--tags=http-server,https-server --image=$LATEST_DEBIAN_OS_NAME --image-project=debian-cloud \
--boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$INSTANCE_TEMPLATE_NAME

## add firewall rule for health checks
gcloud compute firewall-rules create $SETUP_NAME-allow-health-check-firewall-rule \
--allow tcp:80 \
--source-ranges 130.211.0.0/22,35.191.0.0/16 \
--network default

##create firerwall rule to allow http port
gcloud compute --project=$SETUP_PROJECT_ID firewall-rules create $SETUP_NAME-allow-http \
--direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0



##create firerwall rule to allow https port
gcloud compute --project=$SETUP_PROJECT_ID firewall-rules create $SETUP_NAME-allow-https \
--direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0


## create http health check
gcloud compute --project $SETUP_PROJECT_ID   http-health-checks create "$HTTP_HEALTH_CHECK_NAME" \
--port "80" --request-path "/" --check-interval "12" --timeout "10" --unhealthy-threshold "2" --healthy-threshold "1"






## creation production instance group
gcloud beta compute --project=$SETUP_PROJECT_ID instance-groups managed create $INSTANCE_GROUP_NAME_PRODUCTION \
--base-instance-name=$INSTANCE_GROUP_NAME_PRODUCTION --template=$INSTANCE_TEMPLATE_NAME \
--size=1 --zone=$SETUP_ZONE --http-health-check=$HEALTH_CHECK_NAME --initial-delay=300

 


## set autoscaling for production group
gcloud compute --project $SETUP_PROJECT_ID instance-groups managed set-autoscaling $INSTANCE_GROUP_NAME_PRODUCTION \
--zone $SETUP_ZONE  --cool-down-period "120" --max-num-replicas "3" --min-num-replicas "1" --target-load-balancing-utilization "0.8"

## set named port for tcp load balancer
gcloud compute instance-groups managed set-named-ports $INSTANCE_GROUP_NAME_PRODUCTION --named-ports "https:443" --zone $SETUP_ZONE
## set named port for tcp load balancer
gcloud compute instance-groups managed set-named-ports $INSTANCE_GROUP_NAME_PRODUCTION --named-ports "http:80" --zone $SETUP_ZONE


## creation dev instance group
gcloud beta compute --project=$SETUP_PROJECT_ID instance-groups managed create $INSTANCE_GROUP_NAME_DEV \
--base-instance-name=$INSTANCE_GROUP_NAME_DEV --template=$INSTANCE_TEMPLATE_NAME \
--size=0 --zone=$SETUP_ZONE




##create firerwall rule to allow access to httpss port
#gcloud compute firewall-rules create $SETUP_NAME-load-balancer-firewall-rule \
#    --allow tcp:443,tcp:80 \
#    --source-ranges 130.211.0.0/22,35.191.0.0/16 \
#    --network default


##create http tcp health check for tcp load balancer
gcloud compute health-checks create tcp $TCP_HEALTH_CHECK_NAME --project $SETUP_PROJECT_ID  \
--port 80   --check-interval "12" --timeout "10" --unhealthy-threshold "2" --healthy-threshold "1"




##reserver ipv4 for tcp load balancer
gcloud compute addresses create $TCP_LOAD_BALANCER_IPV4_NAME \
--ip-version=IPV4 \
--global

TCP_LOAD_BALANCER_IPV4_ADDRESS=$(gcloud compute addresses describe $TCP_LOAD_BALANCER_IPV4_NAME --global  --format='value(address)')



##reserver ipv4 for tcp load balancer
gcloud compute addresses create $TCP_LOAD_BALANCER_IPV6_NAME \
--ip-version=IPV6 \
--global

TCP_LOAD_BALANCER_IPV6_ADDRESS=$(gcloud compute addresses describe $TCP_LOAD_BALANCER_IPV6_NAME --global  --format='value(address)')



## create http load balancer
gcloud compute backend-services create $LOAD_BALANCER_HTTP_BACKEND \
--project $SETUP_PROJECT_ID   \
--global \
--protocol HTTP \
--http-health-checks $HTTP_HEALTH_CHECK_NAME \
--timeout 5m \
--enable-cdn \
--port-name http



## create http backend
gcloud compute backend-services add-backend $LOAD_BALANCER_HTTP_BACKEND \
--project $SETUP_PROJECT_ID   \
--global \
--instance-group $INSTANCE_GROUP_NAME_PRODUCTION \
--instance-group-zone $SETUP_ZONE \
--balancing-mode UTILIZATION \
--max-utilization 0.8




##Create a default URL map that directs all incoming requests to all your instances.
gcloud compute url-maps create $LOAD_BALANCER_HTTP \
--project $SETUP_PROJECT_ID   \
--default-service $LOAD_BALANCER_HTTP_BACKEND


gcloud compute target-http-proxies create $SETUP_NAME-http-lb-target-proxy \
--project $SETUP_PROJECT_ID   \
--url-map $LOAD_BALANCER_HTTP

#Configure global forwarding rules for the IPv6 addresse or front end configuration for http load balancer
gcloud beta compute forwarding-rules create $SETUP_NAME-http-lb-ipv4-forwarding-rule \
--project $SETUP_PROJECT_ID   \
--global \
--target-http-proxy $SETUP_NAME-http-lb-target-proxy \
--address $TCP_LOAD_BALANCER_IPV4_ADDRESS \
--ports 80


#Configure global forwarding rules for the IPv6 addresse or front end configuration for http load balancer
gcloud beta compute forwarding-rules create $SETUP_NAME-http-lb-ipv6-forwarding-rule \
--project $SETUP_PROJECT_ID   \
--global \
--target-http-proxy $SETUP_NAME-http-lb-target-proxy \
--address $TCP_LOAD_BALANCER_IPV6_ADDRESS \
--ports 80




## create tcp load balancer
gcloud compute backend-services create $LOAD_BALANCER_TCP \
--project $SETUP_PROJECT_ID   \
--global \
--protocol TCP \
--health-checks $TCP_HEALTH_CHECK_NAME \
--timeout 5m \
--port-name https

## create tcp backend
gcloud compute backend-services add-backend $LOAD_BALANCER_TCP \
--project $SETUP_PROJECT_ID   \
--global \
--instance-group $INSTANCE_GROUP_NAME_PRODUCTION \
--instance-group-zone $SETUP_ZONE \
--balancing-mode UTILIZATION \
--max-utilization 0.8


## tcp backend proxy
gcloud compute target-tcp-proxies create $SETUP_NAME-tcp-lb-target-proxy \
--backend-service $LOAD_BALANCER_TCP \
--proxy-header NONE





#delete tcp ipv4 global forwarding rule
#gcloud beta compute forwarding-rules delete $SETUP_NAME-tcp-lb-ipv4-forwarding-rule --global



#Configure global forwarding rules for the IPv4 addresse or front end configuration
gcloud beta compute forwarding-rules create $SETUP_NAME-tcp-lb-ipv4-forwarding-rule \
--global \
--target-tcp-proxy $SETUP_NAME-tcp-lb-target-proxy \
--address $TCP_LOAD_BALANCER_IPV4_ADDRESS \
--ports 443


#gcloud beta compute forwarding-rules delete $SETUP_NAME-tcp-lb-ipv6-forwarding-rule --global

#Configure global forwarding rules for the IPv6 addresse
gcloud beta compute forwarding-rules create $SETUP_NAME-tcp-lb-ipv6-forwarding-rule \
--global \
--target-tcp-proxy $SETUP_NAME-tcp-lb-target-proxy \
--address $TCP_LOAD_BALANCER_IPV6_ADDRESS \
--ports 443


## create pub sub topic for cron


gcloud pubsub topics create $PUBSUB_TOPIC \
--project $SETUP_PROJECT_ID   


## create an app engine cron app which will run every 1 min and push a message to $PUBSUB_TOPIC
##git htdocs/github_projects/appengine-topic-push-cron or from https://github.com/scriptburn/appengine-topic-push-cron.git

# grant Storage Object Viewer permission to  @cloudbuild.gserviceaccount.com role "Cloud Build Service Account" https://console.cloud.google.com/iam-admin/iam?project=scorpion-233719
gcloud app deploy
gcloud app deploy cron.yaml


 
 

## create a domain on gcp and create ssl certificate sudo certbot --apache for it and host cron-app there, which will receive the message pushed by app engine cron 
## to topic $PUBSUB_TOPIC and cron-app will exec the actual cron script on gcp
#make sure json mod is enabled
run $PUBSUB_SETUP_CMD

## register pubsub scubscription url 

#first add https url of domain https://$SETUP_DOMAIN in search console https://search.google.com/search-console
# then add domain here https://console.cloud.google.com/apis/credentials/domainverification?project=scorpion-233719


##create pubsub subcription for cron 

gcloud pubsub subscriptions create $PUBSUB_SUBSCRIPTION \
--project $SETUP_PROJECT_ID   \
--topic $PUBSUB_TOPIC \
--ack-deadline 10 \
--push-endpoint $PUBSUB_PUSH_URL

 
#################
#setup zfs on vm
sudo sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
sudo apt-get update
sudo apt -y install linux-headers-$(uname -r)
sudo ln -s /bin/rm /usr/bin/rm
sudo apt-get install zfs-dkms zfsutils-linux zfs-initramfs acl zip unzip


sudo mkfs.ext4 -t zfs -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb



sudo cp -a /lib/systemd/system/zfs-share.service /etc/systemd/system
sudo systemctl restart zfs-import-cache
sudo systemctl restart zfs-import-scan
sudo systemctl restart zfs-mount
sudo zpool  create -f data sdb
sudo mkdir /data/hosting
sudo mkdir /data/tools


sudo  apt -y install nfs-common nfs-kernel-server
sudo systemctl status nfs-kernel-server

echo "/data *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee --append  /etc/exports
sudo exportfs -a
wget subzero.developmentpath.co.uk/etc.zip
unzip etc.zip
sudo mv etc /data/
sudo wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /data/tools/cloud_sql_proxy
sudo vi /etc/ssh/sshd_config and enable publickeyauth and enablerootlogin
sudo service sshd restart
sudo zfs set acltype=posixacl data
sudo zfs set aclinherit=passthrough data


##set permission
sudo groupadd www-data
sudo useradd www-data

sudo setfacl -Rm g:www-data:rwx,g:www-data:rwx,o:r-- /data/hosting
sudo setfacl -Rm d:g:www-data:rwx,d:g:www-data:rwx,d:o:r-- /data/hosting



sudo chgrp -R www-data /data/hosting
sudo usermod -a -G www-data rajneeshojha123
sudo chmod -R 2774 /data/hosting



sudo chgrp -R www-data /mnt/hosting
sudo usermod -a -G www-data rajneeshojha123
sudo chmod -R 2774 /mnt/hosting


function template_for_image
{
		
	sudo  apt -y install nfs-common && sudo mount -t nfs scorpion-fs-vm:/data /mnt && echo "drive mounted" 
	sudo systemctl  start redis-server && echo "redis started"
	sudo service apache2 start  && echo "apache started"
	
	sudo mv /etc/letsencrypt /etc/letsencrypt.bak
	sudo ln -s /mnt/etc/letsencrypt /etc/letsencrypt

	nohup /mnt/tools/cloud_sql_proxy -instances=scorpion-233719:europe-west2:scorpion-mysql-vm=tcp:3306 & 
	echo "sql proxy started" 
	echo "all done"
}


## steup cert auto renew on fs vm as we can not run command as sudo from our pubsub cron initiator
## login to any vm





IFS='' read -r -d '' SETUP_CERBOT_ON_FS <<-EOF

	export DEBIAN_FRONTEND=noninteractive




    echo "updated-1"


    sudo apt install -y apt-transport-https lsb-release ca-certificates && sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && sudo sh -c 'echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list' && echo "php 7.2 repo added"


 	sudo apt-get update -y && echo "updated-2"
    sudo apt-get upgrade -yq && echo "upgrade-1"

	sudo  apt -y install apache2 certbot python-certbot-apache -t stretch-backports

    #sudo mv /etc/apache2 /etc/apache2.bak && sudo ln -s /mnt/etc/apache2 /etc/apache2

    phpv="$PHP_VERSION"
    sudo apt  -y  install php\$phpv libapache2-mod-php\$phpv && echo "php installed \$phpv"

    sudo update-alternatives --set php /usr/bin/php\$phpv
    sudo update-alternatives --set phar /usr/bin/phar\$phpv
    sudo update-alternatives --set phar.phar /usr/bin/phar.phar\$phpv
    sudo update-alternatives --set phpize /usr/bin/phpize\$phpv
    sudo update-alternatives --set php-config /usr/bin/php-config\$phpv

	sudo mv /etc/apache2 /etc/apache2.bak && sudo ln -s /data/etc/apache2 /etc/apache2
	sudo wget https://dl.eff.org/certbot-auto && sudo chmod a+x certbot-auto
	sudo mv certbot-auto /etc/letsencrypt/certbot-auto
	gcloud auth login
	gcloud compute instances list --filter="name~'$INSTANCE_GROUP_NAME_PRODUCTION'" --format="value(name)" |xargs -I '{}' gcloud compute ssh '{}' --zone='europe-west2-c' --command "sudo service apache2 restart"

	sudo service apache2 stop
EOF

##setup crontab for root on fs vm
 #45 2 * * 6 /data/hosting/SETUP_DOMAIN_FOLDER/cron-app/cron-job-runner/cerbot-renew-scheduler.sh


