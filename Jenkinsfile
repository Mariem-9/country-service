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
        NEXUS_CRED = credentials('Nexus')
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
        stage('Deploy to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Nexus', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                    mvn deploy:deploy-file \
                      -DrepositoryId=nexus \
                      -Durl=http://localhost:8082/repository/maven-releases/ \
                      -Dfile=target/country-service-0.0.1-SNAPSHOT.jar \
                      -DgroupId=com.example \
                      -DartifactId=country-service \
                      -Dversion=1.0.0 \
                      -Dpackaging=jar \
                      -DgeneratePom=true \
                      -DnexusUsername=$NEXUS_USER \
                      -DnexusPassword=$NEXUS_PASS
                    '''
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
        stage('Deploy from Nexus to Tomcat') {
    steps {
        script {
            sh """
            # Download the artifact from Nexus
            curl -u $NEXUS_CRED_USR:$NEXUS_CRED_PSW \
            -o country-service.war \
            http://localhost:8082/repository/maven-releases/com/example/country-service/1.0.0/country-service-1.0.0.war

            # Deploy to Tomcat
            curl -u $TOMCAT_USER:$TOMCAT_PASS \
            --upload-file country-service.war \
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
