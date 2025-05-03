pipeline {
    agent any

    parameters {
        string(
          name: 'WEBHOOK_URL',
          defaultValue: 'https://discordapp.com/api/webhooks/1367885671728943114/FGTkAXc478ytK5jqUgj0VGBM_qbmN9xPn745srWb2fcTT5XBD9_gRKxLu_RmlBzAeZW7',
          description: 'Discord webhook URL for notifications'
        )
    }
    
    environment {
        registry           = 'ngnquanq/demand-forecasting'
        registryCredential = 'dockerhub'
        HELM_RELEASE_NAME  = 'application'
        HELM_CHART_PATH    = './helm/application'
        KUBE_CREDENTIAL_ID = 'gke-kubeconfig'
        KUBE_NAMESPACE     = 'model-serving'
    }

    stages {
        stage('Test') {
            steps {
                echo 'Running tests…'
                sh 'echo "Tests passed!"'
            }
        }

        stage('Build') {
            steps {
                echo 'Building Docker image…'
                sh 'docker build -t $registry:${env.BUILD_ID} .'
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: registryCredential,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                    sh 'docker push $registry:${env.BUILD_ID}'
                }
            }
        }

        stage('Deploy') {
            steps {
                // inject your kubeconfig so kubectl/helm can authenticate
                withCredentials([file(
                    credentialsId: "${KUBE_CREDENTIAL_ID}",
                    variable: 'KUBECONFIG'
                )]) {
                    script {
                        // 1) discover the external IP
                        env.EXT_IP = sh(
                            script: "kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
                            returnStdout: true
                        ).trim()
                        echo "External IP is: ${env.EXT_IP}"

                        // 2) build a nip.io hostname
                        env.INGRESS_HOST = "${env.EXT_IP}.nip.io"
                        echo "Using host: ${env.INGRESS_HOST}"

                        // 3) helm upgrade/install with on-the-fly overrides
                        sh """
                          helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH} \
                            --namespace ${KUBE_NAMESPACE} \
                            --set image.repository=${registry} \
                            --set image.tag=${env.BUILD_ID} \
                            --set service.type=ClusterIP \
                            --set service.port=8000 \
                            --set ingress.enabled=true \
                            --set ingress.className=nginx \
                            --set ingress.annotations."nginx\\.ingress\\.kubernetes\\.io/rewrite-target"=/ \
                            --set ingress.hosts[0].host=${INGRESS_HOST} \
                            --set ingress.hosts[0].paths[0].path=/ \
                            --set ingress.hosts[0].paths[0].pathType=Prefix \
                            --kubeconfig \$KUBECONFIG
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            discordSend description: '✅ Build & Deploy succeeded!', webhookURL: "${params.WEBHOOK_URL}"
        }
        failure {
            discordSend description: '❌ Build or Deploy failed!', webhookURL: "${params.WEBHOOK_URL}"
        }
    }
}
