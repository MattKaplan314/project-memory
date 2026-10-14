# Usage guide

This guide walks through setting up shared project memory, using it day to day,
and moving work between assistants.

- [1. Install](#1-install)
- [2. Create the scaffold](#2-create-the-scaffold)
- [3. Populate the memory](#3-populate-the-memory)
- [4. Day-to-day use](#4-day-to-day-use)
- [5. Switching assistants](#5-switching-assistants)
- [6. Test that continuity works](#6-test-that-continuity-works)
- [7. Projects that already have AGENTS.md or CLAUDE.md](#7-projects-that-already-have-agentsmd-or-claudemd)
- [8. Git, teams, and multiple machines](#8-git-teams-and-multiple-machines)
- [9. What each file is for](#9-what-each-file-is-for)
- [10. Troubleshooting](#10-troubleshooting)
- [FAQ](#faq)

---

## 1. Install

You only need `Initialize-ProjectMemory.ps1`. It has no dependencies and can
live anywhere: this repo, a tools folder, or a copy inside each project.

```bash
git clone https://github.com/YOUR-USERNAME/project-memory.git
```

You can also download the script file directly from GitHub.

**Supported shells:** PowerShell 7+ (`pwsh`) or Windows PowerShell 5.1
(`powershell`).

> **Windows note:** If you downloaded the file through a browser and PowerShell
> says it "is not digitally signed" or that running scripts is disabled, unblock
> the file once:
>
> ```powershell
> Unblock-File ./Initialize-ProjectMemory.ps1
> ```
>
> If scripts are disabled entirely, you can allow them for the current session
> only, without changing any machine setting:
>
> ```powershell
> powershell -ExecutionPolicy Bypass -File ./Initialize-ProjectMemory.ps1 -Path 'C:\Projects\MyGame'
> ```

## 2. Create the scaffold

```powershell
& ./Initialize-ProjectMemory.ps1 -Path <project folder> [-Name <display name>] [-WhatIf]
```

| Parameter | Required | Description |
|---|---|---|
| `-Path` | Yes | Project folder. It can be new (it will be created) or existing. Relative paths resolve from your current location. |
| `-Name` | No | Display name written into the memory files. Defaults to the folder name. Must be a single line. |
| `-WhatIf` | No | Preview: lists what would be created and writes nothing. |

**Examples**

```powershell
# New project
& ./Initialize-ProjectMemory.ps1 -Path 'C:\Projects\NewGame' -Name 'New Game'

# Existing project, preview first
& ./Initialize-ProjectMemory.ps1 -Path 'C:\Projects\ExistingApp' -WhatIf
& ./Initialize-ProjectMemory.ps1 -Path 'C:\Projects\ExistingApp'

# macOS / Linux with PowerShell 7
pwsh ./Initialize-ProjectMemory.ps1 -Path ~/code/my-app
```

**Output**

```text
Created: AGENTS.md
Created: CLAUDE.md
Created: project-memory/README.md
...
Project: C:\Projects\NewGame
Created 8 files; preserved 0 existing files.
```

If a file already exists, the output says `Preserved:` and the file is not
touched. Running the script again is always safe. It only creates files that
are missing.

> The script is **not an upgrade tool.** If a newer version of this repo changes
> the templates, rerunning it won't update files you already have.

## 3. Populate the memory

The fresh scaffold intentionally says "unknown" everywhere. Have an assistant
fill it in from real evidence. Open the project in your assistant and paste:

> Read project-memory/README.md and follow its workflow. Inspect this project's
> existing instructions, plans, and code, then populate its shared memory.
> Record what is established, what is only proposed, and what remains unknown.
> Include our current discussion and next useful step. My current goal is:
> **[your goal]**.

- **New, empty project:** describe your idea and the first outcome you want. The
  assistant has no history to import, so don't expect it to find any.
- **Existing project:** give the assistant access to your current plans, docs,
  and code. It can only record what it can actually see. It shouldn't claim to
  have read conversations it has no access to.

Afterwards, skim `PROJECT.md` and `STATE.md`. Correct anything wrong. These two
files are what every future session reads first.

## 4. Day-to-day use

Once the entry points are in place, assistants that read `AGENTS.md` or
`CLAUDE.md` find the memory on their own. Work normally. Following the
workflow in `project-memory/README.md`, the assistant will:

1. **Before work:** read `STATE.md` and the relevant discussion and activity
   records, then check them against the current files.
2. **Before big edits:** add a row to the *Active work* table in `STATE.md`
   so other sessions can see what's in progress.
3. **Before finishing a substantive reply,** including design discussions that
   change no code:
   - write a new file in `activity/` describing what was asked, found, and
     recommended
   - create or update a topic file in `discussions/` when options or open
     questions matter
   - add an entry to `DECISIONS.md` **only** if you actually accepted something
   - refresh the summary in `STATE.md`

Greetings and small talk are skipped. If an assistant couldn't save memory, it
should tell you what is still unsaved.

**Tips**

- Be explicit when you decide something: *"Let's go with option B."* That is
  the evidence an assistant needs to record it as an accepted decision instead
  of a proposal.
- If an assistant forgets to update memory, ask it to: *"Record this
  discussion in project memory."*
- For long tasks, ask for checkpoints so the work can resume if it's
  interrupted.

## 5. Switching assistants

Open the same project folder in another tool, or start a fresh session, and say:

> Read the project's shared memory, including the latest discussion records,
> and continue with **[your follow-up]**.

Follow-ups that refer back to earlier context work too, for example *"Why didn't
we pick the second option?"* Discussion records keep the original option labels
and their order for this purpose. If more than one topic could match, the
assistant should ask which one you mean rather than guess.

## 6. Test that continuity works

Before relying on the setup, run this two-session check:

1. **Session A:** ask an assistant to propose three labelled options for some
   real design question. Pick one and say why. Confirm it recorded the
   discussion.
2. **Session B:** use a fresh session, ideally a *different* model. Ask: *"Why
   was the second option not chosen?"*
3. Check the answer against `project-memory/discussions/`. It should:
   - identify the right option by its label
   - state *your* reason, not invent one
   - keep what you decided separate from what the assistant recommended

If it fails, look at what was actually saved. Most problems come from the first
session not recording enough detail.

## 7. Projects that already have AGENTS.md or CLAUDE.md

The script won't modify your existing instruction files. If one of them doesn't
mention `project-memory/README.md`, you'll see a warning like:

```text
WARNING: CLAUDE.md was preserved. Integrate the shared-memory instructions into it ...
```

Until you integrate it, that assistant won't find the memory on its own. Either
add these lines to the file yourself:

```markdown
# Shared project memory

For project context, prior discussions, decisions, status, or continuing work,
read `project-memory/README.md` and `project-memory/STATE.md`, then retrieve the
relevant discussion, decision, and activity records. Follow the memory
maintenance workflow before ending a substantive project turn.
```

Or ask your assistant: *"Merge the shared-memory instructions from
project-memory/README.md into CLAUDE.md, keeping all existing conventions."*

## 8. Git, teams, and multiple machines

Memory only reaches assistants that can see the same files.

- **One machine, one folder:** nothing extra to do.
- **Multiple machines, worktrees, or teammates:** commit `project-memory/`,
  `AGENTS.md`, and `CLAUDE.md` to your repo. Uncommitted updates are only
  visible on the machine where they were made.
- **Merge conflicts:** these are rare because each update is a *new* file in
  `activity/`. When `STATE.md` or a discussion file conflicts, keep both sides'
  information. The workflow tells assistants to reread shared files before
  patching them and never to rewrite another session's activity record.
- **Busy topics:** if several sessions edit the same discussion, pick one
  session to consolidate it.

> **Privacy:** The workflow tells assistants not to store secrets or unrelated
> personal information, but **review `project-memory/` before you push it to a
> public repository.**

## 9. What each file is for

| File | Purpose | Edited how |
|---|---|---|
| `AGENTS.md`, `CLAUDE.md` | Tell assistants the memory exists and where to start | Rarely |
| `project-memory/README.md` | The full workflow every assistant follows | Rarely; customize to taste |
| `STATE.md` | Current objective, verified state, active work, latest discussion links, gaps, next step | Patched every meaningful turn |
| `PROJECT.md` | Purpose, audience, stack, constraints, module map, conventions | When the project's basics change |
| `DECISIONS.md` | Accepted decisions with source, reasons, and supersession links | Append only; old decisions are marked superseded, not deleted |
| `discussions/*.md` | One file per topic: question, options, recommendation, your response, open questions | Updated as the topic evolves |
| `activity/*.md` | One new file per meaningful update, e.g. `20261013T143000Z-claude-a1b2c3d4.md` | Never edited after writing; corrections get a new linked file |

Each folder's own `README.md` contains the exact template for its records.

## 10. Troubleshooting

| Symptom | Fix |
|---|---|
| *"running scripts is disabled on this system"* | See the [Windows note](#1-install). Use `Unblock-File` or `-ExecutionPolicy Bypass` for that one run. |
| *"Expected a file but found a directory"* or *"Expected a directory but found a file"* | A file or folder in your project has the same name as part of the scaffold, such as a *file* called `project-memory`. Rename it and rerun. Nothing was written. |
| *"Supply a nonempty, single-line project name"* | The folder name couldn't be used (for example a drive root). Pass `-Name 'Something'`. |
| Assistant ignores the memory | Check that the entry file it reads (`AGENTS.md` / `CLAUDE.md`) mentions `project-memory/README.md`. See [section 7](#7-projects-that-already-have-agentsmd-or-claudemd). You can always point it there directly. |
| Assistant records its own suggestion as a decision | Correct it: ask for a new activity record and a fix to `DECISIONS.md`. Be explicit when you accept something. |
| Memory is stale | Ask the assistant to check `STATE.md` against the current code and record what changed. |

## FAQ

**Does this work with my assistant?**
It works with any assistant that can read and write files in your project. It
finds the memory automatically if it reads `AGENTS.md` or `CLAUDE.md` at
startup. Otherwise, start each session by telling it to read
`project-memory/README.md`.

**Does it import my old chat history?**
No. It can only hold what an assistant writes into it. For an existing project,
the assistant populates it from the files it can see.

**Does it run in the background or install hooks?**
No. It is just Markdown files plus a convention. The script runs once and exits.

**Can I edit the memory files myself?**
Yes. They're plain Markdown. Keep the formats in each folder's `README.md`, so
assistants can keep parsing them, and mark your edits as yours.

**Can I customize the workflow?**
Yes. Edit `project-memory/README.md` in your project. To change the defaults
for every new project, edit the templates inside `Initialize-ProjectMemory.ps1`.
