#!/bin/bash

# bora-ssh - SSH Connection Manager
# macOS için interaktif SSH yönetim aracı

# Renkler (soft turuncu tonları)
ORANGE='\033[38;5;208m'
LIGHT_ORANGE='\033[38;5;215m'
YELLOW='\033[38;5;220m'
RESET='\033[0m'
GREEN='\033[38;5;82m'
BLUE='\033[38;5;75m'
RED='\033[38;5;196m'
WHITE='\033[1;37m'

# Konfigürasyon dosyası
CONFIG_DIR="$HOME/.bora-ssh"
CONFIG_FILE="$CONFIG_DIR/servers.conf"

# ASCII Art Başlık
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
    echo -e "${LIGHT_ORANGE}        SSH Connection Manager${RESET}"
    echo ""
}

# Konfigürasyon dizinini oluştur
init_config() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
    fi
}

# Sunucu listesini yükle
load_servers() {
    if [ -f "$CONFIG_FILE" ] && [ -s "$CONFIG_FILE" ]; then
        # Boş satırları filtrele ve array olarak döndür
        while IFS= read -r line || [ -n "$line" ]; do
            if [ -n "$line" ]; then
                echo "$line"
            fi
        done < "$CONFIG_FILE"
    fi
}

# Sunucu kaydet
save_server() {
    local name=$1
    local host=$2
    local user=$3
    local port=$4
    
    echo "$name|$host|$user|$port" >> "$CONFIG_FILE"
}

# Sunucu bilgilerini parse et
parse_server() {
    local line=$1
    IFS='|' read -r name host user port <<< "$line"
    echo "$name|$host|$user|$port"
}

# Yön tuşları için okuma fonksiyonu (macOS uyumlu)
read_key() {
    local key
    local keypress
    
    # macOS için özel karakter okuma
    IFS= read -rs -n1 -t 0.1 keypress 2>/dev/null || keypress=$(dd bs=1 count=1 2>/dev/null)
    
    if [ "$keypress" = $'\x1b' ]; then
        # Escape sequence başladı
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

# Menü göster ve seçim yap
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

# Terminal sekmelerini listele
list_and_activate_tabs() {
    osascript <<'APPLESCRIPT'
tell application "Terminal"
    set tabList to ""
    set windowCount to count of windows
    
    if windowCount = 0 then
        return ""
    end if
    
    repeat with w from 1 to windowCount
        try
            set currentWindow to window w
            set tabCount to count of tabs of currentWindow
            
            repeat with t from 1 to tabCount
                try
                    set currentTab to tab t of currentWindow
                    set tabTitle to custom title of currentTab
                    if tabTitle = "" then
                        set tabTitle to name of currentWindow
                    end if
                    if tabList = "" then
                        set tabList to w & "," & t & "|" & tabTitle
                    else
                        set tabList to tabList & return & w & "," & t & "|" & tabTitle
                    end if
                end try
            end repeat
        end try
    end repeat
    
    return tabList
end tell
APPLESCRIPT
}

# Sekmeyi öne getir
activate_tab() {
    local window_index=$1
    local tab_index=$2
    
    osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    try
        set w to window $window_index
        set t to tab $tab_index of w
        set selected of t to true
        set frontmost of w to true
    end try
end tell
APPLESCRIPT
}

# Ana menü
main_menu() {
    local selected=0
    local menu_items=("SSH Bağlan" "Sunucu Ekle" "Sunucu Düzenle" "Sunucu Sil" "Sunucu Listesi" "Çıkış")
    
    while true; do
        show_banner
        echo -e "${GREEN}Ana Menü:${RESET}"
        echo ""
        show_menu $selected "${menu_items[@]}"
        echo ""
        
        # Açık Terminal sekmelerini göster
        local tabs_info=$(list_and_activate_tabs)
        if [ -n "$tabs_info" ]; then
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo -e "${LIGHT_ORANGE}Açık Sekmeler:${RESET}"
            local tab_num=1
            while IFS= read -r line || [ -n "$line" ]; do
                if [ -n "$line" ]; then
                    IFS='|' read -r indices title <<< "$line"
                    echo -e "  ${BLUE}[$tab_num]${RESET} ${WHITE}$title${RESET}"
                    ((tab_num++))
                fi
            done <<< "$tabs_info"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo ""
        fi
        
        echo -e "${YELLOW}[↑↓] Seç | [Enter] Onayla | [1-9] Sekme Öne Getir | [q] Çıkış${RESET}"
        
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
            "1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9")
                # Rakam tuşuna basıldığında ilgili sekmeyi öne getir
                local tab_num=$((key))
                local tab_count=0
                local target_indices=""
                
                if [ -n "$tabs_info" ]; then
                    while IFS= read -r line || [ -n "$line" ]; do
                        if [ -n "$line" ]; then
                            ((tab_count++))
                            if [ $tab_count -eq $tab_num ]; then
                                target_indices=$line
                                break
                            fi
                        fi
                    done <<< "$tabs_info"
                    
                    if [ -n "$target_indices" ]; then
                        IFS='|' read -r indices title <<< "$target_indices"
                        IFS=',' read -r window_idx tab_idx <<< "$indices"
                        activate_tab "$window_idx" "$tab_idx"
                        echo -e "${GREEN}✓ Sekme öne getirildi: $title${RESET}"
                        sleep 0.5
                    fi
                fi
                ;;
            "q"|"Q")
                exit 0
                ;;
        esac
    done
}

# SSH bağlantı menüsü
ssh_connect_menu() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo ""
        echo -e "${RED}Kayıtlı sunucu bulunamadı!${RESET}"
        echo -e "${YELLOW}Önce bir sunucu ekleyin.${RESET}"
        sleep 2
        return
    fi
    
    local selected=0
    
    while true; do
        show_banner
        echo -e "${GREEN}SSH Bağlantısı Seç:${RESET}"
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
        echo -e "${YELLOW}[↑↓] Seç | [Enter] Bağlan | [Esc] Geri${RESET}"
        
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


# SSH bağlantısı kur (yeni terminal penceresinde)
connect_ssh() {
    local name=$1
    local host=$2
    local user=$3
    local port=$4
    
    show_banner
    echo -e "${GREEN}SSH Bağlantısı:${RESET}"
    echo -e "${BLUE}Sunucu:${RESET} $name"
    echo -e "${BLUE}Host:${RESET} $host"
    echo -e "${BLUE}Kullanıcı:${RESET} $user"
    echo -e "${BLUE}Port:${RESET} $port"
    echo ""
    echo -e "${YELLOW}Yeni pencerede açılıyor...${RESET}"
    echo ""
    
    # macOS'ta yeni terminal penceresi aç ve SSH bağlantısı yap
    # Bağlantı başlığına sunucu adını ekle
    # osascript için güvenli yöntem kullan (heredoc)
    
    # Özel karakterleri escape et
    local safe_name=$(printf '%s' "$name" | sed "s/'/'\"'\"'/g")
    local safe_user=$(printf '%s' "$user" | sed "s/'/'\"'\"'/g")
    local safe_host=$(printf '%s' "$host" | sed "s/'/'\"'\"'/g")
    
    osascript <<EOF
tell application "Terminal"
    -- SSH komutunu hazırla
    set titleCmd to "echo -ne \"\\\\033]0;SSH: $safe_name ($safe_user@$safe_host)\\\\007\""
    set sshCmd to "ssh -p $port $safe_user@$safe_host"
    set fullCmd to titleCmd & "; " & sshCmd
    
    -- Yeni pencereyi aç
    do script fullCmd
    activate
end tell
EOF
    
    sleep 1
    echo -e "${GREEN}✓ SSH bağlantısı yeni pencerede açıldı!${RESET}"
    sleep 1
}

# brew kontrolü
check_brew() {
    if ! command -v brew &> /dev/null; then
        return 1
    fi
    return 0
}

# Sunucu ekle
add_server() {
    # Terminal echo'yu aç (yazılanları görmek için)
    stty echo
    stty -cbreak
    
    show_banner
    echo -e "${GREEN}Yeni Sunucu Ekle:${RESET}"
    echo ""
    
    echo -ne "${BLUE}Sunucu Adı:${RESET} "
    read -r name
    
    echo -ne "${BLUE}Host/IP:${RESET} "
    read -r host
    
    echo -ne "${BLUE}Kullanıcı (varsayılan root):${RESET} "
    read -r user
    user=${user:-root}  # Varsayılan olarak root
    
    echo -ne "${BLUE}Port (varsayılan 22):${RESET} "
    read -r port
    port=${port:-22}
    
    echo ""
    echo -ne "${YELLOW}Kaydedilsin mi? (e/h):${RESET} "
    read -r save_choice
    
    if [ "$save_choice" = "e" ] || [ "$save_choice" = "E" ] || [ "$save_choice" = "y" ] || [ "$save_choice" = "Y" ]; then
        save_server "$name" "$host" "$user" "$port"
        echo ""
        echo -e "${GREEN}✓ Sunucu kaydedildi!${RESET}"
        sleep 1
    else
        echo ""
        echo -e "${YELLOW}Sunucu kaydedilmedi.${RESET}"
        sleep 1
    fi
    
    # Terminal ayarlarını geri yükle (menü navigasyonu için)
    stty -echo
    stty cbreak
}

# Sunucu listesi göster
list_servers() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    show_banner
    echo -e "${GREEN}Kayıtlı Sunucular:${RESET}"
    echo ""
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo -e "${RED}Kayıtlı sunucu bulunamadı!${RESET}"
    else
        local i=1
        for server in "${servers_array[@]}"; do
            IFS='|' read -r name host user port <<< "$server"
            echo -e "${LIGHT_ORANGE}$i.${RESET} ${WHITE}$name${RESET}"
            echo -e "   ${BLUE}Host:${RESET} $host"
            echo -e "   ${BLUE}Kullanıcı:${RESET} $user"
            echo -e "   ${BLUE}Port:${RESET} $port"
            echo ""
            ((i++))
        done
    fi
    
    # Terminal echo'yu aç (tuş basımını görmek için)
    stty echo
    stty -cbreak
    
    echo -e "${YELLOW}Devam etmek için bir tuşa basın...${RESET}"
    read -n 1
    
    # Terminal ayarlarını geri yükle (menü navigasyonu için)
    stty -echo
    stty cbreak
}

# Sunucu güncelle
update_server() {
    local index=$1
    local new_name=$2
    local new_host=$3
    local new_user=$4
    local new_port=$5
    
    # Geçici dosya oluştur
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

# Sunucu sil
delete_server() {
    local index=$1
    
    # Geçici dosya oluştur
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

# Sunucu düzenleme menüsü
edit_server_menu() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo ""
        echo -e "${RED}Kayıtlı sunucu bulunamadı!${RESET}"
        echo -e "${YELLOW}Önce bir sunucu ekleyin.${RESET}"
        sleep 2
        return
    fi
    
    local selected=0
    
    while true; do
        show_banner
        echo -e "${GREEN}Düzenlenecek Sunucuyu Seç:${RESET}"
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
        echo -e "${YELLOW}[↑↓] Seç | [Enter] Düzenle | [Esc] Geri${RESET}"
        
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

# Sunucu düzenle
edit_server() {
    local index=$1
    local old_name=$2
    local old_host=$3
    local old_user=$4
    local old_port=$5
    
    # Terminal echo'yu aç (yazılanları görmek için)
    stty echo
    stty -cbreak
    
    show_banner
    echo -e "${GREEN}Sunucu Düzenle:${RESET}"
    echo ""
    echo -e "${BLUE}Mevcut Bilgiler:${RESET}"
    echo -e "  ${WHITE}Sunucu Adı:${RESET} $old_name"
    echo -e "  ${WHITE}Host/IP:${RESET} $old_host"
    echo -e "  ${WHITE}Kullanıcı:${RESET} $old_user"
    echo -e "  ${WHITE}Port:${RESET} $old_port"
    echo ""
    echo -e "${YELLOW}Yeni bilgileri girin (boş bırakırsanız mevcut değer korunur):${RESET}"
    echo ""
    
    echo -ne "${BLUE}Sunucu Adı [$old_name]:${RESET} "
    read -r name
    name=${name:-$old_name}
    
    echo -ne "${BLUE}Host/IP [$old_host]:${RESET} "
    read -r host
    host=${host:-$old_host}
    
    echo -ne "${BLUE}Kullanıcı [$old_user]:${RESET} "
    read -r user
    user=${user:-$old_user}
    
    echo -ne "${BLUE}Port [$old_port]:${RESET} "
    read -r port
    port=${port:-$old_port}
    
    update_server "$index" "$name" "$host" "$user" "$port"
    
    echo ""
    echo -e "${GREEN}✓ Sunucu bilgileri güncellendi!${RESET}"
    sleep 1
    
    # Terminal ayarlarını geri yükle (menü navigasyonu için)
    stty -echo
    stty cbreak
}

# Sunucu silme menüsü
delete_server_menu() {
    local servers_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            servers_array+=("$line")
        fi
    done < <(load_servers)
    
    if [ ${#servers_array[@]} -eq 0 ]; then
        echo ""
        echo -e "${RED}Kayıtlı sunucu bulunamadı!${RESET}"
        echo -e "${YELLOW}Önce bir sunucu ekleyin.${RESET}"
        sleep 2
        return
    fi
    
    local selected=0
    
    while true; do
        show_banner
        echo -e "${RED}Silinecek Sunucuyu Seç:${RESET}"
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
        echo -e "${YELLOW}[↑↓] Seç | [Enter] Sil | [Esc] Geri${RESET}"
        
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

# Sunucu silme onayı
confirm_delete_server() {
    local index=$1
    local name=$2
    
    # Terminal echo'yu aç (yazılanları görmek için)
    stty echo
    stty -cbreak
    
    show_banner
    echo -e "${RED}Sunucu Silme Onayı:${RESET}"
    echo ""
    echo -e "${YELLOW}Sunucu:${RESET} ${WHITE}$name${RESET}"
    echo ""
    echo -ne "${RED}Bu sunucuyu silmek istediğinizden emin misiniz? (e/h):${RESET} "
    read -r confirm
    
    if [ "$confirm" = "e" ] || [ "$confirm" = "E" ] || [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        delete_server "$index"
        echo ""
        echo -e "${GREEN}✓ Sunucu silindi!${RESET}"
        sleep 1
    else
        echo ""
        echo -e "${YELLOW}Silme işlemi iptal edildi.${RESET}"
        sleep 1
    fi
    
    # Terminal ayarlarını geri yükle (menü navigasyonu için)
    stty -echo
    stty cbreak
}



# Ana program
main() {
    # Hata durumunda terminal ayarlarını geri yükle
    trap 'stty echo; stty -cbreak; exit' INT TERM EXIT
    
    # Terminal ayarları
    stty -echo
    stty cbreak
    
    init_config
    main_menu
    
    # Terminal ayarlarını geri yükle
    stty echo
    stty -cbreak
}

# Programı başlat
main
