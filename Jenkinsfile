pipeline {
    agent any

    tools {
        nodejs 'Node16'
    }

    environment {
        SCANNER_HOME = tool 'SonarScanner'
        FRONTEND_IMAGE = "frontend:latest"
        BACKEND_IMAGE = "backend:latest"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-token',
                    url: 'https://github.com/Asha-Priya/Advanced-End-to-End-DevSecOps.git'
            }
        }

        stage('Install Frontend Dependencies') {
            steps {
                dir('Application-Code/frontend') {
                    sh 'npm install'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('Application-Code/frontend') {
                    sh 'npm run build'
                }
            }
        }

        stage('Install Backend Dependencies') {
            steps {
                dir('Application-Code/backend') {
                    sh 'npm install'
                }
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
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh 'trivy fs .'
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                dir('Application-Code/frontend') {
                    sh "docker build -t ${FRONTEND_IMAGE} ."
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                dir('Application-Code/backend') {
                    sh "docker build -t ${BACKEND_IMAGE} ."
                }
            }
        }
        stage('Login to Amazon ECR') {
            steps {
                sh '''
        aws ecr get-login-password --region ap-south-1 | \
        docker login --username AWS --password-stdin 108964700364.dkr.ecr.ap-south-1.amazonaws.com
        '''
    }
}
       stage('Push Frontend Image') {
           steps {
               sh '''
        docker tag frontend:latest 108964700364.dkr.ecr.ap-south-1.amazonaws.com/frontend:latest
        docker push 108964700364.dkr.ecr.ap-south-1.amazonaws.com/frontend:latest
        '''
    }
}
        stage('Push Backend Image') {
            steps {
                sh '''
        docker tag backend:latest 108964700364.dkr.ecr.ap-south-1.amazonaws.com/backend:latest
        docker push 108964700364.dkr.ecr.ap-south-1.amazonaws.com/backend:latest
        '''
    }
}
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image ${FRONTEND_IMAGE}"
                sh "trivy image ${BACKEND_IMAGE}"
            }
        }
    }

    post {
        always {
            cleanWs()
        }

        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }
    }
}