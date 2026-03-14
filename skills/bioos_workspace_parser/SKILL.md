---
name: bioos_workspace_parser
description: Retrieve and summarize the full profile of a Bio-OS workspace (including workflows, datasets, and run histories) using the get_workspace_profile tool. Trigger this skill when the user provides an existing Workspace for the Agent to use, or when the Agent needs to understand the current state of a Workspace.
---

# Bio-OS Workspace Parser

## 1. Operating Principle
This procedure defines how to extract and summarize the overall profile of a specified Bio-OS workspace into a clean, human-readable structured manifest.

## 2. Operational Standards
1. **Target Identification**: Ensure the target workspace name is known. 
2. **Metadata Retrieval**: Use the `get_workspace_profile` tool to directly fetch a JSON structure containing the workspace's comprehensive metadata. 
3. **Summary Generation**: Parse the returned JSON payload to identify key elements such as:
   - **Workflows**: Available analysis pipelines.
   - **Datasets**: Data structures and associated files.
   - **Run History**: Past execution submissions, statuses, and outputs.
4. **User Presentation (CRITICAL)**: Actively present a clear, concise overview of the workspace's metadata to the user in the conversation.
5. **Execution Continuation**: Use the distilled summary payload to fulfill subsequent user requests (e.g., answering questions, executing tasks, or drafting a paper).
