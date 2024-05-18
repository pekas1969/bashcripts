#!/bin/bash
# Skript zur Installation von Paketen unter verschiedenen Distributionen.
# Bei Arch Linux wird zusätzlich geprüft, ob das Paket in den offiziellen Repos oder im AUR vorhanden ist

# ---------- Functions ----------
# check_package_manager(): prüft, ob und welcher Paketmanager installiert ist
# install_package(): prüft ob das angegebene Paket installiert ist. Falls nicht, wird es mit dem Kommando aus check_package_manager() installiert
# check_package_manager(): erstellt das Kommando für die Installation des Pakets
# ask_install(): die eigentliche Funktion zur Abfrage, ob ein Paket installiert werden soll

check_package_manager() {
    if command -v $1 &>/dev/null; then
        return 0
    else
        return 1
    fi
}

install_package() {

    if "$2" &> /dev/null; then
        echo "$1 ist installiert"
    else
        if [[ $1 =~ \.(rpm|deb|zst|tbz2)$ ]]; then
             echo "Installiere $1 aus lokaler Datei..."
             $4
        else
            echo "Installiere $1..."
            $3
        fi
        if ! $2; then
            echo "$1 konnte nicht installiert werden."
        fi
    fi
}

check_install() {
    # Parameter 1: Name des zu installierenden Paketes
    # Parameter 2: Befehl zum prüfen, ob das Paket installiert ist
    # Parameter 3: Installationsbefehl für Pakete aus dem Repository
    # Parameter 4: Installationsbefehl für lokale Paketer

    if command -v dpkg &> /dev/null; then
        if check_package_manager apt; then
               install_package "$1" "apt install -y $1" "sudo dpkg -i $1" "sudo dpkg -i $1"
        fi

    elif command -v dnf &> /dev/null; then
        if check_package_manager dnf; then
            install_package "$1" "dnf list installed $1" "sudo dnf install -y $1" "sudo dnf install $1"
        fi

    elif command -v yum &> /dev/null; then
        if check_package_manager yum; then
            install_package "$1" "yum list installed $1" "sudo yum install -y $1" "sudo yum localinstall $1"
        fi

    elif command -v pacman &> /dev/null; then
        if check_package_manager pacman; then
            install_package "$1" "pacman -Qs $1" "sudo pacman -S $1 --noconfirm" "sudo pacman -U $1"
        fi

    else
        echo "Fehler: Fehlender oder nicht unterstützter Paketmanager, bitte $1 manuell installieren."
        exit
    fi
}

ask_install() {

    read -p "Möchten Sie $1 installieren? (Ja[j,J], Nein[n,N]): " choice
    case "$choice" in
    [jJ][yY]|[jJ])
        check_install $1
        ;;
    *)
        echo "$1 wird nicht installiert."
        ;;
    esac
    echo -e ""
}

# ---------- Main program ----------

ask_install "xterm"
ask_install "blabla2.rpm"


exit 1
