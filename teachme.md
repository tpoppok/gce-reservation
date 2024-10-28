# Create Reservations
## Preparation
Once before you proceed, you may have to edit files to suit your environment.

[env-vars]
* RESERVATION_NAME: Your unique reservation name
* NUMBER_OF_VMS: Number of VMs you reserve (default:32)
* ZONE: Zone where you deploy your VMs (default:asia-northeast1-b)
* MACHINE_TYPE: Type of VMs you reserve (default:a3-megagpu-8g)
* PROJECT_ID: Your Google Cloud project id (NOT project name or number)


## Environment variables for crreating reservations
### Project ID
```
export PROJECT_ID=$(gcloud config get project)
```

### Your Region
```
export REGION="asia-northeast1"
```

## Setup Service Account
### Create service account
```
gcloud iam service-accounts create reservations-creator
```
### Grant service-account IAM roles to create reservations
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="reservation_creator@${PROJECT_ID}.iam.gserviceaccount.com" \
--role="roles/compute.instanceAdmin.v1"
```
## Build image & push to Artifact Registry
### Create repository
```
gcloud artifacts repositories create reservations \
--repository-format=docker \
--location=$REGION \
--project=$PROJECT_ID
```

### Store Repository URL to Env-vars
```
export REPOSITORY_URL="REGION-docker.pkg.dev/$PROJEC
/reservation-repo"
```

### Build container image
```
docker build . -t reservation-job
```

### Tag your image
```
docker tag reservations-job:latest $REPOSITORY_URL/reservation-job:latest
```

### Push image
```
docker push $REPOSITORY_URL/reservation-job:latest
```

## Create Cloud Run jobs - job
```
gcloud run jobs create reservation-job \
--image $REPOSITORY_URL/reservation-job:latest \
--region=$REGION \
--service-account=reservation-creator@${PROJECT_ID}.iam.gserviceaccount.com \
--env-vars-file=env-vars.yaml \
--project=$PROJECT_ID
```