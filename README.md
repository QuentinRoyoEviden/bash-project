Infiniband Switch Port Verification (ibnetdiscover_qr.sh)

This script verifies the status of ports on a specific Infiniband switch in a cluster. It compares the current output of the ibnetdiscover command on the cluster with a reference file to instantly detect DOWN links and ignore random links.

# Features

Targeted verification: Isolates and analyzes a single switch to avoid having to search through all switches.
Regex format: Validates the switch name format (e.g., iswi1r2s5c0l2) to ensure optimal output.
Comparison: Ignores LIDs to focus only on physical links.
Secure: Automatically cleans up temporary files to avoid overloading storage.

# Prerequisites

* Linux-based OS with bash.
* Standard Infiniband tools installed (ibnetdiscover).
* Basic commands: grep, sed, diff, and cut.

# Usage

The script requires at least two arguments: the reference file and the switch name.

# Syntax

./ibnetdiscover_qr.sh --file_ref: <reference_file_path> --switch: <switch_name>
