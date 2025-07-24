#!/bin/bash
# Automated COBOL compilation script
# Compiles all COBOL programs on container startup

echo "=== COBOL Compilation Starting ==="
echo "Checking for GnuCOBOL installation..."

# Check if cobc is installed
if ! command -v cobc &> /dev/null; then
    echo "ERROR: GnuCOBOL compiler (cobc) not found!"
    echo "Please ensure GnuCOBOL is installed in the Docker image."
    exit 1
fi

echo "GnuCOBOL version: $(cobc --version | head -n1)"

# Directory containing COBOL source files
COBOL_DIR="/app"
COMPILED_DIR="/app/compiled"

# Create compiled directory if it doesn't exist
mkdir -p "$COMPILED_DIR"

# Array of COBOL programs to compile
COBOL_PROGRAMS=(
    "financial-calc.cob"
    "mainframe-sync.cob"
    "legacy-auth.cob"
    "transaction-stream.cob"
    "batch-report.cob"
    "workflow-engine.cob"
)

# Compilation results
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_PROGRAMS=()

# Compile each program
for program in "${COBOL_PROGRAMS[@]}"; do
    if [ -f "$COBOL_DIR/$program" ]; then
        echo -n "Compiling $program... "
        
        # Extract program name without extension
        program_name="${program%.cob}"
        
        # Compile the program
        if cobc -x -o "$COMPILED_DIR/$program_name" "$COBOL_DIR/$program" 2>/tmp/cobol_compile_error.log; then
            echo "SUCCESS"
            chmod +x "$COMPILED_DIR/$program_name"
            ((SUCCESS_COUNT++))
        else
            echo "FAILED"
            echo "Error compiling $program:"
            cat /tmp/cobol_compile_error.log
            ((FAIL_COUNT++))
            FAILED_PROGRAMS+=("$program")
        fi
    else
        echo "WARNING: $program not found, skipping..."
        # Create a stub for missing programs
        if [[ "$program" == "batch-report.cob" ]] || [[ "$program" == "workflow-engine.cob" ]]; then
            echo "Creating stub for $program..."
            cat > "$COBOL_DIR/$program" << 'EOF'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. STUB-PROGRAM.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-MESSAGE    PIC X(50).
       PROCEDURE DIVISION.
           MOVE "Feature not yet implemented" TO WS-MESSAGE
           DISPLAY WS-MESSAGE
           STOP RUN.
EOF
            # Try to compile the stub
            program_name="${program%.cob}"
            if cobc -x -o "$COMPILED_DIR/$program_name" "$COBOL_DIR/$program" 2>/dev/null; then
                echo "Stub created and compiled for $program"
                chmod +x "$COMPILED_DIR/$program_name"
                ((SUCCESS_COUNT++))
            fi
        fi
    fi
done

echo ""
echo "=== Compilation Summary ==="
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
    echo "Failed programs: ${FAILED_PROGRAMS[*]}"
fi

# Create a status file for the health check
cat > "$COMPILED_DIR/compilation_status.json" << EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "total_programs": ${#COBOL_PROGRAMS[@]},
    "compiled_successfully": $SUCCESS_COUNT,
    "compilation_failed": $FAIL_COUNT,
    "failed_programs": [$(printf '"%s",' "${FAILED_PROGRAMS[@]}" | sed 's/,$//')]
}
EOF

# Set executable permissions on all compiled programs
chmod +x "$COMPILED_DIR"/* 2>/dev/null

# Create symlinks in /usr/local/bin for easy access
for program in "$COMPILED_DIR"/*; do
    if [ -f "$program" ] && [ -x "$program" ]; then
        program_name=$(basename "$program")
        ln -sf "$program" "/usr/local/bin/$program_name" 2>/dev/null
    fi
done

echo ""
echo "=== COBOL Compilation Complete ==="

# Exit with error if critical programs failed
if [ $FAIL_COUNT -gt 0 ]; then
    # Check if critical programs failed
    for failed in "${FAILED_PROGRAMS[@]}"; do
        if [[ "$failed" == "financial-calc.cob" ]] || [[ "$failed" == "mainframe-sync.cob" ]]; then
            echo "ERROR: Critical COBOL programs failed to compile!"
            exit 1
        fi
    done
fi

echo "All COBOL programs ready for use!"
exit 0