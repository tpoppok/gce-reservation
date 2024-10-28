FROM debian:buster-slim

RUN apt-get update  -y && \
    apt-get install -y curl && \
    apt-get install -y sudo && \
    apt-get install -y apt-transport-https && \
    apt-get install -y ca-certificates && \
    apt-get install -y gnupg

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && \
    apt-get install google-cloud-sdk -y && \
    apt-get install jq -y

CMD gcloud compute reservations create $RESERVATION_NAME --vm-count $NUMBER_OF_VMS --zone $ZONE --machine-type $MACHINE_TYPE \
    --description=$RESERVATION_NAME \
    --project=$PROJECT_ID
