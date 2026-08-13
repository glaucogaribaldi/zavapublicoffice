CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS people (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name TEXT NOT NULL,
  first_name TEXT,
  last_name TEXT,
  primary_email TEXT,
  primary_phone TEXT,
  domain TEXT NOT NULL DEFAULT 'UNKNOWN' CHECK (domain IN ('WORK','PERSONAL','HYBRID','UNKNOWN')),
  summary TEXT,
  first_seen_at TIMESTAMPTZ,
  last_seen_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  legal_name TEXT,
  website TEXT,
  tax_id TEXT,
  summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_type TEXT NOT NULL,
  original_path TEXT,
  original_uri TEXT,
  checksum TEXT NOT NULL,
  bytes BIGINT,
  mime_type TEXT,
  source_account TEXT,
  source_timestamp TIMESTAMPTZ,
  discovered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ingested_at TIMESTAMPTZ,
  parser_version TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS idx_sources_checksum ON sources(checksum);

CREATE TABLE IF NOT EXISTS source_fragments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id UUID NOT NULL REFERENCES sources(id) ON DELETE CASCADE,
  fragment_type TEXT NOT NULL,
  external_id TEXT,
  thread_id TEXT,
  author_ref TEXT,
  recipient_refs JSONB,
  occurred_at TIMESTAMPTZ,
  text_content TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_fragments_source ON source_fragments(source_id);
CREATE INDEX IF NOT EXISTS idx_fragments_thread ON source_fragments(thread_id);

CREATE TABLE IF NOT EXISTS facts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_type TEXT NOT NULL,
  subject_id UUID,
  predicate TEXT NOT NULL,
  object_type TEXT,
  object_id UUID,
  value_json JSONB,
  truth_state TEXT NOT NULL CHECK (truth_state IN ('FACT','DERIVED_FACT','INFERENCE','USER_CONFIRMED','CONFLICT','UNKNOWN')),
  confidence NUMERIC(5,4) CHECK (confidence IS NULL OR (confidence >= 0 AND confidence <= 1)),
  valid_from TIMESTAMPTZ,
  valid_to TIMESTAMPTZ,
  created_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  supersedes_fact_id UUID REFERENCES facts(id)
);
CREATE INDEX IF NOT EXISTS idx_facts_subject ON facts(subject_type, subject_id);
CREATE INDEX IF NOT EXISTS idx_facts_predicate ON facts(predicate);

CREATE TABLE IF NOT EXISTS fact_evidence (
  fact_id UUID NOT NULL REFERENCES facts(id) ON DELETE CASCADE,
  source_fragment_id UUID NOT NULL REFERENCES source_fragments(id) ON DELETE CASCADE,
  evidence_weight NUMERIC(5,4),
  note TEXT,
  PRIMARY KEY (fact_id, source_fragment_id)
);

CREATE TABLE IF NOT EXISTS person_identifiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  kind TEXT NOT NULL,
  value TEXT NOT NULL,
  normalized_value TEXT NOT NULL,
  confidence NUMERIC(5,4),
  source_fact_id UUID REFERENCES facts(id),
  UNIQUE(kind, normalized_value, person_id)
);
CREATE INDEX IF NOT EXISTS idx_person_identifiers_norm ON person_identifiers(kind, normalized_value);

CREATE TABLE IF NOT EXISTS organization_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  role_title TEXT,
  valid_from TIMESTAMPTZ,
  valid_to TIMESTAMPTZ,
  confidence NUMERIC(5,4),
  fact_id UUID REFERENCES facts(id)
);

CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  organization_id UUID REFERENCES organizations(id),
  status TEXT NOT NULL DEFAULT 'DISCOVERED' CHECK (status IN ('DISCOVERED','ACTIVE','WAITING','DONE','ABANDONED','UNKNOWN')),
  description TEXT,
  inferred_start TIMESTAMPTZ,
  inferred_end TIMESTAMPTZ,
  confidence NUMERIC(5,4),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS project_people (
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  person_id UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  role TEXT,
  confidence NUMERIC(5,4),
  fact_id UUID REFERENCES facts(id),
  PRIMARY KEY(project_id, person_id)
);

CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  occurred_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  person_id UUID REFERENCES people(id),
  organization_id UUID REFERENCES organizations(id),
  project_id UUID REFERENCES projects(id),
  confidence NUMERIC(5,4),
  fact_id UUID REFERENCES facts(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_type TEXT NOT NULL,
  subject_id UUID NOT NULL,
  predicate TEXT NOT NULL,
  object_type TEXT NOT NULL,
  object_id UUID NOT NULL,
  confidence NUMERIC(5,4),
  fact_id UUID REFERENCES facts(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_relationship_subject ON relationships(subject_type, subject_id);
CREATE INDEX IF NOT EXISTS idx_relationship_object ON relationships(object_type, object_id);

CREATE TABLE IF NOT EXISTS open_loops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_person_id UUID REFERENCES people(id),
  counterparty_person_id UUID REFERENCES people(id),
  project_id UUID REFERENCES projects(id),
  organization_id UUID REFERENCES organizations(id),
  title TEXT NOT NULL,
  description TEXT,
  loop_type TEXT NOT NULL CHECK (loop_type IN ('PROMISE','REQUEST','FOLLOW_UP','DEADLINE','WAITING_REPLY','MISSING_DOCUMENT','OTHER')),
  status TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','WAITING','DONE','DISMISSED')),
  due_at TIMESTAMPTZ,
  confidence NUMERIC(5,4),
  source_fact_id UUID REFERENCES facts(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS embeddings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  model TEXT NOT NULL,
  embedding vector,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS clarification_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  reason TEXT,
  priority INTEGER NOT NULL DEFAULT 50,
  status TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','ANSWERED','DISMISSED')),
  related_entity_type TEXT,
  related_entity_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  answered_at TIMESTAMPTZ
);
