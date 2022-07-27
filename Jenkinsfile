pipeline {
    agent any
        stages {
            stage('terraform init') {
                steps {
                    withAWS(credentials: 'aws_credential', region: 'us-east-1'){
                    sh 'terraform init '}
                }
            }
            stage('terraform apply') {
                steps {
                    withAWS(credentials: 'aws_credential', region: 'us-east-1'){
                    sh 'terraform apply --auto-approve -no-color '}
                    }
            }
            stage('creating ec2 slave - ansible playbook ') {
                steps {
                    withAWS(credentials: 'aws_credential', region: 'us-east-1'){
                    sh 'ansible-playbook -i inventroy slave.yaml  '}
                }
            }

        }
    }

