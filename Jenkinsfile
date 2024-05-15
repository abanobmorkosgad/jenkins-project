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

        stage("deploy") {

            steps {
                script {
                    echo "deploying .."
                    def composeInstall = "sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose"
                    def composeExec = "sudo chmod +x /usr/local/bin/docker-compose"
                    def dockerComposeCmd = "sudo docker-compose -f docker-compose.yaml up --detach" 
                    def shellCmd = "bash ./script.sh ${IMAGE_VERSION}"
                    withCredentials([
                        usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sshagent(['ec2-user']) {
                            // sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${composeInstall}"
                            // sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${composeExec}"
                            sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 sudo docker login -u ${USER} -p ${PASS}"
                            sh "scp docker-compose.yaml ec2-user@44.200.41.6:/home/ec2-user"
                            sh "scp script.sh ec2-user@44.200.41.6:/home/ec2-user"
                            // sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${dockerComposeCmd}"
                            sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${shellCmd}"

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