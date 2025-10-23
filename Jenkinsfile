pipeline {
    agent any
    // doit être configuré dans Jenkins  
    tools {
        maven 'Maven 3.9.11' 
        jdk 'jdk21.0.8'   
    }

    environment {
        TOMCAT_USER = 'admin'
        TOMCAT_PASS = 'admin'
        TOMCAT_URL  = 'http://localhost:8081/manager/text' // Tomcat sur le nouveau port 8081
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Mariem-9/country-service.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
       stage('SonarQube Analysis') {
          steps {
              withSonarQubeEnv('SonarQube') {
                  sh 'mvn sonar:sonar'
              }
          }
      }
        stage('Deploy to Tomcat') {
            steps {
                script {
                    sh """
                    curl -u $TOMCAT_USER:$TOMCAT_PASS \
                    --upload-file target/country-service.war \
                    "$TOMCAT_URL/deploy?path=/country-service&update=true"
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Build & Deploy successful!'
        }
        failure {
            echo 'Build or deploy failed!'
        }
    }
}
