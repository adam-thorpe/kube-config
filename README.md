## Minikube manual deployment
Start - `sudo minikube start --driver=docker --force`
Deploy - `kubectl create deployment mock-app --image=adamthorpe2/mock-app`
Add Service - `kubectl expose deployment mock-app --type=LoadBalancer --port=8080`

Workaround:
- Run tunnel: `minikube tunnel`
- Grab External IP from service as HOST

Clean up:
- `sudo kubectl delete deployment mock-app`
- `sudo minikube stop`

## WIP
Start/Stop not working: `rm /tmp/juju-*`



## Minikube auto deployment
Start etc..
Deploy - `sudo kubectl apply -f deployment.yml`
Get url - `sudo minikube service mock-app-service --url`
Clean up - `sudo kubectl delete -f deployment.yml`



## ArgoCD WIP
Start service
- `kubectl create namespace argocd`
- `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`

Set external endpoint: `kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'`

Default password: `argocd admin initial-password -n argocd --insecure` - `1hfvdKJ08js9DrCk` - `test`

Login - `sudo argocd login cd.apps.argoproj.io --username admin --password test --grpc-web --port-forward-namespace argocd`

Register cluster
- `kubectl config get-contexts -o name`
- `argocd cluster add minikube`

Deploy app - `sudo argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default --port-forward-namespace argocd`

Sync - `sudo argocd app sync guestbook --port-forward-namespace argocd`

Clear up
- `sudo argocd app delete guestbook --port-forward-namespace argocd`
- `sudo kubectl delete namespace argocd`