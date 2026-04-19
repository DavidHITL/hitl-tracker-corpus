# HITL Tracker Corpus

Public data and codebook for the **AI Roadmap Tracker** at [humaneintheloop.com](https://humaneintheloop.com).

The tracker scores seven principles from the Center for Humane Technology's *Roadmap for Humane AI* across three domains of change — norms, laws, and product design — using a public codebook and a continuously updated signal corpus.

This repository contains:

- `codebook.md` — the principle × indicator rubric (v0.1, 69 indicators)
- `data/principles.json` — the 7 principles and their current-path / better-future framings
- `data/indicators.json` — all 69 active indicators with direction rules and major-event thresholds
- `data/signals.json` + `data/signals.csv` — every public signal with indicator tag, direction, magnitude, confidence, source URL, and coding rationale
- `data/source_feeds.json` — the source-universe metadata (outlet, tier, geography)
- `data/codebook_version.json` — current codebook version record
- `data/manifest.json` — counts, timestamp, license, provenance pointers
- `schema/*.sql` — the Postgres DDL behind the tracker database
- `scripts/export.mjs` — the export script that produces everything in `data/`

## License

All contents are released under **[CC-BY 4.0](./LICENSE)**. Use them, fork them, build on them — please attribute *Humane in the Loop* and link back to [humaneintheloop.com](https://humaneintheloop.com).

## How to use the data

```bash
# the whole signal corpus as JSON
curl -L https://raw.githubusercontent.com/DavidHITL/hitl-tracker-corpus/main/data/signals.json

# or as CSV (more convenient for pandas / Excel)
curl -L https://raw.githubusercontent.com/DavidHITL/hitl-tracker-corpus/main/data/signals.csv
```

Each signal row carries:

| field | meaning |
|---|---|
| `indicator_id` | links to `indicators.json` (e.g. `1.L.a` = Principle 1, Laws domain, indicator a) |
| `direction` | `+1` advancing, `-1` regressing, `0` mixed/neutral |
| `magnitude` | `minor` / `moderate` / `major` |
| `direction_of_power` | `power_balancing` / `power_concentrating` / `neutral` |
| `confidence` | 0.0–1.0 from the tagger + human review |
| `triangulation_count` | number of distinct source types that covered the event |
| `tagged_by` | `baseline_curation_2026_04_19` for seed signals, `gemini-3-pro` for ongoing |
| `review_status` | `auto_approved` (high-confidence tagger) or `approved` (human-reviewed) |

## Coding methodology

See [`codebook.md`](./codebook.md) for the full rubric. In short:

1. Each signal is a real-world event (law, incident, product change, norm shift).
2. It is tagged to exactly one indicator in the codebook.
3. A direction (`+1` / `-1` / `0`) is assigned relative to that indicator's *positive-direction rule*.
4. A magnitude is assigned per the indicator's *major-event threshold*.
5. Cross-source triangulation (two or more source types within a 7-day window, OR a tier-1 authoritative primary source) is required before the signal counts toward the matrix.

## Spot an error? Please tell me.

Signals are tagged by an LLM and reviewed by a human. Both make mistakes. If you see:

- a wrong indicator tag,
- a direction that reads backwards,
- a dead or mis-attributed source URL,
- a missing event that clearly belongs,

please email **david@napkin.one** with the signal ID (or URL) and what you think is off. Corrections land in the next refresh cycle.

Pull requests are also welcome — see *Contributing* below.

## Refresh cadence

`data/` is regenerated daily by a GitHub Action (see `.github/workflows/refresh.yml`) and committed when content changes. The `manifest.json` carries the UTC timestamp of the most recent export.

For real-time figures, use the live tracker at [humaneintheloop.com](https://humaneintheloop.com). For reproducible analysis, pin to a commit SHA of this repo.

## Contributing

1. **Spot-check signals.** Pick a cell in [the matrix](https://humaneintheloop.com), open 3 signals, check the URL resolves and the direction is defensible. Report disagreements — we keep the rationale on every signal so you can see what reasoning to contest.
2. **Propose source-universe additions.** If there is a tier-1 outlet we should be watching and are not, open an issue with the outlet, RSS/sitemap URL, and the principle(s) it typically reports on.
3. **Propose codebook revisions.** The codebook is versioned; v0.1 is deliberately imperfect. Open an issue for new indicators, tightened thresholds, or scope corrections.

All contributions are released under CC-BY 4.0 alongside the rest of the corpus.

## Context

*Humane in the Loop* is a weekly Substack + live tracker exploring whether AI systems are being built in ways that serve humanity. The CHT principles are the rubric; this tracker is the scoreboard.

- **Live tracker:** https://humaneintheloop.com
- **Essays:** https://humaneintheloop.substack.com
- **Source repository (app code):** private for now
- **Maintainer:** David Felsmann · david@napkin.one
