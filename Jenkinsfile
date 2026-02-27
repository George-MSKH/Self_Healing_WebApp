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
                sshagent(['my-ssh-key']) {
                    sh """
                        export ANSIBLE_ROLES_PATH=./ansible/roles
                        export ANSIBLE_HOST_KEY_CHECKING=False

                        ansible-playbook -i ansible/inventory.json \\
                            ansible/playbooks/application.yml \\
                            -u ubuntu \\
                            --ssh-common-args "-o StrictHostKeyChecking=no -o BatchMode=yes"
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