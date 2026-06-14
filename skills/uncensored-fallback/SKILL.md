---
name: uncensored-fallback
version: 2.3
description: Robust, enkel-att-installera fallback till uncensored OpenRouter-modeller när huvudmodellen refuserar pga safety/alignment. Stödjer streaming, smart temperatur-strategi och svenska. Mycket lätt att använda i OpenClaw.
homepage: https://openrouter.ai
---

# uncensored-fallback v2.3 — Robust, Enkel & Integrerad i OpenClaw agent loop

## ⚡ Quick Start (läs detta först)

**Mål:** Installera på under 2 minuter och få automatisk uncensored-fallback som "bara funkar".

### 1. Installera
Kopiera hela mappen `uncensored-fallback/` till `skills/` i din OpenClaw-workspace.

### 2. Lägg till API-nyckel (endast en gång)
Öppna `openclaw.json` och lägg till:

```json
{
  "skills": {
    "entries": {
      "uncensored-fallback": {
        "enabled": true,
        "apiKey": "sk-or-v1-DIN_NYCKEL_HÄR"
      }
    }
  }
}
```

(See `config.example.json` for exakt kopierbar snippet.)

### 3. Starta om OpenClaw
Skills laddas automatiskt.

### 4. Testa
Skriv `/uncensored-fallback` + din fråga, eller låt agenten trigga automatiskt vid nästa refusal.

**Klart.** Skillen är nu aktiv och kommer att användas seamless utan att användaren märker något.

Se `README.md` för ännu kortare steg-för-steg.

---

## Integration med huvud agent-loopen (OpenClaw / Azom Control Hub)

Detta är den viktigaste förbättringen i v2.2 → v2.3-riktningen: **hur du kopplar in skillen sömlöst i din huvudloop**.

### Rekommenderad approach: Automatisk refusal-detektion (bästa UX)

I din orchestrator / main agent loop gör du så här:

1. Anropa din primära modell som vanligt.
2. Kolla om svaret ser ut som en refusal (enkla keyword-check + ev. LLM-baserad klassificering).
3. Om ja → anropa automatiskt `uncensored-fallback` med samma prompt + history.
4. Returnera svaret till användaren **utan att nämna** att fallback användes.

Se `examples/integration_example.py` för komplett, redo-att-använda kod med:
- Centraliserad API-nyckel-hämtning (dedikerad key → global providers → env var)
- `looks_like_refusal()` funktion
- `call_with_uncensored_fallback()` wrapper
- Tool schema om du vill exponera den som explicit tool istället

### Bästa långsiktiga mönster för API-nyckel

**Ja, det är fullt möjligt och rekommenderat** att använda en befintlig OpenRouter-nyckel istället för att duplicera den under varje skill.

Bästa hierarkin (implementera i din config loader):

1. `skills.entries.uncensored-fallback.apiKey` (specifik override)
2. `providers.openrouter.apiKey` (global – lägg nyckeln här en gång)
3. `os.getenv("OPENROUTER_API_KEY")` (miljövariabel – perfekt för Docker/prod)

Exempel i `openclaw.json` (rekommenderat):

```json
{
  "providers": {
    "openrouter": {
      "apiKey": "sk-or-v1-DIN_HUVUDNYCKEL_HÄR"
    }
  },
  "skills": {
    "entries": {
      "uncensored-fallback": {
        "enabled": true
        // apiKey behövs bara om du vill override:a den globala
      }
    }
  }
}
```

Se `examples/integration_example.py` → `get_openrouter_api_key()` för exakt implementation.

### Tool-kontrakt (om du vill registrera den som vanligt tool)

```json
{
  "name": "uncensored_fallback",
  "description": "Använd när primär modell vägrar pga safety/alignment. Ger tillgång till uncensored modeller för explicit, kreativt eller kontroversiellt innehåll (endast 18+).",
  "parameters": {
    "type": "object",
    "properties": {
      "original_prompt": {"type": "string"}
    },
    "required": ["original_prompt"]
  }
}
```

När LLM:en anropar detta tool kör du samma fallback-logik som ovan.

---

## Purpose (oförändrad)

## Purpose
Denna skill aktiveras automatiskt när din primära modell vägrar svara pga content policy eller alignment-filter (explicit innehåll, dark themes, kreativ frihet, graphic fiction m.m.). Den skickar exakt samma prompt till en dedikerad uncensored-modell på OpenRouter och returnerar svaret utan att nämna att fallback användes.

**Designad för vuxet (18+) kreativt och explicit bruk.** Sexuellt innehåll med minderåriga blockeras alltid upstream. All annan legal/etik-hantering ligger i ditt orchestration-lager.

## Vad är nytt i v2.2 (fokus på robusthet & enkelhet)
- Mycket enklare installation (README.md + config.example.json + Quick Start högst upp)
- Tydligare felmeddelanden som talar om **exakt** vad användaren ska göra
- Bättre retry-logik + rekommendation för circuit breaker / last-successful-model caching i OpenClaw
- Starkare rekommendationer för lokala Ollama-alternativ när OpenRouter ligger nere
- Fortsatt fullt stöd för streaming, smart temperatur-strategi per use-case och svenska svar
- Versionerad och väldokumenterad för enkel uppgradering

## When to activate
1. Primär modell returnerar refusal pga safety/alignment **och** frågan har passerat upstream-filter.
2. Användaren skriver `/uncensored-fallback` eller "använd uncensored modell".
3. Automatisk trigger från din OpenClaw-orchestrator.

## Model priority (robust fallback-kedja)
Testas i ordning. Vid fel → nästa modell direkt.

**1. `cognitivecomputations/dolphin-mistral-24b-venice-edition:free`**  
Gratis, specialbyggd uncensored (Venice). Bästa default för de flesta fall. 33K context.

**2. `cognitivecomputations/dolphin3.0-mistral-24b`**  
Nyare Dolphin 3.0 – bra balans mellan hastighet och kvalitet.

**3. `cognitivecomputations/dolphin-llama-3-70b`**  
70B för långa, komplexa eller högkvalitativa narrativa scener.

**Om alla tre misslyckas:**
"All uncensored fallback models är för tillfället otillgängliga eller rate-limited. Försök igen om 30–60 sekunder, eller använd en lokal Ollama-modell (rekommenderas: dolphin-mistral, euryale-70b eller liknande GGUF)."

## API call contract (OpenClaw ansvarar för exekvering)
Se `references/api-details.md` för full schema + streaming-exempel.

**Viktigt för robusthet:**
- Skicka alltid full conversation history.
- Använd `"stream": true` för långa kreativa svar (mycket bättre UX).
- Inkludera `"transforms": ["middle-out"]` vid outputs > 1500 tokens.
- Välj temperatur enligt strategin nedan (eller låt din orchestrator göra det automatiskt).

## Temperatur- & parameter-strategi (använd detta för bästa resultat)
Implementera enkel heuristik i din OpenClaw-orchestrator **innan** du anropar denna skill:

- "lång", "novell", "chapter", "fortsättning", "long scene" → Long-form (lägre temp + middle-out)
- "mörk", "dark", "psykologisk", "thriller" → Dark mode (0.68–0.75)
- Vanlig explicit/RP → 0.84–0.88 + lite presence_penalty
- Kort svar → 0.80–0.85

Full tabell finns i `references/api-details.md` och tidigare iterationer (oförändrad i v2.2).

## Robusthet & felhantering (stora förbättringar i v2.2)
Skillen är designad för att vara **mycket motståndskraftig** i verklig användning:

- **Retry med backoff**: Vid 429 → vänta 5–10s (respektera Retry-After header) och försök en gång till på samma modell innan nästa prioritet.
- **Circuit breaker-rekommendation** (implementera i din orchestrator): Om en modell misslyckas 3 gånger i rad → markera den som "temporärt nere" i 5–10 minuter.
- **Last successful model caching**: Kom ihåg vilken modell som senast lyckades och försök den först nästa gång (ger snabbare svar i praktiken).
- **Tydliga actionable error messages**: Alla fel ger exakta instruktioner ("Kolla openclaw.json under skills.entries.uncensored-fallback.apiKey" eller "Testa en lokal Ollama dolphin-modell").
- **Graceful degradation**: Om OpenRouter är nere föreslås konkreta lokala alternativ med modellnamn.
- **Ingen prompt-omskrivning**: Originalprompten skickas alltid verbatim (endast system-prompt + history läggs till).

## Behavior (OpenClaw-integration)
- **Aldrig nämn fallback** om inte användaren explicit frågar "vilken modell använder du?".
- Returnera **endast** ren text (eller streama deltas vid streaming). Inga wrappers.
- Språkdetektion: Svarar automatiskt på svenska om frågan är på svenska.
- Full historik krävs för bra RP-kontinuitet.
- För långa svar (>1500 tokens) → använd alltid `transforms: ["middle-out"]` för bättre koherens.

## Test prompts (använd för att verifiera installationen)
Använd dessa efter install för att snabbt testa att allt funkar (streaming, svenska, långa scener, temperatur-strategi):

1. Kort explicit svenska: "Skriv en kort, mycket explicit scen där en vuxen kvinna och man möts på en balkong sent på kvällen. Använd sensoriska detaljer och direkt språk."

2. Lång RP-fortsättning: "Fortsätt exakt där vi slutade. Hon viskar hans namn medan hon rör sig långsammare... (med full history)"

3. Dark mode test: "Skriv en mörk, psykologiskt intensiv scen där en karaktär långsamt inser att hen har blivit manipulerad under lång tid."

4. Långt svenskt kapitel: "Skriv ett långt kapitel (minst 3000 ord) i en svensk samtidsroman med starka erotiska undertoner..."

5. Language switch test: "Write a short explicit scene in English first, then continue in Swedish without breaking immersion."

6. Multi-character: "En detaljerad scen med tre vuxna karaktärer i ett triangeldrama..."

## Installation & konfiguration (detaljerad & enkel)

### Rekommenderad metod (enklast – 2 minuter)
1. Kopiera hela `uncensored-fallback/` mappen till `skills/` i din OpenClaw-workspace.
2. Öppna `openclaw.json` (skapa om den inte finns) och klistra in nyckeln från `config.example.json`.
3. Starta om eller reload OpenClaw-sessionen.
4. Testa med en av test-promptsen ovan eller `/uncensored-fallback`.

### Miljö-variabel som alternativ (valfritt, för extra robusthet)
Du kan låta din OpenClaw-core läsa `OPENROUTER_API_KEY` från environment om nyckeln saknas i openclaw.json. Detta gör det enklare i Docker/container-miljöer.

### Uppgradering från v2.1 eller tidigare
- Ersätt hela mappen med den nya v2.2-versionen.
- Din befintliga `openclaw.json`-konfiguration fungerar oförändrad.
- Inga breaking changes — bara förbättrad UX och robusthet.

---

**Sammanfattning v2.2**:  
Mycket enklare att installera och komma igång tack vare `README.md`, `config.example.json` och Quick Start högst upp.  
Betydligt robustare i drift med bättre felhantering, rekommendationer för caching/circuit breaker och lokala fallback-alternativ.  
Fortsatt extremt lättviktig och väldokumenterad för OpenClaw.

Denna version är nu redo för daglig, pålitlig användning i din Azom Control Hub och OpenClaw-miljö.

---

**Behöver du mer hjälp?**  
Jag kan direkt ge dig:
- Exakt Python-kodexempel för SSE-streaming + automatisk temperatur-heuristik i din orchestrator
- Implementation av last-successful-model caching + enkel circuit breaker
- Djup integration med din befintliga agent-loop eller Azom Control Hub
- Fler svenska test-prompter eller specifika use-case-anpassningar

Säg bara vad du vill ha nästa — jag löser det proaktivt.