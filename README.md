# Educates Workshop Template Repo

This repo is intended to be used as an easy way to duplicate and then add
your workshop specific content that would run on Educates.

## Requirements
* [Docker Desktop](https://www.docker.com/get-started)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [Kind](https://kind.sigs.k8s.io/)

## Commands
### Build and Run Locally
```
make
```
## Rebuild, and redeploy the workshop and training portal with changes
```
make reload
```
## Refresh the content in existing deployment
```
make refresh
```
### Shut everything down
```
make kind-stop
```
## Starting without rebuilding images
```
make kind-start
```
## Resources

* [Educates](https://docs.edukates.io/)