pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = "Dockerhub"
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

        stage('Push To Dockerhub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'Dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                                sh "docker login -u ${USER} -p ${PASS}"
                                sh "docker push ${DOCKER_IMAGE}"
                            }
                }
            }
        }

        stage('Deploy To App Servers') {
            steps {
                withCredentials([file(credentialsId: 'my-ssh-key', variable: 'KEY_FILE')]) {
                    sh """
                    export ANSIBLE_ROLES_PATH=./ansible/roles
                    ANSIBLE_HOST_KEY_CHECKING=False \
                    ansible-playbook -i ansible/inventory.json \
                    ansible/playbooks/application.yml \
                    --private-key=${KEY_FILE} \
                    -u ubuntu
                    --extra-vars "ansible_ssh_private_key_file=$KEY_FILE" \
                    --ssh-common-args "-o ProxyJump=ubuntu@18.157.169.200 -o IdentityFile=$KEY_FILE -o StrictHostKeyChecking=no"
                    """
                }
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