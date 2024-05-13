def gv

pipeline {
    agent any 
    parameters{
        choice(name: 'VERSION', choices: ['1.0.0','1.0.1','1.0.2'], description: '')
        booleanParam(name: 'executetests', defaultValue: true, description: '')
    }
    tools {
        maven 'maven'
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
                    params.executetests == true
                }
            }
            steps {
                script {
                    gv.test()
                }
            }
        }

        stage("deploy") {
            input{
                messege "Select with environment to deploy"
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