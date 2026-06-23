# github — Quick Start for OpenClaw

Drop-in GitHub-skill som ger dig repos, issues, PRs, releases, Actions och search från terminalen — utan att `gh` CLI:n behöver vara installerad.

**Perfekt för** CI/CD-pipelines, sandboxes utan internet/root, automation-script, och OpenClaw-sessioner där du vill ha full GitHub-kontroll via REST API.

## ⚡ Snabbast möjliga installation (2 minuter)

1. **Kopiera hela mappen** `github/` till din OpenClaw `skills/`-katalog:
   ```
   your-openclaw-workspace/
   └── skills/
       └── github/
           ├── README.md
           ├── SKILL.md
           └── scripts/
               └── gh.sh
   ```

2. **Lägg till din GitHub-token** (endast en gång):
   - Fine-grained PAT rekommenderas: https://github.com/settings/tokens?type=beta
   - Permissions: Contents (R/W), Issues (R/W), Pull Requests (R/W), Actions (R), Metadata (R)
   - Spara i `~/.config/moss/secrets.env`:
     ```bash
     echo 'export GITHUB_TOKEN=*** >> ~/.config/moss/secrets.env
     chmod 600 ~/.config/moss/secrets.env
     ```

3. **Testa direkt**:
   ```bash
   ./scripts/gh.sh status              # auth + rate limit
   ./scripts/gh.sh repo list --user <din-användare>
   ./scripts/gh.sh issue list --repo <owner>/<repo>
   ```

Klart! Skillen är redo.

## Vanliga kommandon

- `./scripts/gh.sh status` — auth + 5000/h rate check
- `./scripts/gh.sh repo <list|view|create|clone|fork|delete>` — repo CRUD
- `./scripts/gh.sh issue <list|view|create|close|comment>` — issues
- `./scripts/gh.sh pr <list|view|create|merge>` — pull requests
- `./scripts/gh.sh release <list|create|delete>` — releases
- `./scripts/gh.sh workflow <list|runs|run|logs>` — Actions
- `./scripts/gh.sh search <repos|issues|code|prs> <query>`

## Prefers `gh` CLI när tillgänglig

Om du har `gh` installerat (`apt install gh` på Ubuntu), använd den direkt för richer UX (completions, extensions, `gh run watch`). `gh.sh` är till för:
- Sandboxes utan `gh` installerad
- Script som ska vara portable
- Miljöer där du inte har root-access

## Felsökning

**"60/60 rate limit"** → Token saknas eller ogiltig. Sätt `GITHUB_TOKEN` env var.
**"401 Unauthorized"** → Token expirated eller scopes ändrade. Regenerera PAT.
**"404 Not Found"** → Wrong owner/repo eller du har inte access.

## Säkerhet

- Token läses från `~/.config/moss/secrets.env` (mode 600), aldrig committat
- Skriptet loggar ALDRIG token i klartext — alla outputs visar bara längd/prefix
- Destructive ops (`delete`, `merge`, `close`) promptar eller kräver `--yes`

## Nästa steg

Läs `SKILL.md` för full subcommand-reference + exempel.
Läs `references/auth.md` för token setup + rotation.
Läs `references/api.md` för endpoints + rate limits.
Läs `references/examples.md` för common workflows (release pipeline, PR + auto-merge, issue triage).

Den här skillen är designad för att vara **zero-dependency** (curl + jq + git finns i princip överallt) och **fail-safe** (JSON output → pipe till jq).
