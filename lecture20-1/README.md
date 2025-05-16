# Розгортання Redis за допомогою StatefulSet у Kubernetes

Цей проєкт демонструє, як розгорнути Redis з двома репліками, використовуючи StatefulSet у Kubernetes. Кожен екземпляр Redis має стабільне ім’я та власний постійний том для зберігання даних.

## Мета

- Розгорнути Redis з двома репліками
- Використати StatefulSet для стабільних імен pod'ів
- Використати PVC для зберігання даних
- Забезпечити взаємодію між екземплярами за допомогою Service типу ClusterIP (headless)

## Файли конфігурації

- `redis-configmap.yaml` – конфігураційний файл Redis, що монтується як конфігурація
- `redis-service.yaml` – headless Service для внутрішнього DNS між pod'ами
- `redis-statefulset.yaml` – StatefulSet з визначенням PVC, конфігурації та шаблону pod'а

## Інструкція з розгортання

1. Застосуйте конфігураційні файли у Kubernetes:

```
kubectl apply -f redis-configmap.yaml
kubectl apply -f redis-service.yaml
kubectl apply -f redis-statefulset.yaml

configmap/redis-config created
service/redis created
statefulset.apps/redis created

```

2. Перевірте, чи pod'и запущені:

```
kubectl get pods

NAME      READY   STATUS    RESTARTS   AGE
redis-0   1/1     Running   0          18s
redis-1   1/1     Running   0          16s
```


3. Перевірте роботу Redis:

```
kubectl exec -it redis-0 -- redis-cli ping

PONG
```

4. Перевірте збереження даних:

```
kubectl exec -it redis-0 -- redis-cli set test_key "Hello from redis-0"
kubectl delete pod redis-0
kubectl exec -it redis-0 -- redis-cli get test_key

"Hello from redis-0"
```

## Примітки

- Це базове розгортання Redis без кластеризації (без Sentinel і без Redis Cluster).
- Підходить для тестових або демонстраційних середовищ.
- Для продакшену слід використовувати Redis Sentinel або Redis Cluster з трьома майстер-нодами.

## Prepared on: 5/16/2025 By: Andrii Fil (IT Administrator, DevOps trainee)