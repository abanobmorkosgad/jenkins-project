pipeline {
    agent any 

    stages {

        stage("build") {

            steps {
                echo "bulding the app .."
            }
        }

        stage("test") {
            when {
                expression {
                    BRANCH_NAME == 'dev'
                }
            }
            steps {
                echo "testing the app .."
            }
        }

        stage("deploy") {

            steps {
                echo "deploying the app .."
            }
        }
    }
}