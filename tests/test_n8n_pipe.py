import pytest

from n8n_pipe import extract_event_info, Pipe


def make_emitter():
    request_info = {"chat_id": "123", "message_id": "456"}

    async def emitter(event):
        _ = request_info  # capture in closure for extract_event_info
        return None

    return emitter


def test_extract_event_info():
    emitter = make_emitter()
    chat_id, message_id = extract_event_info(emitter)
    assert chat_id == "123"
    assert message_id == "456"


def test_extract_knowledge_keywords():
    pipe = Pipe()
    text = "This document discusses project plans and team meeting notes"
    keywords = pipe._extract_knowledge_keywords(text)
    assert "document" in keywords
    assert "project" in keywords
    assert "meeting" in keywords


@pytest.mark.asyncio
async def test_check_knowledge_sources_enabled():
    pipe = Pipe()
    pipe.valves.enable_knowledge_integration = True
    pipe.valves.appflowy_url = "https://appflowy.example.com"
    pipe.valves.affine_url = "https://affine.example.com"
    result = await pipe.check_knowledge_sources("project plan")
    assert result["appflowy_available"] is True
    assert result["affine_available"] is True
    assert result["sources"]


@pytest.mark.asyncio
async def test_check_knowledge_sources_disabled():
    pipe = Pipe()
    pipe.valves.enable_knowledge_integration = False
    result = await pipe.check_knowledge_sources("anything")
    assert result == {"knowledge_context": None, "sources": []}
