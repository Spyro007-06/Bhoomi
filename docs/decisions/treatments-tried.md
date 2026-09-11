# Decision needed: where does `CaseBundle.treatments_tried` come from?

## The gap

`docs/API_CONTRACT.md` §12 specifies a `treatments_tried` array on the case
bundle (example: `["Field drained 48h", "Nitrogen withheld"]`) and PRD F12
lists "treatments already tried" as required bundle content. No table in
`backend/app/core/models.py` stores it, so `app/intelligence/bundle.py`
(`compile_bundle()`) returns `[]` unconditionally — an honest empty list, not
a fabricated one, but not the feature either.

Two existing tables look like they might hold this and don't:

- `Confirmation.treatment` (`backend/app/core/models.py:741`) — the
  **agronomist's** post-hoc instruction after reviewing the case
  ("Tricyclazole per label; drain and dry 48h"), written once, at
  confirm time. It documents what the expert told the farmer to do next,
  not what the farmer already did before escalating.
- `FollowUp.response` (`backend/app/core/models.py:629`) — a three-value
  enum (`improved | no_change | got_worse`), not free text, and it is
  captured *after* an advisory already exists (`FOLLOWUP_DUE_DAYS` later),
  not before or during escalation.

Neither captures a farmer's own account of what they tried before the
system got involved.

## Where this would naturally be captured

The only farmer-facing points in the current flow where this information
could be volunteered:

- `POST /farms/{id}/diagnose` (`routers/diagnose.py`) — `description_text` /
  `description_asset_id` already exist for the farmer's free-text problem
  description; "what have you tried" could ride alongside it, or be its
  own optional field.
- `POST /problems/{id}/clarify` (`routers/clarify.py`) — the farmer is
  already answering a structured question here; a free-text aside is a
  bigger scope change to a schema that is otherwise strictly yes/no/unknown.
- A dedicated new capture, either its own endpoint or a field folded into
  escalation (`services/escalation.py`'s `escalate()`), at the moment a case
  is actually created — this is the point closest to "why is this becoming
  a case" and the most natural place for it, since not-yet-escalated
  problems don't get a bundle at all.

## Options

**A. New field on `Problem` (or a new one-row-per-problem table), farmer-writable free text, captured at diagnose/escalate time.**
- Schema: additive (`nullable` text column, or a new table FK'd to
  `problem`). No frozen contract touched — `Problem` is not part of C1/C2/C3.
- Routes: `DiagnoseIn` gains a field, or `escalate()` accepts one from the
  caller. `bundle.py` reads it directly.
- Owners (docs/DESIGN.md §3): schema + routing change is `core/`
  (Shreekumar); reading it into the bundle stays Thaariha's.
- Frozen contracts: none change. `DiagnoseIn` is `core/schemas/`, not a
  frozen contract.
- Captures at most one entry — matches the PRD's singular framing loosely
  but the API_CONTRACT example shows an array of two, so this likely
  under-serves the spec.

**B. New table, `treatment_action` (problem_id FK, farmer text, `created_at`), farmer can add entries over time — via voice or the app, not just at diagnose.**
- Schema: additive, new table.
- Routes: needs a new endpoint (`POST /problems/{id}/treatments`?) or an
  extension of an existing one that appends rather than replaces.
- Owners: table + endpoint is `core/` (Shreekumar); `voice/`
  (Shruthi) if this is meant to be voice-capturable per F9's scope note
  ("onboarding, Doubt Doctor Q&A, advisory read-out" — treatments-tried
  is not currently in that list, so F9's scope may need to grow too);
  bundle read stays Thaariha's.
- Frozen contracts: none change if the new endpoint is additive.
- Matches the plural example in API_CONTRACT §12 directly and is the only
  option that lets a farmer add a second entry after the first without
  overwriting it.

**C. Derive it from `FollowUp` and `Confirmation` instead of capturing anything new.**
- Schema: none.
- Routes: none.
- Owners: none — this is entirely Thaariha's, inside `bundle.py`.
- Frozen contracts: none change.
- Does not actually answer the PRD's requirement: both source rows
  postdate escalation (`Confirmation.treatment` is the agronomist's
  instruction, not the farmer's prior action; `FollowUp` fires after
  advisory). This option ships a bundle field that still reads empty on
  every case that reaches an agronomist through the escalate path, i.e.
  most of them — it doesn't close the gap, it just stops flagging it.

## The question for the team

Does `treatments_tried` need to support **multiple, incrementally-added
entries** (option B — matches the API_CONTRACT example, needs a new table
and endpoint) or is **one free-text field captured at diagnose/escalate
time** (option A — cheaper, additive-only, no new endpoint) an acceptable
reading of the PRD's "treatments already tried"? Option C is listed for
completeness but does not satisfy the requirement and should not be picked
by default just because it needs no schema change.

Whoever decides also decides whether this belongs in F9's voice-capturable
scope, since a farmer describing what they already tried is exactly the
kind of input F9's onboarding/Doubt-Doctor/advisory list does not currently
cover.
