@Library('swift-libs@2.0.0') _

import lib.JenkinsUtilities

//Create objects
def utils = new JenkinsUtilities(this) 

pipeline {
    agent any
    environment {
        GIT_REPO = validateParam(env.GIT_REPO, "GIT_REPO")
        BRANCH_NAME = validateParam(env.BRANCH_NAME, "BRANCH_NAME")
        AWS_ACCOUNT_ID=validateParam(env.AWS_ACCOUNT_ID, "AWS_ACCOUNT_ID")
        AWS_DEFAULT_REGION="us-east-1" 
        IMAGE_REPO_NAME="docker-lambda"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        dockerImage = ''
        BUILD_FOLDER = "appRepo"
    }
   
    stages {
 
        stage('Install sam-cli') {
          steps {
              script { 
                if (fileExists('aws-sam-cli-linux-x86_64.zip')) {
                    sh "/usr/local/bin/sam --version"  
                }
                else{
               sh '''
                wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
                unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
                sudo ./sam-installation/install --update
                /usr/local/bin/sam --version
             '''  
            }            
            }
           }
         }
                 
        // stage('Cloning Git') {
        //     steps {
        //         checkout([$class: 'GitSCM', branches: [[name: '*/poc']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/mmsmannam/aws-lambda-with-docker-image.git']]])     
        //      }
        // }

        stage('Checkout App Repo'){
            steps {
                checkout([
                $class: 'GitSCM',
                branches: [[name: BRANCH_NAME]],
                //extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: BUILD_FOLDER]],
                userRemoteConfigs: [[url: gitRepo, credentialsId: 'swiftci']]
                ])

                script {
                    timestamps {                                      
                        ansiColor {
                        //yaml_data = readYaml (file: "$BUILD_FOLDER/template.yml") 
                        env.AWS_ACCOUNT_ID = yaml_data.image.image_name
                       
                        }
                    }
                }                
            }
        }
        
    
       stage('Logging into AWS ECR') {
            steps {
                script {
                sh "\$(aws ecr get-login --no-include-email --region us-east-1)"
                sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
                }
                
            }
        }
        
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        }
      }
    }
       
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                if ( JENKINS_ENV.toLowerCase() == "poc") {
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
         }
        }
      }
            
      stage('Sam deployment') {
          steps{  
         script {
           if ( JENKINS_ENV.toLowerCase() == "poc") {
            sh "/usr/local/bin/sam deploy --image-repository '${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG} --no-confirm-changeset --no-fail-on-empty-changeset --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND'"   
           }
          }
     }
     }
} 
}