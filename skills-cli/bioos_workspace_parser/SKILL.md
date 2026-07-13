---
name: bioos_workspace_parser
description: Retrieve and summarize the full profile of a Bio-OS workspace by using the `bioos workspace profile` CLI command. Trigger this skill when the user provides an existing workspace or when the agent needs to understand the current state of a workspace.
---

# Bio-OS Workspace Parser

Before running the commands below, use `bioos_cli_locator` if the `bioos` command or authentication has not been verified.

## Operating Principle
This skill extracts a high-level profile of a Bio-OS workspace and turns it into a concise, human-readable manifest for follow-up work.

## Operational Standards
1. Ensure the target workspace name is known.
2. Retrieve the workspace profile with:
   `bioos workspace profile --workspace-name <workspace_name> --output json --pretty`
3. Parse the returned JSON and identify the key elements:
   - workflows
   - datasets or data models
   - recent submissions, statuses, and outputs
   - IES applications when relevant
4. Present a concise summary to the user instead of dumping raw JSON.
5. Keep the raw structured result in working memory for downstream tasks such as execution, debugging, or manuscript drafting.
