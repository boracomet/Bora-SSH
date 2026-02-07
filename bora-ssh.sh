#!/bin/bash

# bora-ssh - SSH Connection Manager
# Interactive SSH management tool for macOS

# Colors (soft orange tones)
ORANGE='\033[38;5;208m'
LIGHT_ORANGE='\033[38;5;215m'
YELLOW='\033[38;5;220m'
RESET='\033[0m'
GREEN='\033[38;5;82m'
BLUE='\033[38;5;75m'
RED='\033[38;5;196m'
WHITE='\033[1;37m'

# Configuration file
CONFIG_DIR="$HOME/.bora-ssh"
CONFIG_FILE="$CONFIG_DIR/servers.conf"

# ASCII Art Banner
show_banner() {
    clear
    echo -e "${ORANGE}"
    cat << "EOF"
__________                                _________ _________ ___ ___  
\______   \ ________________             /   _____//   _____//   |   \ 
 |    |  _//  _ \_  __ \__  \    ______  \_____  \ \_____  \/    ~    \
 |    |   (  <_> )  | \// __ \_ /_____/  /        \/        \    Y    /
 |______  /\____/|__|  (____  /         /_______  /_______  /\___|_  / 
        \/                  \/                  \/        \/       \/  
EOF
    echo -e "${RESET}"
    echo -e "${LIGHT_ORANGE}SSH Connection Manager${RESET}"
    echo ""
}

# Initialize configuration directory
init_config() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
    fi
}

# Load server list
load_servers() {
    if [ -f "$CONFIG_FILE" ] && [ -s "$CONFIG_FILE" ]; then
        # Filter empty lines and return as array
        while IFS= read -r line || [ -n "$line" ]; do
            if [ -n "$line" ]; then
                echo "$line"
            fi
        done < "$CONFIG_FILE"
    fi
}

# Save server
save_server() {
    local name=$1
    local host=$2
    local user=$3
    local port=$4
    
    echo "$name|$host|$user|$port" >> "$CONFIG_FILE"
}

# Parse server information
parse_server() {
    local line=$1
    IFS='|' read -r name host user port <<< "$line"
    echo "$name|$host|$user|$port"
}

# Read key function for arrow keys (macOS compatible)
read_key() {
    local key
    local keypress
    
    # Special character reading for macOS
    IFS= read -rs -n1 -t 0.1 keypress 2>/dev/null || keypress=$(dd bs=1 count=1 2>/dev/null)
    
    if [ "$keypress" = $'\x1b' ]; then
        # Escape sequence started
        IFS= read -rs -n2 -t 0.1 keypress 2>/dev/null || keypress=$(dd bs=1 count=2 2>/dev/null)
        case "$keypress" in
            '[A') key="UP" ;;
            '[B') key="DOWN" ;;
            '[C') key="RIGHT" ;;
            '[D') key="LEFT" ;;
            *) key="OTHER" ;;
        esac
    elif [ "$keypress" = $'\x0a' ] || [ "$keypress" = $'\x0d' ] || [ -z "$keypress" ]; then
        key="ENTER"
    elif [ "$keypress" = $'\x7f' ] || [ "$keypress" = $'\x08' ]; then
        key="BACKSPACE"
    else
        key="$keypress"
    fi
    
    echo "$key"
}

# Show menu and make selection
show_menu() {
    local selected=$1
    local options=("$@")
    local menu_items=("${options[@]:1}")
    
    local i=0
    for item in "${menu_items[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "${LIGHT_ORANGE}▶${RESET} ${WHITE}$item${RESET}"
        else
            echo -e "  ${BLUE}$item${RESET}"
        fi
        ((i++))
    done
}


# Main menu
main_menu() {
    local selected=0
    local menu_items=("Connect SSH" "Add Server" "Edit Server" "Delete Server" "List Servers" "Exit")
    
    while true; do
        show_banner
        echo -e "${GREEN}Main Menu:${RESET}"
        echo ""
        show_menu $selected "${menu_items[@]}"
        echo ""
        echo -e "${YELLOW}[↑↓] Select | [Enter] Confirm | [q] Exit${RESET}"
        
        local key=$(read_key)
        
        case "$key" in
            "UP")
                if [ $selected -gt 0 ]; then
                    ((selected--))
                fi
                ;;
            "DOWN")
                if [ $selected -lt $((${#menu_items[@]} - 1)) ]; then
                    ((selected++))
                fi
                ;;
            "ENTER")
                case $selected in
                    0) ssh_connect_menu ;;
                    1) add_server ;;
                    2) edit_server_menu ;;
                    3) delete_server_menu ;;
                    4) list_servers ;;
                    5) exit 0 ;;
                esac
                ;;
            "q"|"Q")
                exit 0
                ;;
        esac
    done
}

# SSH connection menu
ssh_connect_menu() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo ""
        echo -e "${RED}No saved servers found!${RESET}"
        echo -e "${YELLOW}Please add a server first.${RESET}"
        sleep 2
        return
    fi
    
    local selected=0
    
    while true; do
        show_banner
        echo -e "${GREEN}Select SSH Connection:${RESET}"
        echo ""
        
        local i=0
        for server in "${servers_array[@]}"; do
            IFS='|' read -r name host user port <<< "$server"
            if [ $i -eq $selected ]; then
                echo -e "${LIGHT_ORANGE}▶${RESET} ${WHITE}$name${RESET} (${BLUE}$user@$host:$port${RESET})"
            else
                echo -e "  ${BLUE}$name${RESET} ($user@$host:$port)"
            fi
            ((i++))
        done
        
        echo ""
        echo -e "${YELLOW}[↑↓] Select | [Enter] Connect | [Esc] Back${RESET}"
        
        local key=$(read_key)
        
        case "$key" in
            "UP")
                if [ $selected -gt 0 ]; then
                    ((selected--))
                fi
                ;;
            "DOWN")
                if [ $selected -lt $((${#servers_array[@]} - 1)) ]; then
                    ((selected++))
                fi
                ;;
            "ENTER")
                IFS='|' read -r name host user port <<< "${servers_array[$selected]}"
                connect_ssh "$name" "$host" "$user" "$port"
                return
                ;;
            "q"|"Q"|"OTHER")
                return
                ;;
        esac
    done
}


# Connect SSH (in new terminal window)
connect_ssh() {
    local name=$1
    local host=$2
    local user=$3
    local port=$4
    
    show_banner
    echo -e "${GREEN}SSH Connection:${RESET}"
    echo -e "${BLUE}Server:${RESET} $name"
    echo -e "${BLUE}Host:${RESET} $host"
    echo -e "${BLUE}User:${RESET} $user"
    echo -e "${BLUE}Port:${RESET} $port"
    echo ""
    echo -e "${YELLOW}Opening in new window...${RESET}"
    echo ""
    
    # Open new terminal window on macOS and make SSH connection
    # Add server name to connection title
    # Use safe method for osascript (heredoc)
    
    # Escape special characters
    local safe_name=$(printf '%s' "$name" | sed "s/'/'\"'\"'/g")
    local safe_user=$(printf '%s' "$user" | sed "s/'/'\"'\"'/g")
    local safe_host=$(printf '%s' "$host" | sed "s/'/'\"'\"'/g")
    
    osascript <<EOF
tell application "Terminal"
    -- Prepare SSH command
    set titleCmd to "echo -ne \"\\\\033]0;SSH: $safe_name ($safe_user@$safe_host)\\\\007\""
    set sshCmd to "ssh -p $port $safe_user@$safe_host"
    set fullCmd to titleCmd & "; " & sshCmd
    
    -- Open new window
    do script fullCmd
    activate
end tell
EOF
    
    sleep 1
    echo -e "${GREEN}✓ SSH connection opened in new window!${RESET}"
    sleep 1
}

# Check brew
check_brew() {
    if ! command -v brew &> /dev/null; then
        return 1
    fi
    return 0
}

# Add server
add_server() {
    # Enable terminal echo (to see what is typed)
    stty echo
    stty -cbreak
    
    show_banner
    echo -e "${GREEN}Add New Server:${RESET}"
    echo ""
    
    echo -ne "${BLUE}Server Name:${RESET} "
    read -r name
    
    echo -ne "${BLUE}Host/IP:${RESET} "
    read -r host
    
    echo -ne "${BLUE}User (default root):${RESET} "
    read -r user
    user=${user:-root}  # Default to root
    
    echo -ne "${BLUE}Port (default 22):${RESET} "
    read -r port
    port=${port:-22}
    
    echo ""
    echo -ne "${YELLOW}Save? (y/n):${RESET} "
    read -r save_choice
    
    if [ "$save_choice" = "e" ] || [ "$save_choice" = "E" ] || [ "$save_choice" = "y" ] || [ "$save_choice" = "Y" ]; then
        save_server "$name" "$host" "$user" "$port"
        echo ""
        echo -e "${GREEN}✓ Server saved!${RESET}"
        sleep 1
    else
        echo ""
        echo -e "${YELLOW}Server not saved.${RESET}"
        sleep 1
    fi
    
    # Restore terminal settings (for menu navigation)
    stty -echo
    stty cbreak
}

# List servers
list_servers() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    show_banner
    echo -e "${GREEN}Saved Servers:${RESET}"
    echo ""
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo -e "${RED}No saved servers found!${RESET}"
    else
        local i=1
        for server in "${servers_array[@]}"; do
            IFS='|' read -r name host user port <<< "$server"
            echo -e "${LIGHT_ORANGE}$i.${RESET} ${WHITE}$name${RESET}"
            echo -e "   ${BLUE}Host:${RESET} $host"
            echo -e "   ${BLUE}User:${RESET} $user"
            echo -e "   ${BLUE}Port:${RESET} $port"
            echo ""
            ((i++))
        done
    fi
    
    # Enable terminal echo (to see key press)
    stty echo
    stty -cbreak
    
    echo -e "${YELLOW}Press any key to continue...${RESET}"
    read -n 1
    
    # Restore terminal settings (for menu navigation)
    stty -echo
    stty cbreak
}

# Update server
update_server() {
    local index=$1
    local new_name=$2
    local new_host=$3
    local new_user=$4
    local new_port=$5
    
    # Create temporary file
    local temp_file=$(mktemp)
    local i=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            if [ $i -eq $index ]; then
                echo "$new_name|$new_host|$new_user|$new_port" >> "$temp_file"
            else
                echo "$line" >> "$temp_file"
            fi
            ((i++))
        fi
    done < "$CONFIG_FILE"
    
    mv "$temp_file" "$CONFIG_FILE"
}

# Delete server
delete_server() {
    local index=$1
    
    # Create temporary file
    local temp_file=$(mktemp)
    local i=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            if [ $i -ne $index ]; then
                echo "$line" >> "$temp_file"
            fi
            ((i++))
        fi
    done < "$CONFIG_FILE"
    
    mv "$temp_file" "$CONFIG_FILE"
}

# Edit server menu
edit_server_menu() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo ""
        echo -e "${RED}No saved servers found!${RESET}"
        echo -e "${YELLOW}Please add a server first.${RESET}"
        sleep 2
        return
    fi
    
    local selected=0
    
    while true; do
        show_banner
        echo -e "${GREEN}Select Server to Edit:${RESET}"
        echo ""
        
        local i=0
        for server in "${servers_array[@]}"; do
            IFS='|' read -r name host user port <<< "$server"
            if [ $i -eq $selected ]; then
                echo -e "${LIGHT_ORANGE}▶${RESET} ${WHITE}$name${RESET} (${BLUE}$user@$host:$port${RESET})"
            else
                echo -e "  ${BLUE}$name${RESET} ($user@$host:$port)"
            fi
            ((i++))
        done
        
        echo ""
        echo -e "${YELLOW}[↑↓] Select | [Enter] Edit | [Esc] Back${RESET}"
        
        local key=$(read_key)
        
        case "$key" in
            "UP")
                if [ $selected -gt 0 ]; then
                    ((selected--))
                fi
                ;;
            "DOWN")
                if [ $selected -lt $((${#servers_array[@]} - 1)) ]; then
                    ((selected++))
                fi
                ;;
            "ENTER")
                IFS='|' read -r old_name old_host old_user old_port <<< "${servers_array[$selected]}"
                edit_server "$selected" "$old_name" "$old_host" "$old_user" "$old_port"
                return
                ;;
            "q"|"Q"|"OTHER")
                return
                ;;
        esac
    done
}

# Edit server
edit_server() {
    local index=$1
    local old_name=$2
    local old_host=$3
    local old_user=$4
    local old_port=$5
    
    # Enable terminal echo (to see what is typed)
    stty echo
    stty -cbreak
    
    show_banner
    echo -e "${GREEN}Edit Server:${RESET}"
    echo ""
    echo -e "${BLUE}Current Information:${RESET}"
    echo -e "  ${WHITE}Server Name:${RESET} $old_name"
    echo -e "  ${WHITE}Host/IP:${RESET} $old_host"
    echo -e "  ${WHITE}User:${RESET} $old_user"
    echo -e "  ${WHITE}Port:${RESET} $old_port"
    echo ""
    echo -e "${YELLOW}Enter new information (leave blank to keep current value):${RESET}"
    echo ""
    
    echo -ne "${BLUE}Server Name [$old_name]:${RESET} "
    read -r name
    name=${name:-$old_name}
    
    echo -ne "${BLUE}Host/IP [$old_host]:${RESET} "
    read -r host
    host=${host:-$old_host}
    
    echo -ne "${BLUE}User [$old_user]:${RESET} "
    read -r user
    user=${user:-$old_user}
    
    echo -ne "${BLUE}Port [$old_port]:${RESET} "
    read -r port
    port=${port:-$old_port}
    
    update_server "$index" "$name" "$host" "$user" "$port"
    
    echo ""
    echo -e "${GREEN}✓ Server information updated!${RESET}"
    sleep 1
    
    # Restore terminal settings (for menu navigation)
    stty -echo
    stty cbreak
}

# Delete server menu
delete_server_menu() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo ""
        echo -e "${RED}No saved servers found!${RESET}"
        echo -e "${YELLOW}Please add a server first.${RESET}"
        sleep 2
        return
    fi
    
    local selected=0
    
    while true; do
        show_banner
        echo -e "${RED}Select Server to Delete:${RESET}"
        echo ""
        
        local i=0
        for server in "${servers_array[@]}"; do
            IFS='|' read -r name host user port <<< "$server"
            if [ $i -eq $selected ]; then
                echo -e "${LIGHT_ORANGE}▶${RESET} ${WHITE}$name${RESET} (${BLUE}$user@$host:$port${RESET})"
            else
                echo -e "  ${BLUE}$name${RESET} ($user@$host:$port)"
            fi
            ((i++))
        done
        
        echo ""
        echo -e "${YELLOW}[↑↓] Select | [Enter] Delete | [Esc] Back${RESET}"
        
        local key=$(read_key)
        
        case "$key" in
            "UP")
                if [ $selected -gt 0 ]; then
                    ((selected--))
                fi
                ;;
            "DOWN")
                if [ $selected -lt $((${#servers_array[@]} - 1)) ]; then
                    ((selected++))
                fi
                ;;
            "ENTER")
                IFS='|' read -r name host user port <<< "${servers_array[$selected]}"
                confirm_delete_server "$selected" "$name"
                return
                ;;
            "q"|"Q"|"OTHER")
                return
                ;;
        esac
    done
}

# Confirm server deletion
confirm_delete_server() {
    local index=$1
    local name=$2
    
    # Enable terminal echo (to see what is typed)
    stty echo
    stty -cbreak
    
    show_banner
    echo -e "${RED}Confirm Server Deletion:${RESET}"
    echo ""
    echo -e "${YELLOW}Server:${RESET} ${WHITE}$name${RESET}"
    echo ""
    echo -ne "${RED}Are you sure you want to delete this server? (y/n):${RESET} "
    read -r confirm
    
    if [ "$confirm" = "e" ] || [ "$confirm" = "E" ] || [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        delete_server "$index"
        echo ""
        echo -e "${GREEN}✓ Server deleted!${RESET}"
        sleep 1
    else
        echo ""
        echo -e "${YELLOW}Deletion cancelled.${RESET}"
        sleep 1
    fi
    
    # Restore terminal settings (for menu navigation)
    stty -echo
    stty cbreak
}



# Main program
main() {
    # Restore terminal settings on error
    trap 'stty echo; stty -cbreak; exit' INT TERM EXIT
    
    # Terminal settings
    stty -echo
    stty cbreak
    
    init_config
    main_menu
    
    # Restore terminal settings
    stty echo
    stty -cbreak
}

# Start program
main
