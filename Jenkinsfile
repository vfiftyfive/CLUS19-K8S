  
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
          KUBECONFIG=`pwd`/Helper/config kubectl create secret docker-registry ecr --docker-username=AWS --docker-password=eyJwYXlsb2FkIjoiUW9yUDhCS0tZeXRoeUdOanJCOUIxVThkekRWcWxpNVpaNERRQzBCOG5yQm5hSWFVN1hhK0FzcDBKbFIwd3pPV2I4SWh2TzM3ZDlxVEwxaWRjekFwWHdVeW5sRUZOK3BPWmJxUk1IdVpSYVpCQ1lUSUVSV3JEcmhrdnNkM2o0SFViVGkrWElKVmhQbGpNbVpXVkhSSGh3bzd4dFRtVnJkRy9sRkZIdWE4ekszZGEyZVE5bW1sOEFGb3BNU2hYL0tBckdsUnY3VlEzMEFsVEtKV05NQm5hVEx6TlUzcWR5YjlOQklWT3pHV2NaUTVMb2xLOGFRbWNzRnU2T1FjTEtxaG9mQURLbHVpY3BTM2J5TmRQeG5NSzQ3bEtORjhVbmwvNWRZZDE2eXgrVmN2R2N0RWVQMVVvblBMRHovenRleGE5OTZZUDBqS0NPaldxaUF2T3ZoaTdOeGlNVDhNcDd6TmJIMWRZcGRXR09WOXprN2NCOXhINFc4WUcvY0crVXJ5aUU0ZzgzamQrbk1ORkM5a1BDR1FyTXlubmd3YzU4UlplZTM4WjB6RWhVSFhtVktjQnEyMTgxRmN3OG1DZmRCSHVIQ2dVZHBweFRxajYrMFFsWlRxdStUQ0EyeWp5SUlzeGVmeTRNbmxPcnVhSjJuQTBiVGg0clNyb2JzczRMZkE2U0dFMWoxUzJDL2tscUZTam5zbVFsLy9KcEVGZERrTC9CSlFySUFKUjNNb0x2QjBOOVgrT3F5d3N6aUY5SG1KWTB5L2lxajhvVlZXSlFDc3NaNngyT1Joc3VNc0h0UHRRWGYxcWt6c0VsejdEMFYzbEZ3dmlGaFhEY0pqU1pJY3RsQnoxNW10Q1N0WE5pdDRPa2ZNRUJyaUExU0hwNnhybkNRbS80c0duMmZ5RmFsRE1pSFQ5VFR2TmtuSUlNSU04R1Z5b3AwbGJ1azY4RDlVcXhaZ1laYzc3OHZYanI5SlNIbEorWDh4UUxtOVNLVk5XM21XOXFDM25ySndVcWprRjNRWkZCK25wNEEvTjk2WlpTNy83SFo5dkMrZXRrSGwzdGdIeUw2bUl4eHgyTWlJWXZNd2I0R1BLekRSOUUzQk1uZE82ZUtzRkNJc2g3czJmT0xCYmZ2TTBkVng0Y09YMi84eWtIM0s0UzVENk8zZm9UR0xlcUlOZXAvV2lFUHVBR3IwaFJWamVwaWFaMGNTV2lnWTg4ZzRldG5FZHpjZ2lBZm5Rb01GQW4yTEo3UEE4QzlwNDZ1TUFMWGhiWmZkSUM2Rm5nQWtGaXdSWVREaEpEZ1JIaFZab2l6NlBaRWg4a0RzMlpXTTJDbVBMcGNZemgxcjhrTU1iMzFCMWhSTnFjdVpRZzlFVGhYZy9rNnlEZnZnZXVIS2UvMmRCdlo1WGNUak05VVlwT3NOZmxPNTNRZHRlYitCIiwiZGF0YWtleSI6IkFRRUJBSGlqRUZYR3dGMWNpcFZPYWNHOHFSbUpvVkJQYXk4TFVVdlU4UkNWVjBYb0h3QUFBSDR3ZkFZSktvWklodmNOQVFjR29HOHdiUUlCQURCb0Jna3Foa2lHOXcwQkJ3RXdIZ1lKWUlaSUFXVURCQUV1TUJFRURKTXYxM2VCWm1vUjRQVXI0d0lCRUlBN2M4bG1wZUtOWmIxREEyZWR5TThqMjBzbE5JaTJJb0w5NSs1UFN5Z0wvRHovS3hUZElBNGxuaENtcFZxYUtXbnpxclNOMHNLK0QydTBqYnc9IiwidmVyc2lvbiI6IjIiLCJ0eXBlIjoiREFUQV9LRVkiLCJleHBpcmF0aW9uIjoxNTU5ODI0NDA3fQ== --docker-server=506539650117.dkr.ecr.us-west-1.amazonaws.com --docker-email=nvermand@cisco.com
          KUBECONFIG=`pwd`/Helper/config kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ecr"}]}'
          KUBECONFIG=`pwd`/Helper/config kubectl annotate namespace devbuild opflex.cisco.com/endpoint-group='{"tenant":"kubecluster_demo_01","app-profile":"kubernetes","name":"devBuild"}'
          KUBECONFIG=`pwd`/Helper/config kubectl apply -f `pwd`/redis-master-controller.json -f `pwd`/redis-master-service.json -f `pwd`/redis-slave-controller.json -f `pwd`/redis-slave-service.json -f `pwd`/guestbook-controller.yaml -n devbuild
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





