#!/usr/bin/env python3
"""
MCP Bridge para Obsidian (protocolo MCP estándar sobre stdio).

Implementa el Model Context Protocol (JSON-RPC 2.0) para que opencode pueda
llamar a las herramientas que exponen el contexto del vault de Obsidian:

  - list_projects          Lista proyectos por stack
  - read_note              Lee una nota del vault
  - get_project_context    Lee AGENTS.md, Criterios y Tareas de un proyecto

Sin dependencias externas (solo stdlib). Compatible con MCP 2024-11-05.
"""

import os
import sys
import json
import shutil

VAULT_PATH = os.path.expanduser("~/obsidian-vault")
PROTOCOL_VERSION = "2024-11-05"

STACKS = ["php-wordpress", "mern", "mern-nextjs", "pern", "python", "astro"]

# Archivos de contexto que el bridge intenta leer por proyecto.
# El nombre en disco varía (sin emoji), pero aceptamos variaciones.
PROJECT_CONTEXT_FILES = [
    "AGENTS.md",
    "Criterios de Exito.md",
    "Criterios de Éxito.md",
    "Tareas.md",
]


def _abs(*parts):
    return os.path.join(VAULT_PATH, *parts)


def read_note(note_path):
    """Lee una nota relativa al vault. Devuelve str o None."""
    if note_path is None:
        return None
    full = _abs(note_path)
    if os.path.isfile(full):
        with open(full, "r", encoding="utf-8") as f:
            return f.read()
    # Tambien acepta ruta absoluta dentro del vault
    if os.path.isabs(note_path) and os.path.commonpath([note_path, VAULT_PATH]) == VAULT_PATH:
        if os.path.isfile(note_path):
            with open(note_path, "r", encoding="utf-8") as f:
                return f.read()
    return None


def list_projects():
    """Lista todos los proyectos del vault con su stack y ruta relativa."""
    projects = []
    for stack in STACKS:
        stack_full = _abs("01-Projects", stack)
        if not os.path.isdir(stack_full):
            continue
        for name in sorted(os.listdir(stack_full)):
            p = os.path.join(stack_full, name)
            if os.path.isdir(p):
                projects.append(
                    {
                        "name": name,
                        "stack": stack,
                        "path": f"01-Projects/{stack}/{name}",
                    }
                )
    return projects


def get_project_context(project_path):
    """Lee AGENTS.md, Criterios y Tareas del proyecto dado (ruta relativa)."""
    context = {}
    if not project_path:
        return context
    for fname in PROJECT_CONTEXT_FILES:
        # Saltar duplicados si ya cargamos una variante del mismo nombre
        key = fname.split(" ", 1)[0]  # "Criterios" o "Tareas" o "AGENTS.md"
        if key in context:
            continue
        content = read_note(f"{project_path}/{fname}")
        if content:
            context[fname] = content
    return context


# --- MCP tool schemas ---------------------------------------------------

TOOLS = [
    {
        "name": "list_projects",
        "description": "Lista todos los proyectos del vault de Obsidian "
        "(~/obsidian-vault/01-Projects), agrupados por stack: "
        "php-wordpress, mern, pern, python.",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
    },
    {
        "name": "read_note",
        "description": "Lee el contenido de una nota .md del vault. "
        "La ruta es relativa al vault (ej: '01-Projects/mern/app-demo/Tareas.md').",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Ruta relativa al vault o absoluta dentro del vault.",
                }
            },
            "required": ["path"],
            "additionalProperties": False,
        },
    },
    {
        "name": "get_project_context",
        "description": "Devuelve el contexto completo de un proyecto: "
        "AGENTS.md, Criterios de Exito y Tareas. "
        "Útil para cargar todo el contexto de trabajo de un proyecto de una vez.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Ruta relativa del proyecto dentro del vault "
                    "(ej: '01-Projects/mern/app-demo').",
                }
            },
            "required": ["path"],
            "additionalProperties": False,
        },
    },
    {
        "name": "list_available_vaults",
        "description": "Devuelve la ruta del vault configurado en este bridge.",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
    },
]


# --- Dispatch de tool calls --------------------------------------------

def call_tool(name, args):
    args = args or {}
    if name == "list_projects":
        return list_projects()
    if name == "read_note":
        return read_note(args.get("path"))
    if name == "get_project_context":
        return get_project_context(args.get("path"))
    if name == "list_available_vaults":
        return {"vault": VAULT_PATH}
    raise ValueError(f"Unknown tool: {name}")


# --- JSON-RPC over stdio -----------------------------------------------

def _send(obj):
    data = json.dumps(obj)
    sys.stdout.write(data + "\n")
    sys.stdout.flush()


def _result(req_id, result):
    _send({"jsonrpc": "2.0", "id": req_id, "result": result})


def _error(req_id, code, message, data=None):
    err = {"code": code, "message": message}
    if data is not None:
        err["data"] = data
    _send({"jsonrpc": "2.0", "id": req_id, "error": err})


def handle(req):
    req_id = req.get("id")
    method = req.get("method", "")

    if method == "initialize":
        _result(
            req_id,
            {
                "protocolVersion": PROTOCOL_VERSION,
                "capabilities": {"tools": {}},
                "serverInfo": {
                    "name": "obsidian-context-bridge",
                    "version": "2.0.0",
                },
            },
        )
        return

    if method == "initialized" or method == "notifications/initialized":
        # Notification, no response
        return

    if method == "tools/list":
        _result(req_id, {"tools": TOOLS})
        return

    if method == "tools/call":
        params = req.get("params", {})
        tool_name = params.get("name")
        args = params.get("arguments", {})
        try:
            result = call_tool(tool_name, args)
            # El resultado puede ser None (read_note fallo), dict, list o str.
            if result is None:
                content = [{"type": "text", "text": "No encontrado."}]
            elif isinstance(result, str):
                content = [{"type": "text", "text": result}]
            else:
                content = [
                    {"type": "text", "text": json.dumps(result, ensure_ascii=False, indent=2)}
                ]
            _result(req_id, {"content": content, "isError": False})
        except Exception as e:
            _result(
                req_id,
                {
                    "content": [{"type": "text", "text": f"Error: {e}"}],
                    "isError": True,
                },
            )
        return

    if method == "resources/list":
        _result(req_id, {"resources": []})
        return

    if method == "ping":
        _result(req_id, {})
        return

    # Metodo desconocido
    _error(req_id, -32601, f"Method not found: {method}")


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except json.JSONDecodeError as e:
            _error(None, -32700, f"Parse error: {e}")
            continue
        try:
            handle(req)
        except Exception as e:
            _error(req.get("id"), -32603, f"Internal error: {e}")


if __name__ == "__main__":
    main()
