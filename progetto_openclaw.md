# Progetto OpenClaw — Integrazione Strategica di Ufficio Zava (Aggiornato)

Questo documento descrive come integrare e rendere **Ufficio Zava** nativamente compatibile con l'ecosistema di **OpenClaw su Zava U50**, ottimizzato specificamente per la **VPS con GPU NVIDIA Tesla P4**.

---

## 🗺️ 1. Mappatura dei Componenti: Tradizionale vs OpenClaw

| Componente Richiesto | Architettura Tradizionale (Isolata) | Architettura Integrata in OpenClaw | Vantaggi Chiave |
| :--- | :--- | :--- | :--- |
| **Orchestratore / Chat** | Client custom o interfaccia web da scrivere. | **TRE su U50 (OpenClaw Webchat / Signal)** | Interfaccia già pronta, persistente e sicura. |
| **API Applicativa** | `office-api` (Container custom in Node/Python). | **OpenClaw Custom Skill (`zava_office`)** | TRE chiama le API direttamente tramite tool call nativi (es. `zava_office_search`). |
| **Worker Ingestion** | `office-worker` (Demone sempre attivo su VPS). | **OpenClaw Cron + Sub-agenti (`sessions_spawn`)** | Nessun servizio in background da monitorare; l'ingestion gira asincrona e notifica TRE al termine. |
| **Database** | PostgreSQL + pgvector su VPS. | **PostgreSQL + pgvector su VPS** (Invariato) | Mantiene l'integrità del modello di verità e la provenienza dei dati. |
| **Dashboard** | `office-dashboard` (App React/Node da zero). | **Streamlit (Porta 8501) + OpenClaw Canvas** | Sviluppo in puro Python 10 volte più rapido, grafica scura professionale, report HTML renderizzati in chat. |
| **Modelli AI** | llama.cpp diretto da codice applicativo. | **OpenClaw API Client (Profilo Ibrido)** | Routing intelligente: Gemini (U50) per la chat veloce, Nemotron/Llama locale (VPS) per l'estrazione dati. |

---

## 🚀 2. Decisioni Operative Concordate con Giacomo

1. **Focus 100% su VPS e Modelli NVIDIA:**
   - La compatibilità con il Mac mini M4 (`EDGE`) è temporaneamente congelata.
   - Ci concentriamo interamente sull'ottimizzazione della VPS (`n1-highmem-16` con 104 GB RAM e GPU Tesla P4 da 8 GB).
   - Eseguiremo test e benchmark su modelli della famiglia **NVIDIA Nemotron** (es. versioni 8B o compatte) e altri modelli GGUF ottimizzati tramite `llama.cpp` con CUDA offloading, sfruttando al massimo la GPU Tesla P4 per i calcoli di attenzione e la generosa RAM di sistema per i restanti layer.

2. **Source Vault Sincronizzato da Aruba FTP:**
   - Giacomo caricherà manualmente sull'FTP di Aruba (`pianodivino.com`) i file esportati (Google Takeout, IMAP mbox mailboxes, WhatsApp backups, OpenAI exports).
   - Costruiremo un modulo di sincronizzazione FTP/SFTP (integrato nella skill o lanciato via sub-agente) che preleva questi file, calcola i checksum, li organizza ordinatamente nella struttura `/zava` sulla VPS, e previene l'elaborazione ripetuta.

3. **Iniezione Rapida con Gemini API:**
   - Durante la fase di sviluppo (Milestone M1 e M2), siamo autorizzati a utilizzare le API di Gemini (attive su U50) come motore ad alte prestazioni per il parsing dei documenti e l'estrazione strutturata delle entità.
   - Questo ci permetterà di popolare rapidamente il database PostgreSQL con dati reali di test senza essere rallentati dalla latenza iniziale della Tesla P4, consentendoci di ottimizzare il modello locale in parallelo.

---

## 🛠️ 3. Dettagli di Implementazione OpenClaw

### A. Ufficio Zava come Skill Personalizzata
Creeremo una skill chiamata `zava_office` registrabile in OpenClaw. La skill esporrà i seguenti tool nativi a TRE:
- `zava_office_get_person(id_or_name)`: recupera il profilo Person 360 completo, inclusi contatti, relazioni e conflitti.
- `zava_office_search(query, filter)`: esegue una ricerca semantica e testuale combinata sul database PostgreSQL (usando pgvector).
- `zava_office_add_fact(subject, predicate, object, state, confidence, source_id)`: scrive un fatto verificato o un'inferenza con provenance esplicita.
- `zava_office_get_open_loops()`: estrae tutti i loop aperti classificati per priorità e scadenza.

### B. Ingestion Asincrona via Sub-agenti e Cron
L'ingestion è l'operazione più pesante. Invece di avere un worker sempre attivo che consuma risorse sulla VPS:
1. Un **job `cron` di OpenClaw** (eseguito ogni notte o su trigger) avvia un sub-agente isolato usando `sessions_spawn`.
2. Il sub-agente scarica i nuovi file dal Source Vault `/zava` di Aruba, calcola i checksum e li registra in `sources`.
3. Il sub-agente invia i frammenti di testo estratti all'LLM (Gemini API in dev, o LLM locale sulla VPS in prod) richiedendo output in JSON strutturato con schema rigido (schema.sql).
4. Il sub-agente valida i dati, esegue l'Entity Resolution deterministica ed euristica, e popola le tabelle `facts`, `people`, `organizations` e `open_loops`.
5. Al termine, il sub-agente si chiude e invia un report di completamento a TRE, che ti riassume le novità al tuo risveglio.

### C. La Dashboard: Sfruttare Streamlit e Canvas
Sviluppare un frontend React responsive da zero richiede settimane. Possiamo ottenere lo stesso risultato professionale in pochi giorni:
1. **Streamlit App (Porta 8501):** Sulla falsariga dell'ottima dashboard creata per `krakenfondazione`, scriveremo la Dashboard di Ufficio Zava in Streamlit (Python) eseguita sulla VPS o su U50. Avrà un design scuro, barre di stato globali, grafici interattivi in Plotly per la timeline e tabelle ordinate per Open Loops, Persone e Aziende.
2. **OpenClaw Canvas Integration:** Tramite la skill `canvas`, TRE potrà generare al volo report HTML interattivi e visualizzarli direttamente all'interno della tua chat, ad esempio mostrandoti la mappa delle relazioni di una persona o l'andamento di un progetto senza farti uscire dalla chat.

---

## 🚀 4. Prossimo Passo: Milestone M0 (Audit)
Una volta compilato il file `richiesta_accessi.txt` sulla Scrivania di U50:
1. Eseguirò l'audit hardware e software della VPS (Phase A del Runbook).
2. Verificherò la connettività bidirezionale via Tailscale.
3. Creerò il report di audit sotto `zavapublicoffice/runtime/audits/`.
4. Avvierò i test per l'installazione di PostgreSQL con pgvector e l'ottimizzazione CUDA di llama.cpp sulla Tesla P4.

*TRE — Pronto all'azione.*
