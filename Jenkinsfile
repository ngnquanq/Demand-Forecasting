pipeline {
    agent any

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
                    sh 'docker build -t $registry .'
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
                        sh 'docker push $registry'
                    }
                }
            }
        }
        
    }
}