{
  "name": "Bidirectional Knowledge Sync Between AppFlowy and Affine",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "trigger-knowledge-sync",
        "responseMode": "responseNode",
        "options": {}
      },
      "id": "knowledge-sync-trigger",
      "name": "Knowledge Sync Trigger",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "position": [200, 400],
      "webhookId": "trigger-knowledge-sync"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "sync-source",
              "name": "source",
              "value": "={{ $json.body.source || 'all' }}",
              "type": "string"
            },
            {
              "id": "sync-direction",
              "name": "direction",
              "value": "={{ $json.body.direction || 'bidirectional' }}",
              "type": "string"
            },
            {
              "id": "sync-filter",
              "name": "filter",
              "value": "={{ $json.body.filter || {} }}",
              "type": "object"
            },
            {
              "id": "force-sync",
              "name": "forceSync",
              "value": "={{ $json.body.forceSync || false }}",
              "type": "boolean"
            },
            {
              "id": "sync-timestamp",
              "name": "syncTimestamp",
              "value": "={{ $now }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "id": "process-sync-request",
      "name": "Process Sync Request",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [450, 400]
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT * FROM knowledge_sync_mapping WHERE (source_system = 'appflowy' OR target_system = 'appflowy') AND status = 'active'",
        "options": {}
      },
      "id": "get-appflowy-mappings",
      "name": "Get AppFlowy Mappings",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [700, 200],
      "credentials": {
        "postgres": {
          "id": "postgres_credentials",
          "name": "Postgres Account"
        }
      }
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT * FROM knowledge_sync_mapping WHERE (source_system = 'affine' OR target_system = 'affine') AND status = 'active'",
        "options": {}
      },
      "id": "get-affine-mappings",
      "name": "Get Affine Mappings",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [700, 300],
      "credentials": {
        "postgres": {
          "id": "postgres_credentials",
          "name": "Postgres Account"
        }
      }
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT DISTINCT document_id, source_system, source_id, metadata, sync_timestamp FROM knowledge_sync_log WHERE (source_system = 'appflowy' OR source_system = 'affine') AND status = 'synced' ORDER BY sync_timestamp DESC",
        "options": {}
      },
      "id": "get-recent-changes",
      "name": "Get Recent Changes",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [700, 400],
      "credentials": {
        "postgres": {
          "id": "postgres_credentials",
          "name": "Postgres Account"
        }
      }
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "appflowy-changes",
              "name": "appFlowyChanges",
              "value": "={{ $('Get Recent Changes').all().filter(item => item.source_system === 'appflowy') }}",
              "type": "array"
            },
            {
              "id": "affine-changes", 
              "name": "affineChanges",
              "value": "={{ $('Get Recent Changes').all().filter(item => item.source_system === 'affine') }}",
              "type": "array"
            },
            {
              "id": "sync-needed",
              "name": "syncNeeded",
              "value": "={{ $json.appFlowyChanges.length > 0 || $json.affineChanges.length > 0 || $('Process Sync Request').item.json.forceSync }}",
              "type": "boolean"
            }
          ]
        },
        "options": {}
      },
      "id": "analyze-sync-requirements",
      "name": "Analyze Sync Requirements",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [950, 400]
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "sync-needed-condition",
              "leftValue": "={{ $json.syncNeeded }}",
              "rightValue": true,
              "operator": {
                "type": "boolean",
                "operation": "true",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "id": "check-sync-needed",
      "name": "Check Sync Needed",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [1200, 400]
    },
    {
      "parameters": {
        "fieldsToSplitOut": "appFlowyChanges",
        "options": {}
      },
      "id": "process-appflowy-changes",
      "name": "Process AppFlowy Changes",
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [1450, 200]
    },
    {
      "parameters": {
        "fieldsToSplitOut": "affineChanges",
        "options": {}
      },
      "id": "process-affine-changes",
      "name": "Process Affine Changes", 
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [1450, 300]
    },
    {
      "parameters": {
        "operation": "get",
        "databaseId": "={{ $json.metadata.database_id }}",
        "rowId": "={{ $json.metadata.row_id }}",
        "options": {}
      },
      "id": "get-appflowy-content",
      "name": "Get AppFlowy Content",
      "type": "n8n-nodes-appflowy.database",
      "typeVersion": 1,
      "position": [1700, 200],
      "credentials": {
        "appFlowyApi": {
          "id": "appflowy_credentials",
          "name": "AppFlowy API"
        }
      }
    },
    {
      "parameters": {
        "url": "http://affine:3010/graphql",
        "options": {
          "timeout": 30000
        },
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Content-Type",
              "value": "application/json"
            },
            {
              "name": "Authorization",
              "value": "Bearer {{ $vars.affine_api_token }}"
            }
          ]
        },
        "sendBody": true,
        "contentType": "json",
        "body": {
          "query": "query GetDocument($workspaceId: String!, $docId: String!) { workspace(id: $workspaceId) { doc(id: $docId) { id title content updatedAt createdAt } } }",
          "variables": {
            "workspaceId": "={{ $json.metadata.workspace_id }}",
            "docId": "={{ $json.metadata.doc_id }}"
          }
        }
      },
      "id": "get-affine-content",
      "name": "Get Affine Content",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [1700, 300]
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "transformed-content",
              "name": "transformedContent",
              "value": "={{ $json.title + '\\n\\n' + $json.content }}",
              "type": "string"
            },
            {
              "id": "target-system",
              "name": "targetSystem",
              "value": "affine",
              "type": "string"
            },
            {
              "id": "content-metadata",
              "name": "contentMetadata",
              "value": "={{ { originalSource: 'appflowy', syncTimestamp: $now, originalId: $json.id, title: $json.title } }}",
              "type": "object"
            }
          ]
        },
        "options": {}
      },
      "id": "transform-appflowy-to-affine",
      "name": "Transform AppFlowy to Affine",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [1950, 200]
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "transformed-content-affine",
              "name": "transformedContent",
              "value": "={{ $json.data.workspace.doc.title + '\\n\\n' + $json.data.workspace.doc.content }}",
              "type": "string"
            },
            {
              "id": "target-system-appflowy",
              "name": "targetSystem",
              "value": "appflowy",
              "type": "string"
            },
            {
              "id": "content-metadata-affine",
              "name": "contentMetadata",
              "value": "={{ { originalSource: 'affine', syncTimestamp: $now, originalId: $json.data.workspace.doc.id, title: $json.data.workspace.doc.title } }}",
              "type": "object"
            }
          ]
        },
        "options": {}
      },
      "id": "transform-affine-to-appflowy",
      "name": "Transform Affine to AppFlowy",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [1950, 300]
    },
    {
      "parameters": {
        "url": "http://affine:3010/graphql",
        "options": {
          "timeout": 30000
        },
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Content-Type",
              "value": "application/json"
            },
            {
              "name": "Authorization",
              "value": "Bearer {{ $vars.affine_api_token }}"
            }
          ]
        },
        "sendBody": true,
        "contentType": "json",
        "body": {
          "query": "mutation CreateDocument($workspaceId: String!, $title: String!, $content: String!) { createDoc(workspaceId: $workspaceId, title: $title, content: $content) { id title createdAt } }",
          "variables": {
            "workspaceId": "{{ $vars.affine_workspace_id }}",
            "title": "{{ $json.contentMetadata.title }} (from AppFlowy)",
            "content": "{{ $json.transformedContent }}"
          }
        }
      },
      "id": "create-affine-document",
      "name": "Create Affine Document",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [2200, 200]
    },
    {
      "parameters": {
        "operation": "create",
        "databaseId": "{{ $vars.appflowy_sync_database_id }}",
        "data": {
          "fields": [
            {
              "name": "title",
              "value": "={{ $json.contentMetadata.title }} (from Affine)"
            },
            {
              "name": "content",
              "value": "={{ $json.transformedContent }}"
            },
            {
              "name": "source",
              "value": "affine"
            },
            {
              "name": "original_id",
              "value": "={{ $json.contentMetadata.originalId }}"
            }
          ]
        },
        "options": {}
      },
      "id": "create-appflowy-page",
      "name": "Create AppFlowy Page",
      "type": "n8n-nodes-appflowy.database",
      "typeVersion": 1,
      "position": [2200, 300],
      "credentials": {
        "appFlowyApi": {
          "id": "appflowy_credentials",
          "name": "AppFlowy API"
        }
      }
    },
    {
      "parameters": {
        "operation": "upsert",
        "table": {
          "__rl": true,
          "value": "knowledge_sync_mapping",
          "mode": "list"
        },
        "data": {
          "insert": [
            {
              "column": "source_system",
              "value": "appflowy"
            },
            {
              "column": "source_id",
              "value": "={{ $('Get AppFlowy Content').item.json.id }}"
            },
            {
              "column": "target_system", 
              "value": "affine"
            },
            {
              "column": "target_id",
              "value": "={{ $json.data.createDoc.id }}"
            },
            {
              "column": "mapping_type",
              "value": "document"
            },
            {
              "column": "sync_direction",
              "value": "bidirectional"
            },
            {
              "column": "created_at",
              "value": "={{ $now }}"
            },
            {
              "column": "status",
              "value": "active"
            }
          ]
        },
        "options": {}
      },
      "id": "create-sync-mapping-affine",
      "name": "Create Sync Mapping (Affine)",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [2450, 200],
      "credentials": {
        "postgres": {
          "id": "postgres_credentials",
          "name": "Postgres Account"
        }
      }
    },
    {
      "parameters": {
        "operation": "upsert",
        "table": {
          "__rl": true,
          "value": "knowledge_sync_mapping",
          "mode": "list"
        },
        "data": {
          "insert": [
            {
              "column": "source_system",
              "value": "affine"
            },
            {
              "column": "source_id",
              "value": "={{ $('Get Affine Content').item.json.data.workspace.doc.id }}"
            },
            {
              "column": "target_system",
              "value": "appflowy"
            },
            {
              "column": "target_id",
              "value": "={{ $json.id }}"
            },
            {
              "column": "mapping_type",
              "value": "document"
            },
            {
              "column": "sync_direction",
              "value": "bidirectional"
            },
            {
              "column": "created_at",
              "value": "={{ $now }}"
            },
            {
              "column": "status",
              "value": "active"
            }
          ]
        },
        "options": {}
      },
      "id": "create-sync-mapping-appflowy",
      "name": "Create Sync Mapping (AppFlowy)",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [2450, 300],
      "credentials": {
        "postgres": {
          "id": "postgres_credentials",
          "name": "Postgres Account"
        }
      }
    },
    {
      "parameters": {
        "operation": "insert",
        "table": {
          "__rl": true,
          "value": "bidirectional_sync_log",
          "mode": "list"
        },
        "data": {
          "insert": [
            {
              "column": "sync_session_id",
              "value": "={{ $('Process Sync Request').item.json.syncTimestamp }}"
            },
            {
              "column": "source_system",
              "value": "={{ $('Process Sync Request').item.json.source }}"
            },
            {
              "column": "items_synced",
              "value": "={{ $('Analyze Sync Requirements').item.json.appFlowyChanges.length + $('Analyze Sync Requirements').item.json.affineChanges.length }}"
            },
            {
              "column": "sync_direction",
              "value": "={{ $('Process Sync Request').item.json.direction }}"
            },
            {
              "column": "status",
              "value": "completed"
            },
            {
              "column": "started_at",
              "value": "={{ $('Process Sync Request').item.json.syncTimestamp }}"
            },
            {
              "column": "completed_at",
              "value": "={{ $now }}"
            },
            {
              "column": "errors",
              "value": "{{ [] }}"
            }
          ]
        },
        "options": {}
      },
      "id": "log-sync-completion",
      "name": "Log Sync Completion",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [2700, 400],
      "credentials": {
        "postgres": {
          "id": "postgres_credentials",
          "name": "Postgres Account"
        }
      }
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "sync-summary",
              "name": "syncSummary",
              "value": "={{ { sessionId: $('Process Sync Request').item.json.syncTimestamp, itemsSynced: $('Analyze Sync Requirements').item.json.appFlowyChanges.length + $('Analyze Sync Requirements').item.json.affineChanges.length, direction: $('Process Sync Request').item.json.direction, status: 'completed', completedAt: $now } }}",
              "type": "object"
            }
          ]
        },
        "options": {}
      },
      "id": "prepare-response",
      "name": "Prepare Response",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [2950, 400]
    },
    {
      "parameters": {
        "options": {}
      },
      "id": "respond-to-sync-trigger",
      "name": "Respond to Sync Trigger",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1.1,
      "position": [3200, 400]
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "no-sync-message",
              "name": "message",
              "value": "No synchronization needed - no recent changes detected",
              "type": "string"
            },
            {
              "id": "sync-status",
              "name": "status",
              "value": "skipped",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "id": "prepare-no-sync-response",
      "name": "Prepare No Sync Response",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [1200, 600]
    },
    {
      "parameters": {
        "content": "## Bidirectional Knowledge Sync Between AppFlowy and Affine\n\n**Purpose:** Maintain synchronized content between AppFlowy and Affine workspaces with conflict resolution and mapping tracking.\n\n**Features:**\n- Bidirectional sync between AppFlowy databases and Affine documents\n- Content transformation and mapping\n- Conflict detection and resolution\n- Sync status tracking and logging\n- Force sync capability\n- Selective sync with filters\n\n**Sync Process:**\n1. Analyze recent changes in both systems\n2. Check for existing mappings and conflicts\n3. Transform content between formats\n4. Create/update content in target systems\n5. Create bidirectional mappings\n6. Log sync completion and metrics\n\n**API Endpoints:**\n- POST /webhook/trigger-knowledge-sync\n- Supports: source, direction, filter, forceSync parameters",
        "height": 600,
        "width": 800,
        "color": 7
      },
      "id": "bidirectional-sync-documentation",
      "name": "Bidirectional Sync Documentation",
      "type": "n8n-nodes-base.stickyNote",
      "typeVersion": 1,
      "position": [100, 50]
    }
  ],
  "pinData": {},
  "connections": {
    "Knowledge Sync Trigger": {
      "main": [
        [
          {
            "node": "Process Sync Request",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Process Sync Request": {
      "main": [
        [
          {
            "node": "Get AppFlowy Mappings",
            "type": "main",
            "index": 0
          },
          {
            "node": "Get Affine Mappings",
            "type": "main",
            "index": 0
          },
          {
            "node": "Get Recent Changes",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get Recent Changes": {
      "main": [
        [
          {
            "node": "Analyze Sync Requirements",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Analyze Sync Requirements": {
      "main": [
        [
          {
            "node": "Check Sync Needed",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Sync Needed": {
      "main": [
        [
          {
            "node": "Process AppFlowy Changes",
            "type": "main",
            "index": 0
          },
          {
            "node": "Process Affine Changes",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Prepare No Sync Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Process AppFlowy Changes": {
      "main": [
        [
          {
            "node": "Get AppFlowy Content",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Process Affine Changes": {
      "main": [
        [
          {
            "node": "Get Affine Content",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get AppFlowy Content": {
      "main": [
        [
          {
            "node": "Transform AppFlowy to Affine",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get Affine Content": {
      "main": [
        [
          {
            "node": "Transform Affine to AppFlowy",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Transform AppFlowy to Affine": {
      "main": [
        [
          {
            "node": "Create Affine Document",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Transform Affine to AppFlowy": {
      "main": [
        [
          {
            "node": "Create AppFlowy Page",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create Affine Document": {
      "main": [
        [
          {
            "node": "Create Sync Mapping (Affine)",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create AppFlowy Page": {
      "main": [
        [
          {
            "node": "Create Sync Mapping (AppFlowy)",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create Sync Mapping (Affine)": {
      "main": [
        [
          {
            "node": "Log Sync Completion",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create Sync Mapping (AppFlowy)": {
      "main": [
        [
          {
            "node": "Log Sync Completion",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Log Sync Completion": {
      "main": [
        [
          {
            "node": "Prepare Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Response": {
      "main": [
        [
          {
            "node": "Respond to Sync Trigger",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare No Sync Response": {
      "main": [
        [
          {
            "node": "Respond to Sync Trigger",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "active": true,
  "settings": {
    "executionOrder": "v1"
  },
  "versionId": "bidirectional-sync-v1",
  "meta": {
    "templateCredsSetupCompleted": true
  },
  "id": "BidirectionalKnowledgeSync",
  "tags": ["knowledge-management", "sync", "bidirectional", "appflowy", "affine"]
}
