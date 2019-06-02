  
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
"""){
     node(label) {
          stage('Build with Kaniko') {
               git 'https://github.com/jenkinsci/docker-jnlp-slave.git'
               git 'https://github.com/vfiftyfive/CLUS19-K8S.git'
               container(name: 'kaniko', shell: '/busybox/sh'){
                    echo pwd()
                    sh '''#!/busybox/sh
                    /kaniko/executor --dockerfile=./Dockerfile --context=./CLUS19-K8S --cache=true --single-snapshot--destination=506539650117.dkr.ecr.us-west-1.amazonaws.com/nvermand:latest
                    '''
               }
          }
     }
}
   
