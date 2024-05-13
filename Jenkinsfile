pipeline {
    agent any 
    parameters{
        choice(name: 'ENV', choices: ['dev','test','prod'], description: '')
        booleanParam(name: 'executetests', defaultValue: true, description: '')
    }
    tools {
        maven 'maven'
    }
    environment {
        VERSION = '3.0.1'
    }

    stages {

        stage("build") {

            steps {
                echo "bulding the app .."
                sh "mvn package"
            }
        }

        stage("test") {
            when{
                expression{
                    params.ENV == "test"
                }
            }
            steps {
                echo "testing the app versiobn ${VERSION}"
            }
        }

        stage("deploy") {

            steps {
                echo "deploying the app .."
                // withCredentials([
                //     usernamePassword(credentials: 'github-credentials', usernameVariable: USER, passwordVariable: PASS)
                // ]){
                //     echo "${USER} ${PASS} "
                // }
            }
        }
    }
}