  
def label = "kaniko-${UUID.randomUUID().toString()}"

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
      imagePullPolicy: Always
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

      stage('Build with Kaniko') {

        git 'https://github.com/vfiftyfive/CLUS19-K8S.git'
        container(name: 'kaniko', shell: '/busybox/sh'){
          sh '''#!/busybox/sh
          /kaniko/executor --dockerfile=`pwd`/Dockerfile --context=`pwd` --destination=506539650117.dkr.ecr.us-west-1.amazonaws.com/nvermand:latest
          '''
        }     
      }
    }

def labelK = "kubectl-${UUID.randomUUID().toString()}"
podTemplate(
  name: 'kubectl',
  label: labelK,
  cloud: kubernetes,
  image: 'alpine:latest'
  ) {
    node(label) {

      stage('Deploy pods') {
        git 'https://github.com/vfiftyfive/CLUS19-K8S.git'
        sh '''#!/busybox/sh
        curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl
        '''
      }
    }
  }

//   node('slave-1') {

//     stage('Deploy app pods') {
//       git 'https://github.com/vfiftyfive/CLUS19-K8S.git'
//       def kImage = docker.build("kubectl:${env.BUILD_ID}", "./Helper")

//       kImage.inside {
//         sh 'KUBECONFIG=`pwd`/Helper/config kubectl apply -f `pwd`/redis-master-controller.json -f `pwd`/redis-master-service.json -f `pwd`/redis-slave-controller.json -f `pwd`/redis-slave-service.json -f `pwd`/guestbook-controller.yaml'
//       }
//     }
//   }
}
