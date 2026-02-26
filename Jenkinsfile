pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = "dockerhub"
        DOCKER_IMAGE = 'giorgimeskhoradze/nexusapp:1.0'
    }

    stages{
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/George-MSKH/Self_Healing_WebApp.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} -f docker/app/Dockerfile docker/app/"
                }
            }
        }

        stage('Puåsh To Dockerhub') {
            steps {
                script {
                    docker.withDockerRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        docker.image(DOCKER_IMAGE).push()
                    }
                }
            }
        }

        stage('Deploy To App Servers') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/playbooks/application.yml',
                    inventory: 'ansible/inventory.json'
                )
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully!"
        }
        failure {
            echo "Something failed in the pipeline."
        }
    }
}