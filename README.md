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

## Important
- You're going to need my DockerHub and GitHub credentials, not ideal, but working around this would open up many potential errors. There's nothing important in DockerHub and nor in that GitHub account, so I'll share them with you in the email.
- There's further (informal) notes. You can find them [here](/notes.md).
- This environment will use the main branch of api-gradle-service.
- I didn't include JaCoCo and SonarQube stages in this environment because it involved more manual steps by installing and configuring plugins.

<br/>
<br/>

## Instructions
I built this lab in WSL2 for Windows. Some steps may vary if you are running on Linux.

1. Run deploy-in-minikube.sh
```bash
git clone https://github.com/tomasferrarisenda/bootstrap-lab.git
cd bootstrap-lab
chmod +x deploy-in-minikube.sh
./deploy-in-minikube.sh
```
2. Meanwhile, add to C:\Windows\System32\drivers\etc\hosts:
```bash
127.0.0.1 argocd.local
127.0.0.1 cloudbees-core.local
127.0.0.1 grafana.local

127.0.0.1 frontend-dev.exercise
127.0.0.1 frontend-stage.exercise
127.0.0.1 frontend-prod.exercise

127.0.0.1 api-gradle-dev.exercise
127.0.0.1 api-gradle-stage.exercise
127.0.0.1 api-gradle-prod.exercise
```
3. When the script is done, run (you may have to input your password):
```bash
minikube tunnel 
```
You now should be able to access:
- ArgoCD at ```http://argocd.local/``` (credential are logged by the deploy-in-minikube.sh script)
- Cloudbees Operartions Center at ```http://cloudbees-core.local/cjoc/```
- Grafana at ```http://grafana.local/``` (user: ```admin``` / password: ```admin```)
- SwaggerUI at ```http://frontend-dev.exercise/```

4. Log into Operations Center at ```http://cloudbees-core.local/cjoc/```
5. Create First Admin User:
  - Username: ```admin```
  - Pass: ```admin```
  - Full Name: ```admin```
  - Email: ```admin@admin.com```
6. Start "exercise" managed controller.
    When deployed, access the "exercise" managed-controller UI at ```http://cloudbees-core.local/exercise/```

**NOTE**: I tried to automate these next steps but couldn't get the CasC for the managed controllers to work. We need to do them manually.

8. Go through wizard. Install all suggested plugins
9. Create credentials in "exercise" managed-controller for dockerhub. ID and description must be ```dockerhub```.
10. Create credentials in "exercise" managed-controller for github with PAT. ID and description must be ```github```.
11. Add Shared Library. On "exercise" managed-controller go Manage Jenkins -> System -> Global Pipeline Libraries  
  - Name: ```global-shared-library```
  - Default version: ```main```
  - Source Code Management: GitHub
  - Credentials: ```github```
  - Repository HTTPS URL: ```https://github.com/tomasferrarisenda/global-shared-library```
  - Save
12. Add Template Catalog. Go to Pipeline Template Catalog -> Add catalog
  - Branch: ```main```
  - Check for template catalog updates every: 15 minutes
  - Catalog source code repository location: GitHub
  - Credentials: ```github```
  - Repository HTTPS URL: ```https://github.com/tomasferrarisenda/pipeline-template-catalogs```
  - Save
13. Create Kubernetes pod template for just Docker builds. On "exercise" managed-controller go to Manage Jenkins -> Kubernetes Pod Templates:
  - Name: ```docker```
  - Labels: ```dockerContainerBuilds```
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
14. Create Kubernetes pod template for Gradle builds. On "exercise" managed-controller go to Manage Jenkins -> Kubernetes Pod Templates:
  - Name: ```gradle-docker```
  - Labels: ```gradleContainerBuilds```
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
    env:
    - name: API_SERVER_URL
      value: http://exercise-api-gradle-dev-service.exercise-dev.svc.cluster.local:8080
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
15. Create Kubernetes pod template for Gradle Tests. On "exercise" managed-controller go to Manage Jenkins -> Kubernetes Pod Templates:
  - Name: ```gradle```
  - Labels: ```gradleTests```
  - Raw YAML for the Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gradle
spec:
  containers:
  - name: gradle
    image: gradle:6.8.3-jdk11
    command:
    - cat
    tty: true
    env:
    - name: API_SERVER_URL
      value: http://exercise-api-gradle-dev-service.exercise-dev.svc.cluster.local:8080
  restartPolicy: Never
```
16. (Optional if you plan to build the omniman service) Create Kubernetes pod template for Maven builds. On "exercise" managed-controller go to Manage Jenkins -> Kubernetes Pod Templates:
  - Name: ```maven-docker```
  - Labels: ```mavenContainerBuilds```
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
17. Create api-gradle pipeline. On "exercise" managed-controller go to New item:
  - Name: ```api-gradle```
  - Gradle Docker Build and Deploy
  - Complete with appropiate values
  - Save
  - OK
18. Create api-gradle-test pipeline. On "exercise" managed-controller go to New item:
  - Name: ```api-gradle-unit-test```
  - Gradle Unit Test
  - Complete with appropiate values
  - Save
  - OK
19. (Optional) Create mariadb pipeline. On "exercise" managed-controller go to New item:
  - Name: ```mariadb```
  - Docker Build and Deploy
  - OK
  - Complete with appropiate values
  - Save
20. (Optional) Create frontend pipeline. On "exercise" managed-controller go to New item:
  - Name: ```frontend```
  - Docker Build and Deploy
  - OK
  - Complete with appropiate values
  - Save
21. (Optional) Create ominman pipeline. On "exercise" managed-controller go to New item:
  - Name: ```omniman```
  - Maven Docker Build and Deploy
  - OK
  - Complete with appropiate values
  - Save
22. You can now build any of the services. If successful, they will be automatically deployed to Minikube after a few minutes. 

<br/>
<br/>

## Logs
You can see the logs for each pod on the Explore tab of Grafana. Here's an example for [example-api-gradle-dev](http://grafana.local/explore?orgId=1&left=%7B%22datasource%22:%22P8E80F9AEF21F6940%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22%7Bapp%3D%5C%22exercise-api-gradle-dev%5C%22%7D%20%7C%3D%20%60%60%22,%22queryType%22:%22range%22,%22datasource%22:%7B%22type%22:%22loki%22,%22uid%22:%22P8E80F9AEF21F6940%22%7D,%22editorMode%22:%22builder%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D):

<p title="logs" align="center"> <img src="https://i.imgur.com/pbqYfVg.jpg"></p>





