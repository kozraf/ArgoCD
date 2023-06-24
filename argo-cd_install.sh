sudo tee /home/vagrant/ArgoCD/argocd-pv.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: argocd-pv
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-storage
  nfs:
    path: /srv/nfs/k8s
    server: 192.168.89.141
EOF

sudo tee /home/vagrant/ArgoCD/argocd-pv.yaml <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: argocd-pvc
  namespace: argocd
spec:
  storageClassName: nfs-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF

kubectl apply -f /home/vagrant/ArgoCD/argocd-pv.yaml
kubectl apply -f /home/vagrant/ArgoCD/argocd-pvc.yaml


helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

sudo tee /home/vagrant/ArgoCD/values.yaml <<EOF
repoServer:
  volumes:
    - name: repo-cache
      persistentVolumeClaim:
        claimName: argocd-repo-cache-pvc
  volumeMounts:
    - mountPath: /var/argo/cd/reposerver/repository-cache
      name: repo-cache
EOF

kubectl apply -f /home/vagrant/ArgoCD/values.yaml

helm install argocd argo/argo-cd -f values.yaml --namespace argocd

kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
