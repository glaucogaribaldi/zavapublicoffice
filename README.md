# Zava Public Office — Ufficio Zava

Repository operativo per costruire **Ufficio Zava**, il sistema personale e professionale di memoria, archivio, consulenza e futura segreteria di Giacomo.

## Principio

Ufficio Zava non deve aspettare che Giacomo organizzi la propria vita per poterla comprendere.

È compito di Ufficio Zava trasformare informazioni disordinate, ridondanti, incomplete e contraddittorie in una rappresentazione ordinata, verificabile e progressivamente più accurata della vita, del lavoro, delle relazioni, delle aziende e della storia di Giacomo.

## Gerarchia

```text
Giacomo
  ↓
TRE MAIN — U50
  ↓
OpenClaw orchestration
  ↓
VPS worker node
  ↓
LLM NVIDIA/Nemotron locali
  ↓
sub-agenti / tools / database / dashboard
```

Giacomo deve avere **un solo interlocutore: TRE**. I sub-agenti sono interni e invisibili.

## Sorgenti

`/zava` è il SOURCE VAULT: originali leggibili ma non distruttivamente modificabili.

`/tre` è il workspace dell'agente: copie, indici, database, cache, software, report, inferenze e file derivati.

Sorgenti previste:

- Google Drive
- Gmail / IMAP mailboxes
- ChatGPT export
- WhatsApp
- contatti iPhone
- documenti e archivi vari

## Obiettivi principali

- Person 360 per ogni contatto
- Timeline completa di Giacomo
- separazione visuale Lavoro / Vita con conoscenza incrociabile
- ricostruzione automatica dei progetti
- storia delle aziende
- Company Intelligence
- Open Loops: promesse, follow-up, scadenze, questioni sospese
- ricerca semantica e knowledge graph
- provenienza cliccabile di ogni informazione importante
- dashboard web responsive
- chat con TRE che interroga l'archivio
- futura capacità di segreteria personale e professionale

## Start

**TRE/OpenClaw deve leggere prima di tutto:**

[`TRE_START_HERE.md`](TRE_START_HERE.md)

Poi seguire i documenti in `docs/` nell'ordine indicato.

## Stato

Questo repository definisce architettura, contratti e bootstrap. Gli elementi non ancora verificati a runtime devono essere trattati come **UNTESTED**, mai come funzionanti per assunzione.
