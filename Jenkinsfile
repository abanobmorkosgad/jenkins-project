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

        stage("deploy") {

            steps {
                script {
                    echo "deploying compose to ec2 .."
                    def dockerCmd = "bash ./docker.sh"
                    def dockerComposeCmd = "bash ./docker-compose.sh abanobmorkos10/java-maven:${IMAGE_VERSION}"
                    def ec2="ec2-user@3.236.7.129"
                    withCredentials([
                        usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sshagent(['ec2-user']) {
                            sh "scp docker.sh ${ec2}:~"
                            sh "ssh -o StrictHostKeyChecking=no ${ec2} ${dockerCmd}"
                            sh "ssh -o StrictHostKeyChecking=no ${ec2} sudo docker login -u ${USER} -p ${PASS}"
                            sh "scp docker-compose.yaml ${ec2}:~"
                            sh "scp docker-compose.sh ${ec2}:~"
                            sh "ssh -o StrictHostKeyChecking=no ${ec2} ${dockerComposeCmd}"
                    }
                    }
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
                        sh "git commit -m 'ci: deploy_compose'"
                        sh "git push origin HEAD:deploy_compose"
                    }
                }
            }
        }
    }
}
