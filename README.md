# project-memory

**Shared, file-based memory for AI coding assistants.** Give Claude, Codex, and
any other assistant the same notebook for your project, so a conversation
started in one can be picked up in another. You no longer have to re-explain
what you decided, why, and what comes next.

```powershell
./Initialize-ProjectMemory.ps1 -Path ./my-project -Name 'My Project'
```

---

## The problem

Every assistant session starts from zero. When you switch models, open a new
chat, or come back next week, the context is gone: which options you weighed,
which one *you* picked (versus the one the AI suggested), what was tested, and
what's still unknown. Each tool also has its own private chat history, and
none of them can read the others'.

## The idea

Store the project's memory **inside the project**, as plain Markdown files that
any assistant can read and update. A single PowerShell script creates the
scaffold. It also creates small `AGENTS.md` and `CLAUDE.md` entry points that
tell assistants where the memory is and how to maintain it.

```text
my-project/
├── AGENTS.md                  ← entry point for assistants that read AGENTS.md
├── CLAUDE.md                  ← entry point for Claude Code
└── project-memory/
    ├── README.md              ← the workflow every assistant follows
    ├── STATE.md               ← current objective, active work, latest discussions
    ├── PROJECT.md             ← brief, constraints, conventions, module map
    ├── DECISIONS.md           ← accepted decisions (and superseded ones)
    ├── discussions/           ← one file per topic: options, recommendations, open questions
    └── activity/              ← one new dated file per meaningful update
```

It's built around a few rules:

- **Proposals aren't decisions.** A recommendation from an assistant stays a
  proposal until you accept it. Decisions record who accepted them and where.
- **Unknowns stay explicit.** The scaffold starts out saying "unknown" and "not
  inspected". An empty file never stands in for "nothing happened".
- **History is append-only.** Each update is a new activity file, so multiple
  assistants can work without overwriting each other's records.
- **Verification language is precise.** The records keep *proposed*, *implemented*,
  *tested*, and *accepted by user* separate. An old test pass is not a fresh one.

## Quick start

1. **Get the script.** Clone this repo or download
   [`Initialize-ProjectMemory.ps1`](Initialize-ProjectMemory.ps1). It's a single
   self-contained file.

   ```bash
   git clone https://github.com/YOUR-USERNAME/project-memory.git
   ```

2. **Run it on your project** (new or existing folder):

   ```powershell
   & ./Initialize-ProjectMemory.ps1 -Path 'C:\Projects\MyGame' -Name 'My Game'
   ```

   Add `-WhatIf` to preview without writing anything.

3. **Ask your assistant to fill it in.** Open the project in your assistant and
   paste:

   > Read project-memory/README.md and follow its workflow. Inspect this
   > project's existing instructions, plans, and code, then populate its shared
   > memory. Record what is established, what is only proposed, and what remains
   > unknown. My current goal is: **[your goal]**.

4. **Switch assistants whenever you like.** In a different tool or a fresh session:

   > Read the project's shared memory, including the latest discussion records,
   > and continue with **[your follow-up]**.

The full walkthrough, including existing projects, teams, Git, and
troubleshooting, is in **[the usage guide](docs/GUIDE.md)**.

## Safe to run

The initializer **never overwrites or modifies an existing file.**

- Existing files are left alone byte for byte, including your own `AGENTS.md` or
  `CLAUDE.md`. If an existing entry point doesn't mention the memory, the script
  prints a warning so you can merge the instructions in yourself.
- Every destination path is checked before the first file is written. A
  file/folder name collision fails the run without creating anything.
- Running it again only fills in missing scaffold files.
- `-WhatIf` shows exactly what would be created.

## Requirements

- **PowerShell 7+** (Windows, macOS, Linux) or **Windows PowerShell 5.1**
- An AI assistant that can read and write files in your project folder

## What it is not

This is a **convention plus a scaffold**, not a sync service. It doesn't
import existing chat histories, install hooks, run in the background, or
guarantee that a model follows the workflow. It works when the assistants you
use can see the same files and are told to follow `project-memory/README.md`.
The generated entry points handle that for tools that read `AGENTS.md` or
`CLAUDE.md`.

To share memory across machines, commit the `project-memory/` folder to Git.
Review it before you push it anywhere public.

## Testing

```powershell
& ./Test-ProjectMemory.ps1 -ScratchPath 'C:\Temp\scratch'
```

The test script covers preview mode, fresh creation, byte-for-byte preservation
on rerun, existing-instruction warnings, path collisions, and invalid names.
All checks pass on PowerShell 7 and on Windows PowerShell 5.1. It hasn't been
tested on macOS or Linux.

## Contributing

Issues and pull requests are welcome, especially reports of how different
assistants handle the workflow. If you change the templates, please run the
test script before you submit.

## License

[MIT](LICENSE)
