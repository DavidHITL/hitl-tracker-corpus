# HITL Tracker Codebook v1

**Version:** 0.1
**Published:** 2026-04-18
**Maintainer:** David Felsmann
**Framework source:** Center for Humane Technology, *The AI Roadmap: How We Ensure AI Serves Humanity* (2026)

## Purpose

This codebook specifies how signals — discrete events in AI governance — are tagged against the Center for Humane Technology's seven principles, across three domains of change. The codebook is applied by a Gemini-powered tagging agent; 10% of auto-approved tags are sampled and human-audited each cycle.

This is an independent editorial project of Humane in the Loop, applying CHT's framework as a lens. It is not a CHT publication.

## Structure

Each principle has three domains (Norms, Laws, Design). Each cell (principle × domain) contains 3–4 **indicators** — operational definitions of what can move that cell.

Every signal in the tracker is tagged to exactly one indicator. The signal's direction (+1 / 0 / −1) and magnitude (Major / Minor) are evaluated against that indicator's rules, not against the principle abstractly.

Cells with fewer than 5 signals over the relevant time window display "Insufficient data" rather than a direction.

---

## Three Domains of Change

| Domain | Code | Scope |
|---|---|---|
| **Norms** | N | Public discourse, expert consensus, institutional expectations, civil society pressure |
| **Laws** | L | Binding rules, regulations, court decisions, international agreements, enforcement actions |
| **Design** | D | How AI products and systems are actually built, deployed, and operated |

---

## Signal fields

Every signal carries:

- `indicator_id` (e.g., `1.L.d`) — the specific indicator it updates
- `direction` ∈ {−1, 0, +1} — regressing / neutral / advancing against the indicator's rules
- `magnitude` ∈ {Minor, Major} — systemic weight
- `direction_of_power` ∈ {regulators, industry, public, unclear} — who gains leverage
- `rationale` (≤140 chars) — human-readable justification including base-rate context
- `confidence` ∈ [0, 1] — tagging agent's self-reported confidence
- `triangulation_count` — number of independent source types corroborating

---

## Magnitude rubric

A signal is **Major** if it meets at least one of:
- Affects ≥100M people (population-weighted for policy actions)
- Sets legal precedent in a Tier-1 jurisdiction (US, EU, UK, Japan, G7 body)
- Originates from a frontier AI lab or top-5 global firm by compute
- Is a first-of-its-kind (novel legal/normative/design category)
- Has credible enforcement or implementation path within 12 months

Otherwise: **Minor**.

---

## Direction rubric (general)

- **+1 Advancing** — the action moves governance in the direction CHT's "Better Future" describes for this principle. Consult the indicator's `positive_direction_rule`.
- **0 Neutral / Mixed** — no net directional effect, or effects cut both ways with roughly equal weight.
- **−1 Regressing** — the action moves away from the "Better Future" vision. Consult the indicator's `negative_direction_rule`.

When the direction is genuinely ambiguous (common for research or industry announcements), direction is **0** and confidence should be below 0.85.

---

# Principle 1 — AI should be built safely and transparently

## 1.N — Norms

### 1.N.a — Public expectation of transparency on AI capabilities
- **Positive (+1):** Rising public / media / expert demand for visibility into AI training, evaluation, and deployment.
- **Negative (−1):** Normalization of opacity; "AI is too complex to explain" framings gaining traction.
- **Major:** Coverage in ≥2 tier-1 outlets in the same week; major policy coalition letter.

### 1.N.b — Open publication of safety evaluations as industry norm
- **Positive (+1):** Labs publish eval suites, red-team findings, limitations openly.
- **Negative (−1):** Withdrawal from voluntary transparency (e.g., removed system cards, deleted benchmarks).

### 1.N.c — Incident disclosure as expected behavior
- **Positive (+1):** Near-misses, failures, jailbreaks disclosed proactively.
- **Negative (−1):** Incidents concealed, NDAs on safety findings, whistleblower retaliation.

## 1.L — Laws

### 1.L.a — Pre-deployment evaluation mandates
- **Positive (+1):** Binding requirements to evaluate frontier models before release (capability, misuse, alignment).
- **Negative (−1):** Mandates repealed, narrowed, or exemptions expanded.
- **Major:** Federal/EU/UK statute or binding regulation.

### 1.L.b — Mandatory incident reporting
- **Positive (+1):** Regulated actors required to report AI incidents to authorities within defined windows.
- **Negative (−1):** Reporting rules relaxed or rescinded.

### 1.L.c — Third-party audit requirements
- **Positive (+1):** Independent audits required for high-risk AI systems; right-of-access for auditors.
- **Negative (−1):** Audits made voluntary, weakened, or captured by industry.

### 1.L.d — Red-team disclosure rules
- **Positive (+1):** Binding red-team findings disclosure (to regulators, to public, or both).
- **Negative (−1):** Red-team results kept confidential or never required.

## 1.D — Design

### 1.D.a — Model cards / system cards published
- **Positive (+1):** New model release ships with substantive model card (training data summary, evals, limitations).
- **Negative (−1):** Release without card, or cards that are marketing documents lacking technical substance.

### 1.D.b — Public evaluation results
- **Positive (+1):** Labs publish benchmarks, red-team findings, dangerous-capability evals.
- **Negative (−1):** Results withheld, cherry-picked, or replaced with self-attestation.

### 1.D.c — Capability disclosure at point of interaction
- **Positive (+1):** Users told what model they are talking to, its limitations, confidence bounds.
- **Negative (−1):** AI systems deployed without disclosure, or disguised as humans.

---

# Principle 2 — AI companies owe a duty of care to the public

## 2.N — Norms

### 2.N.a — Professional standards and codes of conduct
- **Positive (+1):** ML/AI engineering codes of ethics, professional licensing discussions gaining traction.
- **Negative (−1):** Industry pushes "move fast and break things" framing; dismissal of responsibility.

### 2.N.b — Public expectation of company accountability for AI harms
- **Positive (+1):** Mainstream expectation that AI companies are responsible for foreseeable downstream harms.
- **Negative (−1):** Normalization of "user is responsible" / "just a tool" deflection.

### 2.N.c — Researcher and whistleblower protections as norm
- **Positive (+1):** Strong norm that safety researchers inside labs can publish critical findings.
- **Negative (−1):** Chilling effects — non-disparagement NDAs, retaliation, equity clawbacks.

## 2.L — Laws

### 2.L.a — Liability for foreseeable AI harms
- **Positive (+1):** Courts or legislatures assign liability to AI developers/deployers for predictable damage.
- **Negative (−1):** Section-230-style shields extended to AI output.
- **Major:** Supreme court ruling, federal statute, EU directive.

### 2.L.b — Duty-of-care statutes applied to AI
- **Positive (+1):** Explicit duty-of-care obligations on AI developers/deployers.
- **Negative (−1):** Carve-outs from existing duty-of-care frameworks.

### 2.L.c — Consumer protection enforcement against deceptive AI claims
- **Positive (+1):** FTC / regulator enforcement against false AI claims, dark patterns, deceptive AI marketing.
- **Negative (−1):** Enforcement declined, agencies defunded, no action despite complaints.

### 2.L.d — Private right of action / class action enablement
- **Positive (+1):** Individuals can sue AI firms for harms; class actions viable.
- **Negative (−1):** Mandatory arbitration, pre-emption, standing doctrine shutting out claims.

## 2.D — Design

### 2.D.a — Safety-by-design practices
- **Positive (+1):** Red teaming, threat modeling, safety evals integrated pre-release.
- **Negative (−1):** Safety teams cut, evals skipped for shipping speed.

### 2.D.b — User reporting / abuse channels
- **Positive (+1):** Functional reporting channels acted on; published response times and resolution rates.
- **Negative (−1):** Reports ignored, channels removed, trust and safety teams dismantled.

### 2.D.c — Post-deployment monitoring and rapid response
- **Positive (+1):** Labs monitor deployed systems, respond to emergent harms within defined windows.
- **Negative (−1):** Ship and forget; no feedback loop from deployment to model updates.

---

# Principle 3 — AI design should center human well-being

## 3.N — Norms

### 3.N.a — Public discourse on well-being metrics over engagement
- **Positive (+1):** Rising critique of engagement-maximization; mainstream coverage of time-well-spent framings.
- **Negative (−1):** Engagement metrics defended as proxy for value; critiques marginalized.

### 3.N.b — Critique of dark-pattern and addictive design
- **Positive (+1):** Civil society, academics, regulators naming specific harmful patterns.
- **Negative (−1):** Dark patterns rebranded as "UX optimization."

### 3.N.c — Mental health implications in mainstream discourse
- **Positive (+1):** Mainstream reporting on AI effects on attention, loneliness, cognitive development.
- **Negative (−1):** Topic marginalized as moral panic.

## 3.L — Laws

### 3.L.a — Restrictions on dark patterns and manipulative UX
- **Positive (+1):** Binding restrictions on specific dark patterns (consent traps, dark nudges).
- **Negative (−1):** Proposed rules dropped, enforcement rare, industry self-regulation accepted as sufficient.

### 3.L.b — Protections for minors
- **Positive (+1):** Age-appropriate design codes, default protections for under-18 users, content restrictions.
- **Negative (−1):** Minor-protection rules weakened, pre-empted, or challenged successfully.
- **Major:** Federal/EU/UK law, binding code.

### 3.L.c — Ad / recommendation system transparency
- **Positive (+1):** Regulation requiring recommendation-system auditability and user control.
- **Negative (−1):** Algorithmic opacity protected as trade secret.

## 3.D — Design

### 3.D.a — Opt-out and de-personalization defaults
- **Positive (+1):** Products ship with de-personalized defaults or easy toggles.
- **Negative (−1):** Personalization forced, opt-out buried or impossible.

### 3.D.b — Well-being features shipped by default
- **Positive (+1):** Time limits, break prompts, default quiet hours enabled out of the box.
- **Negative (−1):** Features exist but hidden, disabled by default, or removed.

### 3.D.c — Attention respect in UX
- **Positive (+1):** Fewer interruptive notifications; batch delivery; user-controlled attention.
- **Negative (−1):** Notification aggressiveness increases; attention engineered for maximum capture.

---

# Principle 4 — AI should not automate away meaningful work and human dignity

## 4.N — Norms

### 4.N.a — Public discourse on AI and labor
- **Positive (+1):** Nuanced public conversation on displacement, augmentation, and worker power.
- **Negative (−1):** Binary "AI will replace X" rhetoric dominates without worker-voice balance.

### 4.N.b — Worker voice in AI deployment decisions
- **Positive (+1):** Union position statements, works councils, collective bargaining over AI deployment.
- **Negative (−1):** Workers systematically excluded from deployment decisions.

### 4.N.c — Public skepticism toward AI replacement rhetoric
- **Positive (+1):** Mainstream pushback against inevitabilist framings.
- **Negative (−1):** Replacement treated as inevitable, debate shut down.

## 4.L — Laws

### 4.L.a — Worker displacement protections and transition funding
- **Positive (+1):** Binding transition support, retraining obligations tied to AI deployment.
- **Negative (−1):** Displacement externalized onto workers; no safety net expansion.

### 4.L.b — Algorithmic management regulations
- **Positive (+1):** Rules limiting algorithmic supervision, scheduling, and discipline of workers.
- **Negative (−1):** Algorithmic management expands unregulated.
- **Major:** Federal/EU statute, landmark case.

### 4.L.c — Notification requirements before AI deployment in workplace
- **Positive (+1):** Employers required to notify and consult workers before deploying consequential AI.
- **Negative (−1):** No notification duty; workers learn of AI via effects.

### 4.L.d — Automated decision-making rights
- **Positive (+1):** Rights to explanation, human review, and contestation of consequential automated decisions.
- **Negative (−1):** Automated decisions opaque and uncontestable.

## 4.D — Design

### 4.D.a — Human-in-the-loop for consequential decisions
- **Positive (+1):** Product design keeps humans in authoritative roles for high-stakes decisions.
- **Negative (−1):** Full automation in high-stakes contexts without review.

### 4.D.b — Augmentation-over-replacement framing
- **Positive (+1):** Products positioned as augmenting human work, with measurable augmentation outcomes.
- **Negative (−1):** Products explicitly marketed as replacing human workers.

### 4.D.c — Transparent attribution of AI-generated work
- **Positive (+1):** AI-generated outputs clearly labeled; provenance tools deployed.
- **Negative (−1):** AI work passed off as human; labeling avoided.

---

# Principle 5 — AI innovation should not come at the expense of rights and freedom

## 5.N — Norms

### 5.N.a — Public debate on AI surveillance and civil liberties
- **Positive (+1):** Journalism, civil society sustained pressure on surveillance applications.
- **Negative (−1):** Surveillance normalized as security or convenience.

### 5.N.b — Attention to algorithmic harms
- **Positive (+1):** Investigations, exposés on discriminatory outcomes, algorithmic bias.
- **Negative (−1):** Harms under-reported; "bias is solved" narrative gains.

### 5.N.c — Recognition of algorithmic discrimination
- **Positive (+1):** Mainstream acknowledgment that AI systems can systematically disadvantage groups.
- **Negative (−1):** Framing shifts to "AI is neutral, humans are biased."

## 5.L — Laws

### 5.L.a — Biometric and facial recognition limits
- **Positive (+1):** Bans or binding limits on law-enforcement or commercial use.
- **Negative (−1):** Expansions of use, rollbacks of moratoria.
- **Major:** Federal, EU AI Act, state-level bans.

### 5.L.b — Algorithmic bias and discrimination protections
- **Positive (+1):** Anti-discrimination laws explicitly cover algorithmic decision-making.
- **Negative (−1):** Algorithmic exceptions to existing anti-discrimination law.

### 5.L.c — Data protection strengthening
- **Positive (+1):** New / expanded privacy rights (access, portability, deletion, purpose limitation).
- **Negative (−1):** Weakening or pre-emption of state privacy laws.

### 5.L.d — Restrictions on predictive policing and algorithmic sentencing
- **Positive (+1):** Bans or oversight regimes on these systems.
- **Negative (−1):** Expansion without oversight.

## 5.D — Design

### 5.D.a — Privacy-preserving design defaults
- **Positive (+1):** Minimization defaults, local/on-device processing, differential privacy shipped.
- **Negative (−1):** Maximum data capture, centralized processing by default.

### 5.D.b — Bias testing and fairness tooling in development
- **Positive (+1):** Fairness audits as standard practice; published mitigation results.
- **Negative (−1):** Fairness work deprioritized or eliminated.

### 5.D.c — User rights surfaced in UX
- **Positive (+1):** Access, correction, deletion surfaced as first-class UI.
- **Negative (−1):** Rights exist on paper but buried or dark-patterned.

---

# Principle 6 — AI should have internationally agreed-upon limits

## 6.N — Norms

### 6.N.a — International scientific consensus on risks
- **Positive (+1):** IPCC-for-AI-style bodies, published risk assessments, expert consensus statements.
- **Negative (−1):** Consensus processes stall; risk denial gains.

### 6.N.b — Multilateral civil society coalitions
- **Positive (+1):** Cross-border coalitions coordinating on AI governance demands.
- **Negative (−1):** Fragmentation, national retreat.

### 6.N.c — Public expectation of cross-border governance
- **Positive (+1):** Mainstream recognition that AI risks require international coordination.
- **Negative (−1):** Techno-nationalism dominant.

## 6.L — Laws

### 6.L.a — Multilateral treaties and conventions
- **Positive (+1):** New binding multilateral instruments; ratifications.
- **Negative (−1):** Withdrawals, stalled negotiations, unsigned protocols.
- **Major:** Council of Europe AI Convention, G7/G20 commitments with binding elements.

### 6.L.b — Export controls on frontier compute and models
- **Positive (+1):** Export controls targeting dangerous-capability compute, coordinated across jurisdictions.
- **Negative (−1):** Controls relaxed, loopholes exploited, uncoordinated.

### 6.L.c — Compute governance and licensing
- **Positive (+1):** Frontier-compute licensing regimes, thresholds codified.
- **Negative (−1):** Proposals shelved; opposition from industry successful.

### 6.L.d — Safety thresholds codified internationally
- **Positive (+1):** Shared red-line definitions (bioweapon uplift, cyber offense, autonomy thresholds).
- **Negative (−1):** No shared definitions; racing to ship past unstated thresholds.

## 6.D — Design

### 6.D.a — Voluntary industry safety commitments
- **Positive (+1):** Frontier labs publish specific, testable safety commitments.
- **Negative (−1):** Commitments withdrawn, watered down, or shown to be unmet.

### 6.D.b — Information sharing on dangerous capabilities
- **Positive (+1):** Labs share capability evaluations with peers and regulators via defined channels.
- **Negative (−1):** Competitive secrecy prevails; no structured sharing.

### 6.D.c — Evaluation protocols aligned internationally
- **Positive (+1):** Cross-lab and cross-border eval methodology converging.
- **Negative (−1):** Proliferation of idiosyncratic self-evals that aren't comparable.

---

# Principle 7 — AI power should be balanced in society

## 7.N — Norms

### 7.N.a — Antitrust and competition discourse applied to AI
- **Positive (+1):** Mainstream conversation about AI market concentration and vertical integration risks.
- **Negative (−1):** National-champion framing dominates; concentration celebrated.

### 7.N.b — Open-source vs closed-source debate
- **Positive (+1):** Substantive public debate; neither side monopolizes framing.
- **Negative (−1):** Debate captured — either open-sourcing dismissed as dangerous, or closed AI dismissed as illegitimate, without serious engagement.

### 7.N.c — Concerns about democratic capture
- **Positive (+1):** Civil society surfaces AI-firm influence on policy; lobbying scrutinized.
- **Negative (−1):** Regulatory capture normalized; AI firms set the agenda unchallenged.

## 7.L — Laws

### 7.L.a — Antitrust action against AI market concentration
- **Positive (+1):** Merger challenges, structural remedies, conduct rules applied to AI firms.
- **Negative (−1):** Mergers waved through; investigations dropped.
- **Major:** FTC/DOJ/EU Commission action with teeth.

### 7.L.b — Interoperability and data portability mandates
- **Positive (+1):** Requirements for data portability, model interoperability, API access on fair terms.
- **Negative (−1):** Walled gardens protected; DMA-style rules weakened.

### 7.L.c — Public-option AI and sovereign compute funding
- **Positive (+1):** Public investment in open infrastructure, academic compute, non-commercial alternatives.
- **Negative (−1):** Public AI starved; private incumbents dominant.

### 7.L.d — Restrictions on political uses of AI
- **Positive (+1):** Rules on deepfakes in campaigns, AI-generated political ads, disinformation.
- **Negative (−1):** No rules; AI-manipulated political speech unregulated.

## 7.D — Design

### 7.D.a — Open-source model releases
- **Positive (+1):** Open-weights releases of frontier-class models, with responsible-release practices.
- **Negative (−1):** Frontier models universally closed; open releases withdrawn or restricted.

### 7.D.b — Decentralized and federated architectures
- **Positive (+1):** Federated training, on-device inference, decentralized serving growing.
- **Negative (−1):** Centralization accelerates; only incumbents can serve frontier models.

### 7.D.c — Third-party access to closed models
- **Positive (+1):** API parity for third-party developers vs internal teams; fair access terms.
- **Negative (−1):** Internal-first APIs, discriminatory pricing, sudden access revocation.

---

## Versioning

Codebook changes are versioned. When an indicator's rule changes, all historical signals tagged against that indicator are re-evaluated by the tagging agent to maintain comparability across time.

- **v1.0.0 (2026-04-18):** Initial publication. 69 indicators across 7 principles × 3 domains.

## Known limitations

- **Single-coder (with LLM agent):** Inter-rater reliability is not measured. A future upgrade path is to recruit 2–3 volunteer coders and compute Cohen's κ.
- **Source universe is finite:** Signals from sources outside the registered universe (see `source-universe-v1.md`) are not ingested.
- **Framework lock-in:** If CHT updates its AI Roadmap framework, this codebook will be re-versioned; historical signals will be re-tagged against the new indicator set.
- **No China-domestic indicators:** CHT's framework is premised on civil society and rule-of-law institutions that do not translate cleanly to authoritarian regimes. See `methodology.md` for the rationale.

## Attribution

This codebook operationalizes the Center for Humane Technology's AI Roadmap. It is not authored, reviewed, or endorsed by CHT. Errors of interpretation are solely the editor's.
