# TODO for Test Suite

This repository lacks automated tests. To provide a comprehensive suite the following tasks are planned:

- [ ] Add pytest configuration and create `tests/` directory.
- [ ] Cover functions in `n8n_pipe.py`:
  - `extract_event_info`
  - `Pipe._extract_knowledge_keywords`
  - `Pipe.check_knowledge_sources`
- [ ] Cover utilities in `start_services.py`:
  - System check helpers (`_check_memory`, `_check_disk_space`, `_get_os_info`, `_check_docker`, `_check_docker_compose`)
  - `check_system_requirements`
  - `get_enabled_services`
  - `check_editor_configuration`
  - generation helpers (`_get_status_script`, `_get_logs_script`, `_get_backup_script`, `_get_dev_session_script`)
- [ ] Ensure tests run without external dependencies by mocking subprocess and file system calls.
- [ ] Run all tests via `pytest`.
