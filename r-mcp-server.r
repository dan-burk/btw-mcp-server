# r-mcp-server.r
# MCP server exposing btw tools plus a custom run_r_code tool

suppressPackageStartupMessages({
  library(btw)
  library(ellmer)
})

run_r_code <- ellmer::tool(
  function(code) {
    tryCatch({
      out <- capture.output({
        result <- eval(parse(text = code), envir = .GlobalEnv)
        print(result)
      })
      paste(out, collapse = "\n")
    }, error = function(e) paste("Error:", e$message))
  },
  name = "run_r_code",
  description = "Run arbitrary R code and return printed + evaluated output",
  code = ellmer::type_string("R code to evaluate")
)

all_tools <- c(btw::btw_tools(), list(run_r_code = run_r_code))

btw::btw_mcp_server(tools = all_tools)