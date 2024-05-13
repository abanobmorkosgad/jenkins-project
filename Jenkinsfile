def gv

pipeline {
    agent any 
    tools {
        maven 'maven'
    }

    stages {

        // stage("init") {

        //     steps {
        //         script {
        //             gv = load "script.groovy"
        //         }
        //     }
        // }

        stage("build jar") {

            steps {
                script {
                    echo "building the app ..."
                    sh "mvn package"
                }
            }
        }

        stage("build docker image") {

            steps {
                script {
                    echo "building docker image ..."
                    withCredentials([
                        usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sh "docker build -t abanobmorkos10/java-maven:1.0.0 ."
                        sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                        sh "docker push abanobmorkos10/java-maven:1.0.0"
                    }
                }
            }
        }

        stage("deploy") {
            input{
                message "Select with environment to deploy"
                ok "Done"
                    parameters{
                        choice(name: 'ENV', choices: ['dev','test','prod'], description: '')
                    }
            }

            steps {
                script {
                    gv.deploy()
                }
            }
        }
    }
}