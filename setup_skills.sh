#!/bin/bash
# setup_skills.sh - Configure and install NaviGen skills to local agent configuration folders

set -e

# Base directory is where this script resides (usually user's project directory if copied)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Target directories for different agent assistants
TARGET_DIRS=(
    "${BASE_DIR}/.agent/skills"
    "${BASE_DIR}/.agents/skills"
    "${BASE_DIR}/.codex/skills"
    "${BASE_DIR}/.claude/skills"
)

# Print usage
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -c, --copy           Copy skills physically (Default, recommended for deployment)"
    echo "  -l, --link           Create symlinks (Recommended for development)"
    echo "  -s, --source <path>  Specify path to bioos-navigen repository (If running from outside the repo)"
    echo "  -h, --help           Show this help message"
    echo ""
    exit 0
}

# Parse options
MODE="copy"
SRC_BASE_DIR=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--copy) MODE="copy"; shift ;;
        -l|--link) MODE="link"; shift ;;
        -s|--source) SRC_BASE_DIR="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
done

# If --source is not specified, default to BASE_DIR (assumes running inside bioos-navigen repo)
if [ -z "${SRC_BASE_DIR}" ]; then
    SRC_BASE_DIR="${BASE_DIR}"
fi

# Ensure SRC_BASE_DIR is absolute
SRC_BASE_DIR="$(cd "${SRC_BASE_DIR}" && pwd)"

echo "Setting up Bio-OS NaviGen skills..."
echo "Project directory: ${BASE_DIR}"
echo "Source repository: ${SRC_BASE_DIR}"
echo "Installation mode: ${MODE}"

# Source directories to check
SOURCES=("skills-cli" "skills-bioinformatics")

for TARGET_DIR in "${TARGET_DIRS[@]}"; do
    AGENT_TYPE=$(basename "$(dirname "${TARGET_DIR}")")
    echo ""
    echo "--> Installing for agent: ${AGENT_TYPE} (${TARGET_DIR})"
    
    # Ensure target directory exists
    mkdir -p "${TARGET_DIR}"

    for src in "${SOURCES[@]}"; do
        SRC_PATH="${SRC_BASE_DIR}/${src}"
        if [ ! -d "${SRC_PATH}" ]; then
            echo "    Warning: Source directory ${SRC_PATH} not found, skipping."
            continue
        fi

        # Find all subdirectories in the source directory that contain a SKILL.md file
        for skill_dir in "${SRC_PATH}"/*; do
            if [ -d "${skill_dir}" ] && [ -f "${skill_dir}/SKILL.md" ]; then
                SKILL_NAME=$(basename "${skill_dir}")
                TARGET_PATH="${TARGET_DIR}/${SKILL_NAME}"

                # Remove existing target (symlink, file, or directory)
                if [ -L "${TARGET_PATH}" ] || [ -f "${TARGET_PATH}" ]; then
                    rm "${TARGET_PATH}"
                elif [ -d "${TARGET_PATH}" ]; then
                    rm -rf "${TARGET_PATH}"
                fi

                if [ "${MODE}" = "link" ]; then
                    # Create symlink
                    # If running inside the repo, use relative symlink
                    # Otherwise, use absolute symlink for stability
                    if [ "${SRC_BASE_DIR}" = "${BASE_DIR}" ]; then
                        REL_PATH="../../${src}/${SKILL_NAME}"
                        ln -s "${REL_PATH}" "${TARGET_PATH}"
                        echo "    [Link] ${SKILL_NAME} -> ${REL_PATH}"
                    else
                        ln -s "${skill_dir}" "${TARGET_PATH}"
                        echo "    [Link] ${SKILL_NAME} -> ${skill_dir}"
                    fi
                else
                    # Copy physically
                    cp -R "${skill_dir}" "${TARGET_PATH}"
                    echo "    [Copy] ${SKILL_NAME}"
                fi
            fi
        done
    done
done

echo ""
echo "Setup completed successfully!"
