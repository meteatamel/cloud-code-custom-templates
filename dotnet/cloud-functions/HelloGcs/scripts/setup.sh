#!/bin/bash

source $(dirname $0)/config.sh

echo "Enable required services"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  cloudfunctions.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com

echo "Grant the pubsub.publisher role to the Cloud Storage service account. This is needed for Eventarc's GCS trigger"
SERVICE_ACCOUNT="$(gsutil kms serviceaccount -p $PROJECT_ID)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT \
    --role roles/pubsub.publisher

echo "Grant the default Compute Engine service account the eventarc.eventReceiver IAM role. This is needed for Eventarc's GCS trigger"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role roles/eventarc.eventReceiver

echo "Create a Google Cloud Storage bucket: $BUCKET_NAME"
gsutil mb -l us-central1 gs://${BUCKET_NAME}
