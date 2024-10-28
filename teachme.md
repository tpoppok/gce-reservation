# Create Reservations
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
### Creation (If needed)
```
gcloud iam service-accounts create reservations-creator
```
### Grant the Service Account IAM roles to create reservations
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="reservation_creator@${PROJECT_ID}.iam.gserviceaccount.com" \
--role="roles/compute.instanceAdmin.v1"
```
## Artifact Registry
```
REGION-docker.pkg.dev/YOUR_PROJECT/YOUR_REPOSITORY
```

