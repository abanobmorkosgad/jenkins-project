def gv

pipeline {
    agent any 
    tools {
        maven 'maven'
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

            steps {
                script {
                    echo "building docker image ..."
                    withCredentials([
                        usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sh "docker build -t abanobmorkos10/java-maven:${IMAGE_VERSION} ."
                        sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                        sh "docker push abanobmorkos10/java-maven:${IMAGE_VERSION}"
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