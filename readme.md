# ArgoCD Kubernetes Setup

This repository contains the scripts and associated files for setting up ArgoCD on a Kubernetes cluster.

## Versions
### v1.0
- Initial setup script for ArgoCD.

## Introduction

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It allows users to maintain and manage their Kubernetes resources using git repositories as the source of truth. This project provides an easy way to set up ArgoCD on a Kubernetes cluster using Helm.

## Features

- **Simple Deployment**: With the provided script, setting up ArgoCD becomes a breeze.
- **Helm Integration**: Uses the Helm package manager for deploying ArgoCD, ensuring easy management and updates.
- **Custom Configuration**: The script includes custom values for the ArgoCD Helm chart, making it flexible for different deployment needs.
- **Namespace Isolation**: ArgoCD is set up in its own dedicated namespace, ensuring isolation and security.

## Requirements
- **Kubernetes** - check out my [RafK8clstr](https://github.com/kozraf/RafK8clstr) which will help you to deploy 3-node K8 cluster
- **Helm** - also included with [RafK8clstr](https://github.com/kozraf/RafK8clstr)

## Setup

1. Ensure you have `kubectl` and `helm` installed and configured.
2. Run the `argo-cd_install.sh` script.

### !Important!

Script included in this repo is used by [RafK8clstr](https://github.com/kozraf/RafK8clstr) but you can adjust it for your needs. Only relevant portion to be adjusted is:

"Create a file with specific values for the ArgoCD Helm chart
sudo tee **/home/vagrant/RafK8clstr/ArgoCD/values.yaml** <<EOF
server:
  service:
    type: NodePort
EOF"

and

"helm install argocd argo/argo-cd -f **/home/vagrant/RafK8clstr/ArgoCD/values.yaml** --namespace argocd"

Just adjust **"/home/vagrant/RafK8clstr/ArgoCD/values.yaml"** to whatever path you desire in your environment so the helm chart will configure the Kubernetes service with NodePort during ArgoCD deployment.


