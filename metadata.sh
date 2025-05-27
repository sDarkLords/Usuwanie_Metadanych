#!/bin/bash

# Skrypt do usuwania metadanego z plików

# Sprawdzanie, czy exiftool jest zainstalowany
if ! command -v exiftool &> /dev/null; then
    echo "Instalowanie exiftool..."
    sudo apt update && sudo apt install -y libimage-exiftool-perl || {
        echo "Błąd: Nie udało się zainstalować exiftool"
        exit 1
    }
fi

# Sprawdzanie, czy podano argument
if [ $# -eq 0 ]; then
    echo "Użycie: $0 <plik> [<kolejny_plik> ...]"
    echo "Przykład: $0 zdjecie.jpg dokument.pdf"
    exit 1
fi

# Pętla przetwarzająca wszystkie argumenty (pliki) przekazane do skryptu
for file in "$@"; do
    # Sprawdzenia czy plik istnieje i jest zwykłym plikiem
    if [ ! -f "$file" ]; then
        echo "Ostrzeżenie: Plik '$file' nie istnieje - pomijam"
        continue
    fi
    
    # Informacja o rozpoczęciu orzetwarzania bieżącego pliku
    echo "Przetwarzam plik: $file"
    
    # Tworzenia kopii zapasowej
    backup="${file}.backup"
    cp "$file" "$backup"
    echo "Utworzono kopię zapasową: $backup"
    
    # Użycie exiftool z opcją -all= do usunięcia wszystkich metadanych
    exiftool -all= "$file" -overwrite_original
    
    # Sprawdzenia statusu wykonania ostatniej komendy 
    if [ $? -eq 0 ]; then
        echo "Metadane zostały usunięte z pliku: $file"
        
        # Porównania rozmiarów plików
        original_size=$(stat -c %s "$backup")
        new_size=$(stat -c %s "$file")
        size_diff=$((original_size - new_size))
        
        # Wyświetlenie informacji o zaoszczędzonym miejscu
        echo "Zaoszczędzone miejsce: $size_diff bajtów"
    else
        # Jeśli wystąpił błąd 
        echo "Błąd: Nie udało się usunąć metadanych z pliku: $file"
        echo "Przywracam oryginalny plik z kopii zapasowej"
        # Przywrócenie oryginalnej wersji pliku z kopii zapasowej 
        mv "$backup" "$file"
    fi
done

echo "Operacja zakończona."
