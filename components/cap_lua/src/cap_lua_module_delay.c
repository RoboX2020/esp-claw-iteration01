/*
 * SPDX-FileCopyrightText: 2026 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#include "cap_lua_internal.h"

#include <stdint.h>

#include "lauxlib.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static int cap_lua_delay_ms(lua_State *L)
{
    lua_Integer ms = luaL_checkinteger(L, 1);

    if (ms < 0) {
        ms = 0;
    }

    vTaskDelay(pdMS_TO_TICKS((uint32_t)ms));
    return 0;
}

int luaopen_delay(lua_State *L)
{
    lua_newtable(L);
    lua_pushcfunction(L, cap_lua_delay_ms);
    lua_setfield(L, -2, "delay_ms");
    return 1;
}
