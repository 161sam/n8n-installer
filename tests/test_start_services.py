from unittest import mock

import pytest

from start_services import EnhancedWorkspaceManager


@pytest.fixture
def workspace():
    return EnhancedWorkspaceManager()


def test_get_enabled_services(monkeypatch, workspace):
    with mock.patch('start_services.dotenv_values', return_value={'COMPOSE_PROFILES': 'n8n,flowise,affine'}):
        services = workspace.get_enabled_services()
    assert services['n8n']
    assert services['flowise']
    assert services['affine']
    assert not services['portainer']


def test_check_editor_configuration(tmp_path, monkeypatch, workspace):
    config_dir = tmp_path / 'editor-config'
    config_dir.mkdir()
    cfg_path = config_dir / 'editor-choice.json'
    cfg_path.write_text('{"configured": true, "editor_type": "vscode", "installation_type": "native"}')
    monkeypatch.setattr(workspace, 'config_dir', config_dir)
    result = workspace.check_editor_configuration()
    assert result['configured']
    assert result['editor_type'] == 'vscode'


def test_get_status_script(workspace):
    script = workspace._get_status_script()
    assert 'docker ps' in script


def test_get_logs_script(workspace):
    script = workspace._get_logs_script()
    assert 'docker logs' in script


def test_check_system_requirements(monkeypatch, workspace):
    monkeypatch.setattr(workspace, '_check_docker', lambda: {'available': True, 'version': 'docker', 'daemon_running': True})
    monkeypatch.setattr(workspace, '_check_docker_compose', lambda: {'available': True, 'command': 'docker compose', 'version': 'v2'})
    monkeypatch.setattr(workspace, '_check_memory', lambda: {'total_gb': 8, 'available_gb': 8})
    monkeypatch.setattr(workspace, '_check_disk_space', lambda: {'free_gb': 100, 'total_gb': 200})
    monkeypatch.setattr(workspace, '_get_architecture', lambda: 'x86_64')
    monkeypatch.setattr(workspace, '_get_os_info', lambda: {'name': 'Ubuntu', 'version': '22.04'})
    monkeypatch.setattr(workspace, '_check_network', lambda: {'connected': True})
    monkeypatch.setattr(workspace, '_check_permissions', lambda: {'sufficient': True, 'docker_accessible': True, 'can_install': True})

    result = workspace.check_system_requirements()
    assert result['docker']['available']
    assert result['compose']['available']
    assert result['memory']['available_gb'] == 8
