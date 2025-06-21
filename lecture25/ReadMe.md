# AWS EKS: Розгортання Кластера та Застосунків

## Мета
- Створити кластер Kubernetes в AWS за допомогою EKS
- Розгорнути застосунки в кластері
- Працювати з основними ресурсами Kubernetes (Pod, Deployment, Service, ConfigMap, PVC, Job, Namespace)

---

## 1. Створення кластера EKS

Кластер створюємо за допомогою `eksctl`:

```bash


eksctl create cluster \
  --name my-eks-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --managed
  
2025-06-05 12:55:33 [ℹ]  eksctl version 0.208.0
2025-06-05 12:55:33 [ℹ]  using region us-east-1
2025-06-05 12:55:33 [!]  Amazon EKS will no longer publish EKS-optimized Amazon Linux 2 (AL2) AMIs after November 26th, 2025. Additionally, Kubernetes version 1.32 is the last version for which Amazon EKS will release AL2 AMIs. From version 1.33 onwards, Amazon EKS will continue to release AL2023 and Bottlerocket based AMIs. The default AMI family when creating clusters and nodegroups in Eksctl will be changed to AL2023 in the future.
2025-06-05 12:55:34 [ℹ]  setting availability zones to [us-east-1b us-east-1f]
2025-06-05 12:55:34 [ℹ]  subnets for us-east-1b - public:192.168.0.0/19 private:192.168.64.0/19
2025-06-05 12:55:34 [ℹ]  subnets for us-east-1f - public:192.168.32.0/19 private:192.168.96.0/19
2025-06-05 12:55:34 [ℹ]  nodegroup "standard-workers" will use "" [AmazonLinux2/1.32]
2025-06-05 12:55:34 [ℹ]  using Kubernetes version 1.32
2025-06-05 12:55:34 [ℹ]  creating EKS cluster "my-eks-cluster" in "us-east-1" region with managed nodes
2025-06-05 12:55:34 [ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial managed nodegroup
2025-06-05 12:55:34 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-1 --cluster=my-eks-cluster'
2025-06-05 12:55:34 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "my-eks-cluster" in "us-east-1"
2025-06-05 12:55:34 [ℹ]  CloudWatch logging will not be enabled for cluster "my-eks-cluster" in "us-east-1"
2025-06-05 12:55:34 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=us-east-1 --cluster=my-eks-cluster'
2025-06-05 12:55:34 [ℹ]  default addons metrics-server, vpc-cni, kube-proxy, coredns were not specified, will install them as EKS addons
2025-06-05 12:55:34 [ℹ]
2 sequential tasks: { create cluster control plane "my-eks-cluster",
    2 sequential sub-tasks: {
        2 sequential sub-tasks: {
            1 task: { create addons },
            wait for control plane to become ready,
        },
        create managed nodegroup "standard-workers",
    }
}
2025-06-05 12:55:34 [ℹ]  building cluster stack "eksctl-my-eks-cluster-cluster"
2025-06-05 12:55:36 [ℹ]  deploying stack "eksctl-my-eks-cluster-cluster"
2025-06-05 12:56:06 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 12:56:37 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 12:57:38 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 12:58:40 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 12:59:42 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 13:00:44 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 13:01:45 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 13:02:47 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 13:03:49 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-cluster"
2025-06-05 13:03:52 [ℹ]  creating addon: metrics-server
2025-06-05 13:03:52 [ℹ]  successfully created addon: metrics-server
2025-06-05 13:03:53 [!]  recommended policies were found for "vpc-cni" addon, but since OIDC is disabled on the cluster, eksctl cannot configure the requested permissions; the recommended way to provide IAM permissions for "vpc-cni" addon is via pod identity associations; after addon creation is completed, add all recommended policies to the config file, under `addon.PodIdentityAssociations`, and run `eksctl update addon`
2025-06-05 13:03:53 [ℹ]  creating addon: vpc-cni
2025-06-05 13:03:53 [ℹ]  successfully created addon: vpc-cni
2025-06-05 13:03:54 [ℹ]  creating addon: kube-proxy
2025-06-05 13:03:55 [ℹ]  successfully created addon: kube-proxy
2025-06-05 13:03:55 [ℹ]  creating addon: coredns
2025-06-05 13:03:56 [ℹ]  successfully created addon: coredns
2025-06-05 13:06:02 [ℹ]  building managed nodegroup stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 13:06:03 [ℹ]  deploying stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 13:06:03 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 13:06:34 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 13:07:28 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 13:08:53 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 13:08:54 [ℹ]  waiting for the control plane to become ready
2025-06-05 13:08:55 [✔]  saved kubeconfig as "/home/andy/.kube/config"
2025-06-05 13:08:55 [ℹ]  no tasks
2025-06-05 13:08:55 [✔]  all EKS cluster resources for "my-eks-cluster" have been created
2025-06-05 13:08:55 [ℹ]  nodegroup "standard-workers" has 2 node(s)
2025-06-05 13:08:55 [ℹ]  node "ip-192-168-27-95.ec2.internal" is ready
2025-06-05 13:08:55 [ℹ]  node "ip-192-168-40-103.ec2.internal" is ready
2025-06-05 13:08:55 [ℹ]  waiting for at least 2 node(s) to become ready in "standard-workers"
2025-06-05 13:08:56 [ℹ]  nodegroup "standard-workers" has 2 node(s)
2025-06-05 13:08:56 [ℹ]  node "ip-192-168-27-95.ec2.internal" is ready
2025-06-05 13:08:56 [ℹ]  node "ip-192-168-40-103.ec2.internal" is ready
2025-06-05 13:08:56 [✔]  created 1 managed nodegroup(s) in cluster "my-eks-cluster"
2025-06-05 13:08:57 [ℹ]  kubectl command should work with "/home/andy/.kube/config", try 'kubectl get nodes'
2025-06-05 13:08:57 [✔]  EKS cluster "my-eks-cluster" in "us-east-1" region is ready

```

**  01-Worker-nodes.png  		**
**  02-Subnets.png  			**
**  03-Auto-Scaling-Group.png  	**

---

## 2. Налаштування `kubectl`

```bash


aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster
Added new context arn:aws:eks:us-east-1:873868729805:cluster/my-eks-cluster to /home/andy/.kube/config


kubectl get nodes
NAME                             STATUS   ROLES    AGE   VERSION
ip-192-168-27-95.ec2.internal    Ready    <none>   14m   v1.32.3-eks-473151a
ip-192-168-40-103.ec2.internal   Ready    <none>   14m   v1.32.3-eks-473151a


```

---

## 3. Розгортання статичного вебсайту

## Структура каталогу

```
.
├── configmap.yaml
├── deployment.yaml
├── service.yaml
├── pvc.yaml
├── pod-with-pvc.yaml
├── job.yaml
├── nginx-test-deployment.yaml
├── nginx-test-service.yaml
├── dev-busybox.yaml
├── gp2-immediate.yaml
```

### 3.1 ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-content
data:
  index.html: |
    <html><body><h1>Hello from EKS!</h1></body></html>
```

### 3.2 Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-web
  template:
    metadata:
      labels:
        app: nginx-web
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: content
        configMap:
          name: web-content
```

### 3.3 Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx-web
  ports:
    - port: 80
      targetPort: 80
```

## Перевірка

```bash


kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
configmap/web-content created
deployment.apps/nginx-web created
service/nginx-service created


kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
nginx-web-d7dcc99cb-2j4kz   1/1     Running   0          26s


kubectl get deployment
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
nginx-web   1/1     1            1           26s


kubectl get svc nginx-service
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
nginx-service   LoadBalancer   10.100.172.250   a909e7167a1844dc0bce68f4faaaef41-203909618.us-east-1.elb.amazonaws.com   80:32005/TCP   26s


```

**  04-Static-website-in-EKS-cluster.png  **

---

## 4. PVC і збереження даних

Для збереження даних було створено PVC з використанням динамічного провізіонування на EBS-диску.

Перед цим у кластер було встановлено EBS CSI Driver:

```bash


eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster my-eks-cluster --approve
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole


eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster my-eks-cluster \
  --region us-east-1 \
  --service-account-role-arn arn:aws:iam::<ACCOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRole \
  --force
  
  
```

### StorageClass: gp2-immediate

Оскільки за замовчуванням кластер мав StorageClass із `WaitForFirstConsumer`, був створений окремий StorageClass із `Immediate`, щоб PVC одразу створював том:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-immediate
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

```bash


kubectl apply -f gp2-immediate.yaml


```

Далі:

### PVC
```yaml
yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: gp2-immediate
```

### Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pvc
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "echo Hello > /data/hello.txt && sleep 3600"]
    volumeMounts:
    - mountPath: /data
      name: ebs-volume
  volumes:
  - name: ebs-volume
    persistentVolumeClaim:
      claimName: ebs-pvc
```

## Перевірка

```bash


kubectl get pvc
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    VOLUMEATTRIBUTESCLASS   AGE
ebs-pvc   Bound    pvc-f6ecd21d-76b3-48ea-b208-f920a56b28f5   1Gi        RWO            gp2-immediate   <unset>                 35m


kubectl get pod busybox-pvc
NAME          READY   STATUS    RESTARTS   AGE
busybox-pvc   1/1     Running   0          35m


kubectl exec -it busybox-pvc -- cat /data/hello.txt
Hello from EBS


```

---

## 5. Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-job
spec:
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sh", "-c", "echo Hello from EKS!"]
      restartPolicy: Never
  backoffLimit: 2
```

## Перевірка

```bash


kubectl get jobs
NAME        STATUS     COMPLETIONS   DURATION   AGE
hello-job   Complete   1/1           3s         13s


kubectl get pods --selector=job-name=hello-job
NAME              READY   STATUS      RESTARTS   AGE
hello-job-xm6lw   0/1     Completed   0          2m53s


kubectl logs hello-job-xm6lw
Hello from EKS!


```

---

## 6. Тестовий застосунок

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-test
  template:
    metadata:
      labels:
        app: nginx-test
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-test-service
spec:
  type: ClusterIP
  selector:
    app: nginx-test
  ports:
    - port: 80
      targetPort: 80
```

## Перевірка

```bash


kubectl get pods -l app=nginx-test
NAME                          READY   STATUS    RESTARTS   AGE
nginx-test-598898876f-9xmnd   1/1     Running   0          32s
nginx-test-598898876f-qrcgt   1/1     Running   0          32s


kubectl get deployment nginx-test
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nginx-test   2/2     2            2           50s


kubectl get svc nginx-test-service
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
nginx-test-service   ClusterIP   10.100.37.129   <none>        80/TCP    81s


kubectl run test-client --rm -it --image=busybox -- sh
If you don't see a command prompt, try pressing enter.
/ # wget -qO- nginx-test-service
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
/ #
/ # exit
Session ended, resume using 'kubectl attach test-client -c test-client -i -t' command when the pod is running
pod "test-client" deleted


```

---

## 7. Робота з namespace

```bash


kubectl create namespace dev


```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-sleep
  namespace: dev
spec:
  replicas: 5
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sleep", "3600"]
```

## Перевірка

```bash


kubectl create namespace dev
namespace/dev created


kubectl apply -f dev-busybox.yaml
deployment.apps/busybox-sleep created


kubectl get pods -n dev
NAME                             READY   STATUS    RESTARTS   AGE
busybox-sleep-5c684d4858-4qlqm   1/1     Running   0          10s
busybox-sleep-5c684d4858-c58vq   1/1     Running   0          11s
busybox-sleep-5c684d4858-fb9th   1/1     Running   0          11s
busybox-sleep-5c684d4858-g6zqm   1/1     Running   0          11s
busybox-sleep-5c684d4858-gp6qd   1/1     Running   0          10s


kubectl get deployment -n dev
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
busybox-sleep   5/5     5            5           23s


```

---

## 8. Очищення ресурсів

```bash


kubectl delete -f .
configmap "web-content" deleted
deployment.apps "nginx-web" deleted
deployment.apps "busybox-sleep" deleted
storageclass.storage.k8s.io "gp2-immediate" deleted
job.batch "hello-job" deleted
deployment.apps "nginx-test" deleted
service "nginx-test-service" deleted
pod "busybox-pvc" deleted
persistentvolumeclaim "ebs-pvc" deleted
service "nginx-service" deleted


kubectl delete namespace dev
namespace "dev" deleted


eksctl delete cluster --name my-eks-cluster --region us-east-1
2025-06-05 15:35:45 [ℹ]  deleting EKS cluster "my-eks-cluster"
2025-06-05 15:35:46 [ℹ]  will drain 0 unmanaged nodegroup(s) in cluster "my-eks-cluster"
2025-06-05 15:35:46 [ℹ]  starting parallel draining, max in-flight of 1
2025-06-05 15:35:47 [ℹ]  deleted 0 Fargate profile(s)
2025-06-05 15:35:49 [✔]  kubeconfig has been updated
2025-06-05 15:35:49 [ℹ]  cleaning up AWS load balancers created by Kubernetes objects of Kind Service or Ingress
2025-06-05 15:35:52 [ℹ]
3 sequential tasks: { delete nodegroup "standard-workers",
    2 sequential sub-tasks: {
        2 sequential sub-tasks: {
            delete IAM role for serviceaccount "kube-system/ebs-csi-controller-sa",
            delete serviceaccount "kube-system/ebs-csi-controller-sa",
        },
        delete IAM OIDC provider,
    }, delete cluster control plane "my-eks-cluster" [async]
}
2025-06-05 15:35:52 [ℹ]  will delete stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:35:52 [ℹ]  waiting for stack "eksctl-my-eks-cluster-nodegroup-standard-workers" to get deleted
2025-06-05 15:35:52 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:36:24 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:37:02 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:38:44 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:39:51 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:41:54 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:43:18 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:45:08 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-nodegroup-standard-workers"
2025-06-05 15:45:09 [ℹ]  will delete stack "eksctl-my-eks-cluster-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa"
2025-06-05 15:45:09 [ℹ]  waiting for stack "eksctl-my-eks-cluster-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa" to get deleted
2025-06-05 15:45:09 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa"
2025-06-05 15:45:40 [ℹ]  waiting for CloudFormation stack "eksctl-my-eks-cluster-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa"
2025-06-05 15:45:41 [ℹ]  serviceaccount "kube-system/ebs-csi-controller-sa" was not created by eksctl; will not be deleted
2025-06-05 15:45:42 [ℹ]  will delete stack "eksctl-my-eks-cluster-cluster"
2025-06-05 15:45:42 [✔]  all cluster resources were deleted


```

---


## Prepared on: 6/5/2025 By: Andrii Fil (IT Administrator, DevOps trainee)