---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: spot-cluster
  region: us-west-2
managedNodeGroups:
# `instanceTypes` defaults to [`m5.large`]
  - name: spot-1
    spot: true
    ssh:
      publicKeyName: OregonEswar #replace with your public key pair