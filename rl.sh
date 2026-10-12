#!/usr/bin/env zsh

set -e

# Vérification du nombre d'arguments
if [[ $# -ne 3 && $# -ne 4 ]]; then
    print -u2 "Usage : $0 <texte> <nombre_ou_plage> <fichier_cible>"
    print -u2 "        $0 <texte> <debut> <fin> <fichier_cible>"
    print -u2 ""
    print -u2 "Paramètres :"
    print -u2 "  <texte>               Texte à répéter. Placeholders disponibles :"
    print -u2 "                        - {i}, {n}, {index}, {} : Numéro d'itération courant"
    print -u2 "                        - {i:0X}, {n:0X}        : Numéro avec zéros (ex. {i:03} -> 001, 002...)"
    print -u2 "                        - {i0}, {n0}            : Itération moins 1 (i - 1)"
    print -u2 "                        - {start}, {end}        : Bornes de début et de fin"
    print -u2 "                        - {total}, {count}      : Nombre total d'itérations"
    print -u2 "  <nombre_ou_plage>     Nombre de fois (ex. 5) ou plage (ex. 3..7)"
    print -u2 "  <debut> <fin>         Bornes spécifiées en deux arguments (ex. 3 7)"
    print -u2 "  <fichier_cible>       Chemin du fichier où ajouter les lignes à la fin"
    print -u2 ""
    print -u2 "Exemples :"
    print -u2 "  $0 \"Ligne {i}\" 5 sortie.txt"
    print -u2 "  $0 \"Ligne {i}\" 3..7 sortie.txt"
    print -u2 "  $0 \"Ligne {i}\" 3 7 sortie.txt"
    print -u2 "  $0 \"host-{i:03}.local\" 10 hosts.txt"
    exit 1
fi

if [[ $# -eq 3 ]]; then
    text="$1"
    range="$2"
    target_file="$3"

    # Utilisation d'une variable pour le regex (bonne pratique)
    range_regex="^([0-9]+)\.\.([0-9]+)$"

    if [[ "$range" =~ $range_regex ]]; then
        start="${match[1]}"
        end="${match[2]}"
    elif [[ "$range" =~ ^[0-9]+$ ]] && [[ "$range" -gt 0 ]]; then
        start=1
        end="$range"
    else
        print -u2 "Erreur : La répétition doit être un entier positif (ex. 10) ou une plage valide (ex. 3..7, reçu : '$range')."
        exit 1
    fi
else
    text="$1"
    start="$2"
    end="$3"
    target_file="$4"

    if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]]; then
        print -u2 "Erreur : Les bornes de début et de fin doivent être des entiers positifs ou nuls (reçu : '$start' et '$end')."
        exit 1
    fi
fi

if (( start > end )); then
    print -u2 "Erreur : La borne de début ($start) ne peut pas être supérieure à la borne de fin ($end)."
    exit 1
fi

count=$((end - start + 1))

# Création du dossier parent si nécessaire
target_dir=$(dirname -- "$target_file")
# dirname retourne '.' si aucun dossier n'est spécifié, on évite donc de créer '.'
if [[ "$target_dir" != "." && ! -d "$target_dir" ]]; then
    mkdir -p -- "$target_dir" || {
        print -u2 "Erreur : Impossible de créer le répertoire cible '$target_dir'."
        exit 1
    }
fi

# Regex pour le padding (sans quotes autour pour la robustesse Zsh/Bash)
pad_regex="\{([in]):0([0-9]+)\}"

# Génération et ajout à la fin du fichier cible
{
    for ((i = start; i <= end; i++)); do
        i0=$((i - 1))
        line="$text"

        # Remplacement avec padding {i:0X} et {n:0X}
        while [[ "$line" =~ $pad_regex ]]; do
            var="${match[1]}"
            padlen="${match[2]}"
            padded=$(printf "%0*d" "$padlen" "$i")
            line="${line/\{$var:0$padlen\}/$padded}"
        done

        # Remplacements des variables d'itération
        line="${line//\{i\}/$i}"
        line="${line//\{n\}/$i}"
        line="${line//\{index\}/$i}"
        line="${line//\{\}/$i}"
        line="${line//\{i0\}/$i0}"
        line="${line//\{n0\}/$i0}"
        line="${line//\{start\}/$start}"
        line="${line//\{end\}/$end}"
        line="${line//\{count\}/$count}"
        line="${line//\{total\}/$count}"

        print -r -- "$line"
    done
} >> "$target_file"
