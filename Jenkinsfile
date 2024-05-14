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
                    echo "increment the app version .."
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile("pom.xml") =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_VERSION = "${version}-${BUILD_NUMBER}"
                }
            }
        }

        stage {
            steps {
                script {
                    echo "building the app .."
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
                        sh "git commit 'ci: version_increment'"
                        sh "git push origin HEAD:version_increment"
                    }
                }
            }
        }
    }
}