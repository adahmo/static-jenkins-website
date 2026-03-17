pipeline {
  agent any

  parameters {
    string(name: 'DOCKER_IMAGE', defaultValue: 'your-dockerhub-user/2098-health', description: 'Docker Hub image name without tag')
  }

  environment {
    IMAGE_NAME = "${params.DOCKER_IMAGE}"
    IMAGE_TAG  = "${BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate Static App') {
      steps {
        sh '''
          set -eux
          test -f index.html
          test -f Dockerfile
          test -f k8s/health-app.yaml
        '''

        script {
          if (params.DOCKER_IMAGE == 'adamumj/2098-health/2098-health') {
            error('Set DOCKER_IMAGE to your real Docker Hub repo, for example: adamumj/2098-health/2098-health')
          }
        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        sh '''
          set -eux
          if [ ! -f "${HOME}/.docker/config.json" ]; then
            echo "Docker Hub login not found for Jenkins user. Run once on the EC2 host: sudo -u jenkins -H docker login"
            exit 1
          fi
          docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
          docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
          docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
          docker push ${DOCKER_IMAGE}:latest
        '''
      }
    }

    stage('Deploy to k3s') {
      steps {
        sh '''
          set -eux
          sed "s|your-dockerhub-user/2098-health|${IMAGE_NAME}|g" k8s/health-app.yaml | kubectl apply -f -
          kubectl -n health-app rollout status deployment/health-app --timeout=300s
        '''
      }
    }
  }

  post {
    always {
      sh 'echo "Keeping Docker login session for next runs"'
    }
  }
}