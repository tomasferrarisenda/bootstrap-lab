
# LEER!!!!!!!!!!!!!!!!!!!!!!!!!
https://docs.cloudbees.com/docs/cloudbees-ci/latest/casc-controller/items#_supported_items_using_casc

# CLOUDBEES CORE MINIKUBE LAB

```bash
export MINIKUBE_IP=$(minikube ip)
sudo echo "$MINIKUBE_IP cloudbees-core.local" | sudo tee -a /etc/hosts
```

## Instructions
1. Run deploy-in-minikube.sh
```bash
chmod +x deploy-in-minikube.sh
./deploy-in-minikube.sh
```
2. Log into Operations Center at http://localhost:8081/cjoc/
<!-- 3. Go through wizard -->
3. Create user:
  - Username: admin
  - Pass: admin
  - Full Name: admin
  - Email: admin@admin.com
<!-- 4. Create Managed controller "invincible-gtg-managed-controller":
  - Disk size: (5gb)
  - Storgaeclass: standard
  - Memory: 1024
  - Cpu: 1.0 -->
<!-- 1. Go to http://localhost:8081/cjoc/manage/core-casc-bundles/?tab=2 and click EDIT on invincible-gtg. Write "invincible-gtg" under "Edit availability pattter". Save.
2. Go to the configuration of "invincible-gtg" managed controller. Under Configuration as Code (CasC) select the bundle. Save -->
<!-- 4. Start "invincible-gtg" managed controller. -->
4. Start "invincible-gtg" managed controller.
5. Run:
```bash
kubectl wait --for=condition=ready -n cloudbees-core pod/invincible-gtg-0 
kubectl port-forward -n cloudbees-core service/invincible-gtg 8082:80 
```
6. Acces the "invincible-gtg" managed-controller UI
7. Go through wizard
8. Create credentials in invincible-gtg-managed-controller for dockerhub. ID must be "dockerhub".
9. Create credentials in invincible-gtg-managed-controller for github with PAT. ID must be "github".
10. Add Shared Library. On invincible-gtg-managed-controller go Manage Jenkins -> System -> Global Pipeline Libraries  
  - Name: global-shared-library
  - Default version: main
  - GitHub
  - Repository HTTPS URL: https://github.com/tomasferrarisenda/global-shared-library
11. Add Template Catalog. Go to Pipeline Template Catalog -> Add catalog
  - Branch: main
  - Check for template catalog updates every: 15 minutes
  - GitHub
  - Repository HTTPS URL: https://github.com/tomasferrarisenda/pipeline-template-catalogs
12. Create Kubernetes pod template. On invincible-gtg-managed-controller go Manage Jenkins -> Kubernetes Pod Templates:
  - Name: maven-docker 
  - Labels: containerBuilds
  - Raw YAML for the Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: maven-docker
spec:
  containers:
  - name: maven
    image: maven:3.8.5-openjdk-11
    command:
    - cat
    tty: true
  - name: docker
    image: docker
    args: ["sleep", "10000"]
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-socket
  restartPolicy: Never
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
```
13. Create pipeline: New item -> Maven Docker Build and Deploy


## CasC

<!-- ### Operations Center
Couldn't deploy Operations Center with CasC because of license:
```bash
2024-05-30 18:10:59.854+0000 [id=30]	SEVERE	jenkins.InitReactorRunner$1#onTaskFailed: Failed ConfigurationAsCode.init
ERROR: This license belongs to another server: 962ad4baa7b523689ed2eec67e92183c
``` -->
