pipeline {
    agent any

    tools {
        nodejs 'Node16'
    }

    environment {

        SCANNER_HOME = tool 'SonarScanner'

        AWS_ACCOUNT = "285861554470"
        AWS_REGION  = "ap-south-1"

        ECR_REGISTRY = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        FRONTEND_REPO = "frontend"
        BACKEND_REPO  = "backend"

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-token',
                    url: 'https://github.com/Asha-Priya/Advanced-End-to-End-DevSecOps.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=devops-project \
                    -Dsonar.sources=Application-Code
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Verify Docker') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh 'trivy fs Application-Code/frontend'
                sh 'trivy fs Application-Code/backend'
            }
        }

        stage('Build Frontend Image') {
            steps {
                dir('Application-Code/frontend') {

                    sh """
                    docker build \
                    -t ${FRONTEND_REPO}:latest \
                    -t ${FRONTEND_REPO}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Build Backend Image') {
            steps {

                dir('Application-Code/backend') {

                    sh """
                    docker build \
                    -t ${BACKEND_REPO}:latest \
                    -t ${BACKEND_REPO}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {

                sh "trivy image ${FRONTEND_REPO}:${IMAGE_TAG}"
                sh "trivy image ${BACKEND_REPO}:${IMAGE_TAG}"

            }
        }

        stage('Push Images to Amazon ECR') {

            steps {

                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-ecr-creds'
                    ]
                ]) {

                    sh """

                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker tag ${FRONTEND_REPO}:latest ${ECR_REGISTRY}/${FRONTEND_REPO}:latest
                    docker tag ${FRONTEND_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}

                    docker tag ${BACKEND_REPO}:latest ${ECR_REGISTRY}/${BACKEND_REPO}:latest
                    docker tag ${BACKEND_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}

                    docker push ${ECR_REGISTRY}/${FRONTEND_REPO}:latest
                    docker push ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}

                    docker push ${ECR_REGISTRY}/${BACKEND_REPO}:latest
                    docker push ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}

                    """
                }
            }
        }

        stage('Update Kubernetes Manifests') {

            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-token',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_TOKEN'
                    )
                ]) {

                    sh """

                    echo "Updating Kubernetes deployment files..."

                    sed -i "s#image: .*frontend:.*#image: ${ECR_REGISTRY}/frontend:${IMAGE_TAG}#g" Kubernetes/frontend/deployment.yaml

                    sed -i "s#image: .*backend:.*#image: ${ECR_REGISTRY}/backend:${IMAGE_TAG}#g" Kubernetes/backend/deployment.yaml

                    git config user.name "Jenkins"
                    git config user.email "jenkins@devsecops.com"

                    git add Kubernetes/frontend/deployment.yaml
                    git add Kubernetes/backend/deployment.yaml

                    git commit -m "Update images to Build-${IMAGE_TAG}" || echo "No changes to commit"

                    git push https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/Asha-Priya/Advanced-End-to-End-DevSecOps.git HEAD:main

                    """
                }
            }
        }
    }

    post {

        success {

            echo "==========================================="
            echo "Pipeline Completed Successfully"
            echo ""
            echo "Frontend Image : ${ECR_REGISTRY}/frontend:${IMAGE_TAG}"
            echo "Backend Image  : ${ECR_REGISTRY}/backend:${IMAGE_TAG}"
            echo "Build Number   : ${BUILD_NUMBER}"
            echo "==========================================="
        }

        failure {

            echo "==========================================="
            echo "Pipeline Failed"
            echo "==========================================="
        }

        always {

            sh 'docker image prune -af || true'

            cleanWs()
        }
    }
}