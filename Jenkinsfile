pipeline {
    agent any
        stages {
            stage('terraform init') {
                steps {
                    withAWS(credentials: 'aws_credential', region: 'us-east-1'){
                    sh 'terraform init -upgrade -no-color'}
                }
            }
            // stage('terraform destroy') {
            //     steps {
            //         withAWS(credentials: 'aws_credential', region: 'us-east-1'){
            //         sh 'terraform destroy --auto-approve -no-color'}
            //     }
            // }
            stage('terraform plan') {
                steps {
                    withAWS(credentials: 'aws_credential', region: 'us-east-1'){
                    sh 'terraform plan -no-color '}
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
                    sh 'ansible-playbook -i /var/jenkins_home/hosts slave.yaml  '}
                }
            }
            stage('build the application'){
                steps {
                    agent { node { label 'slave-vm'} }
                        dockerfile {
                            filename 'dockerfile'
                            dir 'Nodeapp'
                            label 'redisapp:latest'
                            }
                    }
                }
            stage('deploy the application'){
                steps {
                    agent { node { label 'slave-vm'} }
                        docker {
                            image 'redisapp:latest'
                            label 'redisapp:latest'
                            args '-p 3000:3000'
                        }
                    }
                }
            }
        }


