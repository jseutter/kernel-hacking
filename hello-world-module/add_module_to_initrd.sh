#!/bin/bash
#
# SCRIPT: add_module_to_initrd.sh
# DESCRIPTION: Takes a compiled kernel module (.ko file) and injects it
#              into the existing initrd.img, updating the image in place.
#
# USAGE: ./add_module_to_initrd.sh /path/to/your/module.ko /path/to/initrd.img

# --- Configuration ---
MODULE_FILE="$1"
INITRD_PATH="$2"
TMP_DIR="initrd_temp_$$" # Use $$ for a unique temporary directory name

# --- Helper Functions ---

# Function to safely clean up temporary files
cleanup() {
    echo "Cleaning up temporary directory: $TMP_DIR"
    rm -rf "$TMP_DIR"
}

# Function to determine the compression type of the initrd file
get_compression_type() {
    # Check magic bytes for common compression formats
    local magic_bytes=$(head -c 4 "$INITRD_PATH")
    
    if [[ "$magic_bytes" == $'\x1f\x8b\x08'* ]]; then
        echo "gzip"
    elif [[ "$magic_bytes" == $'\xfd7zXZ' ]]; then
        echo "xz"
    elif [[ "$magic_bytes" == $'\x71\x0f' ]]; then
        # Check for uncompressed CPIO header (rare, but possible)
        echo "none"
    else
        echo "unknown"
    fi
}

# --- Main Logic ---

# 1. Argument Validation
if [ -z "$MODULE_FILE" ] || [ -z "$INITRD_PATH" ]; then
    echo "Usage: $0 <path/to/module.ko> <path/to/initrd.img>"
    exit 1
fi

if [ ! -f "$MODULE_FILE" ]; then
    echo "Error: Module file not found: $MODULE_FILE"
    exit 1
fi

if [ ! -f "$INITRD_PATH" ]; then
    echo "Error: initrd file not found: $INITRD_PATH"
    exit 1
fi

# Ensure cleanup runs on script exit or interruption
trap cleanup EXIT SIGHUP SIGINT SIGTERM

echo "--- Starting Kernel Module Injection ---"
echo "Module to inject: $(basename "$MODULE_FILE")"
echo "Target initrd: $INITRD_PATH"
echo "---------------------------------------"

# 2. Preparation and Extraction
mkdir "$TMP_DIR"
cp "$INITRD_PATH" "$TMP_DIR/initrd.bak" # Backup the original

INITRD_BAK="$TMP_DIR/initrd.bak"

# 2a. Decompress the initrd
COMPRESSION=$(get_compression_type)

echo "Detected compression type: $COMPRESSION"

case "$COMPRESSION" in
    "gzip")
        gunzip -c "$INITRD_BAK" > "$TMP_DIR/initrd.cpio"
        ;;
    "xz")
        unxz -c "$INITRD_BAK" > "$TMP_DIR/initrd.cpio"
        ;;
    "none")
        cp "$INITRD_BAK" "$TMP_DIR/initrd.cpio"
        ;;
    "unknown")
        echo "Error: Unknown compression format for initrd.img. Cannot proceed."
        exit 1
        ;;
esac

# 2b. Extract the CPIO archive
cd "$TMP_DIR"
mkdir extract
cd extract

echo "Extracting CPIO archive..."
if ! cpio -idm < ../initrd.cpio; then
    echo "Error: Failed to extract CPIO archive. It might be corrupted or not a CPIO file."
    exit 1
fi

# 3. Inject the Module
echo "Copying $(basename "$MODULE_FILE") into the extracted root..."
cp "$MODULE_FILE" .

# 4. Rebuild the initrd
echo "Rebuilding the CPIO archive..."
# Use find to list all files and cpio to archive them in the newc format
find . -print0 | cpio -o -H newc --null > ../new_initrd.cpio

# 5. Compression and Final Replacement
cd ..

echo "Compressing the new initrd with $COMPRESSION..."

if [ "$COMPRESSION" == "gzip" ]; then
    gzip -c new_initrd.cpio > "$INITRD_PATH.new"
elif [ "$COMPRESSION" == "xz" ]; then
    xz -c new_initrd.cpio > "$INITRD_PATH.new"
elif [ "$COMPRESSION" == "none" ]; then
    cp new_initrd.cpio "$INITRD_PATH.new"
fi

# Replace the original file
mv -f "$INITRD_PATH.new" "$INITRD_PATH"

echo "---------------------------------------"
echo "✅ SUCCESS: initrd.img has been updated with $(basename "$MODULE_FILE")."
echo "You can now boot QEMU and use 'insmod $(basename "$MODULE_FILE")' inside the guest."

# Cleanup trap will run automatically here
