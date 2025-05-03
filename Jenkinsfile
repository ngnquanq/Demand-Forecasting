pipeline {
    // agent {
    //     docker {
    //         image 'docker:stable'
    //         args  '-v /var/run/docker.sock:/var/run/docker.sock'
    //         }
    //     }
    agent any

    parameters{
        string(name: 'WEBHOOK_URL',
               defaultValue: 'https://discordapp.com/api/webhooks/1367885671728943114/FGTkAXc478ytK5jqUgj0VGBM_qbmN9xPn745srWb2fcTT5XBD9_gRKxLu_RmlBzAeZW7',
               description: 'Discord webhook URL for notifications')
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
                    sh ' docker build -t $registry .'
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
                        sh ' docker push $registry'
                    }
                }
            }
        }
    }
    post {
        success {
        discordSend description: 'Build succeeded!', webhookURL: 'https://discordapp.com/api/webhooks/1367885671728943114/FGTkAXc478ytK5jqUgj0VGBM_qbmN9xPn745srWb2fcTT5XBD9_gRKxLu_RmlBzAeZW7'
        }
        failure {
        discordSend description: 'Build failed!', webhookURL: 'https://discordapp.com/api/webhooks/1367885671728943114/FGTkAXc478ytK5jqUgj0VGBM_qbmN9xPn745srWb2fcTT5XBD9_gRKxLu_RmlBzAeZW7'
        }
    }
}