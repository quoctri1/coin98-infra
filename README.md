# coin98-infra

This repo just contain terraform code for deploy infrastructure, but I'll guide detail about how to deploy my testing services include CI/CD.

## How to deploy infrastructure
We have this repo contain terraform code that will deploy our infrastructure. Following descirbe below:

1. Create the AWS network in `network` folder that include our network and security group.
2. Second, `iam` folder create IAM that include role for EKS and nodegroup
3. Next, create EKS cluster and some IAM that will use by [cluster-autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md) and [aws-load-balancer](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) in `eks` folder

## Deploy our application
In this section we have 3 repo need to follow:
1. https://github.com/quoctri1/coin98-fe - Frontend code
2. https://github.com/quoctri1/coin98-be - Backend code
3. https://github.com/quoctri1/helm-coin98 - Helm chart

First of all, we need to deploy [cluster-autoscaler](https://github.com/quoctri1/helm-coin98/tree/main/cluster-autoscaler) and [aws-load-balancer](https://github.com/quoctri1/helm-coin98/tree/main/aws-load-balancer-controller) to help us auto scale our cluster and create alb.

Second, don't forget create argocd and app namespace. Deploy argocd that help to deploy new version of our docker image when have new code change in our helm chart repo. We can't deploy [argocd-app](https://github.com/quoctri1/helm-coin98/blob/main/argo-cd/templates/argocd-app.yaml) application resource first cause lack crds, so we need set `--set crds.application=false`, after that waiting for argocd start up. We can access UI through alb dns.

Next, we can upgrade argocd helm chart that include `argocd-app` by `--set crds.application=true` (will manage our all argocd applications), so waiting for fe and be start.

### Note:
I use github action for CI/CD. You can check [here](https://github.com/quoctri1/coin98-fe/blob/main/.github/workflows/coin98-fe.yaml) (the same in fe and be). To run the CI/CD smoothly, you need to add 2 access key of AWS and ssh key as `WORKFLOW_DEPLOY_KEY` to secret that need to pull and push new code to helm chart repo.
