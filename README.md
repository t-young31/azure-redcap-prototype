# AML + K8s

## Usage

Create a `.env` file from `.env.sample` replacing the values where appropriate
```
make login
made deploy
# make destroy
```

Go to the AML workspace → Jobs → Create → Kubernetes compute → Add cluster → _Run an AML job_

> **Warning**
> The destroy isn't super stable, and may need some manual deletions


## Modules
[k8s/](./terraform/k8s/) borrows heavily from https://github.com/rancher/quickstart/tree/master/rancher/aws

[aml/](./terraform/aml)
