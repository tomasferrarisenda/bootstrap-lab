
# LEER!!!!!!!!!!!!!!!!!!!!!!!!!
https://docs.cloudbees.com/docs/cloudbees-ci/latest/casc-controller/items#_supported_items_using_casc
https://hellokube.dev/posts/configure-minikube-ingress-on-wsl2/

```bash
minikube tunnel
```
# CLOUDBEES CORE MINIKUBE LAB



## Instructions
1. Run deploy-in-minikube.sh
```bash
chmod +x deploy-in-minikube.sh
./deploy-in-minikube.sh
```
1. Edit C:\Windows\System32\drivers\etc\hosts. Add:
```bash
127.0.0.1 cloudbees-core.local
```
2. Run:
```bash
# sudo echo "$(minikube ip) cloudbees-core.local" | sudo tee -a /etc/hosts
# sudo echo "127.0.0.1 cloudbees-core.local" | sudo tee -a /etc/hosts
minikube tunnel
```
<!-- 2. Log into Operations Center at http://localhost:8081/cjoc/ -->
2. Log into Operations Center at http://cloudbees-core.local/cjoc/
<!-- 3. Go through wizard -->
3. Create First Admin User:
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
<!-- 4. Start "invincible-gtg" managed controller. -->
4. Start "exercise" managed controller.
<!-- 5. Run:
```bash
kubectl wait --for=condition=ready -n cloudbees-core pod/invincible-gtg-0 
kubectl port-forward -n cloudbees-core service/invincible-gtg 8082:80 
``` -->
7. Get password:
```bash
kubectl wait --for=condition=ready -n cloudbees-core pods/exercise-0  --timeout=120s
echo "password: $(kubectl exec pods/exercise-0  --namespace cloudbees-core -- cat /var/jenkins_home/secrets/initialAdminPassword)"
```
6. Acces the "exercise" managed-controller UI
<!-- 6. Acces the "invincible-gtg" managed-controller UI -->
7. Go through wizard
8. Create credentials in invincible-gtg-managed-controller for dockerhub. ID must be "dockerhub".
9. Create credentials in invincible-gtg-managed-controller for github with PAT. ID must be "github".
10. Add Shared Library. On invincible-gtg-managed-controller go Manage Jenkins -> System -> Global Pipeline Libraries  
  - Name: global-shared-library
  - Default version: main
  - Source Code Management: GitHub
  - Credentials: GitHub
  - Repository HTTPS URL: https://github.com/tomasferrarisenda/global-shared-library
11. Add Template Catalog. Go to Pipeline Template Catalog -> Add catalog
  - Branch: main
  - Check for template catalog updates every: 15 minutes
  - Catalog source code repository location: GitHub
  - Credentials: GitHub
  - Repository HTTPS URL: https://github.com/tomasferrarisenda/pipeline-template-catalogs
12. Create Kubernetes pod template. On invincible-gtg-managed-controller go Manage Jenkins -> Kubernetes Pod Templates:
  - Name: maven-docker 
  - Labels: mavenContainerBuilds
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
12. Create Kubernetes pod template. On invincible-gtg-managed-controller go Manage Jenkins -> Kubernetes Pod Templates:
  - Name: gradle-docker 
  - Labels: gradleContainerBuilds
  - Raw YAML for the Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gradle-docker
spec:
  containers:
  - name: gradle
    image: gradle:6.8.3-jdk11
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





