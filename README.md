# SEFACA

> Safe Execution Framework for Autonomous Coding Agents

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Experimental](https://img.shields.io/badge/Status-Experimental-orange.svg)](https://github.com/defrecord/sefaca)
[![FreeBSD](https://img.shields.io/badge/FreeBSD-AB2B28?style=flat&logo=freebsd&logoColor=white)](https://www.freebsd.org/)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![Node.js](https://img.shields.io/badge/Node.js-16+-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)

Stop AI agents from eating your infrastructure.

> **Note**: This repository is currently a placeholder while the core SEFACA code is being developed in an incubator. The installation and usage instructions below represent the planned functionality.

## Installation

```bash
curl -sSL https://sefaca.dev/install.sh | sh
```

## Quick Start

```bash
sefaca run --context "[builder:ai:$USER@local(myapp:main)]" "python ai_agent.py"
```

## Features

- **Execution Context**: `[persona:agent:reviewer@env(repo:branch)]` - Complete tracking of every AI action
- **Resource Limits**: CPU, memory, and process constraints
- **Pattern Detection**: Blocks dangerous operations before execution
- **Audit Trail**: Every action logged and traceable

## Execution Context Format

SEFACA uses a structured context format to track and identify every AI action:

```
[persona:agent:reviewer@environment(repository:branch)]
```

- **persona**: The role or type of agent (e.g., `builder`, `reviewer`, `tester`)
- **agent**: The AI system identifier (e.g., `ai`, `gpt4`, `claude`)
- **reviewer**: The human or system reviewing the actions (e.g., `$USER`, `ci-bot`)
- **environment**: The execution environment (e.g., `local`, `staging`, `prod`)
- **repository**: The code repository being worked on
- **branch**: The git branch being modified

Example: `[builder:ai:jwalsh@local(myapp:feature-123)]`

## Documentation

Full documentation available at [docs.sefaca.dev](https://docs.sefaca.dev)

## License

MIT

---

For more information, visit [sefaca.dev](https://sefaca.dev)