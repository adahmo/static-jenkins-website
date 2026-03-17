pipeline {
  agent any

  options {
    skipDefaultCheckout(true)
  }

  parameters {
    string(name: 'DOCKER_IMAGE', defaultValue: 'your-dockerhub-user/2098-health', description: 'Docker Hub image name without tag')
    string(name: 'DOCKERHUB_USERNAME', defaultValue: '', description: 'Docker Hub username')
    password(name: 'DOCKERHUB_PASSWORD', defaultValue: '', description: 'Docker Hub password or access token')
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
          if (params.DOCKER_IMAGE == 'your-dockerhub-user/2098-health') {
            error('Set DOCKER_IMAGE to your real Docker Hub repo, for example: <dockerhub-user>/2098-health')
          }

          if (!params.DOCKERHUB_USERNAME?.trim()) {
            error('Set DOCKERHUB_USERNAME in Build with Parameters.')
          }

          if (!params.DOCKERHUB_PASSWORD?.trim()) {
            error('Set DOCKERHUB_PASSWORD in Build with Parameters.')
          }
        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        sh '''
          set -eu
          printf '%s' "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
          docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
          docker push ${IMAGE_NAME}:${IMAGE_TAG}
          docker push ${IMAGE_NAME}:latest
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
      sh 'docker logout || true'
    }
  }
}