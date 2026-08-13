# Ingestion — Ufficio Zava

## Goal

Ingest heterogeneous personal and professional archives incrementally without modifying originals.

## Supported source families

- Google Takeout / Drive
- Gmail MBOX / Google Takeout mail
- IMAP exports / Maildir / MBOX
- ChatGPT export
- WhatsApp exports
- vCard / contacts
- generic files: PDF, DOCX, XLSX, CSV, TXT, images metadata

## Source registration

Before parsing, register every object in `sources` with:

- stable source id;
- original path/URI;
- checksum;
- size;
- mime type;
- account/source family;
- discovery timestamp.

If checksum already exists, mark duplicate but preserve each original location.

## Pipeline

```text
DISCOVER
  ↓
REGISTER
  ↓
COPY TO /tre staging when needed
  ↓
PARSE
  ↓
NORMALIZE
  ↓
FRAGMENT
  ↓
EXTRACT ENTITIES / FACTS / DATES / TASKS
  ↓
IDENTITY RESOLUTION
  ↓
RELATIONSHIP LINKING
  ↓
PROJECT / COMPANY / TIMELINE / OPEN LOOP UPDATES
  ↓
EMBED
  ↓
INDEX
  ↓
QA / PROVENANCE CHECK
```

## Idempotency

Re-running ingestion must not create uncontrolled duplicates.

Use checksums, parser version and external ids. A new parser version may regenerate derived fragments/facts while preserving lineage.

## Email

Preserve:

- Message-ID;
- thread references;
- From/To/CC/BCC;
- subject;
- date;
- body text and HTML relation;
- attachments and filenames;
- mailbox/folder;
- account source.

Thread reconstruction should occur after parsing individual messages.

## Google Drive

Preserve:

- original path;
- original name;
- export metadata;
- modified/created timestamps where available;
- owner/account;
- sharing metadata where exported;
- relationships between Google-native export variants and original logical document.

## ChatGPT

Preserve conversation id/title/timestamps and message tree when available. Treat assistant-generated content as conversational evidence, not automatically as fact about Giacomo.

User messages are high-value evidence but still require temporal/context awareness.

## WhatsApp

Preserve:

- chat identity;
- participants;
- group name;
- timestamp;
- sender;
- message;
- attachment references.

Do not lose timezone/source export assumptions.

## Contacts

vCard records are identity hints, not proof that two similar names are the same person.

## Extraction

Prefer deterministic parsers first, LLM second.

Examples:
- headers/dates: deterministic;
- vCard: deterministic;
- filenames/mime: deterministic;
- named entities/implicit commitments/project inference: LLM + rules.

## Open loops extraction

Look for explicit and implicit patterns such as:

- "te lo mando";
- "ti faccio sapere";
- "ricordami";
- "sentiamoci";
- unanswered direct questions;
- requested attachments;
- promised deliverables;
- deadline expressions;
- waiting for approval/payment/document.

Every loop must link back to evidence and confidence.

## Project discovery

Projects may be latent. Cluster evidence by:

- recurring title/keywords;
- people set;
- organization;
- attached files;
- time window;
- commercial subject;
- conversation threads.

Create `DISCOVERED` project candidates first. Promote to ACTIVE/DONE/etc only when evidence warrants it.

## Human clarification queue

Generate questions only when answering them materially improves the canonical model, e.g.:

- duplicate identity ambiguity;
- contradictory roles/dates;
- unclear project boundaries;
- uncertain company relationships.

Do not spam Giacomo with low-value questions.
