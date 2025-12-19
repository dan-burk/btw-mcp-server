# R MCP Server (Dockerized)

Exposes the btw MCP server and custom R tools via Docker for isolated, secure execution.

## Build

**ARM64 image:**
```bash
docker build -t btw-mcp-server -f ARM64/Dockerfile .
```

**AMD64 image:**
```bash
docker build -t btw-mcp-server -f AMD64/Dockerfile .
```

*Note: The ARM64 and AMD64 Dockerfiles are currently identical (Docker auto-detects the host architecture). They are split out for potential future infrastructure changes (e.g., architecture-specific package repositories).*

**Note:** You must register this MCP server with Claude Desktop and/or Claude Code (CLI) to use it. See private repo `r-playground-using-mcp` for examples.