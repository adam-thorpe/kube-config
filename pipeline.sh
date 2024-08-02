#!/bin/bash

deploy() {
    ## Start Minikube
    if [ $(eval sudo minikube status | grep "^host: " | sed 's/^.*: //') == "Stopped" ]; then
        rm /tmp/juju-*
        sudo minikube start --driver=docker --force
    fi

    ## Init Argo CD
    if !(sudo kubectl get namespace argocd >/dev/null 2>&1); then
        sudo kubectl create namespace argocd
        sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    fi

    ## Log In
    if [ $(eval sudo argocd account get-user-info --port-forward-namespace argocd | grep "^Logged In: " | sed 's/^.*: //') == "false" ]; then
        
        DEFAULT_PASSWORD=$(eval sudo argocd admin initial-password -n argocd | grep -o "^[A-Za-z0-9_-]*")
        sudo argocd login cd.apps.argoproj.io --username admin --password "$DEFAULT_PASSWORD" --grpc-web --port-forward-namespace argocd
    fi

    ## Deploy app
    sudo argocd app create mock-app \
        --repo https://github.com/adam-thorpe/kube-config.git \
        --path deployment \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace default \
        --port-forward-namespace argocd
    ## Sync
    sudo argocd app sync mock-app --port-forward-namespace argocd

    ## Display URL
    echo ""
    echo "Application Created!"
    echo-app-url
}

echo-app-url() {
    echo "URL: $(eval sudo minikube service mock-app --url -n default)"
}

host-ui() {
    sudo kubectl config set-context --current --namespace=argocd
    sudo argocd admin dashboard
}

clean() {
    sudo argocd app delete mock-app --port-forward-namespace argocd
    sudo kubectl delete namespace argocd
    sudo minikube stop
}

case "$1" in
    deploy) deploy ;;
    echo-app-url) echo-app-url;;
    host-ui) host-ui ;;
    clean) clean ;;
    *) echo "Invalid option." && exit
esac