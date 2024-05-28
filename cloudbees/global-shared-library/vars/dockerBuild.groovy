def login() {
    withCredentials([usernamePassword(credentialsId: 'hub.docker', usernameVariable: 'hubUsername', passwordVariable: 'hubPassword')]) {
        sh """
            docker login --username="${hubUsername}" --password="${hubPassword}"
        """
    }
}

def build(String tag) {
    sh """
        docker build -t "${tag}" .
    """
}

def push(String tag) {
    sh """
        docker push "${tag}"
    """
}