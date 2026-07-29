---
name: bioos_docker_registry_catalog
description: Search and select existing Bio-OS container images through the BioOS Model Atlas REST API. Use whenever User needs a Docker image  for a bioinformatics task, develops or edits a Bio-OS WDL workflow, changes a WDL runtime docker value, checks whether an image or package already exists, compares image candidates, or considers building a new image. Always use this skill before bioos_docker_builder; trigger even when the user asks only for a biological tool or workflow and does not explicitly mention BioOS.
---

# Bio-OS Image Catalog Search

## Operating principle

Search the live image catalog before writing a Dockerfile or choosing a WDL
runtime. Prefer a returned existing image when its recorded packages, platform,
and hardware match the task. Never invent an image URL, tag, installed package,
or compatibility claim.

Use this deployment configuration directly. Replace the empty key only in the
production copy of this skill:

```bash
export BIOOS_IMAGE_SEARCH_API_URL="http://10.20.17.123:8079"
export BIOOS_IMAGE_SEARCH_API_KEY=""
BIOOS_IMAGE_SEARCH_API_URL="${BIOOS_IMAGE_SEARCH_API_URL%/}"
```

If `BIOOS_IMAGE_SEARCH_API_KEY` is still empty, stop before calling the API and
ask the production operator to fill the marked slot. Never invent a key, fall
back to a login flow, read a different environment variable, or silently
switch to a local service.

After filling the production copy, restrict `SKILL.md` so only the AI service
account can read it. Do not commit, redistribute, quote, print, or include the
filled key in WDL, source code, command output, logs, or responses.

After the key is present, verify production catalog access:

```bash
curl --fail-with-body --silent --show-error \
  --connect-timeout 5 \
  --max-time 90 \
  -H "X-API-Key: ${BIOOS_IMAGE_SEARCH_API_KEY}" \
  "${BIOOS_IMAGE_SEARCH_API_URL}/api/catalog/summary"
```

The production catalog contains the full image inventory. Read
`counts.images` from the catalog summary for the searchable image total. Do
not mistake the legacy `asset_type=image` embedding count for the search
scope; semantic catalog recall primarily uses deduplicated
`asset_type=catalog_tool` embeddings and maps tools back to image versions.

## Workflow

### 1. Derive one environment requirement per WDL task

Extract:

- biological intent and input type;
- exact tools and mandatory versions;
- language or runtime;
- CPU versus GPU/CUDA;
- `linux/amd64` platform requirements;
- IES requirements only when the target is an interactive IES image;
- exclusions such as “do not use BWA”.

Search each distinct task environment separately. Do not force unrelated tools
into one container merely to reduce the number of images.

### 2. Start with a natural-language hybrid search

Use a concise biological description plus canonical English tool names:

```bash
curl --fail-with-body --silent --show-error \
  --connect-timeout 5 \
  --max-time 90 \
  -X POST "${BIOOS_IMAGE_SEARCH_API_URL}/api/search/images" \
  -H "X-API-Key: ${BIOOS_IMAGE_SEARCH_API_KEY}" \
  -H "Content-Type: application/json" \
  --data-binary '{
    "q": "paired-end FASTQ adapter trimming and quality control with fastp",
    "status": "available",
    "limit": 5,
    "evidence_level": "summary"
  }'
```

The API combines semantic retrieval, PostgreSQL text search, Trigram matching,
exact tool/package lookup, structured filters, and ranking. Do not implement a
second local keyword catalog.

For an exact mandatory package or version, add the `packages` array to the JSON
body. Package entries are hard constraints, not search hints:

```bash
curl --fail-with-body --silent --show-error \
  --connect-timeout 5 \
  --max-time 90 \
  -X POST "${BIOOS_IMAGE_SEARCH_API_URL}/api/search/images" \
  -H "X-API-Key: ${BIOOS_IMAGE_SEARCH_API_KEY}" \
  -H "Content-Type: application/json" \
  --data-binary '{
    "q": "sort and index an alignment BAM",
    "packages": ["samtools==1.15.1"],
    "status": "available",
    "limit": 5,
    "evidence_level": "summary"
  }'
```

Add `gpu_required`, `runtime`, `language`, `hardware_profile`, `accelerator`,
`requires_ies_image`, or `requires_bioos_compatibility` to the JSON body only
when the requirement is mandatory. Set `status` to `available`. Validate
`asset.os_arch=linux/amd64` after recall; use `os_arch` as a hard filter only
when needed because incomplete catalog metadata can otherwise hide a valid
candidate.

### 3. Retry intelligently when no candidate is returned

If `abstained=true` or `count=0`:

1. Remove speculative hard package/version constraints and retry them as text.
2. Remove optional structured filters such as `os_arch` and validate the
   returned asset fields after recall.
3. Search the exact canonical tool name.
4. Retry a common ecosystem form such as `r-<tool>`,
   `bioconductor-<tool>`, or a known command/package alias.
5. Add a short English task description when the original query is Chinese.

Do not claim the image is absent until the natural-language, exact-name, and
reasonable alias searches all return no usable result.

### 4. Inspect evidence before selecting a candidate

For each serious candidate, read:

- `asset.image_url`, `status`, `os_arch`, `hardware_profile`, and accelerator;
- `asset.package_scan_status`, `package_inventory_source`, and
  `scan_confidence`;
- `asset.package_preview`, `effective_package_count`, and limitations;
- `evidence.matched_packages`, `missing_packages`, `matched_fields`,
  `retrieval_primary_mode`, and confidence fields.

Then fetch the complete effective package inventory using the returned
`asset_id`:

```bash
ASSET_ID="<asset_id>"
curl --fail-with-body --silent --show-error \
  --connect-timeout 5 \
  --max-time 90 \
  -H "X-API-Key: ${BIOOS_IMAGE_SEARCH_API_KEY}" \
  "${BIOOS_IMAGE_SEARCH_API_URL}/api/images/${ASSET_ID}/packages?scope=effective&limit=1000&offset=0"
```

Use `scope=direct` only to distinguish packages recorded directly on the
image from inherited or catalog-derived packages. Read
[API contract](references/api-contract.md) when interpreting response fields
or changing request parameters.

Treat package evidence according to its source:

- container scan: strongest evidence of installed contents;
- build/manual record: useful but dependent on ingestion quality;
- catalog declaration: evidence for the BioContainers tool/version;
- inherited: evidence derived from the recorded base-image relationship.

Never describe a catalog-derived package list as a complete live container
scan. `status=available` means available in the catalog; it does not prove that
the current machine has registry credentials or can pull the image.
Do not contact the registry merely to search. Mark an image `pull-verified`
only after an explicit `docker manifest inspect` or `docker pull` succeeds in
the current environment; respect VPN, credential, and network constraints.

### 5. Choose the image conservatively

Select a candidate only when:

- every mandatory tool/version is matched and `missing_packages` is empty;
- the image is available and its platform matches the Bio-OS task;
- CPU/GPU/CUDA requirements are compatible;
- no recorded limitation contradicts the workflow.

Prefer, in order:

1. direct scanned package/version evidence;
2. direct catalog tool/package/version evidence;
3. exact image/tool-name evidence;
4. semantic intent evidence with package confirmation.

When no version is required, accept the API’s deduplicated top version for the
tool. Do not reject an older image solely because of age when it satisfies the
workflow; report the version and any reproducibility risk. Preserve the exact
returned tag. Do not silently replace it with `latest`.

### 6. Put the selected URL into WDL

Use the exact `asset.image_url` returned by the API:

```wdl
task FastqQc {
    input {
        File reads
        String docker_image = "<exact asset.image_url>"
        Int memory_gb = 8
        Int disk_space_gb = 100
        Int cpu_threads = 4
    }

    command <<<
        fastqc --threads ~{cpu_threads} --outdir . ~{reads}
    >>>

    output {
        File report = glob("*_fastqc.html")[0]
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}
```

Keep task-specific images separate when tasks need different environments.
After inserting the image, use `bioos_wdl_scripter` to validate the WDL.

### 7. Build only when reuse is inadequate

Hand off to `bioos_docker_builder` only after the search and evidence checks
show one of these conditions:

- no candidate exists after the retry sequence;
- every candidate misses a mandatory package or version;
- platform, GPU/CUDA, or runtime constraints are incompatible;
- the user explicitly requires a new custom environment.

Include the failed queries, required packages, and closest candidates in the
handoff so the builder can choose the smallest viable base image.

## Result contract

Return:

- search query and hard constraints;
- selected exact image URL and asset ID;
- why it satisfies the task;
- matched package/version and evidence source;
- platform and hardware compatibility;
- important limitations or unverified claims;
- up to two alternatives;
- the WDL runtime value or patched WDL path;
- whether the result is `catalog-matched`, `package-verified`,
  `pull-verified`, or only `candidate`.

If no image is adequate, say so explicitly and recommend the build handoff.
