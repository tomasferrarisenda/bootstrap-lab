# CLOUDBEES-MINIKUBE LAB BOOTSTRAP
<br/>

## Prerequisites
- minikube installed
- kubectl installed
- helm installed

<br/>
<br/>

## Other repos this project depends on
- https://github.com/tomasferrarisenda/infra-tools-helm-charts
- https://github.com/tomasferrarisenda/cloudbees-casc
- https://github.com/tomasferrarisenda/global-shared-library
- https://github.com/tomasferrarisenda/pipeline-template-catalogs
- https://github.com/tomasferrarisenda/frontend-service
- https://github.com/tomasferrarisenda/frontend-service-helm-chart
- https://github.com/tomasferrarisenda/api-gradle-service
- https://github.com/tomasferrarisenda/api-gradle-service-helm-chart
- https://github.com/tomasferrarisenda/mariadb-service
- https://github.com/tomasferrarisenda/mariadb-service-helm-chart
- https://github.com/tomasferrarisenda/omniman-service
- https://github.com/tomasferrarisenda/omniman-service-helm-chart

<br/>
<br/>

## Further (informal) notes
You can find them [here](/notes.md).

<br/>
<br/>

## Instructions
I'm running this lab in WSL2 for Windows. There are some steps you don't need to run or will need to modify if you are running on Linux.

1. Run deploy-in-minikube.sh
```bash
chmod +x deploy-in-minikube.sh
./deploy-in-minikube.sh
```
1. Edit C:\Windows\System32\drivers\etc\hosts. Add:
```bash
127.0.0.1 hello-world.example
127.0.0.1 cloudbees-core.local
127.0.0.1 grafana.local
127.0.0.1 frontend-dev.exercise
127.0.0.1 frontend-stage.exercise
127.0.0.1 frontend-prod.exercise
```
<!-- 2. Run:
```bash
# sudo echo "$(minikube ip) cloudbees-core.local" | sudo tee -a /etc/hosts
# sudo echo "127.0.0.1 cloudbees-core.local" | sudo tee -a /etc/hosts
minikube tunnel
``` -->
<!-- 2. Log into Operations Center at http://localhost:8081/cjoc/ -->
1. Run:
```bash
minikube tunnel 
```
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
<!-- 7. Get password:
```bash
kubectl wait --for=condition=ready -n cloudbees-core pods/exercise-0  --timeout=120s
echo "password: $(kubectl exec pods/exercise-0  --namespace cloudbees-core -- cat /var/jenkins_home/secrets/initialAdminPassword)"
``` -->
6. Acces the "exercise" managed-controller UI at http://cloudbees-core.local/exercise/
<!-- 6. Acces the "invincible-gtg" managed-controller UI -->
**NOTE**: I tried to automate these next steps but couldn't get the CasC for the managed controllers to work. We need to do them manually.

  7. Go through wizard. Install all suggested plugins
  8. Create credentials in "exercise" managed-controller for dockerhub. ID must be "dockerhub".
  9. Create credentials in "exercise" managed-controller for github with PAT. ID must be "github".
  10. Add Shared Library. On "exercise" managed-controller go Manage Jenkins -> System -> Global Pipeline Libraries  
    - Name: global-shared-library
    - Default version: main
    - Source Code Management: GitHub
    - Credentials: GitHub
    - Repository HTTPS URL: https://github.com/tomasferrarisenda/global-shared-library
    - Save
  11. Add Template Catalog. Go to Pipeline Template Catalog -> Add catalog
    - Branch: main
    - Check for template catalog updates every: 15 minutes
    - Catalog source code repository location: GitHub
    - Credentials: GitHub
    - Repository HTTPS URL: https://github.com/tomasferrarisenda/pipeline-template-catalogs
    - Save
  12. Create Kubernetes pod template for just Docker builds. On "exercise" managed-controller go to Manage Jenkins -> Kubernetes Pod Templates:
    - Name: docker 
    - Labels: dockerContainerBuilds
    - Raw YAML for the Pod:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: docker
  spec:
    containers:
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
  12. Create Kubernetes pod template for Gradle builds. On "exercise" managed-controller go to Manage Jenkins -> Kubernetes Pod Templates:
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
  12. Create Kubernetes pod template for Maven builds. On "exercise" managed-controller go to Manage Jenkins -> Kubernetes Pod Templates:
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
  13. Create frontend pipeline. On "exercise" managed-controller go to New item:
    - Name: frontend
    - Docker Build and Deploy
    - OK
    - Complete with appropiate values
    - Save
  13. Create apiGradle pipeline. On "exercise" managed-controller go to New item:
    - Name: apiGradle
    - Gradle Docker Build and Deploy
    - Complete with appropiate values
    - Save
    - OK
  13. Create mariadb pipeline. On "exercise" managed-controller go to New item:
    - Name: mariadb
    - Docker Build and Deploy
    - OK
    - Complete with appropiate values
    - Save
  14. You can build now any of the service, they will be automatically deployed to Minikube afeter a few minutes. 


## Logs
You can see the logs for each pod on the Explore tab of Grafana. Here's an example for example-api-gradle-dev:

<p title="logs" align="center"> <img src="https://i.imgur.com/pbqYfVg.jpg"></p>

<!-- - http://grafana.local/explore?orgId=1&left=%7B%22datasource%22:%22P8E80F9AEF21F6940%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22%7Bapp%3D%5C%22exercise-api-gradle-dev%5C%22%7D%20%7C%3D%20%60%60%22,%22queryType%22:%22range%22,%22datasource%22:%7B%22type%22:%22loki%22,%22uid%22:%22P8E80F9AEF21F6940%22%7D,%22editorMode%22:%22builder%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D -->

<!-- ### Operations Center
Couldn't deploy Operations Center with CasC because of license:
```bash
2024-05-30 18:10:59.854+0000 [id=30]	SEVERE	jenkins.InitReactorRunner$1#onTaskFailed: Failed ConfigurationAsCode.init
ERROR: This license belongs to another server: 962ad4baa7b523689ed2eec67e92183c
``` -->





