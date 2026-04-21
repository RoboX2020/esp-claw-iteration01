-- QQ send-image demo.
-- Optional args:
--   chat_id: target QQ chat, e.g. "c2c:<openid>" or "group:<group_openid>"
--   path:    local image path for qq_send_image
--   caption: optional caption for qq_send_image
-- If chat_id is omitted, capability.call() may inherit it from the current QQ runtime context.
local capability = require("capability")
local storage = require("storage")

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
    local image_path = string_arg("path", "/fatfs/static/ESP-Claw.png")
    local payload = {
        caption = string_arg("caption", "image from lua qq capability demo"),
    }
    local ok, out, err

    if not storage.exists(image_path) then
        error("[qq_cap_send_image] file does not exist: " .. tostring(image_path))
    end

    payload.path = image_path
    if chat_id then
        payload.chat_id = chat_id
    end

    print("[qq_cap_send_image] sending QQ image...")
    ok, out, err = capability.call("qq_send_image", payload, build_call_opts())
    print(string.format(
        "[qq_cap_send_image] result ok=%s out=%s err=%s",
        tostring(ok), tostring(out), tostring(err)))

    if not ok then
        error(string.format("qq_send_image failed: %s", tostring(err or out)))
    end

    print("[qq_cap_send_image] done")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
    error(err)
end
