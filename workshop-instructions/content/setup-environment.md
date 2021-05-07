#### Workshop Command Execution
This workshop uses action blocks for various purposes, anytime you see such a block with an icon on the right hand side, you can click on it and it will perform the listed action for you.

> This is a real environment where action blocks can create real apps and Kubernetes clusters. **Please, wait for an action to fully execute before proceeding to the next so the workshop behaves as expected.**

#### Workshop Terminals
Two terminals are included in this workshop, you will mainly use terminal 1, but if it's busy you can use terminal 2 .

Try the action block's bellow
```execute-1
echo "Hi I'm terminal 1"
```
```execute-2
echo "Hi I'm terminal 2"
```
#### Workshop Code Editor
The workshop features a built in code editor you can use by pressing the `Editor` tab button. Pressing the refresh button in the workshop's UI can help the editor load when switching tabs. The files in this editor automatically
save.


The editor takes a few moments to load, please select the **Editor** tab now to display it, or click on the action block below.

```dashboard:open-dashboard
name: Editor
```

#### Workshop Console (Ocant)
You will have the ability to inspect your Kubernetes cluster with [Octant](https://github.com/vmware-tanzu/octant), an Open Source developer-centric web interface for Kubernetes that lets you inspect a Kubernetes cluster and its applications.

You haven't deployed anything to Kubernetes so there isn't much to display at the moment. When you get to the section `7: Deploying to Kubernetes`, you will have a Kubernetes cluster and a Spring Boot app to inspect with [Octant](https://github.com/vmware-tanzu/octant).

```dashboard:open-dashboard
name: Console
```
