# Dashboard — Ufficio Zava

## Goal

Single responsive web interface for Giacomo. TRE remains the conversational front door; dashboard exposes structured memory and evidence.

## Main navigation

- Home
- Lavoro
- Vita
- Persone
- Progetti
- Aziende
- Timeline Zava
- Open Loops
- Documenti / Sorgenti
- Company Intelligence
- Chat TRE

## Home

Show:
- open loops requiring attention;
- waiting replies;
- active projects;
- recent people/interactions;
- newly discovered conflicts;
- high-value clarification questions;
- ingestion status.

## Lavoro

Views:
- active/waiting/done/abandoned projects;
- companies;
- contacts;
- clients/suppliers;
- processes reconstructed from evidence;
- contracts/documents;
- commercial opportunities;
- operational open loops.

## Vita

Views:
- personal people;
- hybrid people;
- personal timeline;
- events;
- interests;
- conversations and memories.

This is a visual separation only; cross-domain retrieval is allowed.

## Person 360

Sections:
- identity;
- current/historical roles;
- relationship to Giacomo;
- timeline;
- projects;
- organizations;
- recent interactions;
- communication patterns;
- open loops;
- inferred behavioral notes;
- source/evidence browser.

Facts and inferences must be visually distinct.

## Project page

Show:
- project summary;
- state;
- inferred timeline;
- people;
- organizations;
- communications;
- files;
- decisions;
- deliverables;
- open loops;
- source evidence.

## Company page

Show:
- history;
- people/roles over time;
- projects;
- clients/suppliers;
- contracts;
- finance-related documents;
- decisions;
- processes;
- timeline;
- unresolved questions.

## Chat TRE

The chat must:
- use retrieval from canonical memory;
- return concise answers by default;
- cite source items when available;
- distinguish fact/inference/conflict;
- allow follow-up navigation to person/project/source;
- optionally create a clarification request rather than hallucinating.

## Search

One global search across:
- people;
- companies;
- projects;
- source fragments;
- timeline;
- open loops.

Use lexical + semantic retrieval.

## Mobile

Dashboard must remain usable on iPhone. Prioritize:
- Home;
- search;
- chat;
- person page;
- open loops.

## Suggested frontend

TRE should evaluate mature open-source choices. Prefer a conventional stack such as Next.js/React unless a better maintained alternative is justified.
