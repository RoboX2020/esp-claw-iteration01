/*
 * SPDX-FileCopyrightText: 2026 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#pragma once

#include <stdbool.h>
#include <stdint.h>

#include "esp_err.h"

esp_err_t basic_demo_wifi_init(void);
esp_err_t basic_demo_wifi_start(const char *ssid, const char *password);
esp_err_t basic_demo_wifi_wait_connected(uint32_t timeout_ms);
bool basic_demo_wifi_is_connected(void);
const char *basic_demo_wifi_get_ip(void);
