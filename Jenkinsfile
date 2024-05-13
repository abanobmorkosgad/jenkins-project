def gv

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

        stage("init") {

            steps {
                script {
                    gv = load "script.groovy"
                }
            }
        }

        stage("build") {

            steps {
                script {
                    gv.build()
                }
            }
        }

        stage("test") {
            when{
                expression{
                    params.ENV == "test"
                }
            }
            steps {
                script {
                    gv.test()
                }
            }
        }

        stage("deploy") {

            steps {
                script {
                    gv.deploy()
                }
            }
        }
    }
}