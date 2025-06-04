#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Header
echo -e "${CYAN}"
cat << "EOF"
▄▖            ▄▖    ▐▘                 ▄▖▗   ▗   
▚ █▌▛▘▌▌█▌▛▘  ▙▌█▌▛▘▜▘▛▌▛▘▛▛▌▀▌▛▌▛▘█▌  ▚ ▜▘▀▌▜▘▛▘
▄▌▙▖▌ ▚▘▙▖▌   ▌ ▙▖▌ ▐ ▙▌▌ ▌▌▌█▌▌▌▙▖▙▖  ▄▌▐▖█▌▐▖▄▌
EOF
echo -e "${NC}"


echo -e "${BLUE}# CPU USAGE #${NC}"
cpu_col=$(top -bn1 | awk 'NR==7 {for (i=1; i<=NF; i++) if ($i == "%CPU") print i}')
cpu_usaged=$(top -bn1 | tail -n +7 | awk -v col="$cpu_col" 'NR>1 {sum += $col} END {print sum}')
echo -e "${YELLOW}${cpu_usaged}% of CPU used${NC}"

echo -e "${BLUE}# MEMORY USAGE #${NC}"
used_mem=$(free --mega | grep 'Mem:' -w | awk '{print $3}')
free_mem=$(free --mega | grep 'Mem:' -w | awk '{print $4}')
echo -e "${YELLOW}${used_mem} MB Used${NC}"
echo -e "${GREEN}${free_mem} MB Free${NC}"

echo -e "${BLUE}# DISK USAGE #${NC}"
total_disk_size=$(df -h --total | awk '/^total/ {print $2}')
disk_usaged=$(df -h --total | awk '/^total/ {print $3}')
free_disk_space=$(df -h --total | awk '/^total/ {print $4}')
used_percentage=$(df -h --total | awk '/^total/ {print $5}')
used_number="${used_percentage%\%}"
free_percentage=$((100 - used_number))
echo -e "${YELLOW}Total Disk Size: ${total_disk_size}${NC}"
echo -e "${YELLOW}Used Disk Space: ${disk_usaged}${NC}"
echo -e "${GREEN}Free Disk Space: ${free_disk_space}${NC}"
echo -e "${RED}Disk Usage: ${used_percentage}${NC}"
echo -e "${GREEN}Disk Free: ${free_percentage}%${NC}"

echo -e "${BLUE}# TOP 5 CPU USAGE #${NC}"
ps -eo user,pid,%cpu,%mem --sort=-%cpu | head -n 6

echo -e "${BLUE}# TOP 5 MEMORY USAGE #${NC}"
ps -eo user,pid,%cpu,%mem --sort=-%mem | head -n 6
