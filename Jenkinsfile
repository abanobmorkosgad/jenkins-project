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
                    buildJar()
                }
            }
        }

        stage("build docker image") {

            steps {
                script {
                    buildImage 'abanobmorkos10/java-maven:2.0.0'
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