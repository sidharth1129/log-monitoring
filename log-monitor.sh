#!/bin/bash

# Check if a log file is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

logfile="$1"

# Check if the log file exists
if [ ! -f "$logfile" ]; then
    echo "Error: Log file '$logfile' not found."
    exit 1
fi

# Define variables
KEYWORDS=("error" "404" "500")
LOG_DIR="logs"
SUMMARY_FILE="${LOG_DIR}/summary.txt"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to monitor the log file for new entries
monitor_log() {
    echo "Monitoring $logfile for new entries..."

    # Continuous monitoring using tail
    tail -n 0 -f "$logfile" | while read line; do
        echo "$line"  # Display new log entries in real time
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

