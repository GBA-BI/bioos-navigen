---
name: bioos_cli_locator
description: Prepare Bio-OS CLI access before running CLI-based Bio-OS skills. Use when the `bioos` command has not been verified or is unavailable, or when Bio-OS authentication and config are missing or invalid.
---

# Bio-OS CLI Locator

## CLI Setup

Bio-OS CLI skills use the `bioos` command.

1. Run this check first:

   `bioos --help`

2. If it fails, stop immediately and ask the user before running any other
   Bio-OS command. Wait for explicit instruction before installing or
   upgrading `pybioos`.

## Authentication Setup

1. Check the current authentication status:

   `bioos auth status --pretty`

2. If authentication is not configured, get the config path and the example
   supported by the installed pybioos version:

   `bioos config path --pretty`

   `bioos config example --pretty`

3. Write the required credentials and service settings to the reported config
   path. Use only values supplied by the user or the calling system. Never
   fabricate, print, expose, or commit credentials.

4. Preserve unrelated fields when the config file already exists, and restrict
   the file to its owner:

   `chmod 600 <config_path>`

5. Verify the result:

   `bioos auth status --pretty`

Do not continue with authenticated Bio-OS operations until the authentication
status is usable.
