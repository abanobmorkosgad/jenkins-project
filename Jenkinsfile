#!/usr/bin/env groovy 
@Library('jenkins-shared-library')
def gv

pipeline {
    agent any 
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

        stage("build jar") {

            steps {
                script {
                    bulidJar()
                }
            }
        }

        stage("build docker image") {

            steps {
                script {
                    bulidImage()
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