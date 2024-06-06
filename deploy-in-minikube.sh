#!/bin/bash

# Start cluster. Extra beefy.
minikube start --cpus 5 --memory 5120 --addons ingress 

helm install argocd -n argocd argo-cd/helm-chart --values argo-cd/helm-chart/values-custom.yaml --dependency-update --create-namespace

until kubectl -n argocd get secret argocd-initial-admin-secret &> /dev/null; do
  echo "Waiting for secret 'argocd-initial-admin-secret' to be available..."
  sleep 3
done

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --namespace argocd --timeout=120s

kubectl port-forward -n argocd service/argocd-server 8080:443 &

echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"
echo " "
echo "TO ACCESS THE ARGOCD DASHBOARD:"
echo " "
echo "URL: http://argocd.local/"
echo "user: admin"
echo "password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
echo " "
echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"

# We create an application that will monitor the helm-charts/infra/argo-cd directory, the same we used to deploy ArgoCD, making ArgoCD self-managed. Any changes we apply in the helm/infra/argocd directory will be automatically applied.
kubectl create -n argocd -f argo-cd/self-manage/argocd-application.yaml  

# We create an application that will automatically deploy any ArgoCD Applications we specify in the argo-cd/applications directory (App of Apps pattern).
kubectl create -n argocd -f argo-cd/self-manage/argocd-app-of-apps-application.yaml  


echo "Waiting for Cloudbees pod to be ready..."

until [[ $(kubectl -n cloudbees-core get pods -l "app.kubernetes.io/name=cloudbees-core" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
  echo "Waiting for Cloudbees pod to be ready..."
  sleep 3 
done
 
kubectl port-forward -n cloudbees-core service/cjoc 8081:80 &

echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"
echo " "
echo "TO ACCESS THE CLOUDBEES OPERATIONS CENTER DASHBOARD:"
echo " "
echo "URL: http://cloudbees-core.local/cjoc/"
echo " "
echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"

kubectl wait --for=condition=ready -n exercise-dev pod -l app=exercise-api-gradle-dev
kubectl port-forward -n exercise-dev service/exercise-api-gradle-dev-service 8082:8080 &

