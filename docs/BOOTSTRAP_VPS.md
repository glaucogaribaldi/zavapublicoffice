# VPS Bootstrap — TRE/OpenClaw Runbook

## Rule zero

Observe before modifying. Never claim the VPS is clean or ready without runtime evidence.

## Phase A — Inventory

Record:

```bash
hostnamectl
cat /etc/os-release
uname -a
lscpu
free -h
lsblk -f
df -h
nvidia-smi || true
ip addr
ss -lntup
systemctl --failed
systemctl list-units --type=service --state=running
which docker || true
docker version || true
which python3
python3 --version
```

Also inspect:
- existing users;
- OpenClaw installation/state;
- Tailscale status;
- disk mount points;
- active containers;
- CUDA packages;
- large directories;
- existing model files.

Save findings under `runtime/audits/` with timestamp.

## Phase B — Connectivity

Verify both directions as needed:
- VPS ↔ U50 through Tailscale;
- dedicated SSH key;
- stable host identity;
- no dependency on public exposure for internal control.

Record exact tested commands and result.

## Phase C — Base runtime

Install only after inventory:
- Git;
- Docker/Compose if selected;
- PostgreSQL client/server or containerized equivalent;
- build tooling for llama.cpp;
- required NVIDIA/CUDA dependencies compatible with installed driver;
- Python runtime for workers if used;
- Node runtime only if required by dashboard/OpenClaw.

Pin important versions in documentation.

## Phase D — LLM server

Evaluate llama.cpp CUDA support on Tesla P4.

Expose only an internal endpoint, preferably Tailscale/local network.

Required endpoints/operations:
- health;
- model metadata;
- OpenAI-compatible chat completion if runtime supports it.

Do not invent model IDs. Discover/record actual model runtime identifiers.

## Phase E — Office services

Bring up:

```text
postgres
office-api
office-worker
office-dashboard
llm-server
```

All must have health checks and persistent storage where relevant.

## Phase F — Source Vault connection

Determine actual supported protocol for `pianodivino.com` (FTP/FTPS/SFTP/WebDAV/etc.) using credentials already entrusted to TRE.

Mounting is optional. A robust pull/sync adapter may be better.

Hard contract:
- `/zava`: import/read only;
- `/tre`: writable.

Never implement an operation that overwrites a `/zava` source by default.

## Phase G — Sample test

Create a synthetic/sample dataset with:
- two people;
- one ambiguous alias;
- one organization;
- one project;
- one promise/open loop;
- one contradictory statement.

Ingest it and verify:
- source registered;
- fragments stored;
- people resolved correctly;
- conflict represented;
- open loop created;
- provenance retrievable;
- semantic search returns relevant evidence;
- TRE can retrieve the result from U50.

## Completion gate

Bootstrap is `READY` only if the end-to-end sample test passes.

Otherwise report `BLOCKED` or `PARTIAL` with evidence.
