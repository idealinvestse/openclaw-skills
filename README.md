# OpenClaw Skills

A curated collection of high-quality, production-ready skills for [OpenClaw](https://docs.openclaw) — the lightweight, skill-based agent framework.

## Philosophy

- **Token efficient** — Skills are kept small and delegate heavy docs to `references/`
- **Robust by default** — Proper error handling, retries, graceful degradation
- **Easy to integrate** — Clear contracts for the main agent loop
- **Uncensored when needed** — First-class support for creative/explicit use cases via `uncensored-fallback`
- **VPS-friendly** — Designed to run alongside OpenClaw on the same machine

## Available Skills

| Skill                    | Version | Description                              | Key Features                     |
|--------------------------|---------|------------------------------------------|----------------------------------|
| `uncensored-fallback`    | 2.3     | Routes to uncensored OpenRouter models on refusal | Streaming, smart temp, auto key fallback, easy main-loop integration |
| *(more coming)*          | —       | —                                        | —                                |

## Quick Install (any skill)

```bash
# From your OpenClaw workspace root
cp -r /path/to/openclaw-skills/skills/uncensored-fallback skills/
```

Then add the skill to `openclaw.json` under `skills.entries`.

## Structure

```
openclaw-skills/
├── skills/
│   └── <skill-name>/
│       ├── README.md
│       ├── SKILL.md
│       ├── config.example.json
│       ├── examples/
│       └── references/
├── prompts/          # Prompts for Grok / other builders
├── scripts/          # Helper scripts (install, validate, etc.)
└── catalog.json      # Machine-readable skill index
```

## For OpenClaw Developers

See `prompts/build-openclaw-skills.md` — a ready-to-use prompt you can give to Grok (or another instance) to extend this collection or improve existing skills while running on the same VPS as OpenClaw.

## License

MIT (or your preferred license)

## Contributing

Skills should follow the guidelines in `prompts/build-openclaw-skills.md`.

---

Maintained with ❤️ for the OpenClaw community.