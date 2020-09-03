# bin/bash

if [ ! $# -eq 1 ]; then
  echo "Must supply cluster name as args"
  exit 1
elif [ -z "$WAVEFRONT_URL" ]; then
  echo "Must set Wavefront URL"
  exit 1
elif [ -z "$WAVEFRONT_API_KEY" ]; then
  echo "Must set Wavefront API KEY"
  exit 1
fi

# TODO make this better
if [[ "$CREATE_WAVEFRONT_COLLECTOR_PSP" == "true" || "$CREATE_WAVEFRONT_COLLECTOR_PSP" == "yes" ]]; then
  echo "Creating Wavefront collector pod security policies"
  kubectl apply -f k8s/wavefront-psp/wavefront-collector-psp.yaml
  kubectl apply -f k8s/wavefront-psp/wavefront-collector-rbac-role.yaml
fi

CLUSTER_NAME=$1
ZIPKIN_APP_NAME=spring-pet-clinic

kubectl create namespace wavefront
helm repo add wavefront https://wavefronthq.github.io/helm/
helm repo update
helm upgrade --install wavefront wavefront/wavefront -n wavefront \
  --set wavefront.url=$WAVEFRONT_URL \
  --set wavefront.token=$WAVEFRONT_API_KEY \
  --set clusterName=$CLUSTER_NAME \
  --set proxy.zipkinPort=9411 \
  --set proxy.args="--traceZipkinApplicationName $ZIPKIN_APP_NAME"
