currentBuild.displayName  = "Jenkins-build-#" + currentBuild.number
pipeline {
    agent any
    tools {
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-token')
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('SCM') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/atharva-kulkarni123/prime-video-deployment.git'
            }
        }
        stage('Sonarqube-Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=prime \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://13.126.152.219:9000 \
                        -Dsonar.login=$SONAR_TOKEN '''
                }
            }
        }
        stage('Quality-Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('Docker build and push') {
            steps {
                withDockerRegistry(credentialsId: 'docker', url: 'https://index.docker.io/v1/') {
                     sh 'docker container prune -f'
                     sh 'docker build -t prime-videos .'
                     sh 'docker tag prime-videos atharvak2427/prime-videos:latest'
                     sh 'docker push atharvak2427/prime-videos:latest'
                     sh 'docker run -d -p 3000:3000 prime-videos'
                }
            }
        }
         stage ("Trivy scan") {
            steps {
                sh "trivy fs . > trivyfs.json"
            }
         }
        stage('trivy scan') {
            steps {
                sh 'trivy image --format json --output trivy-report.json prime-videos:latest'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'trivy-*.json', allowEmptyArchive: true
        }
    }
}
