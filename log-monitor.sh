#!/bin/bash

# Define variables
LOG_FILE="name_of_your_logfile.log" #give the name of the required log file.
KEYWORDS=("error" "404" "500")
LOG_DIR="logs"
SUMMARY_FILE="${LOG_DIR}/summary.txt"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to monitor log file
monitor_log() {
    echo "Monitoring log file: ${LOG_FILE}"
    tail -f "${LOG_FILE}" | while read line; do
        echo "$line"
        analyze_log "$line"
    done
}

# Function to analyze log entries
analyze_log() {
    log_entry="$1"
    for keyword in "${KEYWORDS[@]}"; do
        if [[ $log_entry == *"$keyword"* ]]; then
            echo "Found keyword: $keyword"
            echo "$log_entry" >> "${LOG_DIR}/${keyword}.log"
        fi
    done
}

# Function to generate summary report
generate_summary() {
    echo "Generating summary report..."
    for keyword in "${KEYWORDS[@]}"; do
        echo "Top occurrences of '$keyword':" >> "${SUMMARY_FILE}"
        sort "${LOG_DIR}/${keyword}.log" | uniq -c | sort -nr | head -n 5 >> "${SUMMARY_FILE}"
        echo -e "\n\n" >> "${SUMMARY_FILE}"
    done
}

# Function to handle Ctrl+C
trap 'generate_summary; echo "Exiting..."; exit' INT

# Main function
main() {
    monitor_log
}

# Run main function
main

