---
name: feature-flag-hygiene
description: "Audit feature flags for staleness: flags defaulted to true that can be made permanent, and flags that may no longer be needed. Use when asked to review feature flags, clean up flags, audit flag hygiene, or check for stale/abandoned flags."
---

# Feature Flag Hygiene Skill

## What This Skill Does

1. Finds all feature flag definitions in the codebase
2. Uses `git log` to determine when each flag was introduced
3. Categorises each flag by staleness and risk
4. Asks the user what to do with each stale flag
5. Optionally makes the changes (promotes defaults, removes flag gates, deletes config entries)

---

## Step 1 — Locate the Flag Config File

Search for the file that defines feature flag defaults. Common patterns:

| Framework | File to look for |
|---|---|
| OpenFeature | `flagConfig.ts`, `open-feature/config.*` |
| LaunchDarkly SDK | `src/config/featureFlags.*`, `src/flags.*` |
| Environment-based (BE) | `.env`, `settings.py`, `application.yml` — look for `FEATURE_*` or `IS_*_ENABLED` vars |
| Custom | search for `IS_.*_ENABLED` constants or a dict/map of `{ FLAG_NAME: boolean }` |

Read the full file and extract every flag name and its default value.

---

## Step 2 — Determine Flag Age Using Git

For each flag, find when it was first committed:

```bash
git log --all --follow -S "FLAG_NAME" --format="%ad %H %s" --date=short -- path/to/flagConfig | tail -1
```

This gives the **oldest commit** that introduced that flag name.

Also run to see the most recent change:
```bash
git log --all --follow -S "FLAG_NAME" --format="%ad %H %s" --date=short -- path/to/flagConfig | head -1
```

Build a table:

| Flag | Default | First seen | Last changed | Age (days) |
|---|---|---|---|---|
| IS_NEW_DESIGN_SYSTEM_ENABLED | true | 2024-01-10 | 2024-01-10 | 553 |
| IS_SIGNAL_AGENT_CHAT_ENABLED | false | 2025-11-01 | 2025-11-01 | 93 |

---

## Step 3 — Categorise Each Flag

Apply these rules:

| Category | Criteria | What to ask |
|---|---|---|
| **Stale-on** | Default `true`, age > 28 days | "This feature has been fully on for N days. Should the flag gate be removed and the code made permanent?" |
| **Stale-off** | Default `false`, age > 28 days | "This flag has been off for N days. Was the feature abandoned or is it still in rollout?" |
| **Recently promoted** | Default `true`, age < 28 days | Keep — still in rollout observation window |
| **Active rollout** | Default `false`, age < 28 days | Keep — not yet mature |

The staleness threshold is **28 days (4 weeks)**. A flag enabled in production for more than 4 weeks with no issues is considered stable and ready for cleanup. Ask the user if they want to adjust it before analysing.

---

## Step 4 — Find All Usages in the Codebase

For each stale flag, find every reference so the user knows the blast radius:

```bash
grep -r "FLAG_NAME" src/ -l
```

Adjust the path and file extensions to match the project's language (e.g., `--include="*.ts"`, `--include="*.py"`).

Also count conditional guards:
```bash
grep -r "FLAG_NAME" src/ | grep -c "if\|&&\|?\|"
```

Report: "IS_NEW_DESIGN_SYSTEM_ENABLED is referenced in 8 files and guards 3 conditional branches."

---

## Step 5 — Ask the User, Flag by Flag

For each stale flag, present the findings and ask:

**Stale-on flag:**
> `IS_NEW_DESIGN_SYSTEM_ENABLED` has been defaulted `true` for 553 days and is referenced in 8 files.
> Options:
> 1. **Remove the flag** — delete all `IS_NEW_DESIGN_SYSTEM_ENABLED` guards, keep the `true` branch as permanent code, remove the flag from config
> 2. **Keep for now** — no change
> 3. **Skip** — move to the next flag

**Stale-off flag:**
> `IS_SIGNAL_AGENT_CHAT_ENABLED` has been defaulted `false` for 93 days and is referenced in 3 files.
> Options:
> 1. **Promote to true** — change the default to `true` (begins rollout)
> 2. **Delete the feature** — remove all conditional branches that use the `false` path, delete the flag
> 3. **Keep as-is** — no change
> 4. **Skip** — move to the next flag

---

## Step 6 — Apply Changes (if requested)

### Removing a stale-on flag

1. For each file that references the flag:
   - Find `if (IS_FLAG_ENABLED) { ... } else { ... }` → keep the `if`-branch body, delete the `else`-branch
   - Find `IS_FLAG_ENABLED && <expr>` → replace with `<expr>`
   - Find `IS_FLAG_ENABLED ? valueA : valueB` → replace with `valueA`
   - For backend: remove guard blocks, environment variable reads, and any middleware/decorator that checks the flag
2. Delete the flag entry from the config file
3. If the flag is typed (e.g., TypeScript union, Python enum), remove it from the type/enum definition
4. Run the type-checker or linter to catch any remaining references

### Promoting a stale-off flag default to `true`

1. Change the default in the config file: `IS_FLAG: false` → `IS_FLAG: true`
2. If the flag is managed by an external service (e.g., LaunchDarkly, Unleash, Azure App Configuration), note that the production default also needs updating in that service's console

### Deleting an abandoned stale-off flag

1. Same as stale-on removal but keep the **`false`-branch** (the non-flagged behaviour) instead of the `true` branch
2. Delete the flag from config

---

## Step 7 — Summary Report

After applying all changes, output a summary:

```
Feature Flag Hygiene Summary
============================
Removed (made permanent):
  - IS_NEW_DESIGN_SYSTEM_ENABLED   (553 days old, 8 files cleaned)
  - IS_MVD_MORE_BEAUTIFUL_ENABLED  (420 days old, 5 files cleaned)

Promoted default to true:
  - IS_PART_HISTORY_COMPONENT_PAGINATION_ENABLED  (default changed)

Kept (user chose to skip):
  - IS_SIGNAL_AGENT_CHAT_ENABLED
  - IS_VIEWER_USER_ROLE_ENABLED

No action needed (< 28 days old):
  - (none)
```

Remind the user: **If any flag is controlled by an external feature-flag service (LaunchDarkly, Unleash, Azure App Configuration, etc.), coordinate the flag archive/deletion in that service's console after removing code references.**

---

## Notes for Common Patterns

### Frontend (React / OpenFeature)

- Flag config is typically in a central file imported at the app boundary
- Consumption is usually via a hook (e.g., `useFeatureFlags()`) or context
- Flag names are destructured: `const { IS_MY_FLAG_ENABLED } = useFeatureFlags();`
- Look for flag sections split by targeting scope (global, per-customer, targeted)

### Backend (Node.js / Python)

- Flags are commonly read from environment variables, a config service, or a flags module
- Guard patterns: `if feature_enabled("FLAG_NAME"):`, `if (flagClient.variation("FLAG_NAME", false)) {`
- Check middleware, decorators, and route guards in addition to inline conditionals
- Environment-based flags may require `.env` or infrastructure changes in addition to code removal
