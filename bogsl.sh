#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PORT=5555
FILE=""

# Optional port flag handling, flag must be before filename
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)
            PORT="$2"
            shift 2
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

if [ -z "$FILE" ]; then
    echo "Usage: $0 [--port <port>] <path-to-dsl-file>"
    exit 1
fi

# Resolve to absolute path
ABSPATH="$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")"

cd "$SCRIPT_DIR"

# Build dependency classpath (cached: regenerated if pom.xml changes)
if [ ! -f target/.classpath ] || [ pom.xml -nt target/.classpath ]; then
    echo "Building classpath..." >&2
    mvn -q dependency:build-classpath -Dmdep.outputFile=target/.classpath
fi

CLASSPATH="$SCRIPT_DIR/src/main/rascal:$(cat "$SCRIPT_DIR/target/.classpath")"

java -cp "$CLASSPATH" org.rascalmpl.shell.RascalShell BoGSL "$ABSPATH" "$PORT" \
    2> >(grep -v "^INFO:\|Loading modules\|^Version:" >&2)
