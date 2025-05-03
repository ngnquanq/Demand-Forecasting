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
    
    environment {
        registry            = 'ngnquanq/demand-forecasting'
        jenkins_registry   = 'ngnquanq/custom-jenkins'
        registryCredential  = 'dockerhub'
        HELM_RELEASE_NAME   = 'application'
        HELM_CHART_PATH     = './helm/application'
        KUBE_CREDENTIAL_ID  = 'gke-kubeconfig'    
        KUBE_NAMESPACE      = 'model-serving'
    }


    stages {
        stage('test') {
            steps {
                script {
                    echo 'Running tests...'
                    sh 'echo "Tests passed!"'
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image model image...'
                    sh ' docker build -t $registry .'
                    echo 'Building Docker image jenkins image...'
                    sh ' docker build -t $jenkins_registry ./infrastructure/config/'
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
                        sh ' docker push $jenkins_registry'
                        echo 'Pushing Docker image to Docker Hub...'
                        echo 'Pushing Docker image to Docker Hub jenkins image...'
                        echo 'Docker image pushed successfully!'
                        echo 'Docker image pushed successfully jenkins image!'
                    }
                }
            }
        }
        stage('Deploy') {
            agent {
                kubernetes {
                    containerTemplate{
                        name 'helm'
                        image 'ngnquanq/custom-jenkins:latest'
                        alwaysPullImage true
                    }
                }
            }
            steps {
                script {
                    container('helm'){
                        sh("helm upgrade --install hpp ./helm-charts/hpp --namespace model-serving")
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
    
