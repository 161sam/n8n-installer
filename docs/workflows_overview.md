# Übersicht der n8n-Workflows

Dieser Ordner fasst die bereitgestellten Beispiel-Workflows aus dem Verzeichnis `modularium/ai-workspace/` zusammen.
Die Workflows lassen sich über die n8n-CLI oder die Weboberfläche importieren.
Gemeinsam bilden sie ein umfassendes Knowledge-Management-System.

## Synchronisation

| Workflow-Datei | Zweck |
| -------------- | ----- |
| `AppFlowy-Content-Sync.json` | Überträgt Inhalte aus AppFlowy in den Vektor-Speicher. |
| `Affine-Content-Sync.json` | Synct Affine-Dokumente in den Vektor-Speicher. |
| `Google-Drive-Sync.json` | Importiert Dateien aus Google Drive und verarbeitet sie für die Suche. |
| `Bidirectional-Knowledge-Sync.md` | Synchronisiert AppFlowy und Affine bidirektional. |
| `Database-Setup.json` | Legt Tabellen und Views der Knowledge-Datenbank an. |
| `Backup-Recovery.json` | Erstellt Sicherungen und ermöglicht eine Wiederherstellung. |

## Abfrage- und Suchwerkzeuge

| Workflow-Datei | Zweck |
| -------------- | ----- |
| `AppFlowy-Query-Tool.json` | Durchsucht AppFlowy-Inhalte direkt und semantisch. |
| `Affine-Query-Tool.json` | Bietet gezielte Abfragen in Affine. |
| `Cross-Platform-Search.json` | Kombinierte Suche über mehrere Quellen. |
| `Get_Postgres_Tables.json` | Liefert eine Liste der Tabellen in Postgres. |
| `Summarize_Slack_Conversation.json` | Erstellt Zusammenfassungen von Slack-Chats. |

## Orchestrierung und Agenten

| Workflow-Datei | Zweck |
| -------------- | ----- |
| `Knowledge-Orchestrator.json` | Überwacht und koordiniert alle Knowledge-Flows. |
| `Enhanced-RAG-AI-Agent.json` | Erweiterter AI-Agent mit Zugriff auf alle Tools. |
| `RAG-Agent-Integration-Hub.json` | Zentrale Integration sämtlicher Agent- und Sync-Workflows. |

## Hilfs-Workflows

| Workflow-Datei | Zweck |
| -------------- | ----- |
| `Create_Google_Doc.json` | Erstellt ein neues Google-Dokument aus Text. |
| `Post_Message_to_Slack.json` | Sendet Nachrichten an einen Slack-Kanal. |
| `Conflict-Resolution.json` | Erkennt und löst Datenkonflikte automatisiert. |

Jeder Workflow ist als JSON-Datei (teilweise mit `.md`-Endung) gespeichert.
Er folgt dem in `modularium/ai-workspace/AGENTS.md` beschriebenen Format.

```bash
n8n import:workflow --input <datei>
```

verwendet werden. Das n8n-CLI-Werkzeug ist in dieser Umgebung möglicherweise nicht installiert.
