from unittest.mock import patch


def _line(mcp_status, key=""):
    from hermes_cli import banner
    with patch("agent.secret_scope.get_secret", return_value=key):
        return banner._keiro_status_line(mcp_status, "A", "D", "T")


def test_keiro_not_installed():
    assert "not installed" in _line([{"name": "other", "status": "connected", "connected": True, "tools": 1}])
    assert "not installed" in _line([])


def test_keiro_configured_no_key():
    s = [{"name": "keirolabs", "status": "configured", "connected": False, "tools": 0}]
    assert "no API key" in _line(s, key="")


def test_keiro_ready():
    s = [{"name": "keirolabs", "status": "connected", "connected": True, "tools": 12}]
    line = _line(s, key="keiro_x")
    assert "ready" in line and "12 tool(s)" in line


def test_keiro_disabled():
    s = [{"name": "keirolabs", "status": "disabled", "connected": False, "disabled": True, "tools": 0}]
    assert "disabled" in _line(s, key="keiro_x")


def test_keiro_failed():
    s = [{"name": "keirolabs", "status": "failed", "connected": False, "tools": 0}]
    assert "failed to connect" in _line(s, key="keiro_x")


def test_keiro_connecting():
    s = [{"name": "keirolabs", "status": "connecting", "connected": False, "tools": 0}]
    assert "connecting" in _line(s, key="keiro_x")


def test_keiro_name_case_insensitive():
    s = [{"name": "KeiroLabs", "status": "connected", "connected": True, "tools": 4}]
    assert "ready" in _line(s, key="keiro_x")