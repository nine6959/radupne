# Ponytail skills

The **ponytail** skill set — a lazy senior developer that writes the minimal
code that actually works. Reuse before custom code, stdlib before dependencies,
one line before fifty.

Source: <https://github.com/DietrichGebert/ponytail> (MIT).

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `ponytail` | `/ponytail [lite\|full\|ultra]` | Lazy mode itself: simplest solution that works. |
| `ponytail-review` | `/ponytail-review` | Reviews a diff for over-engineering, one line per cut. |
| `ponytail-audit` | `/ponytail-audit` | Whole-repo over-engineering audit, ranked. |
| `ponytail-debt` | `/ponytail-debt` | Harvests `ponytail:` shortcut comments into a debt ledger. |
| `ponytail-gain` | `/ponytail-gain` | Measured-impact scoreboard: less code, less cost, more speed. |
| `ponytail-help` | `/ponytail-help` | Quick-reference card for all modes and commands. |

## Using these as Claude Code skills

To activate them in Claude Code, copy a skill into your project's skill path:

```bash
cp -r skills/ponytail .claude/skills/ponytail
```

Then invoke it with `/ponytail`. Repeat for any of the other skills above.
