# rl

Script Zsh permettant de répéter une ligne un certain nombre de fois ou sur une plage d'indices donnée à la fin d'un fichier cible, avec prise en charge de placeholders d'itération.

## Utilisation

```zsh
# Répétition N fois ou avec une plage "debut..fin" :
./rl.sh <texte> <nombre_ou_plage> <fichier_cible>

# Répétition avec début et fin en deux arguments distincts :
./rl.sh <texte> <debut> <fin> <fichier_cible>
```

### Paramètres

1. **texte** : Le texte à répéter. Vous pouvez y inclure des placeholders :
   - `{i}`, `{n}`, `{index}`, `{}` : Numéro d'itération courant.
   - `{i:0X}`, `{n:0X}` : Numéro avec complétion de zéros (ex. `{i:03}` donne `001`, `002`...).
   - `{i0}`, `{n0}` : Numéro d'itération moins 1 (`i - 1`).
   - `{start}`, `{end}` : Bornes de départ et de fin.
   - `{total}`, `{count}` : Nombre total d'itérations générées.
2. **nombre_ou_plage** / **debut fin** :
   - Un entier strictement positif (ex. `5` pour itérer de `1` à `5`).
   - Une plage sous forme `debut..fin` (ex. `3..7`).
   - Deux entiers `debut` et `fin` séparés par un espace (ex. `3 7`).
3. **fichier_cible** : Le chemin vers le fichier où ajouter les lignes à la fin (créé automatiquement s'il n'existe pas).

## Exemples

```zsh
# Répéter une ligne fixe 3 fois
./rl.sh "-------------------" 3 output.txt

# Répéter avec compteur de 1 à 5
./rl.sh "Ligne numéro {i}" 5 output.txt

# Répéter sur une plage de 3 à 7 (syntaxe plage)
./rl.sh "Serveur node-{i:02} (sur {total})" 3..7 output.txt

# Répéter sur une plage de 3 à 7 (arguments distincts)
./rl.sh "Serveur node-{i:02} (sur {total})" 3 7 output.txt

# Répéter avec complétion de zéros et total
./rl.sh "Serveur host-{i:03}.local ({i}/{total})" 10 serveurs.log
```
