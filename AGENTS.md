# Repository guidance

## Project goal
Build Haeondong as a small, replayable life-and-society simulation. Prioritize player choice, understandable cause and effect, independent NPC lives, and a world that leaves a trace when the player returns.

## Current scope
- Keep the first playable slice focused on one neighborhood, the player, and three distinct NPCs over a simulated week.
- Do not expand to ten NPCs or add broad feature systems before validating the P0 play loop.
- No hosted LLM, Jev service, or local OpenJev model is a required runtime dependency. Rule-based behavior must remain fully playable.
- Planning documents under `docs/` are intentionally local-only and excluded by `.gitignore`; keep them available in the workspace and do not force-add them to Git.

## Implementation conventions
- Keep deterministic simulation/state transitions in `src/simulation.js`; keep DOM, canvas rendering, input, and browser storage in `src/main.js`.
- Avoid new runtime packages unless the P0 needs them and the benefit is clear. The current project runs without installing dependencies.
- Keep saves versioned and resilient to missing or malformed browser storage.
- NPC actions and relationship changes must have a reason grounded in needs, goals, schedules, or remembered events. Avoid sudden personality or relationship swings.
- Treat offline catch-up as bounded simulation, not proof that an always-running server exists.
- Preserve Korean text and test user-visible strings for natural phrasing.
- Keep mobile touch controls usable and do not rely on color alone to communicate state.

## Verification
- Run `npm test` after simulation changes.
- Run `node --check src/main.js` and `node --check src/simulation.js` after JavaScript changes.
- Report browser, device, playtest, and performance checks only when actually performed. Mark unavailable checks as `NOT YET VERIFIED`.

## Git and publishing
- Do not publish local planning files, secrets, save data, or environment files.
- Do not force push, rewrite history, or change repository visibility without explicit direction.
- Write commit messages in Korean. Make a commit at each verified, meaningful milestone rather than batching unrelated work into one large change.
- Push completed milestones to the configured GitHub remote after local verification; preserve remote commits and resolve divergence with a normal merge.
