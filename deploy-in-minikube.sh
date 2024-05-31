#!/bin/bash

# Prompt the user for their GitHub token
# read -p "Enter your DockerHub username: " REGISTRY_USER 
# read -p "Enter your DockerHub password: " REGISTRY_PASS 
# read -p "Enter your DockerHub email: " REGISTRY_EMAIL

# Start cluster. Extra beefy beause Backstage is a bit heavy.
minikube start --cpus 4 --memory 4096  
# minikube start --cpus 4 --memory 4096 --addons ingress 

# Install ArgoCD
helm install argocd -n argocd helm-charts/infra/argo-cd --values helm-charts/infra/argo-cd/values-custom.yaml --dependency-update --create-namespace

# Get ArgoCD admin password
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
echo "URL: http://localhost:8080/"
echo "user: admin"
echo "password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
echo " "
echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"

# Then we create an application that will monitor the helm-charts/infra/argo-cd directory, the same we used to deploy ArgoCD, making ArgoCD self-managed. Any changes we apply in the helm/infra/argocd directory will be automatically applied.
kubectl create -n argocd -f argo-cd/self-manage/argocd-application.yaml  

# Finally, we create an application that will automatically deploy any ArgoCD Applications we specify in the argo-cd/applications directory (App of Apps pattern).
kubectl create -n argocd -f argo-cd/self-manage/argocd-app-of-apps-application.yaml  


# export REGISTRY_SERVER=https://index.docker.io/v1/

# # Replace `[...]` with the registry username
# export REGISTRY_USER=[...]

# # Replace `[...]` with the registry password
# export REGISTRY_PASS=[...]

# # Replace `[...]` with the registry email
# export REGISTRY_EMAIL=[...]

# kubectl create secret \
#     docker-registry regcred -n cloudbees-core \
#     --docker-server=$REGISTRY_SERVER \
#     --docker-username=$REGISTRY_USER \
#     --docker-password=$REGISTRY_PASS \
#     --docker-email=$REGISTRY_EMAIL


# Wait for the Cloudbees pod to be ready
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
echo "URL: http://localhost:8081/cjoc/"
# echo "password: $(kubectl exec cjoc-0 --namespace cloudbees-core -- cat /var/jenkins_home/secrets/initialAdminPassword)"
echo " "
echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"



