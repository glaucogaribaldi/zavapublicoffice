# STATUS — Ufficio Zava

## Repository bootstrap

Status: **SPECIFICATION READY / RUNTIME UNTESTED**

The repository currently contains:
- mission and TRE start prompt;
- architecture;
- canonical data model;
- ingestion contract;
- dashboard specification;
- NVIDIA/Nemotron strategy;
- VPS bootstrap runbook;
- implementation roadmap;
- initial PostgreSQL schema;
- Docker Compose topology skeleton;
- environment template;
- service implementation contracts.

## Not yet verified

The following must NOT be described as working until TRE/OpenClaw provides runtime evidence:
- actual VPS cleanliness/state;
- CUDA/driver compatibility;
- llama.cpp CUDA build;
- Nemotron model selection/performance;
- OpenClaw worker node deployment;
- FTP/FTPS/SFTP protocol and source access;
- database startup;
- API implementation;
- worker implementation;
- dashboard implementation;
- U50 → VPS → LLM → DB → U50 end-to-end flow.

## First gate

`M1 READY` requires all of:

- [ ] VPS audit stored in repository
- [ ] U50↔VPS control path verified
- [ ] local NVIDIA-backed LLM endpoint verified
- [ ] PostgreSQL + pgvector healthy
- [ ] sample source registered with checksum
- [ ] sample fragmented and parsed
- [ ] at least 2 people resolved
- [ ] one project produced
- [ ] one open loop produced
- [ ] one conflict represented as CONFLICT, not overwritten
- [ ] evidence/provenance retrievable
- [ ] TRE on U50 can request and retrieve the result
- [ ] runtime report marks tests PASS with commands/evidence

Until all boxes pass, the system is not operational.
