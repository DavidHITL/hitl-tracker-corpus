-- V2 seed data — codebook version, CHT principle content, indicators, source feeds
-- Published: 2026-04-18
-- Depends on: 002_v2_signals_pipeline.sql

set search_path to tracker, public;

-- =====================================================================
-- CHT content columns on principles (extend v1)
-- =====================================================================
alter table tracker.principles
  add column if not exists current_path text,
  add column if not exists better_future text,
  add column if not exists norms_recommendations jsonb,
  add column if not exists laws_recommendations jsonb,
  add column if not exists design_recommendations jsonb,
  add column if not exists slug text;

-- Backfill slugs
update tracker.principles set slug = 'safe-transparent'     where id = 1 and slug is null;
update tracker.principles set slug = 'duty-of-care'         where id = 2 and slug is null;
update tracker.principles set slug = 'human-wellbeing'      where id = 3 and slug is null;
update tracker.principles set slug = 'meaningful-work'      where id = 4 and slug is null;
update tracker.principles set slug = 'rights-freedom'       where id = 5 and slug is null;
update tracker.principles set slug = 'international-limits' where id = 6 and slug is null;
update tracker.principles set slug = 'balanced-power'       where id = 7 and slug is null;

create unique index if not exists principles_slug_uniq on tracker.principles (slug);

-- =====================================================================
-- Codebook version
-- =====================================================================
insert into tracker.codebook_versions (version, notes, indicator_count, is_current)
values ('v1.0.0', 'Initial publication. 69 indicators across 7 principles × 3 domains. See /methodology/codebook.', 69, true)
on conflict (version) do update set
  notes = excluded.notes,
  indicator_count = excluded.indicator_count,
  is_current = excluded.is_current;

-- =====================================================================
-- CHT Principle content (summary paraphrases + recommendation scaffolds)
-- NOTE: exact CHT verbatim text is rendered in the frontend from the
-- source PDF. The texts below are editorially summarized operational
-- definitions suited for DB indexing and non-quote use.
-- =====================================================================

update tracker.principles set
  current_path = 'AI systems are deployed without meaningful transparency about capabilities, training, or failure modes. Incident disclosure is voluntary and uneven. Public understanding lags deployment.',
  better_future = 'AI development is visible to the public and to independent scrutiny. Capabilities, evaluations, and failures are disclosed by default. Transparency is a pre-condition of trust, not an optional gesture.',
  norms_recommendations = '["Treat transparency as a default professional norm, not a competitive liability.", "Normalize proactive disclosure of incidents and near-misses."]'::jsonb,
  laws_recommendations = '["Mandate pre-deployment evaluations for frontier systems.", "Require incident reporting to regulators within defined windows.", "Enable third-party audits with right-of-access."]'::jsonb,
  design_recommendations = '["Publish model cards with substantive technical content, not marketing.", "Disclose dangerous-capability evaluations publicly.", "Surface model identity and limits at point of use."]'::jsonb
where id = 1;

update tracker.principles set
  current_path = 'AI firms externalize harms onto users and society. Liability is unclear or pre-empted. Whistleblowers face retaliation. Safety teams are cut to accelerate shipping.',
  better_future = 'AI developers and deployers owe the public a binding duty of care. Harms are internalized. Safety work is foundational, not optional. Whistleblowers are protected.',
  norms_recommendations = '["Establish professional standards and codes of conduct for AI engineering.", "Protect safety researchers and whistleblowers as a sectoral norm."]'::jsonb,
  laws_recommendations = '["Codify liability for foreseeable AI harms.", "Enforce existing consumer protection law against deceptive AI claims.", "Enable private rights of action for individuals harmed by AI systems."]'::jsonb,
  design_recommendations = '["Integrate safety-by-design and red teaming into release gates.", "Maintain functional user-reporting channels with published resolution metrics.", "Implement post-deployment monitoring and rapid response."]'::jsonb
where id = 2;

update tracker.principles set
  current_path = 'Products optimize for engagement over well-being. Dark patterns are routine. Children are exposed to manipulative design. Mental health effects are externalized.',
  better_future = 'Human well-being is the design target. Engagement metrics are subordinate to outcomes that serve users and communities. Protections for minors are default, not opt-in.',
  norms_recommendations = '["Shift public and professional discourse from engagement to well-being outcomes.", "Make dark-pattern design professionally disreputable."]'::jsonb,
  laws_recommendations = '["Restrict specific manipulative design patterns.", "Default protections for minors (age-appropriate design codes).", "Require transparency and user control over recommendation systems."]'::jsonb,
  design_recommendations = '["Ship privacy- and attention-respecting defaults.", "Build well-being features (time limits, quiet hours) as first-class UI.", "Reduce interruptive attention-capture in favor of user-initiated engagement."]'::jsonb
where id = 3;

update tracker.principles set
  current_path = 'AI is framed as a replacement for human work without worker voice in deployment decisions. Algorithmic management erodes dignity. Automated decision systems operate without explanation or contestability.',
  better_future = 'AI augments meaningful work and preserves human dignity. Workers have voice in deployment decisions. Consequential automated decisions are explainable and contestable.',
  norms_recommendations = '["Include worker voice in AI deployment decisions as a professional standard.", "Reject inevitabilist replacement framings in favor of augmentation."]'::jsonb,
  laws_recommendations = '["Fund transition support and retraining for workers displaced by AI.", "Regulate algorithmic management of workers.", "Require notification and consultation before consequential AI deployment in workplaces.", "Codify rights to explanation and human review of automated decisions."]'::jsonb,
  design_recommendations = '["Keep humans in authoritative roles for high-stakes decisions.", "Position products as augmenting rather than replacing human work.", "Provide transparent attribution of AI-generated work."]'::jsonb
where id = 4;

update tracker.principles set
  current_path = 'AI systems enable new scales of surveillance, discrimination, and manipulation. Biometric capture is expanding. Algorithmic decisions shape access to housing, credit, liberty without meaningful review.',
  better_future = 'AI innovation operates within a strong rights and freedom framework. Surveillance is constrained. Bias is measured and mitigated. Data protection is robust. People retain meaningful control over how AI affects their lives.',
  norms_recommendations = '["Treat algorithmic surveillance as a civil liberties concern, not an infrastructure question.", "Recognize systemic algorithmic discrimination as a legitimate policy target."]'::jsonb,
  laws_recommendations = '["Limit biometric and facial recognition deployment, especially by law enforcement.", "Extend anti-discrimination law to cover algorithmic decision-making.", "Strengthen data protection (access, deletion, purpose limitation, portability).", "Restrict predictive policing and algorithmic sentencing without oversight."]'::jsonb,
  design_recommendations = '["Default to data minimization and on-device processing where feasible.", "Build fairness testing into the development lifecycle.", "Surface user rights (access, correction, deletion) as first-class UI."]'::jsonb
where id = 5;

update tracker.principles set
  current_path = 'AI development races ahead of governance. Frontier labs operate with voluntary and inconsistent safety commitments. Dangerous capabilities emerge before international agreement is possible.',
  better_future = 'AI development operates within internationally agreed limits. Safety thresholds are shared across jurisdictions. Export controls and compute governance align across allies. Dangerous capabilities are coordinated, not raced.',
  norms_recommendations = '["Build international scientific consensus on AI risks (IPCC-style).", "Foster multilateral civil society coordination on AI governance demands."]'::jsonb,
  laws_recommendations = '["Advance binding multilateral instruments (e.g., Council of Europe AI Convention).", "Coordinate export controls on frontier compute and models.", "Establish compute governance and licensing regimes.", "Codify shared safety thresholds (bioweapon uplift, cyber offense, autonomy)."]'::jsonb,
  design_recommendations = '["Publish voluntary frontier-safety commitments that are specific and testable.", "Share dangerous-capability evaluations with peers and regulators.", "Align evaluation protocols internationally."]'::jsonb
where id = 6;

update tracker.principles set
  current_path = 'AI power concentrates in a handful of firms with unprecedented influence over markets, public discourse, and policy. Open alternatives are starved of capital and compute. Democratic institutions struggle to hold AI firms accountable.',
  better_future = 'AI power is distributed across a healthy ecosystem of commercial, open-source, public, and cooperative actors. Antitrust and competition policy apply. Democratic institutions retain capacity to govern.',
  norms_recommendations = '["Treat AI market concentration as a competition and democratic concern.", "Sustain substantive public debate on open vs closed AI beyond either-side capture."]'::jsonb,
  laws_recommendations = '["Apply antitrust and competition rules to AI markets.", "Mandate interoperability and data portability.", "Fund public-option AI and sovereign compute alternatives.", "Restrict political use of AI (deepfakes, AI-generated campaign speech)."]'::jsonb,
  design_recommendations = '["Support responsible open-weights releases of capable models.", "Invest in decentralized and federated architectures.", "Provide fair API access to closed models for third-party developers."]'::jsonb
where id = 7;

-- =====================================================================
-- Indicators (69 rows)
-- =====================================================================
-- Schema: (id, principle_id, domain, letter, name, positive_direction_rule,
--          negative_direction_rule, major_threshold, codebook_version, display_order)

insert into tracker.indicators (id, principle_id, domain, letter, name,
  positive_direction_rule, negative_direction_rule, major_threshold, codebook_version, display_order) values

-- Principle 1 — Safe & Transparent
('1.N.a', 1, 'norms', 'a', 'Public expectation of transparency on AI capabilities',
  'Rising public/media/expert demand for visibility into AI training, evaluation, and deployment.',
  'Normalization of opacity; "AI is too complex to explain" framings gaining traction.',
  'Coverage in ≥2 tier-1 outlets same week; major policy coalition letter.', 'v1.0.0', 1),
('1.N.b', 1, 'norms', 'b', 'Open publication of safety evaluations as industry norm',
  'Labs publish eval suites, red-team findings, limitations openly.',
  'Withdrawal from voluntary transparency (removed system cards, deleted benchmarks).',
  NULL, 'v1.0.0', 2),
('1.N.c', 1, 'norms', 'c', 'Incident disclosure as expected behavior',
  'Near-misses, failures, jailbreaks disclosed proactively.',
  'Incidents concealed, NDAs on safety findings, whistleblower retaliation.',
  NULL, 'v1.0.0', 3),
('1.L.a', 1, 'laws', 'a', 'Pre-deployment evaluation mandates',
  'Binding requirements to evaluate frontier models before release (capability, misuse, alignment).',
  'Mandates repealed, narrowed, or exemptions expanded.',
  'Federal/EU/UK statute or binding regulation.', 'v1.0.0', 1),
('1.L.b', 1, 'laws', 'b', 'Mandatory incident reporting',
  'Regulated actors required to report AI incidents to authorities within defined windows.',
  'Reporting rules relaxed or rescinded.',
  NULL, 'v1.0.0', 2),
('1.L.c', 1, 'laws', 'c', 'Third-party audit requirements',
  'Independent audits required for high-risk AI systems; right-of-access for auditors.',
  'Audits made voluntary, weakened, or captured by industry.',
  NULL, 'v1.0.0', 3),
('1.L.d', 1, 'laws', 'd', 'Red-team disclosure rules',
  'Binding red-team findings disclosure (to regulators, to public, or both).',
  'Red-team results kept confidential or never required.',
  NULL, 'v1.0.0', 4),
('1.D.a', 1, 'design', 'a', 'Model cards / system cards published',
  'New model release ships with substantive model card (training data, evals, limitations).',
  'Release without card, or cards that are marketing documents lacking technical substance.',
  NULL, 'v1.0.0', 1),
('1.D.b', 1, 'design', 'b', 'Public evaluation results',
  'Labs publish benchmarks, red-team findings, dangerous-capability evals.',
  'Results withheld, cherry-picked, or replaced with self-attestation.',
  NULL, 'v1.0.0', 2),
('1.D.c', 1, 'design', 'c', 'Capability disclosure at point of interaction',
  'Users told what model, its limitations, confidence bounds.',
  'AI systems deployed without disclosure, or disguised as humans.',
  NULL, 'v1.0.0', 3),

-- Principle 2 — Duty of Care
('2.N.a', 2, 'norms', 'a', 'Professional standards and codes of conduct',
  'ML/AI engineering codes of ethics, professional licensing discussions gaining traction.',
  'Industry pushes "move fast and break things" framing; dismissal of responsibility.',
  NULL, 'v1.0.0', 1),
('2.N.b', 2, 'norms', 'b', 'Public expectation of company accountability for AI harms',
  'Mainstream expectation that AI companies are responsible for foreseeable downstream harms.',
  'Normalization of "user is responsible" / "just a tool" deflection.',
  NULL, 'v1.0.0', 2),
('2.N.c', 2, 'norms', 'c', 'Researcher and whistleblower protections as norm',
  'Strong norm that safety researchers inside labs can publish critical findings.',
  'Chilling effects — non-disparagement NDAs, retaliation, equity clawbacks.',
  NULL, 'v1.0.0', 3),
('2.L.a', 2, 'laws', 'a', 'Liability for foreseeable AI harms',
  'Courts or legislatures assign liability to AI developers/deployers for predictable damage.',
  'Section-230-style shields extended to AI output.',
  'Supreme court ruling, federal statute, EU directive.', 'v1.0.0', 1),
('2.L.b', 2, 'laws', 'b', 'Duty-of-care statutes applied to AI',
  'Explicit duty-of-care obligations on AI developers/deployers.',
  'Carve-outs from existing duty-of-care frameworks.',
  NULL, 'v1.0.0', 2),
('2.L.c', 2, 'laws', 'c', 'Consumer protection enforcement against deceptive AI claims',
  'FTC/regulator enforcement against false AI claims, dark patterns, deceptive marketing.',
  'Enforcement declined, agencies defunded, no action despite complaints.',
  NULL, 'v1.0.0', 3),
('2.L.d', 2, 'laws', 'd', 'Private right of action / class action enablement',
  'Individuals can sue AI firms for harms; class actions viable.',
  'Mandatory arbitration, pre-emption, standing doctrine shutting out claims.',
  NULL, 'v1.0.0', 4),
('2.D.a', 2, 'design', 'a', 'Safety-by-design practices',
  'Red teaming, threat modeling, safety evals integrated pre-release.',
  'Safety teams cut, evals skipped for shipping speed.',
  NULL, 'v1.0.0', 1),
('2.D.b', 2, 'design', 'b', 'User reporting / abuse channels',
  'Functional reporting channels acted on; published response times and resolution rates.',
  'Reports ignored, channels removed, trust and safety teams dismantled.',
  NULL, 'v1.0.0', 2),
('2.D.c', 2, 'design', 'c', 'Post-deployment monitoring and rapid response',
  'Labs monitor deployed systems, respond to emergent harms within defined windows.',
  'Ship and forget; no feedback loop from deployment to model updates.',
  NULL, 'v1.0.0', 3),

-- Principle 3 — Human Well-being
('3.N.a', 3, 'norms', 'a', 'Public discourse on well-being metrics over engagement',
  'Rising critique of engagement-maximization; mainstream coverage of time-well-spent.',
  'Engagement metrics defended as proxy for value; critiques marginalized.',
  NULL, 'v1.0.0', 1),
('3.N.b', 3, 'norms', 'b', 'Critique of dark-pattern and addictive design',
  'Civil society, academics, regulators naming specific harmful patterns.',
  'Dark patterns rebranded as "UX optimization."',
  NULL, 'v1.0.0', 2),
('3.N.c', 3, 'norms', 'c', 'Mental health implications in mainstream discourse',
  'Mainstream reporting on AI effects on attention, loneliness, cognitive development.',
  'Topic marginalized as moral panic.',
  NULL, 'v1.0.0', 3),
('3.L.a', 3, 'laws', 'a', 'Restrictions on dark patterns and manipulative UX',
  'Binding restrictions on specific dark patterns.',
  'Proposed rules dropped, enforcement rare, industry self-regulation accepted.',
  NULL, 'v1.0.0', 1),
('3.L.b', 3, 'laws', 'b', 'Protections for minors',
  'Age-appropriate design codes, default protections for under-18 users, content restrictions.',
  'Minor-protection rules weakened, pre-empted, or successfully challenged.',
  'Federal/EU/UK law, binding code.', 'v1.0.0', 2),
('3.L.c', 3, 'laws', 'c', 'Ad / recommendation system transparency',
  'Regulation requiring recommendation-system auditability and user control.',
  'Algorithmic opacity protected as trade secret.',
  NULL, 'v1.0.0', 3),
('3.D.a', 3, 'design', 'a', 'Opt-out and de-personalization defaults',
  'Products ship with de-personalized defaults or easy toggles.',
  'Personalization forced, opt-out buried or impossible.',
  NULL, 'v1.0.0', 1),
('3.D.b', 3, 'design', 'b', 'Well-being features shipped by default',
  'Time limits, break prompts, default quiet hours enabled out of the box.',
  'Features exist but hidden, disabled by default, or removed.',
  NULL, 'v1.0.0', 2),
('3.D.c', 3, 'design', 'c', 'Attention respect in UX',
  'Fewer interruptive notifications; batch delivery; user-controlled attention.',
  'Notification aggressiveness increases; attention engineered for maximum capture.',
  NULL, 'v1.0.0', 3),

-- Principle 4 — Meaningful Work
('4.N.a', 4, 'norms', 'a', 'Public discourse on AI and labor',
  'Nuanced public conversation on displacement, augmentation, and worker power.',
  'Binary "AI will replace X" rhetoric dominates without worker-voice balance.',
  NULL, 'v1.0.0', 1),
('4.N.b', 4, 'norms', 'b', 'Worker voice in AI deployment decisions',
  'Union position statements, works councils, collective bargaining over AI deployment.',
  'Workers systematically excluded from deployment decisions.',
  NULL, 'v1.0.0', 2),
('4.N.c', 4, 'norms', 'c', 'Public skepticism toward AI replacement rhetoric',
  'Mainstream pushback against inevitabilist framings.',
  'Replacement treated as inevitable, debate shut down.',
  NULL, 'v1.0.0', 3),
('4.L.a', 4, 'laws', 'a', 'Worker displacement protections and transition funding',
  'Binding transition support, retraining obligations tied to AI deployment.',
  'Displacement externalized onto workers; no safety net expansion.',
  NULL, 'v1.0.0', 1),
('4.L.b', 4, 'laws', 'b', 'Algorithmic management regulations',
  'Rules limiting algorithmic supervision, scheduling, and discipline of workers.',
  'Algorithmic management expands unregulated.',
  'Federal/EU statute, landmark case.', 'v1.0.0', 2),
('4.L.c', 4, 'laws', 'c', 'Notification requirements before AI deployment in workplace',
  'Employers required to notify and consult workers before deploying consequential AI.',
  'No notification duty; workers learn of AI via effects.',
  NULL, 'v1.0.0', 3),
('4.L.d', 4, 'laws', 'd', 'Automated decision-making rights',
  'Rights to explanation, human review, and contestation of consequential automated decisions.',
  'Automated decisions opaque and uncontestable.',
  NULL, 'v1.0.0', 4),
('4.D.a', 4, 'design', 'a', 'Human-in-the-loop for consequential decisions',
  'Product design keeps humans in authoritative roles for high-stakes decisions.',
  'Full automation in high-stakes contexts without review.',
  NULL, 'v1.0.0', 1),
('4.D.b', 4, 'design', 'b', 'Augmentation-over-replacement framing',
  'Products positioned as augmenting human work, with measurable augmentation outcomes.',
  'Products explicitly marketed as replacing human workers.',
  NULL, 'v1.0.0', 2),
('4.D.c', 4, 'design', 'c', 'Transparent attribution of AI-generated work',
  'AI-generated outputs clearly labeled; provenance tools deployed.',
  'AI work passed off as human; labeling avoided.',
  NULL, 'v1.0.0', 3),

-- Principle 5 — Rights & Freedom
('5.N.a', 5, 'norms', 'a', 'Public debate on AI surveillance and civil liberties',
  'Journalism, civil society sustained pressure on surveillance applications.',
  'Surveillance normalized as security or convenience.',
  NULL, 'v1.0.0', 1),
('5.N.b', 5, 'norms', 'b', 'Attention to algorithmic harms',
  'Investigations, exposés on discriminatory outcomes, algorithmic bias.',
  'Harms under-reported; "bias is solved" narrative gains.',
  NULL, 'v1.0.0', 2),
('5.N.c', 5, 'norms', 'c', 'Recognition of algorithmic discrimination',
  'Mainstream acknowledgment that AI systems can systematically disadvantage groups.',
  'Framing shifts to "AI is neutral, humans are biased."',
  NULL, 'v1.0.0', 3),
('5.L.a', 5, 'laws', 'a', 'Biometric and facial recognition limits',
  'Bans or binding limits on law-enforcement or commercial use.',
  'Expansions of use, rollbacks of moratoria.',
  'Federal, EU AI Act, state-level bans.', 'v1.0.0', 1),
('5.L.b', 5, 'laws', 'b', 'Algorithmic bias and discrimination protections',
  'Anti-discrimination laws explicitly cover algorithmic decision-making.',
  'Algorithmic exceptions to existing anti-discrimination law.',
  NULL, 'v1.0.0', 2),
('5.L.c', 5, 'laws', 'c', 'Data protection strengthening',
  'New/expanded privacy rights (access, portability, deletion, purpose limitation).',
  'Weakening or pre-emption of state privacy laws.',
  NULL, 'v1.0.0', 3),
('5.L.d', 5, 'laws', 'd', 'Restrictions on predictive policing and algorithmic sentencing',
  'Bans or oversight regimes on these systems.',
  'Expansion without oversight.',
  NULL, 'v1.0.0', 4),
('5.D.a', 5, 'design', 'a', 'Privacy-preserving design defaults',
  'Minimization defaults, local/on-device processing, differential privacy shipped.',
  'Maximum data capture, centralized processing by default.',
  NULL, 'v1.0.0', 1),
('5.D.b', 5, 'design', 'b', 'Bias testing and fairness tooling in development',
  'Fairness audits as standard practice; published mitigation results.',
  'Fairness work deprioritized or eliminated.',
  NULL, 'v1.0.0', 2),
('5.D.c', 5, 'design', 'c', 'User rights surfaced in UX',
  'Access, correction, deletion surfaced as first-class UI.',
  'Rights exist on paper but buried or dark-patterned.',
  NULL, 'v1.0.0', 3),

-- Principle 6 — International Limits
('6.N.a', 6, 'norms', 'a', 'International scientific consensus on risks',
  'IPCC-for-AI-style bodies, published risk assessments, expert consensus statements.',
  'Consensus processes stall; risk denial gains.',
  NULL, 'v1.0.0', 1),
('6.N.b', 6, 'norms', 'b', 'Multilateral civil society coalitions',
  'Cross-border coalitions coordinating on AI governance demands.',
  'Fragmentation, national retreat.',
  NULL, 'v1.0.0', 2),
('6.N.c', 6, 'norms', 'c', 'Public expectation of cross-border governance',
  'Mainstream recognition that AI risks require international coordination.',
  'Techno-nationalism dominant.',
  NULL, 'v1.0.0', 3),
('6.L.a', 6, 'laws', 'a', 'Multilateral treaties and conventions',
  'New binding multilateral instruments; ratifications.',
  'Withdrawals, stalled negotiations, unsigned protocols.',
  'Council of Europe AI Convention, G7/G20 binding commitments.', 'v1.0.0', 1),
('6.L.b', 6, 'laws', 'b', 'Export controls on frontier compute and models',
  'Export controls targeting dangerous-capability compute, coordinated across jurisdictions.',
  'Controls relaxed, loopholes exploited, uncoordinated.',
  NULL, 'v1.0.0', 2),
('6.L.c', 6, 'laws', 'c', 'Compute governance and licensing',
  'Frontier-compute licensing regimes, thresholds codified.',
  'Proposals shelved; opposition from industry successful.',
  NULL, 'v1.0.0', 3),
('6.L.d', 6, 'laws', 'd', 'Safety thresholds codified internationally',
  'Shared red-line definitions (bioweapon uplift, cyber offense, autonomy thresholds).',
  'No shared definitions; racing to ship past unstated thresholds.',
  NULL, 'v1.0.0', 4),
('6.D.a', 6, 'design', 'a', 'Voluntary industry safety commitments',
  'Frontier labs publish specific, testable safety commitments.',
  'Commitments withdrawn, watered down, or shown to be unmet.',
  NULL, 'v1.0.0', 1),
('6.D.b', 6, 'design', 'b', 'Information sharing on dangerous capabilities',
  'Labs share capability evaluations with peers and regulators via defined channels.',
  'Competitive secrecy prevails; no structured sharing.',
  NULL, 'v1.0.0', 2),
('6.D.c', 6, 'design', 'c', 'Evaluation protocols aligned internationally',
  'Cross-lab and cross-border eval methodology converging.',
  'Proliferation of idiosyncratic self-evals that aren''t comparable.',
  NULL, 'v1.0.0', 3),

-- Principle 7 — Balanced Power
('7.N.a', 7, 'norms', 'a', 'Antitrust and competition discourse applied to AI',
  'Mainstream conversation about AI market concentration and vertical integration risks.',
  'National-champion framing dominates; concentration celebrated.',
  NULL, 'v1.0.0', 1),
('7.N.b', 7, 'norms', 'b', 'Open-source vs closed-source debate',
  'Substantive public debate; neither side monopolizes framing.',
  'Debate captured — either open-sourcing dismissed as dangerous, or closed AI dismissed as illegitimate, without serious engagement.',
  NULL, 'v1.0.0', 2),
('7.N.c', 7, 'norms', 'c', 'Concerns about democratic capture',
  'Civil society surfaces AI-firm influence on policy; lobbying scrutinized.',
  'Regulatory capture normalized; AI firms set the agenda unchallenged.',
  NULL, 'v1.0.0', 3),
('7.L.a', 7, 'laws', 'a', 'Antitrust action against AI market concentration',
  'Merger challenges, structural remedies, conduct rules applied to AI firms.',
  'Mergers waved through; investigations dropped.',
  'FTC/DOJ/EU Commission action with teeth.', 'v1.0.0', 1),
('7.L.b', 7, 'laws', 'b', 'Interoperability and data portability mandates',
  'Requirements for data portability, model interoperability, API access on fair terms.',
  'Walled gardens protected; DMA-style rules weakened.',
  NULL, 'v1.0.0', 2),
('7.L.c', 7, 'laws', 'c', 'Public-option AI and sovereign compute funding',
  'Public investment in open infrastructure, academic compute, non-commercial alternatives.',
  'Public AI starved; private incumbents dominant.',
  NULL, 'v1.0.0', 3),
('7.L.d', 7, 'laws', 'd', 'Restrictions on political uses of AI',
  'Rules on deepfakes in campaigns, AI-generated political ads, disinformation.',
  'No rules; AI-manipulated political speech unregulated.',
  NULL, 'v1.0.0', 4),
('7.D.a', 7, 'design', 'a', 'Open-source model releases',
  'Open-weights releases of frontier-class models, with responsible-release practices.',
  'Frontier models universally closed; open releases withdrawn or restricted.',
  NULL, 'v1.0.0', 1),
('7.D.b', 7, 'design', 'b', 'Decentralized and federated architectures',
  'Federated training, on-device inference, decentralized serving growing.',
  'Centralization accelerates; only incumbents can serve frontier models.',
  NULL, 'v1.0.0', 2),
('7.D.c', 7, 'design', 'c', 'Third-party access to closed models',
  'API parity for third-party developers vs internal teams; fair access terms.',
  'Internal-first APIs, discriminatory pricing, sudden access revocation.',
  NULL, 'v1.0.0', 3)

on conflict (id) do update set
  name = excluded.name,
  positive_direction_rule = excluded.positive_direction_rule,
  negative_direction_rule = excluded.negative_direction_rule,
  major_threshold = excluded.major_threshold,
  codebook_version = excluded.codebook_version;

-- =====================================================================
-- Source feeds (31 rows)
-- =====================================================================
insert into tracker.source_feeds (outlet, source_type, geography, url, rss_url, tier, ingestion_method, triangulation_weight) values
-- Official (11)
('Congress.gov',                         'official',  'us',            'https://www.congress.gov',                'https://www.congress.gov/rss/most-viewed-bills.xml', 1, 'api',        1.0),
('Federal Register',                     'official',  'us',            'https://www.federalregister.gov',         'https://www.federalregister.gov/documents/current.rss', 1, 'rss', 1.0),
('CourtListener',                        'official',  'us',            'https://www.courtlistener.com',           NULL, 1, 'api', 1.0),
('FTC Press',                            'official',  'us',            'https://www.ftc.gov/news-events',         'https://www.ftc.gov/news-events/news/press-releases/feed', 1, 'rss', 1.0),
('DOJ Antitrust',                        'official',  'us',            'https://www.justice.gov/atr',             'https://www.justice.gov/atr/rss.xml', 1, 'rss', 1.0),
('EUR-Lex',                              'official',  'eu',            'https://eur-lex.europa.eu',               NULL, 1, 'firecrawl', 1.0),
('European Commission Digital',          'official',  'eu',            'https://digital-strategy.ec.europa.eu',   NULL, 1, 'firecrawl', 1.0),
('UK Parliament Hansard',                'official',  'uk',            'https://hansard.parliament.uk',           NULL, 1, 'firecrawl', 1.0),
('UK ICO',                               'official',  'uk',            'https://ico.org.uk',                      'https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/feed/', 1, 'rss', 1.0),
('Council of Europe AI',                 'official',  'international', 'https://www.coe.int/en/web/artificial-intelligence', NULL, 1, 'firecrawl', 1.0),
('OECD AI Policy Observatory',           'official',  'international', 'https://oecd.ai',                         NULL, 1, 'firecrawl', 1.0),

-- Media (6)
('Reuters — Tech',                       'media',     'global',        'https://www.reuters.com/technology',      'https://www.reutersagency.com/feed/?best-sectors=tech', 1, 'rss', 0.7),
('Financial Times — AI',                 'media',     'global',        'https://www.ft.com/artificial-intelligence', NULL, 1, 'firecrawl', 0.7),
('New York Times — AI',                  'media',     'global',        'https://www.nytimes.com/spotlight/artificial-intelligence', NULL, 1, 'firecrawl', 0.7),
('Bloomberg — AI',                       'media',     'global',        'https://www.bloomberg.com/ai',            NULL, 1, 'firecrawl', 0.7),
('Washington Post — AI',                 'media',     'us',            'https://www.washingtonpost.com/technology/artificial-intelligence', NULL, 1, 'firecrawl', 0.7),
('MIT Technology Review',                'media',     'global',        'https://www.technologyreview.com/topic/artificial-intelligence', 'https://www.technologyreview.com/feed/', 1, 'rss', 0.7),

-- Research (5)
('arXiv cs.CY',                          'research',  'global',        'https://arxiv.org/list/cs.CY/recent',     'http://export.arxiv.org/rss/cs.CY', 1, 'rss', 0.8),
('arXiv cs.AI (safety)',                 'research',  'global',        'https://arxiv.org/list/cs.AI/recent',     'http://export.arxiv.org/rss/cs.AI', 2, 'rss', 0.8),
('Stanford HAI',                         'research',  'global',        'https://hai.stanford.edu',                NULL, 1, 'firecrawl', 0.9),
('AI Now Institute',                     'research',  'global',        'https://ainowinstitute.org',              NULL, 1, 'firecrawl', 0.8),
('Brookings AI Governance',              'research',  'global',        'https://www.brookings.edu/topic/artificial-intelligence', NULL, 1, 'firecrawl', 0.8),

-- Industry (4)
('Anthropic',                            'industry',  'global',        'https://www.anthropic.com/news',          'https://www.anthropic.com/rss.xml', 1, 'rss', 0.5),
('OpenAI',                               'industry',  'global',        'https://openai.com/blog',                 NULL, 1, 'firecrawl', 0.5),
('Google DeepMind',                      'industry',  'global',        'https://deepmind.google/discover',        NULL, 1, 'firecrawl', 0.5),
('Frontier Model Forum',                 'industry',  'global',        'https://www.frontiermodelforum.org',      NULL, 1, 'firecrawl', 0.6),

-- Advocacy (3)
('Center for Humane Technology',         'advocacy',  'global',        'https://www.humanetech.com',              NULL, 1, 'firecrawl', 0.8),
('Electronic Frontier Foundation',       'advocacy',  'us',            'https://www.eff.org/issues/ai',           'https://www.eff.org/rss/updates.xml', 1, 'rss', 0.7),
('Algorithmic Justice League',           'advocacy',  'us',            'https://www.ajl.org',                     NULL, 2, 'firecrawl', 0.7),

-- Capital (2)
('CB Insights Pressroom',                'capital',   'global',        'https://www.cbinsights.com/newsroom',     NULL, 2, 'firecrawl', 0.6),
('Data Center Dynamics',                 'capital',   'global',        'https://www.datacenterdynamics.com',      'https://www.datacenterdynamics.com/rss', 2, 'rss', 0.6)

on conflict do nothing;
