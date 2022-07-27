pipeline {
    agent any
        stages {
            stage('terraform init') {
                steps {
                    sh 'terraform init '
                }
            }
            stage('terraform apply') {
                steps {
                    withAWS(credentials: 'aws_credential', region: 'us-east-1'){
                    sh 'terraform apply --auto-approve'}
                    }
            }
        }
    }

