# Roadmap — Ufficio Zava

## M0 — Audit

Goal: know the real VPS/U50 state.

Deliverables:
- VPS audit report;
- U50↔VPS connectivity evidence;
- runtime inventory;
- storage protocol verified;
- explicit blockers.

## M1 — End-to-end skeleton

Goal: prove the architecture before building features.

Deliverables:
- PostgreSQL running;
- office-api health endpoint;
- office-worker;
- local NVIDIA/Nemotron-compatible inference endpoint;
- sample ingestion;
- provenance;
- TRE U50 retrieval.

Gate: synthetic E2E PASS.

## M2 — Core ingestion

Implement parsers/importers for:
- contacts/vCard;
- email MBOX/Maildir;
- ChatGPT export;
- Drive files/metadata;
- generic documents.

WhatsApp may follow after format acquisition.

Gate: idempotent re-ingestion tests PASS.

## M3 — People & Truth

Implement:
- people;
- identifiers;
- entity resolution;
- organizations/roles;
- facts/evidence;
- conflicts;
- Person 360.

Gate: ambiguous-person test and provenance test PASS.

## M4 — Timeline / Projects / Open Loops

Implement:
- timeline events;
- latent project discovery;
- project status;
- commitments/follow-ups;
- clarification queue.

Gate: known synthetic cases reconstructed correctly.

## M5 — Company Intelligence

Implement:
- company history;
- people/roles over time;
- project relations;
- contracts/document linking;
- finance-related evidence;
- processes reconstructed from repeated cases.

## M6 — Dashboard

Responsive UI with:
- Home;
- Work/Life;
- People;
- Projects;
- Companies;
- Timeline;
- Open Loops;
- Sources;
- TRE chat/search.

## M7 — Real archive bootstrap

As Takeout/export archives arrive:
- register;
- ingest incrementally;
- monitor quality;
- deduplicate entities;
- generate high-value clarification questions.

Never wait for every archive before starting.

## M8 — Daily operating mode

Move from historical reconstruction to continuous updates.

Add:
- scheduled source checks;
- new-email ingestion;
- new-file ingestion;
- daily summary;
- open-loop refresh;
- project change detection.

## M9 — Secretary capabilities

Only after canonical memory is reliable:
- mail reading integration;
- draft preparation;
- calendar integration;
- Drive organization;
- contact follow-up workflows;
- explicit delegation controls.

## M10 — Mac mini EDGE migration

Target: Mac mini M4 16 GB.

Before migration:
- benchmark compact model;
- verify API compatibility;
- export/replicate database;
- run same E2E test suite;
- identify VPS-only heavy workflows;
- ensure normal daily use works without heavy VPS compute.
