# Lua Script Authoring

Use this skill when the user wants to write, generate, or modify a managed Lua script for this device.

## Runtime Constraints
- Managed Lua scripts must stay under `/spiffs/lua`.
- The script path must end with `.lua`.
- Prefer relative paths such as `blink.lua` or `rainbow.lua`; the runtime resolves them under `/spiffs/lua`.
- Use `lua_write_script` to save or overwrite script content.

## Available Lua Modules
The runtime includes these built-in and application-registered modules:

### `delay`
- `delay.delay_ms(ms)`
- Use for short blocking delays inside a script.

### `storage`
- `storage.mkdir(path)`
- `storage.write_file(path, content)`
- `storage.read_file(path)`
- Use only for files the script needs to manage.

### `gpio`
- `gpio.set_direction(pin, mode)`
- `gpio.set_level(pin, level)`
- `gpio.get_level(pin)`
- Supported modes: `input`, `output`, `input_output`, `output_od`, `input_output_od`, `disable`

### `led_strip`
- `local strip = led_strip.new(gpio_pin, max_leds)`
- `strip:set_pixel(index, r, g, b)`
- `strip:refresh()`
- `strip:clear()`
- `strip:close()`
- This is for WS2812-style LED strips on a GPIO pin.

## Writing Guidance
- Write plain Lua script files, not markdown or pseudocode.
- Keep dependencies limited to standard Lua plus the modules listed above.
- Prefer small scripts with a clear entry flow and explicit comments for pin usage.
- If the script touches GPIO or LED hardware, state the pin numbers and expected electrical behavior in comments.
- If a requested peripheral is not covered by `gpio` or `led_strip`, say that the current runtime does not expose that peripheral module.

## Example Shape
```lua
local gpio = require("gpio")
local delay = require("delay")

gpio.set_direction(2, "output")

while true do
    gpio.set_level(2, 1)
    delay.delay_ms(500)
    gpio.set_level(2, 0)
    delay.delay_ms(500)
end
```

## Save Rule
When the script is ready, call `lua_write_script` with:
- `path`: relative `.lua` path under `/spiffs/lua`
- `content`: full Lua source
- `overwrite`: `true` only when replacing an existing script intentionally
