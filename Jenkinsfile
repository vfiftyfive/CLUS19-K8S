  
def label = "kaniko-${UUID.randomUUID().toString()}"

node ('master') {

  stage('Prepare Build') {

    sh '''#!/bin/bash
    ansible-playbook $WORKSPACE/../../ansible/aci_prov.yaml
    '''
  } 
}

podTemplate(
  name: 'kaniko',
  label: label,
  cloud: 'kubernetes',
  yaml: """
  apiVersion: v1
  kind: Pod
  metadata:
    name: kaniko
  spec:
    containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
      - /busybox/cat
      tty: true
      volumeMounts:
        - name: aws-secret
          mountPath: /root/.aws/
        - name: docker-config
          mountPath: /kaniko/.docker/
      env:
        - name: AWS_REGION
          value: us-west-1
      envFrom:
        - configMapRef:
            name: proxy
    - name: alpine
      image: alpine:latest
      command:
      - cat
      tty: true
      envFrom:
        - configMapRef:
            name: proxy
    restartPolicy: Never
    volumes:
      - name: docker-config
        configMap:
          name: docker-config
      - name: aws-secret
        secret:
          secretName: aws-secret
  """) {
  node(label) {
    withEnv(['KUBECONFIG=$WORKSPACE/Helper/config']) {

      stage('Build with Kaniko') {
        checkout scm
        container(name: 'kaniko', shell: '/busybox/sh'){
          sh """#!/busybox/sh
          /kaniko/executor --dockerfile=`pwd`/Dockerfile --context=`pwd` --destination=506539650117.dkr.ecr.us-west-1.amazonaws.com/nvermand:latest
          """
        }     
      }

      stage('Deploy pods') {
      
        container(name: 'alpine', shell: '/bin/sh') {
          sh """
          apk --no-cache add curl 
          curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.12.8/bin/linux/amd64/kubectl
          chmod +x `pwd`/kubectl
          mv `pwd`/kubectl /bin/kubectl
          KUBECONFIG=`pwd`/Helper/config kubectl create namespace devBuild
          KUBECONFIG=`pwd`/Helper/config kubectl annotate namespace voting-app opflex.cisco.com/endpoint-group='{"tenant":"kubecluster_demo_01","app-profile":"kubernetes","name":"devBuild"}'
          KUBECONFIG=`pwd`/Helper/config kubectl apply -f `pwd`/redis-master-controller.json -f `pwd`/redis-master-service.json -f `pwd`/redis-slave-controller.json -f `pwd`/redis-slave-service.json -f `pwd`/guestbook-controller.yaml -n devBuild
          sleep 30
          """
        }
      }

      stage('Run Integration Test') {
        container(name: 'alpine', shell: '/bin/sh') {
          def ret= sh(
            script: 'chmod u+x $WORKSPACE/Helper/kube.sh && KUBECONFIG=$WORKSPACE/Helper/config $WORKSPACE/Helper/kube.sh',
            returnStdout: true
          ).trim()
          if ( ret == 'fail' ) {
            currentBuild.result = 'FAILURE'
          }
        }
      }
    }
  }
}

node('master') {

  stage('Clean-up') {
    sh '''#!/bin/bash
    ansible-playbook $WORKSPACE/../../ansible/aci_del.yaml
    '''
  }
}


