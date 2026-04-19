#!/usr/bin/env node
/**
 * Export public corpus from Supabase tracker schema → data/*.json + data/*.csv
 *
 * Env required:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * Run: `node scripts/export.mjs`
 *
 * Writes to repo-root/data/ — intended to be committed when contents change.
 */

import { writeFileSync, mkdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const DATA_DIR = resolve(__dirname, "..", "data");

// Accept either SUPABASE_URL or NEXT_PUBLIC_SUPABASE_URL so the script works
// both in CI (bare env) and when sourcing a Next.js `.env.vercel` file.
// Sanitize env values. Vercel's `.env.vercel` dumps sometimes embed a literal
// "\n" (two chars: backslash + n) at the end of values when quoted — strip it,
// along with real whitespace and trailing slashes.
const clean = (v) => (v || "").trim().replace(/\\n$/, "").replace(/\/$/, "").trim();
const SUPABASE_URL = clean(process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL);
const KEY = clean(process.env.SUPABASE_SERVICE_ROLE_KEY);
if (!SUPABASE_URL || !KEY) {
  console.error("Missing SUPABASE_URL (or NEXT_PUBLIC_SUPABASE_URL) or SUPABASE_SERVICE_ROLE_KEY in env.");
  process.exit(1);
}

/**
 * Query PostgREST. The tracker schema is exposed via `public.tracker_*` views,
 * OR we can set `Accept-Profile: tracker` to hit tracker tables directly if the
 * schema is exposed. We use the public proxy views where they exist, tracker
 * schema via profile header where they don't.
 */
async function query(path, { profile = "public" } = {}) {
  const url = `${SUPABASE_URL}/rest/v1/${path}`;
  const res = await fetch(url, {
    headers: {
      apikey: KEY,
      Authorization: `Bearer ${KEY}`,
      "Accept-Profile": profile,
    },
  });
  if (!res.ok) {
    throw new Error(`${res.status} ${res.statusText} — ${url}\n${await res.text()}`);
  }
  return res.json();
}

function toCSV(rows, columns) {
  const esc = (v) => {
    if (v === null || v === undefined) return "";
    const s = typeof v === "string" ? v : JSON.stringify(v);
    if (/[",\n\r]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
    return s;
  };
  const header = columns.join(",");
  const body = rows.map((r) => columns.map((c) => esc(r[c])).join(",")).join("\n");
  return `${header}\n${body}\n`;
}

function writeJSON(name, data) {
  const path = resolve(DATA_DIR, name);
  writeFileSync(path, JSON.stringify(data, null, 2) + "\n");
  console.log(`  wrote ${name} (${data.length ?? Object.keys(data).length} records)`);
}

function writeCSV(name, rows, columns) {
  const path = resolve(DATA_DIR, name);
  writeFileSync(path, toCSV(rows, columns));
  console.log(`  wrote ${name} (${rows.length} rows)`);
}

async function main() {
  mkdirSync(DATA_DIR, { recursive: true });

  console.log("Exporting corpus from Supabase...");

  // Principles — 7 rows, public view
  const principles = await query(
    "principles?select=id,slug,short_name,full_name,current_path,better_future,norms_recommendations,laws_recommendations,design_recommendations,display_order&order=display_order.asc",
    { profile: "tracker" },
  );
  writeJSON("principles.json", principles);

  // Indicators — ~69 rows
  const indicators = await query(
    "indicators?select=id,principle_id,domain,letter,name,positive_direction_rule,negative_direction_rule,major_threshold,codebook_version,active,display_order&active=eq.true&order=principle_id.asc,domain.asc,letter.asc",
    { profile: "tracker" },
  );
  writeJSON("indicators.json", indicators);

  // Signals — same filter as the public `tracker_signals` view:
  //   review_status ∈ (auto_approved, approved, overridden) AND NOT is_preliminary
  const signals = await query(
    "signals?select=id,title,summary,primary_url,indicator_id,direction,magnitude,direction_of_power,rationale,confidence,geography,occurred_at,triangulation_count,review_status,tagged_by,codebook_version,flagship&review_status=in.(auto_approved,approved,overridden)&is_preliminary=eq.false&order=occurred_at.desc&limit=10000",
    { profile: "tracker" },
  );
  writeJSON("signals.json", signals);
  writeCSV(
    "signals.csv",
    signals,
    [
      "id",
      "occurred_at",
      "title",
      "indicator_id",
      "direction",
      "magnitude",
      "geography",
      "confidence",
      "triangulation_count",
      "primary_url",
      "summary",
      "rationale",
      "codebook_version",
    ],
  );

  // Codebook version metadata
  const codebook = await query(
    "codebook_versions?select=version,published_at,indicator_count,notes,is_current&is_current=eq.true",
    { profile: "tracker" },
  );
  writeJSON("codebook_version.json", codebook[0] ?? null);

  // Source feeds — outlet-level metadata only (no rss_url credentials, but all
  // our feed URLs are public RSS/sitemap, so safe to expose)
  const sources = await query(
    "source_feeds?select=id,outlet,source_type,geography,url,tier,active,triangulation_weight&active=eq.true&order=tier.asc,outlet.asc",
    { profile: "tracker" },
  );
  writeJSON("source_feeds.json", sources);

  // Summary manifest for quick introspection
  const manifest = {
    generated_at: new Date().toISOString(),
    counts: {
      principles: principles.length,
      indicators: indicators.length,
      signals: signals.length,
      source_feeds: sources.length,
    },
    codebook_version: codebook[0]?.version ?? null,
    license: "CC-BY-4.0",
    source_repository: "https://github.com/DavidHITL/hitl-tracker-corpus",
    tracker_ui: "https://humaneintheloop.com",
  };
  writeJSON("manifest.json", manifest);

  console.log("Done.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
