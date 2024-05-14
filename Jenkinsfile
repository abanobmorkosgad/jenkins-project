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
                    def dockerInstall = "sudo yum install -y docker"
                    def dockerStart = "sudo systemctl start docker"
                    def dockerLogin = "sudo docker login -u ${USER} -P ${PASS}"
                    def dockerCmd = "sudo docker run -p 3080:3080 -d abanobmorkos10/java-maven:${IMAGE_VERSION}"
                    withCredentials([
                        usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sshagent(['ec2-user']) {
                            sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${dockerInstall}"
                            sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${dockerStart}"
                            sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 sudo docker login -u ${USER} -P ${PASS}"
                            sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${dockerCmd}"
                    }
                    }
                    // sshagent(['ec2-user']) {
                    //     sh "ssh -o StrictHostKeyChecking=no ec2-user@44.200.41.6 ${dockerCmd}"
                    // }
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
                        sh "git commit -m 'ci: version_increment'"
                        sh "git push origin HEAD:version_increment"
                    }
                }
            }
        }
    }
}