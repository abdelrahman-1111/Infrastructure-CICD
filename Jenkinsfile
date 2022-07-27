pipeline {
    agent any
    tool name: 'terraform', type: 'terraform'
    stages {
        stage('terraform init') {
            steps {
            sh 'terraform init '
            }
        stage('terraform apply') {
            steps {
            sh 'terraform apply --auto-approve'
                }
            }
        }
    }
}
