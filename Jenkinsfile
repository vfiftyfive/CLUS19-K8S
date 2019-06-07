  
def label = "kaniko-${UUID.randomUUID().toString()}"

node ('master') {

  stage('Deploy ACI objects') {

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
          KUBECONFIG=`pwd`/Helper/config kubectl create namespace devbuild
          apk update && apk add py-pip jq
          pip install awscli
          VAULT_TOKEN=\$(curl --request POST \
          --data '{"role_id": "304cd485-6b5f-81e1-392d-76daa2dbdb83", "secret_id": "2a3e92ab-2908-c783-7076-5b85f851424c"}' \
          http://10.51.48.8:8200/v1/auth/approle/login | jq '.auth.client_token' | tr -d '"')
          ACCKEY=\$(curl \
          -H "X-Vault-Token: \$VAULT_TOKEN" \
          -X GET \
          http://10.51.48.8:8200/v1/aws/awskeys | jq '.data.acckey' | tr -d '"' )
          SECKEY=\$(curl \
          -H "X-Vault-Token: \$VAULT_TOKEN" \
          -X GET \
          http://10.51.48.8:8200/v1/aws/awskeys | jq '.data.seckey' | tr -d '"' )
          aws configure set aws_access_key_id \$ACCKEY
          aws configure set aws_secret_access_key \$SECKEY
          aws configure set default.region us-west-1
          DOCKERPASSWD=\$(aws ecr get-login --no-include-email | cut -d " " -f 6)
          KUBECONFIG=`pwd`/Helper/config kubectl create secret docker-registry ecr --docker-username=AWS --docker-password=\$DOCKERPASSWD --docker-server=506539650117.dkr.ecr.us-west-1.amazonaws.com --docker-email=nvermand@cisco.com
          KUBECONFIG=`pwd`/Helper/config kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ecr"}]}'
          KUBECONFIG=`pwd`/Helper/config kubectl annotate namespace devbuild opflex.cisco.com/endpoint-group='{"tenant":"kubecluster_demo_01","app-profile":"kubernetes","name":"devBuild"}'
          KUBECONFIG=`pwd`/Helper/config kubectl apply -f `pwd`/redis-master-controller.json -f `pwd`/redis-master-service.json -f `pwd`/redis-slave-controller.json -f `pwd`/redis-slave-service.json -f `pwd`/guestbook-controller.yaml
          sleep 60
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
          sh '''#!/bin/sh
          KUBECONFIG=$WORKSPACE/Helper/config kubectl delete namespace devbuild
          '''
        }
      }
    }
  }
}

node('master') {

  stage('Clean-up ACI') {
    sh '''#!/bin/bash
    ansible-playbook $WORKSPACE/../../ansible/aci_del.yaml
    '''

    if ( currentBuild.result == 'SUCCESS' ) {
      stage('Merge dev to prod') {
        withCredentials([usernamePassword(credentialsId: '75f66db3-7769-4eb9-b8ae-9090f54997e0', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]){    
          sh('''
              git config --local credential.helper "!f() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; f"
              git push origin dev:master
          ''')
        }
      }
    }
  }
}





