# Data Model — Ufficio Zava

## Canonical principle

Raw files are evidence. PostgreSQL holds normalized canonical knowledge. Derived knowledge never replaces original evidence.

## Core entities

### people
- id UUID
- display_name
- first_name
- last_name
- primary_email
- primary_phone
- domain: WORK | PERSONAL | HYBRID | UNKNOWN
- summary
- first_seen_at
- last_seen_at
- created_at
- updated_at

### person_identifiers
- person_id
- kind: email | phone | handle | linkedin | other
- value
- normalized_value
- confidence
- source_fact_id

### organizations
- id
- name
- legal_name
- website
- vat_or_tax_id when present
- summary

### organization_roles
- person_id
- organization_id
- role_title
- valid_from
- valid_to
- confidence
- fact_id

### projects
- id
- title
- organization_id nullable
- status: DISCOVERED | ACTIVE | WAITING | DONE | ABANDONED | UNKNOWN
- description
- inferred_start
- inferred_end
- confidence

### project_people
- project_id
- person_id
- role
- confidence
- fact_id

### events
Timeline object.
- id
- event_type
- title
- description
- occurred_at
- ended_at nullable
- person_id nullable
- organization_id nullable
- project_id nullable
- confidence

### sources
Immutable imported source registry.
- id
- source_type
- original_path
- original_uri
- checksum
- bytes
- mime_type
- source_account
- source_timestamp
- discovered_at
- ingested_at
- parser_version

### source_fragments
Addressable evidence fragments: email, message, paragraph, file segment, contact record, etc.
- id
- source_id
- fragment_type
- external_id nullable
- thread_id nullable
- author_ref
- recipient_refs
- occurred_at
- text_content
- metadata JSONB

### facts
- id
- subject_type
- subject_id
- predicate
- object_type
- object_id nullable
- value_json
- truth_state
- confidence
- valid_from nullable
- valid_to nullable
- created_by
- created_at
- supersedes_fact_id nullable

Truth states:
- FACT
- DERIVED_FACT
- INFERENCE
- USER_CONFIRMED
- CONFLICT
- UNKNOWN

### fact_evidence
- fact_id
- source_fragment_id
- evidence_weight
- note

### relationships
Generic graph edge.
- id
- subject_type
- subject_id
- predicate
- object_type
- object_id
- confidence
- fact_id

Examples:
- KNOWS
- WORKED_WITH
- WORKS_AT
- FOUNDED
- CLIENT_OF
- SUPPLIER_OF
- PARTICIPATED_IN
- DISCUSSED
- OWES_ACTION_TO

### open_loops
- id
- owner_person_id nullable
- counterparty_person_id nullable
- project_id nullable
- organization_id nullable
- title
- description
- loop_type: PROMISE | REQUEST | FOLLOW_UP | DEADLINE | WAITING_REPLY | MISSING_DOCUMENT | OTHER
- status: OPEN | WAITING | DONE | DISMISSED
- due_at nullable
- confidence
- source_fact_id

### notes
Explicit human or AI notes. Must not be silently promoted to facts.

### embeddings
Prefer pgvector references to source fragments/entities rather than duplicating canonical fields.

## Identity resolution

Never merge people only by display name.

Use evidence such as:
- exact email;
- normalized phone;
- stable account identifier;
- signature/organization consistency;
- conversation context;
- user confirmation.

Ambiguous matches remain separate until confidence threshold or USER_CONFIRMED merge.

## Temporal model

Roles, organizations, projects and facts can change over time. Preserve validity ranges and historical states. Never overwrite history simply because current information differs.

## Person 360 computed view

A Person 360 page is assembled from canonical tables, not stored as an opaque LLM biography.

It should expose:
- identity;
- identifiers;
- professional timeline;
- relationship with Giacomo;
- interactions;
- organizations;
- projects;
- open loops;
- observed communication patterns;
- AI inferences separately from facts;
- provenance links.

## Google Sheets export

Sheets is a view/export only. Suggested columns:

Person ID | Name | Company | Role | Emails | Phones | LinkedIn | Domain | First interaction | Last interaction | Interaction count | Shared projects | Open loops | Relationship summary | Identity confidence | Web verified | Last verified | Notes
