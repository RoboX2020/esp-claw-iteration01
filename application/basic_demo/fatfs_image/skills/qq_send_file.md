# QQ File Return

Use this skill when the user wants the device to send a local file or image back to a QQ chat.

## When to use
- The user asks to send back a file, attachment, image, photo, log, or generated output through QQ.
- The target conversation is already the active QQ chat, or the user provides an explicit QQ `chat_id`.

## Available tools
- `list_dir`: inspect device storage and confirm the file path
- `read_file`: inspect small text files before sending when needed
- `cap_cli`: run `cap call qq_send_image '<json>'` or `cap call qq_send_file '<json>'`

## Path guidance
- Prefer real local paths already stored on the device.
- Common roots in this demo are `/spiffs`, `/spiffs/qq`, `/spiffs/lua`, or other application-managed storage paths.
- Use `list_dir` first if the exact file path is unknown.
- Use `read_file` only for small text inspection, not for binary payloads.

## Sending rules
- Use `qq_send_image` for image files such as `.jpg`, `.jpeg`, `.png`, `.gif`, or `.webp`.
- Use `qq_send_file` for non-image files such as `.txt`, `.json`, `.log`, `.csv`, or archives.
- Execute the chosen QQ capability through `cap_cli` as `cap call <cap_name> '<json>'`.
- Pass `caption` only when the user wants an accompanying message.
- The JSON payload should include an explicit QQ `chat_id`, `path`, and optional `caption`.
- The second argument of `cap call` must be one complete JSON string. Do not rewrite it as `--chat_id` flags or `key=value`.

## Examples

Send an image to a QQ chat through `cap_cli`:
```text
cap call qq_send_image '{"chat_id":"group123","path":"/spiffs/qq/capture.jpg","caption":"Here is the image."}'
```

Send a file to a QQ group through `cap_cli`:
```text
cap call qq_send_file '{"chat_id":"group1234567890","path":"/spiffs/reports/status.json","caption":"Latest status report."}'
```

## Workflow
1. Confirm the target file exists with `list_dir` if needed.
2. Choose `qq_send_image` or `qq_send_file` based on file type.
3. Execute the QQ capability through `cap_cli` with `cap call <cap_name> '<json>'`.
4. Tell the user whether the send succeeded.

## Notes
- This skill only sends files that already exist on the device filesystem.
- QQ generic file delivery may depend on platform-side enablement. If `qq_send_file` fails, prefer falling back to `qq_send_image` for images or explain that QQ rejected generic file upload.
