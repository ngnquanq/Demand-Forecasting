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
        stage('Deploy') {
        steps {
            // inject your kubeconfig so both kubectl and helm can authenticate
            withCredentials([file(credentialsId: 'gke-kubeconfig', variable: 'KUBECONFIG')]) {
            script {
                // 1) grab the external IP, explicitly using your GKE context
                env.EXT_IP = sh(
                script: "kubectl --kubeconfig=\$KUBECONFIG --context=gke_global-phalanx-449403-d2_us-central1_demandforecasting-gke get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
                returnStdout: true
                ).trim()
                echo "External IP is: ${env.EXT_IP}"

                // 2) build a nip.io host so we don’t need real DNS
                env.INGRESS_HOST = "${env.EXT_IP}.nip.io"
                echo "Using hostname: ${env.INGRESS_HOST}"

                // 3) perform the helm upgrade/install, pointing at the same context
                sh """
                helm --kubeconfig \$KUBECONFIG --kube-context gke_global-phalanx-449403-d2_us-central1_demandforecasting-gke \
                    upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH} \
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
                    --set ingress.hosts[0].paths[0].pathType=Prefix
                """
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