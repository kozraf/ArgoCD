# Create a directory for ArgoCD on NFS and set the permissions
sudo mkdir -p /srv/nfs/argocd
sudo chown nobody:nogroup /srv/nfs/argocd
sudo chmod 777 /srv/nfs/argocd

# Create a new Kubernetes namespace for ArgoCD
kubectl create namespace argocd

# Create a file with the definition for a Persistent Volume (PV) using a here-document (EOF)
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
    path: /srv/nfs/argocd
    server: 192.168.89.141
EOF

# Create a file with the definition for a Persistent Volume Claim (PVC) using a here-document (EOF)
sudo tee /home/vagrant/ArgoCD/argocd-pvc.yaml <<EOF
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

# Apply the PV and PVC definitions to the Kubernetes cluster
kubectl apply -f /home/vagrant/ArgoCD/argocd-pv.yaml
kubectl apply -f /home/vagrant/ArgoCD/argocd-pvc.yaml

# Add the ArgoCD Helm repository and update Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create a file with specific values for the ArgoCD Helm chart
sudo tee /home/vagrant/ArgoCD/values.yaml <<EOF
server:
  service:
    type: NodePort
EOF

# Install ArgoCD using Helm and the custom values
helm install argocd argo/argo-cd -f values.yaml --namespace argocd
# If above was run before - CRDs will still exists so use:
#helm install argocd argo/argo-cd -f values.yaml --skip-crds -n argocd

# Wait for all pods in all namespaces to be running
while true; do
  for ns in $(kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
    for pod in $(kubectl get pods -n $ns -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
      total=$(kubectl get pod $pod -n $ns -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' | wc -l)
      running=$(kubectl get pod $pod -n $ns -o=jsonpath='{range .status.containerStatuses[*]}{.state.running}{end}' | grep -c true)
      if [[ $total -ne $running ]]; then
        for i in $(seq 0 3); do
          echo -ne "\r[${animation:$i:1}]"
          sleep 0.1
          done
        echo -e "\033[33m---\033[0m"
        echo -e "\033[33mWaiting for all containers to be running in pod $pod in namespace $ns \033[0m"
        sleep 1
      fi
    done
  done
  echo -e "\e[32mAll pods are ready!\e[0m"
  break
done

#Instructions for the user:
echo -e "\e[32mInstructions:!\e[0m"
echo -e "1. Check on which node kubernetes-dashboard pod is running"
kubectl get po -A -o wide
kubectl get no -A -o wide
echo -e "2. Check NodePort value for ArgoCD Server service:"
kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}'
echo -e "3. Access it with https://nodeip:32321"
echo -e "4. Use secret to access it:"
kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

#Uninstall with:
#helm uninstall argocd -n argocd