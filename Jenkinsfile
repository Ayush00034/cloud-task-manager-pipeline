pipeline {
    agent {
        label 'ayush'
    }

    environment {
        IMAGE_NAME = 'cloud-task-manager'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test1') {
            steps {
                sh '''
                export APP_SERVER_HOST=35.154.14.209
                export RDS_ENDPOINT=cloud-task-manager-db.cj24i200o8mb.ap-south-1.rds.amazonaws.com:3306
                export RDS_PASSWORD=YourSecurePassword123!
                export S3_BUCKET=cloud-task-manager-uploads-1tmyl5

                echo "Hello"
                echo "$APP_SERVER_HOST"
                '''
            }
        }
    }
}