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
▖ ▖  ▘      ▖       ▄▖    ▜
▛▖▌▛▌▌▛▌▚▘  ▌ ▛▌▛▌  ▌▌▛▌▀▌▐ ▌▌▛▘█▌▛▘
▌▝▌▙▌▌▌▌▞▖  ▙▖▙▌▙▌  ▛▌▌▌█▌▐▖▙▌▄▌▙▖▌
   ▄▌           ▄▌          ▄▌
EOF
echo -e "${NC}"

# Function to download logs
download_logs() {
    echo -e "${YELLOW}Downloading the log file...${NC}"
    wget -q -O nginx_logs.log https://gist.githubusercontent.com/kamranahmedse/e66c3b9ea89a1a030d3b739eeeef22d0/raw/77fb3ac837a73c4f0206e78a236d885590b7ae35/nginx-access.log
    echo -e "${GREEN}Download completed.${NC}"
}

# Function to display top 5 IP addresses with the most requests
top_5_ips() {
    echo -e "${BLUE}Top 5 IP addresses with the most requests:${NC}"
    awk '{print $1}' nginx_logs.log | sort | uniq -c | sort -nr | head -n 5 | \
    awk '{printf "IP: %s - Number of requests: %s\n", $2, $1}'
    echo ""
}

# Function to display top 5 most requested paths
top_5_paths() {
    echo -e "${BLUE}Top 5 most requested paths:${NC}"
    awk '{print $7}' nginx_logs.log | sort | uniq -c | sort -nr | head -n 5 | \
    awk '{printf "Path: %s - Number of requests: %s\n", $2, $1}'
    echo ""
}

# Function to display top 5 HTTP status codes
top_5_status_codes() {
    echo -e "${BLUE}Top 5 HTTP status codes:${NC}"
    awk '{print $9}' nginx_logs.log | sort | uniq -c | sort -nr | head -n 5 | \
    awk '{printf "Status code: %s - Number of requests: %s\n", $2, $1}'
    echo ""
}

# Function to display top 5 user agents
top_5_user_agents() {
    echo -e "${BLUE}Top 5 User Agents:${NC}"
    awk -F'"' '{print $6}' nginx_logs.log | sort | uniq -c | sort -nr | head -n 5 | \
    awk '{count=$1; $1=""; print "User-Agent:", substr($0,2), "- Number of requests:", count}'
    echo ""
}

# Function to run all analysis functions
run_all_analyses() {
    top_5_ips
    top_5_paths
    top_5_status_codes
    top_5_user_agents
}

# Main execution
if [ -f "./nginx_logs.log" ]; then
    echo -e "${GREEN}Log file found. Starting analysis...${NC}"
    run_all_analyses
else
    echo -e "${YELLOW}Log file not found. Initiating download...${NC}"
    download_logs
    echo -e "${GREEN}Starting analysis...${NC}"
    run_all_analyses
fi
