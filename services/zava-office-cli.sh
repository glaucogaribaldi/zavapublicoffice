#!/bin/bash
# ======================================================================
# Ufficio Zava — CLI Applicativa / API wrapper
# ======================================================================
set -e

# Configurazione connessione PostgreSQL via Tailscale
DB_HOST="100.116.213.114"
DB_PORT="5432"
DB_USER="zavaoffice"
DB_NAME="zavaoffice"
export PGPASSWORD="zava_office_secure_pass_2026"

run_query() {
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "$1"
}

run_query_raw() {
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -Atc "$1"
}

usage() {
  echo "Ufficio Zava — CLI Operativa"
  echo "Uso: $0 <comando> [argomenti...]"
  echo ""
  echo "Comandi disponibili:"
  echo "  people                  Mostra tutte le persone nel database"
  echo "  person <id|nome>        Mostra il profilo Person 360 di una persona"
  echo "  add-person <display_name> [email] [phone] [domain]"
  echo "                          Aggiunge una nuova persona canonica"
  echo "  organizations           Mostra tutte le organizzazioni/aziende"
  echo "  projects                Mostra tutti i progetti"
  echo "  open-loops              Mostra tutti gli open loops (impegni/scadenze)"
  echo "  add-open-loop <owner_id> <title> <description> <type>"
  echo "                          Aggiunge un open loop"
  echo "  add-fact <subj_type> <subj_id> <predicate> <truth_state> <confidence> <val_json>"
  echo "                          Aggiunge un fatto con livello di verità"
  echo "  search <query>          Esegue una ricerca testuale integrata"
  echo ""
}

case "$1" in
  people)
    run_query "SELECT id, display_name, primary_email, primary_phone, domain, created_at FROM people ORDER BY display_name ASC;"
    ;;
  person)
    if [ -z "$2" ]; then
      echo "Errore: Specifica l'ID o il nome della persona."
      exit 1
    fi
    # Cerca sia per ID che per display_name parziale
    if [[ "$2" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
      run_query "SELECT * FROM people WHERE id = '$2';"
      echo "--- IDENTIFICATIVI COLLEGATI ---"
      run_query "SELECT kind, value, confidence FROM person_identifiers WHERE person_id = '$2';"
      echo "--- FATTI ED EVIDENZE ---"
      run_query "SELECT f.id, f.predicate, f.value_json, f.truth_state, f.confidence FROM facts f WHERE f.subject_type = 'PEOPLE' AND f.subject_id = '$2';"
    else
      run_query "SELECT id, display_name, primary_email, primary_phone, domain FROM people WHERE display_name ILIKE '%$2%';"
    fi
    ;;
  add-person)
    if [ -z "$2" ]; then
      echo "Errore: Specifica il display_name."
      exit 1
    fi
    EMAIL=${3:-NULL}
    PHONE=${4:-NULL}
    DOMAIN=${5:-UNKNOWN}
    
    # Gestione apici per i valori opzionali
    EMAIL_VAL="NULL"
    [ "$EMAIL" != "NULL" ] && EMAIL_VAL="'$EMAIL'"
    PHONE_VAL="NULL"
    [ "$PHONE" != "NULL" ] && PHONE_VAL="'$PHONE'"

    run_query_raw "INSERT INTO people (display_name, primary_email, primary_phone, domain) VALUES ('$2', $EMAIL_VAL, $PHONE_VAL, '$DOMAIN') RETURNING id, display_name;"
    ;;
  organizations)
    run_query "SELECT id, name, legal_name, website, summary FROM organizations ORDER BY name ASC;"
    ;;
  projects)
    run_query "SELECT id, title, status, description, inferred_start FROM projects ORDER BY created_at DESC;"
    ;;
  open-loops)
    run_query "SELECT id, title, loop_type, status, due_at, confidence FROM open_loops ORDER BY created_at DESC;"
    ;;
  add-open-loop)
    if [ -z "$2" ] || [ -z "$3" ] || [ -z "$5" ]; then
      echo "Errore: add-open-loop <owner_person_id> <title> <description> <type>"
      exit 1
    fi
    run_query_raw "INSERT INTO open_loops (owner_person_id, title, description, loop_type, status) VALUES ('$2', '$3', '$4', '$5', 'OPEN') RETURNING id, title;"
    ;;
  add-fact)
    if [ -z "$2" ] || [ -z "$4" ] || [ -z "$5" ]; then
      echo "Errore: add-fact <subj_type> <subj_id> <predicate> <truth_state> <confidence> <val_json>"
      exit 1
    fi
    VAL_JSON=${6:-'{}'}
    run_query_raw "INSERT INTO facts (subject_type, subject_id, predicate, truth_state, confidence, value_json) VALUES ('$2', '$3', '$4', '$5', $6, '$VAL_JSON'::jsonb) RETURNING id, predicate;"
    ;;
  search)
    if [ -z "$2" ]; then
      echo "Errore: Specifica la chiave di ricerca."
      exit 1
    fi
    echo "=== RISULTATI NELLE PERSONE ==="
    run_query "SELECT id, display_name, primary_email, domain FROM people WHERE display_name ILIKE '%$2%' OR primary_email ILIKE '%$2%';"
    echo "=== RISULTATI NEI PROGETTI ==="
    run_query "SELECT id, title, status, description FROM projects WHERE title ILIKE '%$2%' OR description ILIKE '%$2%';"
    echo "=== RISULTATI NEGLI OPEN LOOPS ==="
    run_query "SELECT id, title, loop_type, status FROM open_loops WHERE title ILIKE '%$2%' OR description ILIKE '%$2%';"
    ;;
  *)
    usage
    exit 1
    ;;
esac
