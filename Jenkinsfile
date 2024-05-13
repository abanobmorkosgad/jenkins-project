pipeline {
    agent any 

    environment {
        VERSION = '3.0.1'
    }

    stages {

        stage("build") {

            steps {
                echo "bulding the app .."
            }
        }

        stage("test") {

            steps {
                echo "testing the app versiobn ${VERSION}"
            }
        }

        stage("deploy") {

            steps {
                echo "deploying the app .."
            }
        }
    }
}