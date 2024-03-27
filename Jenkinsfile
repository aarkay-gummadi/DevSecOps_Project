pipeline {
    agent none
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_cred')
        AWS_DEFAULT_REGION='us-west-2'
        THE_BUTLER_SAYS_SO = credentials('aws_cred')
    }
    stages {
        stage('clean workspace') {
            agent { label 'docker' }
            steps {
                cleanWs ()
            }
        }
        stage('checkout from Git') {
            agent { label 'docker' }
            steps {
                git branch: 'main', url: 'https://github.com/rajkumarqt/waytodevsecops.git'
            }
        }
        stage('Build docker images') {
            agent { label 'docker' }
            steps {
                sh 'docker image build -t rajkumar207/netflix:$BUILD_ID .'
            }
        }
        stage('Trivy Scan') {
            agent { label 'docker' }
            steps {
                script {
                    sh 'trivy image --format json -o trivy-report.json rajkumar207/netflix:$BUILD_NUMBER'
                }
                publishHTML([reportName: 'Trivy Vulnerability Report', reportDir: '.', reportFiles: 'trivy-report.json', keepAll: true, alwaysLinkToLastBuild: true, allowMissing: false])
            }
        }
        stage('login to dockerhub') {
            agent { label 'docker' }
    	    steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }    
        }
        stage('push image to dockerhub') {
            agent { label 'docker' }
            steps {
                sh 'docker image push rajkumar207/netflix:$BUILD_NUMBER'
            }
        }
        stage('k8s up and running') {
            agent { label 'kubernetes' }
            steps {
                sh 'cd deployment/terraform/aws && terraform init && terraform fmt && terraform validate && terraform plan -var-file values.tfvars && terraform $action -var-file values.tfvars --auto-approve'
            }
        }
        stage('deploy to k8s') {
            agent { label 'kubernetes' }
            steps {
                sh 'aws eks update-kubeconfig --name my-eks-cluster'
                sh 'kubectl apply -f deployment/k8s/deployment.yaml'
                sh """
                kubectl patch deployment netflix-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"netflix-app","image":"rajkumar207/netflix:$BUILD_NUMBER"}]}}}}'
                """
            }
        }
        stage('kubescape scan') {
            agent { label 'kubernetes' }
            steps {
                script {
                    sh "/usr/bin/kubescape scan -t 40 deployment/k8s/deployment.yaml --format junit -o TEST-report.xml"
                    junit "**/TEST-*.xml"
                }
            }
        }
    }
}