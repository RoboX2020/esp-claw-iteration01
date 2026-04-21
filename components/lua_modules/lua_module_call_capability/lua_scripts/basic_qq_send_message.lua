-- QQ send-message demo.
-- Optional args:
--   chat_id: target QQ chat, e.g. "c2c:<openid>" or "group:<group_openid>"
--   message: text to send with qq_send_message
-- If chat_id is omitted, capability.call() may inherit it from the current QQ runtime context.
local capability = require("capability")

local a = type(args) == "table" and args or {}

local function string_arg(key, default)
    local value = a[key]
    if type(value) == "string" and value ~= "" then
        return value
    end
    return default
end

local function build_call_opts()
    local opts = {
        channel = "qq",
        source_cap = "lua_builtin_demo",
    }

    if type(a.session_id) == "string" and a.session_id ~= "" then
        opts.session_id = a.session_id
    end
    if type(a.chat_id) == "string" and a.chat_id ~= "" then
        opts.chat_id = a.chat_id
    end

    return opts
end

local function run()
    local chat_id = string_arg("chat_id", nil)
    local payload = {
        message = string_arg("message", "hello from lua qq capability demo"),
    }
    local ok, out, err

    if chat_id then
        payload.chat_id = chat_id
    end

    print("[qq_cap_send_message] sending QQ message...")
    ok, out, err = capability.call("qq_send_message", payload, build_call_opts())
    print(string.format(
        "[qq_cap_send_message] result ok=%s out=%s err=%s",
        tostring(ok), tostring(out), tostring(err)))

    if not ok then
        error(string.format("qq_send_message failed: %s", tostring(err or out)))
    end

    print("[qq_cap_send_message] done")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
    error(err)
end
