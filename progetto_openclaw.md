# Progetto OpenClaw — Integrazione Strategica di Ufficio Zava (Aggiornato - Post-Audit)

Questo documento descrive come integrare e rendere **Ufficio Zava** nativamente compatibile con l'ecosistema di **OpenClaw su Zava U50**, ottimizzato specificamente per la **VPS con 2 GPU NVIDIA Tesla T4**.

---

## 🗺️ 1. Mappatura dei Componenti: Tradizionale vs OpenClaw

| Componente Richiesto | Architettura Tradizionale (Isolata) | Architettura Integrata in OpenClaw | Vantaggi Chiave |
| :--- | :--- | :--- | :--- |
| **Orchestratore / Chat** | Client custom o interfaccia web da scrivere. | **TRE su U50 (OpenClaw Webchat / Signal)** | Interfaccia già pronta, persistente e sicura. |
| **API Applicativa** | `office-api` (Container custom in Node/Python). | **OpenClaw Custom Skill (`zava_office`)** | TRE chiama le API direttamente tramite tool call nativi (es. `zava_office_search`). |
| **Worker Ingestion** | `office-worker` (Demone sempre attivo su VPS). | **OpenClaw Cron + Sub-agenti (`sessions_spawn`)** | Nessun servizio in background da monitorare; l'ingestion gira asincrona e notifica TRE al termine. |
| **Database** | PostgreSQL + pgvector su VPS. | **PostgreSQL + pgvector su VPS** (Invariato) | Mantiene l'integrità del modello di verità e la provenienza dei dati. |
| **Dashboard** | `office-dashboard` (App React/Node da zero). | **Streamlit (Porta 8501) + OpenClaw Canvas** | Sviluppo in puro Python 10 volte più rapido, grafica scura professionale, report HTML renderizzati in chat. |
| **Modelli AI** | llama.cpp diretto da codice applicativo. | **Servizio Nemotron locale su VPS (Porta 8080)** | OpenAI-compatible, già attivo con modello 30B caricato interamente in VRAM (2 x T4). |

---

## 🚀 2. Risultati dell'Audit e Decisioni Operative

1. **La Sorpresa delle 2 GPU NVIDIA Tesla T4:**
   - La VPS dispone di **2 x Tesla T4 (15 GB VRAM ciascuna, 30 GB totali)**.
   - Sulla macchina è già attivo il servizio `kraken-nemotron.service` che serve il modello **`unsloth/Nemotron-3-Nano-30B-A3B-GGUF:UD-Q4_K_XL`** sulla porta `8080` dell'IP Tailscale `100.73.54.72`.
   - Il modello risiede **completamente in VRAM** (~22.5 GB usati), garantendo un'inferenza locale ultra-rapida e precisa senza alcun carico sulla CPU di sistema.

2. **Source Vault Sincronizzato da Aruba FTP:**
   - Giacomo caricherà manualmente sull'FTP di Aruba (`pianodivino.com`) i file esportati (Google Takeout, IMAP mbox mailboxes, WhatsApp backups, OpenAI exports).
   - Costruiremo un modulo di sincronizzazione FTP/SFTP (integrato nella skill o lanciato via sub-agente) che preleva questi file, calcola i checksum, li organizza ordinatamente nella struttura `/zava` sulla VPS, e previene l'elaborazione ripetuta.

3. **Iniezione Rapida con Gemini API:**
   - Durante la fase di sviluppo (Milestone M1 e M2), siamo autorizzati a utilizzare le API di Gemini (attive su U50) come motore ad alte prestazioni per il parsing dei documenti e l'estrazione strutturata delle entità.
   - Questo ci permetterà di popolare rapidamente il database PostgreSQL con dati reali di test senza essere rallentati dalla latenza iniziale, potendo testare contemporaneamente l'estrazione locale con il modello Nemotron-3-Nano 30B già attivo.

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
3. Il sub-agente invia i frammenti di testo estratti all'LLM (Gemini API in dev, o Nemotron 30B locale su VPS in prod) richiedendo output in JSON strutturato con schema rigido (schema.sql).
4. Il sub-agente valida i dati, esegue l'Entity Resolution deterministica ed euristica, e popola le tabelle `facts`, `people`, `organizations` e `open_loops`.
5. Al termine, il sub-agente si chiude e invia un report di completamento a TRE, che ti riassume le novità al tuo risveglio.

### C. La Dashboard: Sfruttare Streamlit e Canvas
Sviluppare un frontend React responsive da zero richiede settimane. Possiamo ottenere lo stesso risultato professionale in pochi giorni:
1. **Streamlit App (Porta 8501):** Sulla falsariga dell'ottima dashboard creata per `krakenfondazione`, scriveremo la Dashboard di Ufficio Zava in Streamlit (Python) eseguita sulla VPS o su U50. Avrà un design scuro, barre di stato globali, grafici interattivi in Plotly per la timeline e tabelle ordinate per Open Loops, Persone e Aziende.
2. **OpenClaw Canvas Integration:** Tramite la skill `canvas`, TRE potrà generare al volo report HTML interattivi e visualizzarli direttamente all'interno della tua chat, ad esempio mostrandoti la mappa delle relazioni di una persona o l'andamento di un progetto senza farti uscire dalla chat.

---

## 🚀 4. Prossimo Passo: Milestone M1 (Skeleton)
Il database PostgreSQL relazionale con pgvector verrà avviato direttamente sulla VPS in Docker Compose. L'orchestrazione dei parser e delle query verrà scritta sotto forma di OpenClaw Skill ed esposta a TRE, che interrogherà Nemotron locale tramite l'IP Tailscale `100.73.54.72`.

Tutti i log, i file di progetto e il commento aggiornato sono stati inseriti nel repository locale e pushed su GitHub.

*TRE — Pronto all'azione.*
