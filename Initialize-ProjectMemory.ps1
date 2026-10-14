<#
.SYNOPSIS
Creates a portable shared project-memory scaffold without replacing files.
.EXAMPLE
& ./Initialize-ProjectMemory.ps1 -Path 'C:\Projects\NewProject' -Name 'New Project'
.EXAMPLE
& ./Initialize-ProjectMemory.ps1 -Path 'C:\Projects\ExistingProject' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Path,

    [string] $Name
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
if (Test-Path -LiteralPath $projectRoot -PathType Leaf) {
    throw "Project path is a file: $projectRoot"
}
if ([string]::IsNullOrWhiteSpace($Name)) {
    $Name = [System.IO.Path]::GetFileName($projectRoot.TrimEnd([char[]]'\/'))
}
if ([string]::IsNullOrWhiteSpace($Name) -or $Name -match '[\r\n]') {
    throw 'Supply a nonempty, single-line project name with -Name.'
}
$createdUtc = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')

$entryPoint = @'
# Shared project memory

For project context, prior discussions, decisions, status, or continuing work,
read `project-memory/README.md` and `project-memory/STATE.md`, then retrieve the
relevant discussion, decision, and activity records. Check their freshness
against the working files. Follow the memory maintenance workflow before ending
a substantive project turn, including a discussion that changes no code.

Do not invent missing history or treat a proposal as a user-approved decision.
Keep task-specific instructions and existing project conventions in effect.
'@

$files = [ordered]@{
    'AGENTS.md' = $entryPoint
    'CLAUDE.md' = $entryPoint
    'project-memory/README.md' = @'
# Shared project memory: {{PROJECT_NAME}}

Scaffold version: 1. Created: {{CREATED_UTC}}.

This folder is the durable context shared by assistants working on this project.
It is maintained by participating assistants, not an automatic conversation-sync
service. Each assistant needs access to these same files and must follow this
workflow. Read only the records relevant to the task.

## Finding context

- `STATE.md`: current objective, active work, latest conversation pointers, gaps.
- `PROJECT.md`: purpose, audience, constraints, conventions, module map.
- `DECISIONS.md`: accepted decisions and superseded choices, with sources.
- `discussions/`: topic records, including options and unresolved questions.
- `activity/`: separate dated records of meaningful work and findings.

For a follow-up such as "the second option", read the linked topic and its latest
activity entries. Preserve option labels and ordering. Do not guess the referent
if several conversations fit. State the missing context or ask one precise
question when it materially changes the answer.

## Starting work

1. Read STATE and the relevant linked records. An empty scaffold is not evidence
   that a project has no history. Inspect existing plans and code as needed.
2. Verify material claims against their source and current files. A historical
   test result applies to the recorded revision/configuration, not every later
   working tree. A commit alone does not capture uncommitted edits.
3. For implementation, record the objective, owner/session, and files in STATE's
   active-work table before substantial edits. Inspect other active entries;
   an entry is coordination context, not a lock or proof a process is running.

## Recording a meaningful turn

Before finishing a substantive project response, including design-only work:

1. Add a uniquely named activity file using the format in activity/README.md.
   Record the actual question, findings, recommendation, evidence, next action,
   and gaps. Write useful context rather than copying whole transcripts. Never
   store secrets, private reasoning, or unrelated personal information.
2. Create/update the relevant discussion record when options, explanations, or
   unresolved questions matter for a follow-up. Attribute user statements,
   assistant proposals, and verified observations separately.
3. Add a decision only when acceptance is supported by the user's words or an
   existing delegated decision boundary. Link its source. Mark replaced decisions
   as superseded instead of silently rewriting history.
4. Refresh STATE's concise summary and recent-discussion links. Record a timestamp
   and revision plus relevant dirty files when code evidence is involved. Preserve
   other active work. Mark your completed/interrupted work accurately.
5. Respond normally to the user. A special handoff file is unnecessary. If memory
   could not be saved, say which context remains unsaved.

During long tasks, record meaningful checkpoints so interrupted work can resume.
Skip memory updates for greetings or exchanges that add no project information.
Memory recording does not authorize unrelated work or override a request to stop.

## Concurrent models and conflicting evidence

Use one new activity file per update, with a timestamp and unique suffix. Never
rewrite another model's activity record. Corrections get a new linked record.
Before patching shared summaries, reread them and preserve intervening updates;
avoid replacing whole files. A single writer should consolidate a busy topic.
If simultaneous updates cannot be reconciled, save a separate activity record and
report the conflict. These Markdown files provide no locking or automatic merge.

Keep disagreements and uncertainty visible. Newer prose is not automatically
more reliable than older evidence. STATE and topic summaries are navigation aids;
the linked user instructions, artifacts, and results support their claims.

## Completion language

Distinguish proposed, accepted, implemented, tested, visually reviewed, and
accepted-by-user. Record what a check actually establishes and what remains
unverified. Never convert a historical success or generated summary into a fresh
verification claim.

## First use

Ask an assistant to read this folder and inspect the project, then populate
PROJECT and STATE from available evidence. For a new project, provide the idea
and first desired outcome. For an existing project, provide access to its current
plans/history. Keep unknowns explicit. No history is imported by this scaffold.

To verify continuity, have one assistant record three labelled options and your
choice. In a fresh assistant session with access to this folder, ask why the
second option was or was not chosen. Check the answer against the saved discussion.
'@
    'project-memory/PROJECT.md' = @'
# Project brief: {{PROJECT_NAME}}

Status: unpopulated scaffold. Created: {{CREATED_UTC}}.

- Project purpose / value to users: unknown.
- Intended audience and platform: unknown.
- First usable outcome: unknown.
- Acceptance condition for that outcome: unknown.
- Technical stack and launch commands: unknown.
- Design and visual references: unknown.
- Constraints and explicit exclusions: unknown.
- Relevant existing plans: not inspected.

## Module map

Not inspected. Add module responsibilities and integration points when known.
Keep detailed architecture in existing project documentation and link it here.

## Working conventions

Not established. Link existing conventions rather than duplicating them.
'@
    'project-memory/STATE.md' = @'
# Current state: {{PROJECT_NAME}}

Memory updated: {{CREATED_UTC}} (scaffold creation only).
Code revision / relevant uncommitted changes: not inspected.
Evidence freshness: no project facts or checks have been verified.

## Current objective

Populate shared memory from this project's files and the user's current goal.

## Verified state

Unknown. No implementation or tests were inspected by the initializer.

## Active work

| Objective | Owner/session | Files or subsystem | Last checkpoint | Status |
|---|---|---|---|---|
| No work recorded | Unknown | Unknown | None | Unknown |

## Latest discussions

No discussions imported. Add topic links and a sentence explaining the current
question, recommendation, accepted choice, or unresolved point. Track multiple
active topics separately so follow-ups have an identifiable context.

## Known gaps and conflicts

- Existing project history has not been inspected.
- Cross-model retrieval and memory maintenance have not been validated.

## Next useful action

Read the existing project instructions and plans; fill PROJECT and this summary
using source-backed facts. Ask for the user's initial direction if this is empty.
'@
    'project-memory/DECISIONS.md' = @'
# Accepted decisions

No decisions imported. This does not mean the project has no prior decisions.

Add concise entries using this format; proposals belong in discussions.

```text
ID and date:
Decision:
Status: accepted / superseded
Accepted by and source (user statement or delegated authority):
Reason and relevant alternatives:
Implications:
Supersedes / superseded by:
Related discussion and evidence:
```
'@
    'project-memory/discussions/README.md' = @'
# Topic discussions

Create one descriptive Markdown file per active topic, for example
`api-design.md`. Link it from ../STATE.md. Keep decision-relevant detail and
exact option labels so another model can answer a follow-up without a handoff.

```text
Topic:
Updated (timestamp with timezone):
Participants / source sessions:
User's question and relevant wording:
Context and constraints:
Options (preserve identifiers and ordering):
Assistant recommendation and reasoning summary:
User's response:
Accepted decision, if any (link to DECISIONS):
Open questions:
Evidence and related activity records:
Next useful action:
```

Use concise rationale, not private reasoning or an invented transcript. If an
option list is substantially revised, label the new version and preserve the old
list in its source activity record. Distinguish proposed from implemented work.

With simultaneous writers, add separate activity records first. Reread before
patching this topic; nominate one consolidator if concurrent edits are frequent.
'@
    'project-memory/activity/README.md' = @'
# Activity records

Write one new Markdown file for each meaningful update. Use a timestamp and unique
suffix, for example `20261013T143000Z-codex-a1b2c3d4.md`. Use the actual current time
and a generated suffix. Existing entries are historical evidence; add a linked
correction rather than overwriting them.

```text
Recorded (timestamp with timezone):
Author/model and session identifier, if available:
Topic / objective:
User request or source of authorization:
User statements / accepted decisions:
Assistant proposals (not yet accepted):
Actions, changes, or findings:
Files affected:
Evidence: commands, results, artifact paths, revision and relevant dirty files:
Verification limits / uncertainties:
Next useful action:
Related discussion, decision IDs, or corrected activity entry:
```

For a discussion-only update, files and tests may be "not applicable". Preserve
the actual options and conclusions so the discussion remains recoverable even
if the current summary later changes. Avoid duplicating sensitive transcripts.
'@
}

# Validate all destinations before creating anything. Existing regular files are
# always preserved; directory/file collisions fail explicitly.
foreach ($relative in $files.Keys) {
    $target = Join-Path $projectRoot $relative
    if (Test-Path -LiteralPath $target -PathType Container) {
        throw "Expected a file but found a directory: $target"
    }
    $parent = Split-Path -Parent $target
    while ($parent -and $parent.Length -ge $projectRoot.Length) {
        if (Test-Path -LiteralPath $parent -PathType Leaf) {
            throw "Expected a directory but found a file: $parent"
        }
        $parent = Split-Path -Parent $parent
    }
}

$created = 0
$preserved = 0
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($relative in $files.Keys) {
    $target = Join-Path $projectRoot $relative
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        $preserved++
        Write-Output "Preserved: $relative"
        continue
    }
    if ($PSCmdlet.ShouldProcess($target, 'Create shared project-memory file')) {
        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        # CreateNew also prevents overwriting a file created after the preflight.
        $stream = [System.IO.File]::Open($target, [System.IO.FileMode]::CreateNew,
            [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        try {
            $content = $files[$relative].Replace('{{PROJECT_NAME}}', $Name).Replace('{{CREATED_UTC}}', $createdUtc)
            $bytes = $utf8.GetBytes($content + [Environment]::NewLine)
            $stream.Write($bytes, 0, $bytes.Length)
        }
        finally { $stream.Dispose() }
        $created++
        Write-Output "Created: $relative"
    }
}

foreach ($entry in @('AGENTS.md', 'CLAUDE.md')) {
    $target = Join-Path $projectRoot $entry
    if ((Test-Path -LiteralPath $target -PathType Leaf) -and
        -not ([System.IO.File]::ReadAllText($target).Contains('project-memory/README.md'))) {
        Write-Warning "$entry was preserved. Integrate the shared-memory instructions into it before relying on automatic discovery. Start with: Read project-memory/README.md and project-memory/STATE.md for project continuity."
    }
}
Write-Output "Project: $projectRoot"
Write-Output "Created $created files; preserved $preserved existing files."
if (-not $WhatIfPreference) {
    Write-Output 'Next: ask your assistant to read project-memory/README.md and populate the memory from the project and your current goal.'
    Write-Output 'This command creates the scaffold; it does not import chats, install hooks, start a service, or verify cross-model continuity.'
}
