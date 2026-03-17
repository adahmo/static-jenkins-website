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
        }
      }
    }

    stage('Deploy to k3s') {
      steps {
        sh '''
          set -eux
          sed "s|your-dockerhub-user/2098-health|${IMAGE_NAME}|g" k8s/health-app.yaml | kubectl apply -f -
          kubectl -n health-app rollout status deployment/health-app --timeout=180s
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