source settings.sh



make_vm() {
    NAME=$1
    PROJECT=$2
    ZONE=$3

    echo "Creating VM $NAME in $PROJECT"
    gcloud compute instances create "$NAME" \
    --project="$PROJECT" \
    --zone="$ZONE" \
    --machine-type=n1-standard-4 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=120864790947-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=http-server,https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name="$NAME",image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20231130,mode=rw,size=30,type=projects/bbr-replication3670-31200/zones/us-west1-a/diskTypes/pd-standard \
    --no-shielded-secure-boot \
    --no-shielded-vtpm \
    --no-shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any
    made_vm=$?

    echo "uploading files to $NAME"
    until gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME" --command "mkdir -p bbr-replication"
    do
	if [ made_vm ];
	then
	    echo "awaiting ssh key propagation $NAME..."
	    sleep 2
	else
	    break
	fi
    done;
    gcloud compute scp ~/bbr-replication-1 "$NAME":bbr-replication-1
}
#kernel script broken
#kernel upgrade not needed for ubuntu 20.04+

#upgrade_kernel() {
 #   NAME=$1
  #  PROJECT=$2
  #  ZONE=$3

  #  echo "Installing kernel on $NAME"
  #  gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME" --command "cd ~/bbr-replication-1 && bash up_kernel.sh"
#}

install_deps() {
    NAME=$1
    PROJECT=$2
    ZONE=$3

    echo "Installing required dependencies on $NAME"
    gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME" --command "cd ~/bbr-replication-1 && bash install_dependencies.sh"
}

link_vms() {
    NAME1=$1
    NAME2=$2
    PROJECT=$3
    ZONE=$4

    gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME1" \
	--command 'cat ~/.ssh/id_rsa.pub' | \
	gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME2" \
	--command 'cat >> ~/.ssh/authorized_keys'

    gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME2" \
	--command 'hostname -I' | \
	gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME1" \
	--command 'cat > ~/.bbr_pair_ip'
}

wait_for_reboots() {
    NAME1=$1
    NAME2=$2
    PROJECT=$3
    ZONE=$4

until gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME1" --command "echo $NAME1 Rebooted!"
do
    echo "$NAME1 rebooting.."
    sleep 2
done;

until gcloud compute ssh --project "$PROJECT" --zone "$ZONE" "$NAME2" --command "echo $NAME2 Rebooted!"
do
    echo "$NAME2 rebooting..."
    sleep 2
done;
}

# Comment out completed steps

#create_project
source settings.sh

make_vm ${NAME1} ${PROJECT} ${ZONE}
make_vm ${NAME2} ${PROJECT} ${ZONE}

upgrade_kernel ${NAME1} ${PROJECT} ${ZONE}
upgrade_kernel ${NAME2} ${PROJECT} ${ZONE}

wait_for_reboots ${NAME1} ${NAME2} ${PROJECT} ${ZONE}

install_deps ${NAME1} ${PROJECT} ${ZONE}
install_deps ${NAME2} ${PROJECT} ${ZONE}

link_vms ${NAME1} ${NAME2} ${PROJECT} ${ZONE}
