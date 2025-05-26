# Розгортання Falco в Kubernetes через DaemonSet

## Мета

Розгорнути Falco в кластері Kubernetes для моніторингу подій безпеки на **кожному вузлі**. Falco працює як DaemonSet — це дозволяє автоматично запускати окремий под Falco на кожному вузлі кластера.

---

## Кроки виконання

### 1. Створення кластера Minikube з кількома вузлами

```bash
minikube start --nodes=3 --driver=docker
```

Це створить кластер з 1 control-plane (`minikube`) і 2 worker-вузлами (`minikube-m02`, `minikube-m03`).

---

### 2. Перевірка кількості вузлів

```bash
kubectl get nodes

NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   58s   v1.32.0
minikube-m02   Ready    <none>          33s   v1.32.0
minikube-m03   Ready    <none>          10s   v1.32.0
```

---

### 3. Створення DaemonSet Falco

Falco розгортається з `falco-daemonset.yaml`, який включає:

- Привілейований доступ (`privileged: true`)
- Монтування системних директорій:
  - `/proc`, `/boot`, `/lib/modules`, `/var/run/docker.sock`, `/usr`
- Обмеження ресурсів:
  - `requests: 100m CPU / 128Mi memory`
  - `limits: 100m CPU / 256Mi memory`
- `tolerations: - operator: Exists` — для підтримки усіх вузлів

---

### 4. Застосування DaemonSet

```bash
kubectl apply -f falco-daemonset.yaml

daemonset.apps/falco created
```

---

### 5. Перевірка, що Falco запущений на всіх вузлах

```bash
kubectl get pods -l app=falco -n kube-system -o wide

NAME          READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
falco-56g5f   1/1     Running   0          66s   10.244.1.2   minikube-m02   <none>           <none>
falco-7m7qq   1/1     Running   0          66s   10.244.2.2   minikube-m03   <none>           <none>
falco-nt2jg   1/1     Running   0          66s   10.244.0.3   minikube       <none>           <none>
```

---

### 6. Перегляд логів з конкретного вузла

```bash
kubectl logs falco-hj8lj -n kube-system --tail=20

2025-05-16T18:49:10+0000: Falco version: 0.40.0 (x86_64)
2025-05-16T18:49:10+0000: Falco initialized with configuration files:
2025-05-16T18:49:10+0000:    /etc/falco/falco.yaml | schema validation: ok
2025-05-16T18:49:10+0000: System info: Linux version 5.15.167.4-microsoft-standard-WSL2 (root@f9c826d3017f) (gcc (GCC) 11.2.0, GNU ld (GNU Binutils) 2.37) #1 SMP Tue Nov 5 00:21:55 UTC 2024
2025-05-16T18:49:10+0000: Loading rules from:
2025-05-16T18:49:11+0000:    /etc/falco/falco_rules.yaml | schema validation: ok
2025-05-16T18:49:11+0000:    /etc/falco/falco_rules.local.yaml | schema validation: none
2025-05-16T18:49:11+0000: The chosen syscall buffer dimension is: 8388608 bytes (8 MBs)
2025-05-16T18:49:11+0000: Starting health webserver with threadiness 16, listening on 0.0.0.0:8765
2025-05-16T18:49:11+0000: Loaded event sources: syscall
2025-05-16T18:49:11+0000: Enabled event sources: syscall
2025-05-16T18:49:11+0000: Opening 'syscall' source with modern BPF probe.
2025-05-16T18:49:11+0000: One ring buffer every '2' CPUs.
```

---

## Результат

 Falco успішно розгорнутий як DaemonSet  
 Кожен вузол кластера має окремий под Falco  
 Системні події моніторяться в реальному часі  
 Логи підтверджують коректну роботу на кожному вузлі

---

## Prepared on: 5/16/2025 By: Andrii Fil (IT Administrator, DevOps trainee)