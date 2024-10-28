# Create Reservations
This tutorial is for the procedure to Cloud Run jobs that executes Google Compute Engine reservations.

## Preparation
Once before you proceed, you may have to edit files to suit your environment.

[env-vars.yaml]
* RESERVATION_NAME: Your unique reservation name
* NUMBER_OF_VMS: Number of VMs you reserve (default:32)
* ZONE: Zone where you deploy your VMs (default:asia-northeast1-b)
* MACHINE_TYPE: Type of VMs you reserve (default:a3-megagpu-8g)
* PROJECT_ID: Your Google Cloud project id (NOT project name or number)


## Environment variables for crreating reservations
### Verify your current project
```bash
gcloud config get project
```
If shell returns "(unset)" it means that you haven't currently been any projects. Then you should set your project as below:
```bash
gcloud config set project [YOUR_PROJECT_ID]
```

### Set Project ID
```bash
export PROJECT_ID=$(gcloud config get project)
```

### Your Region
```bash
export REGION="asia-northeast1"
```

## Setup Service Account
### Create service account
```bash
gcloud iam service-accounts create reservation-creator
```
### Grant service-account IAM roles to create reservations
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:reservation-creator@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/compute.instanceAdmin.v1"
```
## Build image & push to Artifact Registry
### Create repository
```bash
gcloud artifacts repositories create reservations \
--repository-format=docker \
--location=$REGION \
--project=$PROJECT_ID
```

### Store Repository URL to Env-vars
```bash
export REPOSITORY_URL="REGION-docker.pkg.dev/$PROJECT_ID/reservations"
```

### Build container image
```bash
docker build . -t reservation-job
```

### Tag your image
```bash
docker tag reservation-job:latest $REPOSITORY_URL/reservation-job:latest
```

### Push image
```bash
docker push $REPOSITORY_URL/reservation-job:latest
```

## Create Cloud Run jobs - job
```bash
gcloud run jobs create reservation-job \
--image $REPOSITORY_URL/reservation-job:latest \
--region=$REGION \
--service-account=reservation-creator@${PROJECT_ID}.iam.gserviceaccount.com \
--env-vars-file=env-vars.yaml \
--project=$PROJECT_ID
```
