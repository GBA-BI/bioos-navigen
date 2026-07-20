# Bio-OS remote WDL validator

## Contents

- Service boundary
- Endpoints
- Request modes
- Response semantics
- Client behavior
- Direct curl usage

## Service boundary

The current internal service wraps `womtool 88` behind FastAPI. It runs with OpenJDK 17 in a Linux AMD64 container. It is synchronous, unauthenticated, intended for a trusted network or gateway, and does not persist uploads or validation history. Each request uses a temporary directory that is deleted after validation.

Default base URL:

```text
http://10.20.17.123:8078
```

Override the default with `BIOOS_WDL_VALIDATOR_URL`. Treat the address as environment-specific rather than a permanent public endpoint.

## Endpoints

### Health

```http
GET /api/v1/wdl/healthz
```

A healthy response has HTTP `200`, `status="ok"`, and `womtool_available=true`.

### Validate

```http
POST /api/v1/wdl/validate
```

The service accepts exactly one input mode per request.

## Request modes

| Mode | Content type | Fields | Use |
| --- | --- | --- | --- |
| `content` | `application/json` | `wdl_content`, optional `filename` | One WDL with no local imports |
| `file` | `multipart/form-data` | `wdl_file` | One local WDL file |
| `archive` | `multipart/form-data` | `archive_file`, conditional `root_wdl_path` | Multiple WDL files/imports in a zip |
| `folder` | `multipart/form-data` | repeated `folder_files`, conditional `root_wdl_path` | Browser/client folder upload |

When an archive/folder contains multiple WDL files, send `root_wdl_path` as the relative path inside the upload. The server returns candidate paths when it cannot choose a root.

## Response semantics

Validation success:

```json
{
  "ok": true,
  "message": "WDL 文件验证通过",
  "mode": "content",
  "root_wdl_path": "main.wdl",
  "stdout": "Success!",
  "stderr": "",
  "dependencies": [],
  "exit_code": 0
}
```

WDL syntax/type failure still uses HTTP `200`:

```json
{
  "ok": false,
  "message": "WDL 文件验证失败",
  "stderr": "Unrecognized token on line 5...",
  "exit_code": 1
}
```

Always decide WDL validity from `ok`, not HTTP status alone. For `ok=false`, prefer `stderr`, then `stdout`.

| HTTP status | Meaning |
| --- | --- |
| `200` | Request completed; inspect `ok` |
| `400` | Conflicting modes, bad root path, unsafe/invalid archive, or other request error |
| `413` | Upload or extracted content exceeded the configured limit (currently 50 MB by default) |
| `415` | Unsupported content type |
| `422` | Invalid JSON/request fields |
| `503` | Server-side womtool unavailable |
| `504` | Validation timed out (server default 60 seconds in the recorded deployment) |

## Client behavior

1. Use content mode only when there are no local imports.
2. Use archive/project mode when imports exist; preserve paths exactly.
3. On multiple-root errors, select the workflow entry file rather than guessing.
4. Distinguish HTTP/request failure, service unavailability, and WDL validation failure in reports.
5. Do not place credentials in WDL source sent to an unauthenticated service.

## Direct curl usage

Check service health:

```bash
curl --fail-with-body --silent --show-error \
  "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/healthz"
```

Validate one WDL file:

```bash
curl --fail-with-body --silent --show-error \
  -X POST "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/validate" \
  -F "wdl_file=@/abs/path/main.wdl"
```

Validate a project with local imports:

```bash
WDL_ARCHIVE_DIR="$(mktemp -d)"
(cd /abs/path/project && zip -q -r "${WDL_ARCHIVE_DIR}/project.zip" . -i '*.wdl')
curl --fail-with-body --silent --show-error \
  -X POST "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/validate" \
  -F "archive_file=@${WDL_ARCHIVE_DIR}/project.zip;type=application/zip" \
  -F "root_wdl_path=main.wdl"
```

`curl` failure identifies an HTTP or transport problem. A successful `curl` command does not prove that the WDL is valid because syntax and type errors return HTTP `200`; always inspect the JSON `ok` field. When `jq` is available, save the response and make that check explicit:

```bash
curl --fail-with-body --silent --show-error \
  -X POST "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/validate" \
  -F "wdl_file=@/abs/path/main.wdl" \
  | tee /tmp/wdl-validation-response.json
jq -e '.ok == true' /tmp/wdl-validation-response.json
```
