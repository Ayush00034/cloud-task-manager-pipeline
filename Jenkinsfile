pipeline {
    agent {
        label 'ayush'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Credential Test') {
            steps {
                withCredentials([string(credentialsId: 'rds-password', variable: 'RDS_PASSWORD')]) {
                    sh '''
                        echo "Credential loaded successfully"
                        echo "Password length: ${#RDS_PASSWORD}"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Credential test passed.'
        }

        failure {
            echo 'Credential test failed.'
        }
    }
}