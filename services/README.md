# Services — Implementation Contract

This directory is intentionally a **skeleton** at repository bootstrap.

TRE/OpenClaw must implement the services below after auditing the real VPS. Nothing in this directory should be considered runtime-verified until tests exist and pass.

## `services/api`

Preferred characteristics:
- simple HTTP API;
- OpenAPI schema;
- PostgreSQL access through migrations/typed models;
- no direct dependency on one LLM vendor;
- health/readiness endpoints.

Minimum endpoints:

```text
GET  /health
GET  /ready
GET  /people
GET  /people/{id}
GET  /projects
GET  /projects/{id}
GET  /organizations
GET  /timeline
GET  /open-loops
GET  /sources/{id}
GET  /facts/{id}/evidence
POST /search
POST /ingestion/jobs
GET  /ingestion/jobs/{id}
POST /chat/context
```

## `services/worker`

Responsibilities:
- discover source objects;
- register sources/checksums;
- parse supported formats;
- create fragments;
- deterministic normalization;
- LLM structured extraction;
- identity resolution;
- facts/evidence writes;
- relationships;
- embeddings;
- timeline/project/open-loop updates;
- retry and job-state management.

Long-running jobs must be restartable/idempotent.

## `services/dashboard`

Implement the UI described in `docs/DASHBOARD.md`.

The dashboard reads from office-api. It must not directly parse the Source Vault.

## `services/llm-provider`

Optional adapter process/library around local inference.

Required logical methods:
- chat;
- structured extraction;
- embeddings where applicable;
- health;
- model metadata.

Prefer OpenAI-compatible local HTTP where practical, but isolate provider-specific behavior behind an adapter.

## Tests

Each service needs:
- unit tests for deterministic behavior;
- integration tests against PostgreSQL;
- E2E synthetic archive test;
- healthcheck verification.

Runtime evidence belongs in `runtime/`, not in assumptions inside documentation.
