# BioOS Model Atlas image API contract

Read this reference when changing search parameters, interpreting evidence, or
debugging an API response.

## Configuration

The production base URL is `http://10.20.17.123:8079` and excludes `/api`.
Use the single `FILL_PRODUCTION_READ_ONLY_KEY_HERE` slot in `SKILL.md`; do not
duplicate the key in this reference file. If that slot is empty, stop before
calling the API. Do not attempt a user login, invent a key, read a different
environment variable, or fall back to a local service.

Authentication is:

```http
X-API-Key: <BIOOS_IMAGE_SEARCH_API_KEY>
```

The same key is read-only and may call image search, catalog summary, and image
package inventory. Do not use a user login flow for service-to-service search.
Treat the filled production copy of `SKILL.md` as a secret file readable only
by the AI service account. Do not print, quote, redistribute, or commit it.

## Search images

```http
POST /api/search/images
Content-Type: application/json
X-API-Key: <key>
```

Supported body fields:

| Field | Type | Meaning |
|---|---|---|
| `q` | string | Natural language, tool name, image name, or mixed query |
| `packages` | string[] | Mandatory package constraints; version may use `name==version` |
| `data_types` | string[] | Input/data-type hints |
| `runtime` | string | Required runtime |
| `language` | string | Required language |
| `hardware_profile` | string | Required hardware profile |
| `accelerator` | string | Required accelerator |
| `status` | string | Usually `available` |
| `gpu_required` | boolean | Require GPU stack |
| `requires_ies_image` | boolean | Require IES image |
| `requires_bioos_compatibility` | boolean | Require recorded BioOS/IES compatibility |
| `os_arch` | string | Usually `linux/amd64` |
| `limit` | integer | 1–50 |
| `evidence_level` | string | `none`, `summary`, or `debug` |

Important response fields:

```text
count
abstained
abstention_reason
items[].asset_id
items[].score
items[].asset.image_url
items[].asset.summary
items[].asset.package_preview
items[].asset.package_scan_status
items[].asset.package_inventory_source
items[].asset.scan_confidence
items[].asset.os_arch
items[].asset.hardware_profile
items[].asset.accelerator
items[].asset.limitations
items[].evidence.matched_packages
items[].evidence.missing_packages
items[].evidence.matched_fields
items[].evidence.retrieval_primary_mode
```

`packages` are mandatory constraints. Put uncertain tool names in `q` instead.
An empty result with package constraints does not prove the tool is absent.

## Catalog summary

```http
GET /api/catalog/summary
X-API-Key: <key>
```

Use this endpoint for catalog health, visible image counts, package coverage,
tool/version counts, and embedding counts. Do not use total counts as evidence
that a particular image satisfies a workflow.

The production baseline validated on 2026-07-28 contained 77,007 images,
10,543 catalog tools, 10,543 catalog-tool embeddings, and 94 legacy
image-level embeddings. Treat these as an operational baseline rather than
hard-coded invariants because the catalog may grow. The 94 image-level
embeddings are not the searchable image total.

## Image package inventory

```http
GET /api/images/{asset_id}/packages?scope=effective&limit=200&offset=0
X-API-Key: <key>
```

- `scope=effective`: direct, inherited, and catalog-derived effective packages.
- `scope=direct`: only package rows recorded directly for the image.
- `limit`: 1–1000.
- `offset`: zero-based pagination offset.

Inspect:

```text
image.package_scan_status
image.package_inventory_source
image.package_inventory_updated_at
image.scan_confidence
items[].name
items[].version
items[].manager
items[].source
items[].package_scope
items[].origin_image_id
items[].search_weight
total
has_more
inventory_note
```

Follow pagination until `has_more=false` when a complete recorded inventory is
required.

## Failure interpretation

| Status | Meaning | Action |
|---|---|---|
| `401` | Missing or invalid permanent key | Check the environment; do not log the key |
| `404` | Endpoint not deployed or asset not visible/found | Check service version and asset ID |
| `422` | Invalid parameter or contradictory request | Correct the request; retain error body |
| `5xx` | Service/database failure | Report transport failure; do not claim no image exists |

Use `curl --fail-with-body --silent --show-error` so HTTP failures remain
visible and produce a non-zero exit status.
