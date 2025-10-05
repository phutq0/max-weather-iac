def stagingJobName = 'max-weather' + '/' + 'staging' 

pipelineJob(stagingJobName) {
  parameters {
    stringParam('IMAGE_TAG', 'latest', 'Enter the image tag to build and deploy (e.g., 1.2.3)')
  }
  definition {
    cps {
      script(readFileFromWorkspace("jenkins/seed/Jenkinsfile.staging"))
      sandbox()
    }
  }
}

def productionJobName = 'max-weather' + '/' + 'production' 

pipelineJob(productionJobName) {
  parameters {
    stringParam('IMAGE_TAG', 'latest', 'Enter the image tag to build and deploy (e.g., 1.2.3)')
  }
  definition {
    cps {
      script(readFileFromWorkspace("jenkins/seed/Jenkinsfile.production"))
      sandbox()
    }
  }
}
