def gv

pipeline {
    agent any 
    tools {
        maven 'maven'
    }

    environment {
        REPO_SERVER = "339712792713.dkr.ecr.us-east-1.amazonaws.com"
        REPO_NAME = "${REPO_SERVER}/java-maven"
    }

    stages {

        stage("increment version") {

            steps {
                script {
                    echo "increment the app version ..."
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile("pom.xml") =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_VERSION = "${version}-${BUILD_NUMBER}"
                }
            }
        }

        stage("build app") {
            steps {
                script {
                    echo "building the app ..."
                    sh "mvn clean package"
                }
            }
        }

        stage("build image") {
            environment {
                AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
                AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
            }
            steps {
                script {
                    echo "building docker image ..."
                    withCredentials([
                        usernamePassword(credentialsId: 'ecr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sh "docker build -t ${REPO_NAME}:${IMAGE_VERSION} ."
                        sh "docker login -u ${USER} -p ${PASS} ${REPO_SERVER}"
                        sh "docker push ${REPO_NAME}:${IMAGE_VERSION}"
                    }
                }
            }
        }

        stage("add kubeconfig") {
            when{
                expression {
                    BUILD_NUMBER == 1
                }
            }
            environment {
                AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
                AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
            }
            steps {
                script {
                    echo "adding kubeconfig file .."
                    def clsuter_name = "my-app-cluster"
                    def cluster_region = "us-east-1"
                    echo "add kubeconfig .."
                    sh "aws eks update-kubeconfig --region ${cluster_region} --name ${clsuter_name}"
                }
            }
        }

        stage("deploy to eks cluster") {
            environment {
                AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
                AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
            }
            steps {
                script {
                    echo "deploying to eks cluster .."
                    sh "envsubst < kubernetes/deployment.yaml | kubectl apply -f -"
                    sh "kubectl apply -f kubernetes/service.yaml"
                }
            }
        }

        stage("commit version update") {
            steps{
                script {
                    withCredentials([
                        usernamePassword(credentialsId: 'github', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sh "git config --global user.email 'jenkins@example.com'"
                        sh "git config --global user.name 'jenkins'"
                        
                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/abanobmorkosgad/jenkins-project.git "
                        sh "git add ."
                        sh "git commit -m 'ci: kubernetes'"
                        sh "git push origin HEAD:kubernetes"
                    }
                }
            }
        }
    }
}