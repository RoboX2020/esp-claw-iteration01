# Scheduler Management

Use this skill when the user needs to inspect or control timer-based schedule rules.

## When to use
- The user asks to list current schedules.
- The user asks to add a new once/interval/cron schedule.
- The user asks to pause, resume, enable, disable, trigger, or reload a schedule.

## Must work with Event Router
- Scheduler only publishes events; it does not define post-trigger behavior by itself.
- To make a schedule actually do something, add a matching event router automation rule (`match.event_type` + `match.event_key`).
- Router rule operations and formats are documented in `cap_router_mgr.md` (`add_router_rule` / `update_router_rule`).

## Time semantics: `interval` vs `cron`
- `interval`: runs by relative elapsed time; it can run without network time sync when it does not depend on absolute start/end timestamps.
- `cron`: runs on wall-clock time and absolute Unix time; valid time sync is required.
- `once`: also depends on absolute timestamp (`start_at_ms`) and therefore needs valid time.

## Available capabilities
- `scheduler_list`: list all scheduler entries and runtime state.
- `scheduler_get`: get one scheduler entry by id.
- `scheduler_add`: add one scheduler entry from `schedule_json` string.
- `scheduler_enable`: enable one scheduler entry by id.
- `scheduler_disable`: disable one scheduler entry by id.
- `scheduler_pause`: pause one scheduler entry by id.
- `scheduler_resume`: resume one scheduler entry by id.
- `scheduler_trigger_now`: trigger one scheduler entry immediately.
- `scheduler_reload`: reload scheduler definitions from disk.

## `scheduler_add` input format
- Input object format:
```json
{
  "schedule_json": "<JSON string of one scheduler entry object>"
}
```
- `schedule_json` object template:
```json
{
  "id": "",
  "enabled": true,
  "kind": "",
  "timezone": "",
  "start_at_ms": 0,
  "end_at_ms": 0,
  "interval_ms": 30000,
  "cron_expr": "",
  "event_type": "",
  "event_key": "",
  "source_channel": "",
  "chat_id": "",
  "content_type": "",
  "session_policy": "",
  "text": "",
  "payload_json": "{}",
  "max_runs": 0
}
```

## Field meanings
- `id`: schedule unique id.
- `enabled`: whether schedule is active (`true`) or disabled (`false`).
- `kind`: `once` / `interval` / `cron`.
- `timezone`: timezone string used for cron and wall-clock interpretation.
- `start_at_ms`: absolute Unix timestamp (ms), mainly for `once` or absolute interval anchor. `0` for default.
- `end_at_ms`: optional absolute stop time (ms), `0` means no time-bound stop.
- `interval_ms`: interval period for `interval`.
- `cron_expr`: 5-field cron expression for `cron`.
- `event_type`: published event type. Common values are `schedule` and `message`.
- `event_key`: logical key for rule matching and tracing.
- `source_channel`: event source channel (for example `time`, `qq`, `telegram`).
- `chat_id`: target chat/session id when message semantics are needed.
- `content_type`: event content type (for example `trigger`, `text`).
- `session_policy`: session policy (`trigger`, `chat`, `global`, `ephemeral`, `nosave`).
- `text`: event text payload.
- `payload_json`: structured payload string.
- `max_runs`: max trigger count. `0` means unlimited.

## `event_type` semantics
- `schedule`:
- Recommended for deterministic automation pipelines.
- Must have a matching event router rule, otherwise trigger events are not consumed into actions.
- `message`:
- Used when you want scheduler ticks to behave like incoming messages.
- Set `source_channel`, `chat_id`, and `text` explicitly to avoid route failures.
- In `basic_demo` with LLM enabled, each trigger is equivalent to sending `text` to the agent once, then routing the response outbound.

## Recommended workflow
1. Use `scheduler_list` or `scheduler_get` to inspect current state.
2. Add/update one schedule.
3. If `event_type` is `schedule`, add/update matching router rule in `cap_router_mgr`.
4. Trigger once (`scheduler_trigger_now`) or wait one cycle, then verify with `scheduler_get`.

## Examples

Complete `interval + schedule` entry (requires matching router rule):
```json
{
  "schedule_json": "{\"id\":\"drink_reminder_30s\",\"enabled\":true,\"kind\":\"interval\",\"timezone\":\"UTC0\",\"start_at_ms\":0,\"end_at_ms\":0,\"interval_ms\":30000,\"cron_expr\":\"\",\"event_type\":\"schedule\",\"event_key\":\"drink_reminder\",\"source_channel\":\"time\",\"chat_id\":\"\",\"content_type\":\"trigger\",\"session_policy\":\"trigger\",\"text\":\"drink reminder tick\",\"payload_json\":\"{\\\"message\\\":\\\"time to drink water\\\"}\",\"max_runs\":3}"
}
```

Matching router rule for the above schedule (via `add_router_rule` in `cap_router_mgr`):
```json
{
  "rule_json": "{\"id\":\"drink_reminder_to_qq\",\"description\":\"Send drink reminder to QQ\",\"enabled\":true,\"consume_on_match\":true,\"match\":{\"event_type\":\"schedule\",\"event_key\":\"drink_reminder\"},\"actions\":[{\"type\":\"send_message\",\"input\":{\"channel\":\"qq\",\"chat_id\":\"c2c:D49D721C39B08F751706A40AB8BEA53D\",\"message\":\"该喝水了\"}}]}"
}
```

Complete `interval + message` entry (timer-driven agent wake-up):
```json
{
  "schedule_json": "{\"id\":\"sedentary_reminder\",\"enabled\":true,\"kind\":\"interval\",\"timezone\":\"UTC0\",\"start_at_ms\":0,\"end_at_ms\":0,\"interval_ms\":30000,\"cron_expr\":\"\",\"event_type\":\"message\",\"event_key\":\"sedentary_reminder\",\"source_channel\":\"qq\",\"chat_id\":\"c2c:D49D721C39B08F751706A40AB8BEA53D\",\"content_type\":\"text\",\"session_policy\":\"trigger\",\"text\":\"久坐提醒：起来活动一下吧！\",\"payload_json\":\"{}\",\"max_runs\":3}"
}
```

Pause a schedule:
```json
{
  "id": "sedentary_reminder"
}
```
