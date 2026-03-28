# Claude Code — Relay

See `AGENTS.md` for architecture, build commands, and code style.

## Agent Routing

- **Implementation** (features, bugs, refactors) → `swift-developer` agent
- **Build verification / test runs** → `swift-tester` agent (invoked by swift-developer)
- **Broad exploration** → read `AGENTS.md` first, then source files directly

## Active Tooling

- **Format hook**: Write/Edit on `.swift` files auto-runs `swiftlint --fix` then `swift-format`
- **Lint config**: `.swiftlint.yml` in project root
- **Agents**: `.claude/agents/swift-developer.md`, `.claude/agents/swift-tester.md`
- **Xcode MCP**: configured via `xcrun mcpbridge`; default tab `windowtab1` — verify with `XcodeListWindows` if builds fail unexpectedly (tab ID can change between Xcode sessions)

## Workflow Rules

- Never commit or push — user manages git history directly
- Do not modify `AGENTS.md` — it serves other AI tools
- Prefer editing existing files over creating new ones
