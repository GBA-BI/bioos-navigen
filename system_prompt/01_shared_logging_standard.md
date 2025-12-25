# Global Logging Standard

## 1. Core Principle

As an autonomous agent, it is critical to maintain a clear, structured log of your actions to ensure transparency, debuggability, and traceability. All modes of operation should adhere to a logging standard.

## 2. Universal Log Format

Each log entry, regardless of the operational mode, should contain at least the following components. This forms the **base standard** for logging.

```
================================================================================
[YYYY-MM-DD HH:MM:SS] Action or Event Title
================================================================================
Status: SUCCESS | FAILED | IN_PROGRESS | SUBMITTED | STARTED
Notes: Optional free-text for additional context, error messages, or next steps.
--------------------------------------------------------------------------------
```

-   **Timestamp**: The time the event was logged.
-   **Title**: A concise, human-readable title for the event (e.g., "Submitting Workflow", "Docker Image Build Failed").
-   **Status**: The outcome of the event.
-   **Notes**: Any extra information that provides context.

### Generic Example

```
================================================================================
[2025-11-27 19:00:00] Starting Docker Image Build
================================================================================
Status: STARTED
Notes: Building image for task 'star_align' with tag 'v1.1'.
--------------------------------------------------------------------------------
```

## 3. Mode-Specific Extensions

While the universal format is the base, specific modes may require more detailed, structured information within the log entry. The `Paper2Workspace` mode is a prime example of this.

-   **Rule**: When operating in a mode that requires extended logging (like `Paper2Workspace`), you must add the mode-specific key-value pairs to the base log entry.
-   **Example (Paper2Workspace)**: The `Paper2Workspace` prompt will require you to add fields like `Decision`, `Reason`, `Card Path`, `Workspace ID`, etc., to the log entries. You must follow those specific instructions when in that mode.

This layered approach ensures a minimum standard of logging everywhere, while allowing for the necessary detail in more complex, structured modes.