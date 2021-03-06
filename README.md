# k8s-kubectl

This Dockerfile generates a minimal image with kubectl and git installed.

This makes it easy to execute `kubectl apply -k` to use [kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) from a Tekton task, having git is required to clone base templates

## why do I need this?

Without this, you'll get a message something like this:

```
error: couldn't make loader for https://github.com/me/myrepo/deploy: no 'git' program on path: exec: "git": executable file not found in $P
```

## example

```yaml
apiVersion: tekton.dev/v1alpha1
kind: Task
metadata:
  name: deploy-using-kubectl
spec:
  inputs:
    resources:
      - name: source
        type: git
      - name: image
        type: image
    params:
      - name: PATHTODEPLOYMENT
        type: string
        description: Path to the manifest to apply
        default: deploy
      - name: NAMESPACE
        type: string
        description: Namespace to deploy into
      - name: DRYRUN
        type: string
        description: If true run a server-side dryrun.
        default: "false"
      - name: YAMLPATHTOIMAGE
        type: string
        description:
          The path to the image to replace in the yaml manifest (arg to yq)
  steps:
    - name: replace-image
      image: mikefarah/yq
      workingDir: /workspace/source
      command: ["yq"]
      args:
        - "w"
        - "-i"
        - "$(inputs.params.PATHTODEPLOYMENT)/deployment.yaml"
        - "$(inputs.params.YAMLPATHTOIMAGE)"
        - "$(inputs.resources.image.url)"
    - name: run-kubectl
      image: quay.io/bigkevmcd/k8s-kubectl
      workingDir: /workspace/source
      command: ["kubectl"]
      args:
        - "apply"
        - "-n"
        - "$(inputs.params.NAMESPACE)"
        - "-k"
        - "$(inputs.params.PATHTODEPLOYMENT)"
```
