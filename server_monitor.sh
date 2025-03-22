#!/bin/bash

# Server Monitor - A bash application to monitor Linux servers
# Author: Trae AI

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'

# Server data file
SERVER_FILE="servers.dat"

# Create server file if it doesn't exist
if [ ! -f "$SERVER_FILE" ]; then
    touch "$SERVER_FILE"
fi

# Function to display the header
display_header() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║                   ${GREEN}SERVER MONITORING TOOL${BLUE}                  ║${RESET}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# Function to display the main menu
display_menu() {
    display_header
    echo -e "${CYAN}1.${RESET} Monitor Server"
    echo -e "${CYAN}2.${RESET} Add Server"
    echo -e "${CYAN}3.${RESET} Edit Server"
    echo -e "${CYAN}4.${RESET} Delete Server"
    echo -e "${CYAN}5.${RESET} List Servers"
    echo -e "${CYAN}0.${RESET} Exit"
    echo ""
    echo -e "${YELLOW}Please enter your choice:${RESET} "
}

 # Function to encrypt password
encrypt_password() {
    local password=$1
    # Simple encryption using base64 (for demonstration - in production use stronger encryption)
    echo $(echo "$password" | base64)
}

# Function to decrypt password
decrypt_password() {
    local encrypted=$1
    # Decrypt the base64 encoded password
    echo $(echo "$encrypted" | base64 --decode)
}

# Function to add a server
add_server() {
    display_header
    echo -e "${GREEN}=== Add New Server ===${RESET}"
    
    # Get server details
    read -p "Enter server name: " name
    read -p "Enter server IP: " ip
    read -p "Enter SSH port (default: 22): " port
    port=${port:-22}
    read -p "Enter username: " username
    read -s -p "Enter password: " password
    echo ""
    
    # Encrypt password before storing
    encrypted_password=$(encrypt_password "$password")
    
    # Add server to the file
    echo "$name:$ip:$port:$username:$encrypted_password" >> "$SERVER_FILE"
    
    echo -e "\n${GREEN}Server added successfully!${RESET}"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to edit a server
edit_server() {
    display_header
    echo -e "${GREEN}=== Edit Server ===${RESET}"
    
    if [ ! -s "$SERVER_FILE" ]; then
        echo -e "${RED}No servers found.${RESET}"
        read -n 1 -s -r -p "Press any key to continue..."
        return
    fi
    
    echo -e "${CYAN}ID | Name | IP | Port | Username${RESET}"
    echo -e "${CYAN}----------------------------------${RESET}"
    
    id=1
    while IFS=: read -r name ip port username password; do
        echo -e "${id} | ${name} | ${ip} | ${port} | ${username}"
        id=$((id+1))
    done < "$SERVER_FILE"
    
    echo ""
    read -p "Enter the ID of the server to edit: " server_id
    
    # Validate input
    if ! [[ "$server_id" =~ ^[0-9]+$ ]] || [ "$server_id" -lt 1 ] || [ "$server_id" -gt $((id-1)) ]; then
        echo -e "${RED}Invalid server ID.${RESET}"
        read -n 1 -s -r -p "Press any key to continue..."
        return
    fi
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Read the server file line by line
    id=1
    while IFS=: read -r name ip port username password; do
        if [ "$id" -eq "$server_id" ]; then
            echo -e "\n${YELLOW}Editing server: ${name}${RESET}"
            read -p "Enter new server name [$name]: " new_name
            read -p "Enter new server IP [$ip]: " new_ip
            read -p "Enter new SSH port [$port]: " new_port
            read -p "Enter new username [$username]: " new_username
            read -s -p "Enter new password (leave empty to keep current): " new_password
            echo ""
            
            # Use current values if new ones are not provided
            new_name=${new_name:-$name}
            new_ip=${new_ip:-$ip}
            new_port=${new_port:-$port}
            new_username=${new_username:-$username}
            
            # Encrypt new password if provided, otherwise keep the old encrypted password
            if [ -n "$new_password" ]; then
                new_encrypted_password=$(encrypt_password "$new_password")
            else
                new_encrypted_password=$encrypted_password
            fi
            
            echo "$new_name:$new_ip:$new_port:$new_username:$new_encrypted_password" >> "$temp_file"
        else
            echo "$name:$ip:$port:$username:$encrypted_password" >> "$temp_file"
        fi
        id=$((id+1))
    done < "$SERVER_FILE"
    
    # Replace the original file with the temporary file
    mv "$temp_file" "$SERVER_FILE"
    
    echo -e "\n${GREEN}Server updated successfully!${RESET}"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to delete a server
delete_server() {
    display_header
    echo -e "${GREEN}=== Delete Server ===${RESET}"
    
    if [ ! -s "$SERVER_FILE" ]; then
        echo -e "${RED}No servers found.${RESET}"
        read -n 1 -s -r -p "Press any key to continue..."
        return
    fi
    
    echo -e "${CYAN}ID | Name | IP | Port | Username${RESET}"
    echo -e "${CYAN}----------------------------------${RESET}"
    
    id=1
    while IFS=: read -r name ip port username password; do
        echo -e "${id} | ${name} | ${ip} | ${port} | ${username}"
        id=$((id+1))
    done < "$SERVER_FILE"
    
    echo ""
    read -p "Enter the ID of the server to delete: " server_id
    
    # Validate input
    if ! [[ "$server_id" =~ ^[0-9]+$ ]] || [ "$server_id" -lt 1 ] || [ "$server_id" -gt $((id-1)) ]; then
        echo -e "${RED}Invalid server ID.${RESET}"
        read -n 1 -s -r -p "Press any key to continue..."
        return
    fi
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Read the server file line by line
    id=1
    while IFS=: read -r name ip port username password; do
        if [ "$id" -ne "$server_id" ]; then
            echo "$name:$ip:$port:$username:$password" >> "$temp_file"
        fi
        id=$((id+1))
    done < "$SERVER_FILE"
    
    # Replace the original file with the temporary file
    mv "$temp_file" "$SERVER_FILE"
    
    echo -e "\n${GREEN}Server deleted successfully!${RESET}"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to draw a bar graph
draw_bar_graph() {
    local value=$1
    local max=$2
    local width=50
    local bar_width=$((value * width / max))
    
    printf "${YELLOW}["
    for ((i=0; i<width; i++)); do
        if [ $i -lt $bar_width ]; then
            printf "${GREEN}█"
        else
            printf "${RED}░"
        fi
    done
    printf "${YELLOW}] ${value}%%${RESET}\n"
}

# Function to draw a line graph
draw_line_graph() {
    local title=$1
    local data=($2)
    local max_value=0
    local width=50
    local height=10
    
    # Find the maximum value
    for value in "${data[@]}"; do
        if (( $(echo "$value > $max_value" | bc -l) )); then
            max_value=$value
        fi
    done
    
    # Ensure max_value is not zero to avoid division by zero
    if (( $(echo "$max_value == 0" | bc -l) )); then
        max_value=1
    fi
    
    echo -e "${CYAN}$title${RESET}"
    
    # Draw the graph
    for ((y=height; y>=0; y--)); do
        printf "${YELLOW}%3d%% " $((y * 100 / height))
        
        for ((x=0; x<${#data[@]}; x++)); do
            value=${data[$x]}
            bar_height=$(echo "$value * $height / $max_value" | bc -l)
            bar_height=${bar_height%.*}
            
            if [ $y -le $bar_height ]; then
                printf "${GREEN}█"
            else
                printf " "
            fi
        done
        
        echo -e "${RESET}"
    done
    
    # Draw the x-axis
    printf "     "
    for ((x=0; x<${#data[@]}; x++)); do
        printf "─"
    done
    echo ""
    
    # Draw the time labels
    printf "     "
    for ((x=0; x<${#data[@]}; x+=5)); do
        printf "${YELLOW}${x}s${RESET}"
        # Add spaces to align with the graph
        if [ $x -lt 10 ]; then
            printf "   "
        else
            printf "  "
        fi
    done
    echo ""
}

# Function to monitor a server
monitor_server() {
    display_header
    echo -e "${GREEN}=== Monitor Server ===${RESET}"
    
    if [ ! -s "$SERVER_FILE" ]; then
        echo -e "${RED}No servers found.${RESET}"
        read -n 1 -s -r -p "Press any key to continue..."
        return
    fi
    
    echo -e "${CYAN}ID | Name | IP | Port | Username${RESET}"
    echo -e "${CYAN}----------------------------------${RESET}"
    
    id=1
    while IFS=: read -r name ip port username password; do
        echo -e "${id} | ${name} | ${ip} | ${port} | ${username}"
        id=$((id+1))
    done < "$SERVER_FILE"
    
    echo ""
    read -p "Enter the ID of the server to monitor: " server_id
    
    # Validate input
    if ! [[ "$server_id" =~ ^[0-9]+$ ]] || [ "$server_id" -lt 1 ] || [ "$server_id" -gt $((id-1)) ]; then
        echo -e "${RED}Invalid server ID.${RESET}"
        read -n 1 -s -r -p "Press any key to continue..."
        return
    fi
    
    # Get server details
    server_line=$(sed -n "${server_id}p" "$SERVER_FILE")
    IFS=: read -r name ip port username encrypted_password <<< "$server_line"
    
    # Start monitoring
    monitor_metrics "$name" "$ip" "$port" "$username" "$encrypted_password"
}

# Function to monitor server metrics
monitor_metrics() {
    local name=$1
    local ip=$2
    local port=$3
    local username=$4
    local encrypted_password=$5
    
    # Decrypt password for use
    local password=$(decrypt_password "$encrypted_password")
    
    # Variables to track previous values for network calculations
    prev_rx_bytes=0
    prev_tx_bytes=0
    
    # Monitoring loop
    while true; do
        # Start time measurement for performance tracking
        start_time=$(date +%s.%N)
        
        # Clear screen each time
        display_header
        
        echo -e "${GREEN}Monitoring Server: ${YELLOW}$name ${GREEN}(${YELLOW}$ip${GREEN})${RESET}"
        echo -e "${CYAN}Press 'q' to return to the main menu${RESET}"
        echo -e "${CYAN}Data refreshes every 30 seconds. Last update: $(date +"%H:%M:%S")${RESET}"
        echo ""
        
        # Optimize by combining commands in a single SSH session - fixed grep issues
        server_data=$(sshpass -p "$password" ssh -p "$port" -o StrictHostKeyChecking=no "$username@$ip" "
            echo '--- CPU INFO ---'
            cat /proc/stat | grep '^cpu'
            echo '--- LOAD INFO ---'
            cat /proc/loadavg
            echo '--- CPU COUNT ---'
            nproc
            echo '--- MEM INFO ---'
            cat /proc/meminfo | grep -E 'MemTotal|MemFree|Buffers|Cached'
            echo '--- FREE INFO ---'
            free -m
            echo '--- NET INFO ---'
            cat /proc/net/dev
            echo '--- DISK INFO ---'
            df -h
        ")
        
        # Parse CPU info - fixed to use proper pattern matching
        cpu_info=$(echo "$server_data" | awk '/^--- CPU INFO ---$/,/^--- LOAD INFO ---$/' | grep '^cpu')
        load_line=$(echo "$server_data" | awk '/^--- LOAD INFO ---$/,/^--- CPU COUNT ---$/' | grep -v "^--- LOAD INFO ---$" | grep -v "^--- CPU COUNT ---$")
        num_cores=$(echo "$server_data" | awk '/^--- CPU COUNT ---$/,/^--- MEM INFO ---$/' | grep -v "^--- CPU COUNT ---$" | grep -v "^--- MEM INFO ---$")
        
        # Parse overall CPU usage
        cpu_line=$(echo "$cpu_info" | head -n 1)
        
        # Check if we have valid CPU data
        if [[ -n "$cpu_line" ]]; then
            cpu_values=($cpu_line)
            user=${cpu_values[1]}
            nice=${cpu_values[2]}
            system=${cpu_values[3]}
            idle=${cpu_values[4]}
            iowait=${cpu_values[5]}
            irq=${cpu_values[6]}
            softirq=${cpu_values[7]}
            
            total=$((user + nice + system + idle + iowait + irq + softirq))
            idle_pct=$((100 * idle / total))
            cpu_pct=$((100 - idle_pct))
        else
            cpu_pct=0
        fi
        
        # Parse memory usage
        mem_info=$(echo "$server_data" | awk '/^--- MEM INFO ---$/,/^--- FREE INFO ---$/')
        free_info=$(echo "$server_data" | awk '/^--- FREE INFO ---$/,/^--- NET INFO ---$/')
        
        mem_total=$(echo "$mem_info" | grep "MemTotal" | awk '{print $2}')
        mem_free=$(echo "$mem_info" | grep "MemFree" | awk '{print $2}')
        buffers=$(echo "$mem_info" | grep "Buffers" | awk '{print $2}')
        cached=$(echo "$mem_info" | grep "Cached" | grep -v "SwapCached" | awk '{print $2}')
        
        # Check if we have valid memory data
        if [[ -n "$mem_total" && -n "$mem_free" && -n "$buffers" && -n "$cached" ]]; then
            mem_used=$((mem_total - mem_free - buffers - cached))
            mem_pct=$((100 * mem_used / mem_total))
        else
            mem_pct=0
        fi
        
        # Parse network usage
        net_info=$(echo "$server_data" | awk '/^--- NET INFO ---$/,/^--- DISK INFO ---$/' | grep -v "lo:")
        
        # Parse network usage
        rx_bytes=0
        tx_bytes=0
        
        while read -r line; do
            if [[ $line =~ [0-9]+:[[:space:]]+([^:]+):[[:space:]]+([0-9]+)[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+([0-9]+) ]]; then
                interface=${BASH_REMATCH[1]}
                rx_bytes=$((rx_bytes + ${BASH_REMATCH[2]}))
                tx_bytes=$((tx_bytes + ${BASH_REMATCH[3]}))
            fi
        done <<< "$net_info"
        
        # Calculate network rate (bytes per second)
        if [ $prev_rx_bytes -ne 0 ]; then
            rx_rate=$(( (rx_bytes - prev_rx_bytes) / 30 ))  # 30 second interval
            tx_rate=$(( (tx_bytes - prev_tx_bytes) / 30 ))
            
            # Convert to KB/s for display
            rx_rate_kb=$(echo "scale=2; $rx_rate / 1024" | bc)
            tx_rate_kb=$(echo "scale=2; $tx_rate / 1024" | bc)
        else
            rx_rate_kb="0.00"
            tx_rate_kb="0.00"
        fi
        
        # Store current values for next iteration
        prev_rx_bytes=$rx_bytes
        prev_tx_bytes=$tx_bytes
        
        # Convert to MB for display
        rx_mb=$(echo "scale=2; $rx_bytes / 1048576" | bc)
        tx_mb=$(echo "scale=2; $tx_bytes / 1048576" | bc)
        
        # Parse disk usage
        disk_info=$(echo "$server_data" | awk '/^--- DISK INFO ---$/,0' | grep -v "^--- DISK INFO ---$")
        
        # Display CPU metrics
        echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${BLUE}║                      ${GREEN}CPU METRICS${BLUE}                          ║${RESET}"
        echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${RESET}"
        echo -e "${CYAN}Overall CPU Usage:${RESET}"
        draw_bar_graph $cpu_pct 100
        
        # Display individual CPU core usage - FIXED to only show actual cores
        # Get the actual CPU core lines (excluding the aggregate cpu line)
        core_lines=$(echo "$cpu_info" | grep -v "^cpu " | grep "^cpu[0-9]")
        core_count=$(echo "$core_lines" | wc -l)
        
        echo -e "${CYAN}Individual CPU Core Usage (${core_count:-0} cores detected):${RESET}"
        
        # Only process if we have actual cores
        if [[ $core_count -gt 0 ]]; then
            # Process each actual CPU core line
            while IFS= read -r core_line; do
                if [[ -n "$core_line" ]]; then
                    # Extract the core number from the line (e.g., "cpu0" -> "0")
                    core_num=$(echo "$core_line" | sed -E 's/cpu([0-9]+).*/\1/')
                    
                    core_values=($core_line)
                    core_user=${core_values[1]}
                    core_nice=${core_values[2]}
                    core_system=${core_values[3]}
                    core_idle=${core_values[4]}
                    core_iowait=${core_values[5]}
                    core_irq=${core_values[6]}
                    core_softirq=${core_values[7]}
                    
                    core_total=$((core_user + core_nice + core_system + core_idle + core_iowait + core_irq + core_softirq))
                    core_idle_pct=$((100 * core_idle / core_total))
                    core_pct=$((100 - core_idle_pct))
                    
                    echo -e "${CYAN}CPU Core $((core_num+1)):${RESET}"
                    draw_bar_graph $core_pct 100
                fi
            done <<< "$core_lines"
        else
            echo -e "${YELLOW}No individual CPU cores detected${RESET}"
        fi
        
        echo -e "${CYAN}Load Average:${RESET} ${load_line}"
        echo ""
        
        # Display Memory metrics
        echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${BLUE}║                    ${GREEN}MEMORY METRICS${BLUE}                         ║${RESET}"
        echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${RESET}"
        echo -e "${CYAN}Memory Usage:${RESET}"
        draw_bar_graph $mem_pct 100
        
        # Display swap info - fixed to properly extract swap info
        swap_info=$(echo "$free_info" | grep -A 1 "Swap:" | tail -n 1)
        echo -e "${CYAN}Swap Usage:${RESET} ${swap_info}"
        echo ""
        
        # Display Network metrics
        echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${BLUE}║                    ${GREEN}NETWORK METRICS${BLUE}                        ║${RESET}"
        echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${RESET}"
        echo -e "${CYAN}Total Received:${RESET} ${rx_mb} MB"
        echo -e "${CYAN}Total Transmitted:${RESET} ${tx_mb} MB"
        echo -e "${CYAN}Current RX Rate:${RESET} ${rx_rate_kb} KB/s"
        echo -e "${CYAN}Current TX Rate:${RESET} ${tx_rate_kb} KB/s"
        echo ""
        
        # Display Disk metrics
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${BLUE}║                      ${GREEN}DISK METRICS${BLUE}                        ║${RESET}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${RESET}"
        echo -e "${CYAN}Disk Space Usage:${RESET}"
        echo "$disk_info" | grep -v "tmpfs" | grep -v "udev" | grep -v "cdrom" | head -n 10
        echo ""
        
        # Calculate how long the data collection and display took
        end_time=$(date +%s.%N)
        execution_time=$(echo "$end_time - $start_time" | bc)
        echo -e "${CYAN}Data collection and display completed in ${execution_time} seconds${RESET}"
        
        # Wait for remaining time to complete 30 seconds, but check for 'q' key press every 0.1 seconds
        remaining_time=$(echo "30 - $execution_time" | bc)
        remaining_time=${remaining_time%.*}
        
        # Ensure remaining_time is positive
        if (( $(echo "$remaining_time > 0" | bc -l) )); then
            for ((i=0; i<$(echo "$remaining_time * 10" | bc | cut -d. -f1); i++)); do
                read -t 0.1 -n 1 key
                if [[ $key == "q" ]]; then
                    return
                fi
            done
        fi
    done
}

# Main program loop
while true; do
    display_menu
    read -r choice
    
    case $choice in
        1) monitor_server ;;
        2) add_server ;;
        3) edit_server ;;
        4) delete_server ;;
        5) list_servers ;;
        0) 
            echo -e "${GREEN}Thank you for using Server Monitor. Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${RESET}"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
    esac
done
