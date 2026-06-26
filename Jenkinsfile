pipeline {
    agent {
        label 'ayush'
    }

    environment {
        IMAGE_NAME      = 'cloud-task-manager'
        APP_SERVER_HOST = credentials('app-server-host')
        APP_USER        = 'ubuntu'
        RDS_ENDPOINT    = credentials('rds-endpoint')
        RDS_PASSWORD    = credentials('rds-password')
        S3_BUCKET       = credentials('s3-bucket-name')
        AWS_REGION      = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Pulling code from GitHub onto the Build Node...'
                echo "2nd"
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh '''
                echo "Creating venv..."

                python3 -m venv venv

                venv/bin/pip install --upgrade pip
                venv/bin/pip install -r requirements.txt

                venv/bin/python -c "from app.app import app; print('Import OK')"
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                echo 'Provisioning/updating App Server, RDS, S3 via Terraform....'

                dir('terraform') {
                    sh '''
                    terraform init -input=false
                    terraform apply -auto-approve -var-file=terraform.tfvars
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image on the Build Node...'

                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
            }
        }

        stage('Ship Image to App Server') {
            steps {
                echo 'Transferring image from Build Node to App Server via native SSH...'

                sh """
                docker save ${IMAGE_NAME}:latest | gzip > image.tar.gz
                scp -o StrictHostKeyChecking=no image.tar.gz ${APP_USER}@${APP_SERVER_HOST}:/tmp/image.tar.gz

                ssh -o StrictHostKeyChecking=no ${APP_USER}@${APP_SERVER_HOST} \
                'gunzip -c /tmp/image.tar.gz | docker load && rm /tmp/image.tar.gz'
                """
            }
        }

        stage('Deploy on App Server') {
            steps {
                echo 'Starting the container on the App Server...'

                sh """
                ssh -o StrictHostKeyChecking=no ${APP_USER}@${APP_SERVER_HOST} "
                docker stop flask_app 2>/dev/null || true
                docker rm flask_app 2>/dev/null || true

                docker run -d \\
                --name flask_app \\
                --restart always \\
                -p 5000:5000 \\
                -e DB_HOST=${RDS_ENDPOINT} \\
                -e DB_USER=admin \\
                -e DB_PASS=${RDS_PASSWORD} \\
                -e DB_NAME=taskdb \\
                -e S3_BUCKET=${S3_BUCKET} \\
                -e AWS_REGION=${AWS_REGION} \\
                ${IMAGE_NAME}:latest
                "
                """
            }
        }

        stage('Health Check') {
            steps {
                echo 'Verifying deployment...'

                sh "sleep 10 && curl -f http://${APP_SERVER_HOST}:5000/health || exit 1"
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully! Controller dispatched, Build Node built and shipped, App Server is live.'
        }

        failure {
            echo 'Pipeline failed. Check logs above..'
        }
    }
}