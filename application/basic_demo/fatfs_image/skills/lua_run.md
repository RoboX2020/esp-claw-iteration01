# Lua Script Execution

Use this skill when the user wants to see existing Lua scripts, run one, or inspect async execution jobs.

## Current Managed Scripts
At the moment the image includes:
- `hello.lua`

Current script content summary:
- `hello.lua`: prints `hello lua!`

## Listing Scripts
Use `lua_list_scripts` to inspect the current managed script set.
- Optional input: `prefix`
- Example: list everything with `{}` or filter a subdirectory with `{"prefix":"effects"}`

## Running a Script Synchronously
Use `lua_run_script` when the user wants immediate output.
- Required: `path`
- Optional: `args`, `timeout_ms`
- Prefer relative paths such as `hello.lua`

Example:
```json
{
  "path": "hello.lua"
}
```

If the script expects structured inputs, pass them through `args`. The runtime exposes them to Lua as the global `args`.

## Running a Script Asynchronously
Use `lua_run_script_async` for long-running or continuous scripts.
- Required: `path`
- Optional: `args`, `timeout_ms`
- Returns a `job_id`

After starting an async script:
- Use `lua_list_async_jobs` to see all jobs or filter by status
- Use `lua_get_async_job` with the returned `job_id` to inspect one job

## Execution Notes
- Paths must resolve under `/spiffs/lua` and end with `.lua`.
- Prefer `lua_run_script` for short scripts that should finish and return text.
- Prefer `lua_run_script_async` for loops, animations, watchers, or long-running device behaviors.
- If the user asks to run a script that does not exist yet, switch to the Lua authoring flow first.
