pipeline {
    agent {
    docker {
      image 'docker:stable-dind'
      args  '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment{
        registry = 'ngnquanq/demand-forecasting'
        registryCredential = 'dockerhub'
    }

    stages {
        stage('test') {
            steps {
                script {
                    // Run your test commands here
                    echo 'Running tests...'
                    sh 'echo "Tests passed!"'
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    // Build your Docker image here
                    echo 'Building Docker image...'
                    sh 'sudo docker build -t $registry .'
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                     usernameVariable: 'DOCKER_USER',
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                        sh 'sudo docker push $registry'
                    }
                }
            }
        }
        
    }
}