# Running Hotstuff in shadow

This document shows how to run [Hotstuff](https://github.com/asonnino/hotstuff) in [shadow](https://github.com/shadow/shadow).

## Install Shadow

please refer to [Shadow installation](https://github.com/shadow/shadow?tab=readme-ov-file#quickstart)

## Hotstuff Setup

Run the following commands to initialize Hotstuff, including install dependencies, compile the code, and generate executable files (client and node).

```bash
git clone git@github.com:asonnino/hotstuff.git
cd hotstuff/benchmark
pip install -r requirements.txt
fab local
```

## Example: Run Hotstuff in shadow

Put our configured files (e.g., `./4nodes` and `./9nodes`) to the Hotstuff directory `./benchmark`.

Run Hotstuff in shadow. E.g., run 9 nodes

```bash
cd 9nodes
rm -rf shadow.data/
shadow shadow.yaml > shadow.log
```
