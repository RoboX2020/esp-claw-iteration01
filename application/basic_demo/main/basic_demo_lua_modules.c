/*
 * SPDX-FileCopyrightText: 2026 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#include "basic_demo_lua_modules.h"

#include "cap_lua.h"

#include "lua_module/lua_module_gpio.h"
#include "lua_module/lua_module_led_strip.h"

esp_err_t basic_demo_lua_modules_register(void)
{
    static const cap_lua_module_t s_modules[] = {
        {.name = "gpio", .open_fn = luaopen_gpio},
        {.name = "led_strip", .open_fn = luaopen_led_strip},
    };

    return cap_lua_register_modules(s_modules,
                                    sizeof(s_modules) / sizeof(s_modules[0]));
}
