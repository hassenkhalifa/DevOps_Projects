#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Header
echo -e "${CYAN}"
cat << "EOF"
▖       ▄▖    ▌ ▘      ▄▖    ▜ 
▌ ▛▌▛▌  ▌▌▛▘▛▘▛▌▌▌▌█▌  ▐ ▛▌▛▌▐ 
▙▖▙▌▙▌  ▛▌▌ ▙▖▌▌▌▚▘▙▖  ▐ ▙▌▙▌▐▖
    ▄▌   
EOF
echo -e "${NC}"

# Check if an argument was provided
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 /path/to/destination_directory${NC}"
    exit 1
fi

destination_directory="$1"

# Check if the directory exists
if [ ! -d "$destination_directory" ]; then
    echo -e "${RED}Error: The directory '$destination_directory' does not exist.${NC}"
    exit 1
fi

# Check if the directory is writable
if [ ! -w "$destination_directory" ]; then
    echo -e "${RED}Error: You do not have write permissions for '$destination_directory'.${NC}"
    exit 1
fi

# Generate a timestamp
current_date=$(date +%Y%m%d_%H%M%S)

# Define the archive name
archive_name="log_archive_${current_date}.tar.gz"

# Create the compressed archive
echo -e "${YELLOW}Creating archive...${NC}"
tar -czf "$archive_name" /var/log

# Check if the archive was created successfully
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to create the archive.${NC}"
    exit 1
fi

# Move the archive to the destination directory
echo -e "${YELLOW}Moving archive to destination directory...${NC}"
mv "$archive_name" "$destination_directory"/

# Check if the move operation was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to move the archive to '$destination_directory'.${NC}"
    exit 1
fi

echo -e "${GREEN}Archive created and moved successfully: $destination_directory/$archive_name${NC}"

