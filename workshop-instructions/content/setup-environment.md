#### Command Execution
This workshop uses action blocks for various purposes.
Any time you see such a block with an icon in the top right corner, you can click on it and it will perform the specified action for you.

> This is a real environment where action blocks can create real apps and Kubernetes clusters.
> **Please wait for an action to fully execute before proceeding to the next so the workshop behaves as expected.**

#### Terminals
Two terminals are included in this workshop, you will mainly use terminal 1, but if it's busy you can use terminal 2.

Try the action blocks below.
```execute-1
echo "Hi I'm terminal 1"
```
```execute-2
echo "Hi I'm terminal 2"
```

#### Code Editor
The workshop features a built-in code editor you can use by pressing the `Editor` tab button.
The files in this editor save automatically.

Select the **Editor** tab now to display it, or click on the action block below.
> The editor takes a few moments to load.
> Pressing the refresh button in the workshop's UI can help the editor load when switching tabs.
```dashboard:open-dashboard
name: Editor
```

#### Kubernetes Console (Octant)
You will have the ability to inspect your Kubernetes cluster with [Octant](https://github.com/vmware-tanzu/octant), an Open Source developer-centric web interface for Kubernetes that lets you inspect a Kubernetes cluster and its applications.

You haven't deployed anything to Kubernetes so there isn't much to display at the moment, but you can take a quick look at the dashboard now and come back to it later in the workshop.

```dashboard:open-dashboard
name: Console
```

Click the following action block to return to the Terminal.
```dashboard:open-dashboard
name: Terminal
```
