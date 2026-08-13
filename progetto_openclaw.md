# Progetto OpenClaw — Integrazione Strategica di Ufficio Zava (Aggiornato - REAL VPS)

Questo documento descrive come integrare e rendere **Ufficio Zava** nativamente compatibile con l'ecosistema di **OpenClaw su Zava U50**, ottimizzato specificamente per la **REAL VPS dell'Ufficio (`ufficio` - n1-highmem-16)**.

---

## 🗺️ 1. Mappatura dei Componenti: Tradizionale vs OpenClaw

| Componente Richiesto | Architettura Tradizionale (Isolata) | Architettura Integrata in OpenClaw | Vantaggi Chiave |
| :--- | :--- | :--- | :--- |
| **Orchestratore / Chat** | Client custom o interfaccia web da scrivere. | **TRE su U50 (OpenClaw Webchat / Signal)** | Interfaccia già pronta, persistente e sicura. |
| **API Applicativa** | `office-api` (Container custom in Node/Python). | **OpenClaw Custom Skill (`zava_office`)** | TRE chiama le API direttamente tramite tool call nativi (es. `zava_office_search`). |
| **Worker Ingestion** | `office-worker` (Demone sempre attivo su VPS). | **OpenClaw Cron + Sub-agenti (`sessions_spawn`)** | Nessun servizio in background da monitorare; l'ingestion gira asincrona e notifica TRE al termine. |
| **Database** | PostgreSQL + pgvector su VPS. | **PostgreSQL + pgvector su VPS** (Invariato) | Mantiene l'integrità del modello di verità e la provenienza dei dati. |
| **Dashboard** | `office-dashboard` (App React/Node da zero). | **Streamlit (Porta 8501) + OpenClaw Canvas** | Sviluppo in puro Python 10 volte più rapido, grafica scura professionale, report HTML renderizzati in chat. |
| **Modelli AI** | llama.cpp diretto da codice applicativo. | **Servizio LLM locale su VPS + Gemini Cloud** | Configurazione ibrida: Gemini (U50) per ingestion rapida in dev, llama.cpp (P4 + 102 GB RAM) per prod locale. |

---

## 🚀 2. Risultati dell'Audit e Decisioni Operative

1. **La Vera Configurazione della VPS (`ufficio`):**
   - **CPU & RAM:** 16 vCPUs e **102 GiB di RAM** (un'istanza `n1-highmem-16` reale ed estremamente potente).
   - **GPU:** **1 x NVIDIA Tesla P4 (8 GB VRAM)** con driver `580.173.02` e CUDA `13.0`.
   - **Stato:** Macchina pulitissima (Ubuntu 22.04 LTS), nessun database o LLM server attivo. Docker non installato.

2. **Strategia Modelli AI (NVIDIA locale + Gemini Fallback):**
   - **Iniezione Rapida (Sviluppo):** Come concordato, useremo l'**API Gemini di U50** per il parsing pesante e l'estrazione strutturata delle entità durante la fase di sviluppo (Milestone M1/M2). Questo sblocca lo sviluppo senza colli di bottiglia hardware.
   - **Ottimizzazione Locale (VPS):** Sfruttando l'enorme quantità di RAM di sistema (102 GB), installeremo `llama.cpp` compilato con supporto CUDA sulla VPS. Questo ci consentirà di far girare sia modelli compatti (es. Llama-3-8B o Nemotron-Mini) quasi interamente in VRAM, sia modelli pesanti da 30B (es. Nemotron-3-Nano) sfruttando la RAM di sistema ed eseguendo l'offload parziale di layer critici sulla Tesla P4 per accelerare l'attenzione.

3. **Source Vault Sincronizzato da Aruba FTP:**
   - Giacomo caricherà manualmente sull'FTP di Aruba (`pianodivino.com`) i file esportati (Google Takeout, IMAP mbox mailboxes, WhatsApp backups, OpenAI exports).
   - Costruiremo un modulo di sincronizzazione FTP/SFTP (integrato nella skill o lanciato via sub-agente) che preleva questi file, calcola i checksum, li organizza ordinatamente nella struttura `/zava` sulla VPS, e previene l'elaborazione ripetuta.

4. **Database PostgreSQL locale su VPS:**
   - Installeremo Docker ed avvieremo PostgreSQL con pgvector tramite Docker Compose direttamente sulla VPS. L'orchestrazione dei parser e delle query avverrà tramite la Skill OpenClaw su U50.

---

## 🛠️ 3. Dettagli di Implementazione OpenClaw

### A. Ufficio Zava como Skill Personalizzata
Creeremo una skill chiamata `zava_office` registrabile in OpenClaw. La skill esporrà i seguenti tool nativi a TRE:
- `zava_office_get_person(id_or_name)`: recupera il profilo Person 360 completo, inclusi contatti, relazioni e conflitti.
- `zava_office_search(query, filter)`: esegue una ricerca semantica e testuale combinata sul database PostgreSQL (usando pgvector).
- `zava_office_add_fact(subject, predicate, object, state, confidence, source_id)`: scrive un fatto verificato o un'inferenza con provenance esplicita.
- `zava_office_get_open_loops()`: estrae tutti i loop aperti classificati per priorità e scadenza.

### B. Ingestion Asincrona via Sub-agenti e Cron
L'ingestion è l'operazione più pesante. Invece di avere un worker sempre attivo che consuma risorse sulla VPS:
1. Un **job `cron` di OpenClaw** (eseguito ogni notte o su trigger) avvia un sub-agente isolato usando `sessions_spawn`.
2. Il sub-agente scarica i nuovi file dal Source Vault `/zava` di Aruba, calcola i checksum e li registra in `sources`.
3. Il sub-agente invia i frammenti di testo estratti all'LLM (Gemini API in dev, o Nemotron locale su VPS in prod) richiedendo output in JSON strutturato con schema rigido (schema.sql).
4. Il sub-agente valida i dati, esegue l'Entity Resolution deterministica ed euristica, e popola le tabelle `facts`, `people`, `organizations` e `open_loops`.
5. Al termine, il sub-agente si chiude e invia un report di completamento a TRE, che ti riassume le novità al tuo risveglio.

### C. La Dashboard: Sfruttare Streamlit e Canvas
Sviluppare un frontend React responsive da zero richiede settimane. Possiamo ottenere lo stesso risultato professionale in pochi giorni:
1. **Streamlit App (Porta 8501):** Sulla falsariga dell'ottima dashboard creata per `krakenfondazione`, scriveremo la Dashboard di Ufficio Zava in Streamlit (Python) eseguita sulla VPS o su U50. Avrà un design scuro, barre di stato globali, grafici interattivi in Plotly per la timeline e tabelle ordinate per Open Loops, Persone e Aziende.
2. **OpenClaw Canvas Integration:** Tramite la skill `canvas`, TRE potrà generare al volo report HTML interattivi e visualizzarli direttamente all'interno della tua chat, ad esempio mostrandoti la mappa delle relazioni di una persona o l'andamento di un progetto senza farti uscire dalla chat.

---

## 🚀 4. Prossimo Passo: Milestone M1 (Skeleton)
Siamo pronti a partire! Il database PostgreSQL relazionale con pgvector verrà avviato direttamente sulla VPS in Docker Compose dopo l'installazione di Docker. L'orchestrazione dei parser e delle query verrà scritta sotto forma di OpenClaw Skill ed esposta a TRE, che interrogherà Nemotron locale tramite l'IP Tailscale `100.116.213.114` (o l'IP pubblico `34.63.231.43` per superare eventuali blocchi Tailscale SSH).

Tutti i log, i file di progetto e il commento aggiornato sono stati inseriti nel repository locale e pushed su GitHub.

*TRE — Pronto all'azione.*
