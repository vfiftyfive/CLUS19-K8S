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
    image: gcr.io/kaniko-project/executor:latest
    args: ["--dockerfile=test_image/Dockerfile",
            "--context=s3://nvermand/kaniko.tar.gz",
            "--destination=506539650117.dkr.ecr.us-west-1.amazonaws.com/nvermand:latest"]
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
"""){}
     
