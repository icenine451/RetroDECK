# This script provides a logging function 'log' that can be sourced in other scripts.
# It logs messages to both the terminal and a specified logfile, allowing different log levels.
# The log function takes three parameters: log level, log message, and optionally the logfile. If no logfile is specified, it writes to retrodeck/logs/retrodeck.log

# Example usage:
# log w "foo" -> logs a warning with message foo in the default log file retrodeck/logs/retrodeck.log
# log e "bar" -> logs an error with message bar in the default log file retrodeck/logs/retrodeck.log
# log i "par" rekku.log -> logs an information with message in the specified log file inside the logs folder retrodeck/logs/rekku.log

if [ "${log_init:-false}" = false ]; then
    logs_folder=${logs_folder:-"/tmp"}
    touch "$logs_folder/retrodeck.log"
    # exec > >(tee "$logs_folder/retrodeck.log") 2>&1 # this is broken, creates strange artifacts and corrupts the log file
    log_init=true
fi

log() {

    # exec > >(tee "$logs_folder/retrodeck.log") 2>&1 # this is broken, creates strange artifacts and corrupts the log file

    local level="$1"
    local message="$2"
    local timestamp="$(date +[%Y-%m-%d\ %H:%M:%S.%3N])"
    local colorize_terminal

    # Use specified logfile or default to retrodeck.log
    local logfile
    if [ -n "$3" ]; then
        logfile="$3"
    else
        logfile="$logs_folder/retrodeck.log"
    fi

    # Check if the shell is sh (not bash or zsh) to avoid colorization
    if [ "${SHELL##*/}" = "sh" ]; then
        colorize_terminal=false
    else
        colorize_terminal=true
    fi

    case "$level" in
        w) 
            if [ "$colorize_terminal" = true ]; then
                # Warning (yellow) for terminal
                colored_message="\e[33m[WARN]\e[0m $message"
            else
                # Warning (no color for sh) for terminal
                colored_message="$timestamp [WARN] $message"
            fi
            # Write to log file without colorization
            log_message="$timestamp [WARN] $message"
            ;;
        e) 
            if [ "$colorize_terminal" = true ]; then
                # Error (red) for terminal
                colored_message="\e[31m[ERROR]\e[0m $message"
            else
                # Error (no color for sh) for terminal
                colored_message="$timestamp [ERROR] $message"
            fi
            # Write to log file without colorization
            log_message="$timestamp [ERROR] $message"
            ;;
        i) 
            if [ "$colorize_terminal" = true ]; then
                # Info (green) for terminal
                colored_message="\e[32m[INFO]\e[0m $message"
            else
                # Info (no color for sh) for terminal
                colored_message="$timestamp [INFO] $message"
            fi
            # Write to log file without colorization
            log_message="$timestamp [INFO] $message"
            ;;
        d) 
            if [ "$colorize_terminal" = true ]; then
                # Debug (green) for terminal
                colored_message="\e[32m[DEBUG]\e[0m $message"
            else
                # Debug (no color for sh) for terminal
                colored_message="$timestamp [DEBUG] $message"
            fi
            # Write to log file without colorization
            log_message="$timestamp [DEBUG] $message"
            ;;
        *) 
            # Default (no color for other shells) for terminal
            colored_message="$timestamp $message"
            # Write to log file without colorization
            log_message="$timestamp $message"
            ;;
    esac

    # Display the message in the terminal
    echo -e "$colored_message"

    # Write the log message to the log file
    echo "$log_message" >> "$logfile"

}

# This function is merging the temporary log file into the actual one
tmplog_merger() {

    # Check if /tmp/retrodeck.log exists
    if [ -e "/tmp/retrodeck.log" ]; then

        # Sort both temporary and existing log files by timestamp
        sort -k1,1n -k2,2M -k3,3n -k4,4n -k5,5n "/tmp/retrodeck.log" "$logs_folder/retrodeck.log" > "$logs_folder/merged_logs.tmp"

        # Move the merged logs to replace the original log file
        mv "$logs_folder/merged_logs.tmp" "$logs_folder/retrodeck.log"

        # Remove the temporary file
        rm "/tmp/retrodeck.log"
    fi
}
