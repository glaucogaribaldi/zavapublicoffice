# Architecture — Ufficio Zava

## 1. Obiettivo architetturale

Separare chiaramente:

- identità/orchestrazione di TRE;
- compute AI;
- memoria persistente;
- sorgenti originali;
- servizi applicativi;
- dashboard.

Il sistema deve sopravvivere a cambi di modello, VPS e macchina finale.

## 2. Topologia

```text
                     Giacomo
                        │
                        ▼
                  TRE MAIN / U50
                        │
              Tailscale / SSH / API
                        │
                        ▼
               Ufficio Zava VPS Node
        ┌───────────────┼────────────────┐
        │               │                │
        ▼               ▼                ▼
   API/backend       AI runtime       Workers
        │               │                │
        ├───────────────┼────────────────┤
        │               ▼                │
        │          NVIDIA/Nemotron       │
        │                                │
        ▼                                ▼
   PostgreSQL + vector              ingestion jobs
        │
        ├── canonical entities
        ├── relations/graph
        ├── provenance
        ├── projects
        ├── open loops
        └── timeline

External source vault:
ftp.pianodivino.com/zava  → READ/IMPORT ONLY

Agent workspace:
ftp.pianodivino.com/tre   → READ/WRITE
```

## 3. Componenti logici

### 3.1 TRE MAIN

Responsabilità:

- unico interlocutore;
- decide quando interrogare Ufficio Zava;
- delega lavori pesanti;
- riceve risultati sintetici;
- non conserva da solo la memoria canonica.

### 3.2 Office API

API stabile indipendente dal modello.

Funzioni minime:

- search;
- person lookup;
- project lookup;
- timeline query;
- source/provenance lookup;
- open loops;
- company lookup;
- chat context retrieval;
- ingestion trigger/status.

### 3.3 Worker layer

Worker separati per:

- source discovery;
- parsing;
- entity extraction;
- entity resolution;
- embeddings;
- timeline updates;
- project reconstruction;
- open loop extraction;
- enrichment;
- company intelligence.

### 3.4 AI provider abstraction

Definire un adapter OpenAI-compatible o interno con almeno:

- `chat()`;
- `structured_extract()`;
- `embed()`;
- health/status;
- model metadata.

Nessun dominio applicativo deve importare direttamente un singolo SDK modello.

### 3.5 Persistence

Preferenza iniziale:

- PostgreSQL;
- pgvector;
- relational graph edge table;
- object/file metadata tables;
- optional object cache locale.

Aggiungere Neo4j/altro solo con ADR motivato.

## 4. Deployment profiles

### FULL — VPS

Per:

- import iniziale massivo;
- ricostruzione storica;
- entity resolution pesante;
- embeddings batch;
- analisi aziendale;
- web enrichment.

### EDGE — Mac mini M4 16 GB

Per:

- query quotidiane;
- aggiornamenti incrementali;
- classificazioni leggere;
- retrieval;
- chat;
- task piccoli.

Il database può restare locale o remoto secondo benchmark futuri, ma schema/API devono essere gli stessi.

## 5. Availability

Servizi desiderati:

- `office-api`
- `office-worker`
- `office-dashboard`
- `postgres`
- `llm-server`

Tutti con healthcheck.

## 6. Evidence policy

Ogni claim operativo deve essere accompagnato da runtime evidence.

Distinguere sempre:

- CONFIGURED
- IMPLEMENTED
- TESTED
- VERIFIED

## 7. Non-obiettivi iniziali

Non implementare subito:

- invio email automatico;
- modifica Drive automatica;
- calendari attivi;
- azioni irreversibili esterne.

Prima costruire memoria e comprensione. Le capacità di segreteria attiva arrivano in una fase successiva.
