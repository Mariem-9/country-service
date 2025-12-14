# 🌐 Projet Micro-service : Country Service

Ce dépôt contient le code source d'un micro-service Spring Boot pour la gestion des données de pays. Le projet a été conçu pour être intégré dans un environnement DevOps complet, avec une chaîne d'intégration et de déploiement continu (CI/CD) entièrement automatisée.

## 🔗 Architecture CI/CD Implémentée

Nous avons mis en œuvre la pipeline CI/CD suivante, allant du commit de code au monitoring continu, conformément à l'architecture définie. 

| Phase | Outils Utilisés | Rôle |
| :--- | :--- | :--- |
| **Code / Build / Test** | `Git`, `Maven`, `JUnit`, `SonarQube` | Gestion du code source, compilation, tests unitaires et analyse de la qualité du code. |
| **Conteneurisation** | `Docker`, `Docker Hub` | Construction de l'image Docker de l'application et publication sur le registre. |
| **Déploiement Continu** | `Jenkins`, `Ansible`, `Kubernetes` | Orchestration et déploiement final sécurisé de l'application sur le cluster K8s. |
| **Monitoring** | `Prometheus`, `Grafana` | Surveillance continue de l'infrastructure et de l'état de l'application. |

## ⚙️ Pipeline Jenkins (Jenkinsfile)

L'automatisation est gérée par le `Jenkinsfile` suivant.

### Code du Pipeline

Le code ci-dessous est basé sur le pipeline fourni.

```groovy
pipeline {
    agent any
    tools {
        maven 'Maven 3.9.11' // Outil Maven pour le build 
    }
    stages {
        // Étape 1: Récupération du code (Pull Code)
        stage('1. Checkout Code') {
            steps {
                git(
                    branch: 'main',
                    url: '[https://github.com/Mariem-9/country-service.git](https://github.com/Mariem-9/country-service.git)' // Dépôt du micro-service 
                )
            }
        }
        
        // Étape 2: Build, Test (JUnit) et SonarQube (Analyse Code)
        stage('2. Build, Test & Code Analysis') {
            steps {
                // 1. Build de l'application et exécution des tests unitaires 
                sh 'mvn clean install'
                
                // 2. Analyse de code par SonarQube 
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }
        
        // Étape 3: Création et Push de l'Image Docker (Push Image)
        stage('3. Build & Push Docker Image') {
            steps {
                script {
                    // Construction de l'image avec tag BUILD_NUMBER 
                    sh "docker build . -t mariembenamor/my-app:${BUILD_NUMBER}"
                    
                    // Login à Docker Hub avec credentials sécurisés 
                    withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'DOCKERHUB_PWD')]) {
                        sh 'docker login -u mariembenamor -p ${DOCKERHUB_PWD}'
                    }
                    // Push de l'image 
                    sh "docker push mariembenamor/my-app:${BUILD_NUMBER}"
                }
            }
        }
        
        // Étape 4: Déploiement sur Kubernetes (via Ansible)
        stage('4. Deploy to Kubernetes (via Ansible)') {
            steps {
                withCredentials([string(credentialsId: 'ansible_vault_passs', variable: 'VAULT_PASS')]) {
                    sh '''
                        echo "$VAULT_PASS" > vault_pass.txt
                        ansible-playbook playbookCICD.yml --vault-password-file vault_pass.txt // Exécution du playbook 
                        rm -f vault_pass.txt
                    '''
                }
            }
        }
        
        // Étape 5: Configuration du Monitoring et Alerting
        stage('5. Deploy Monitoring Stack') {
            steps {
                kubeconfig(credentialsId: 'Kubeconfig-file', serverUrl: "", caCertificate: "") { // Authentification K8s 
                    sh '''
                        echo "📊 Installation Prometheus + Grafana via Helm" 
                        # Ajout et mise à jour des dépôts Helm 
                        helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts) || true
                        helm repo update
                        
                        # Installation ou mise à jour de la stack kube-prometheus-stack 
                        helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \\
                          --wait \\
                          -n monitoring --create-namespace \\
                          --timeout 10m
                        
                        # L'étape de configuration finale est cruciale pour lier l'application au monitoring
                        # kubectl apply -f k8s/monitoring/country-service-monitor.yaml
                        
                        echo "✅ Stack de monitoring Prometheus/Grafana déployée."
                    '''
                }
            }
        }
    }
    post {
        always {
            [cite_start]cleanWs() // Nettoyage de l'espace de travail 
        }
        success {
            [cite_start]echo '✅ Pipeline CI/CD complété avec succès pour le micro-service.' 
        }
        failure {
            echo '❌ Le pipeline CI/CD a échoué. [cite_start]Vérifiez les étapes ci-dessus.' 
        }
    }
}
```
### Rôle et Explication Détaillée de Chaque Étape

| Étape | Rôle Principal | Outils | Description et But |
| :--- | :--- | :--- | :--- |
| **1. Checkout Code** | Intégration Continue (CI) | `Git`, `Jenkins` | Récupère le code source depuis GitHub pour commencer le cycle CI/CD. |
| **2. Build, Test & Code Analysis** | Qualité du Code | `Maven`, `JUnit`, `SonarQube` | **Build :** Compile le code. **Test :** Exécute les tests unitaires (`JUnit`). **Analyse :** Envoie les résultats à `SonarQube` pour l'analyse de la qualité. |
| **3. Build & Push Docker Image** | Conteneurisation | `Docker`, `Docker Hub` | Crée un conteneur standardisé de l'application et le publie sur le registre public `Docker Hub` pour le déploiement sur Kubernetes. |
| **4. Deploy to Kubernetes (via Ansible)** | Déploiement Continu (CD) | `Ansible`, `Kubernetes` | Automatise le déploiement des manifestes Kubernetes (Deployment, Service, etc.) sur le cluster. Assure la "Continuous Delivery" du schéma. |
| **5. Deploy Monitoring Stack** | Opérationnel / Monitoring | `Helm`, `Prometheus`, `Grafana` | Installe l'infrastructure de surveillance complète. **Validation :** `Prometheus` est opérationnel et collecte les métriques d'infrastructure (Node Exporter, Jenkins, Kubelet). `Grafana` est en ligne et affiche les tableaux de bord par défaut (comme les statistiques Kubelet). |
