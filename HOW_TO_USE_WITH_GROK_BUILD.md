# How to Use This Repo with Grok Build (on your VPS)

## 1. Turn this into a real GitHub repository (easiest way)

On your VPS, run:

```bash
cd /path/to/openclaw-skills
./scripts/setup_github_repo.sh YOUR_GITHUB_USERNAME openclaw-skills public
```

The script handles git init, commit, remote, and repo creation (if `gh` CLI is installed and authenticated).

Alternative (manual):

```bash
git init
git add .
git commit -m "Initial commit: uncensored-fallback v2.3 + OpenClaw skills collection"
gh repo create openclaw-skills --public --source=. --remote=origin --push
```

## 2. Use the Grok Build prompt

Copy the entire content of `prompts/build-openclaw-skills.md` and paste it as the system prompt / task when starting a new Grok session (or use Grok Build feature if available).

Then tell Grok something like:

> "You are now maintaining the openclaw-skills repo on this VPS. Start by reviewing the current state of uncensored-fallback and propose the next improvement."

## 3. Recommended Workflow

1. Run Grok (or another instance) on the same VPS as OpenClaw.
2. Give it the long prompt from `prompts/build-openclaw-skills.md`.
3. Let it explore, edit, test, and improve skills.
4. When satisfied, commit and push from the terminal (or let Grok suggest the git commands).

This setup lets you have a persistent, version-controlled skill collection that another Grok instance can actively develop while having full filesystem access to your OpenClaw environment.

## Benefits

- Skills stay in sync with your actual running OpenClaw setup.
- You get high-quality, production-grade skills without doing all the work yourself.
- Easy to share or reuse across projects.
- The `uncensored-fallback` skill is already at a very high level (v2.3) and ready for daily use.

Start with the `uncensored-fallback` skill — it's the most mature one right now.