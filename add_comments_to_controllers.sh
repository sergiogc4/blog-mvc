#!/bin/bash

# Script per afegir comentaris PHPDoc (en català) als controladors
# Es crea una còpia de seguretat a backup_controllers/ abans de modificar

set -e

BACKUP_DIR="backup_controllers"
mkdir -p "$BACKUP_DIR"

# Funció per afegir comentaris de classe i mètodes
process_file() {
    local file="$1"
    local classname="$2"
    local class_desc="$3"
    local backup_file="$BACKUP_DIR/$(basename "$file")"

    # Copia de seguretat
    cp "$file" "$backup_file"
    echo "📁 Backup creat: $backup_file"

    # Afegir comentari de classe si no existeix
    if ! grep -q "/\*\*.*$classname" "$file"; then
        sed -i "s/^\(class $classname\)/\/**\n * $class_desc\n *\n * @package Blog\\\Controllers\n *\/\n\1/" "$file"
        echo "✅ Comentari de classe afegit a $file"
    fi

    # Afegir comentaris als mètodes (només els que no en tenen)
    # Mètode profile
    if grep -q "public function profile()" "$file" && ! grep -q "@method profile" "$file"; then
        sed -i "/public function profile()/i \\
    /**\n     * Mostra el perfil de l'usuari autenticat.\n     *\n     * @return void\n     */" "$file"
        echo "  📝 Comentari per a profile()"
    fi

    # Mètode editProfile
    if grep -q "public function editProfile()" "$file" && ! grep -q "@method editProfile" "$file"; then
        sed -i "/public function editProfile()/i \\
    /**\n     * Mostra el formulari d'edició del perfil.\n     *\n     * @return void\n     */" "$file"
        echo "  📝 Comentari per a editProfile()"
    fi

    # Mètode updateProfile
    if grep -q "public function updateProfile()" "$file" && ! grep -q "@method updateProfile" "$file"; then
        sed -i "/public function updateProfile()/i \\
    /**\n     * Actualitza el nom i la biografia de l'usuari.\n     *\n     * @return void\n     */" "$file"
        echo "  📝 Comentari per a updateProfile()"
    fi

    # Mètode uploadAvatar
    if grep -q "public function uploadAvatar()" "$file" && ! grep -q "@method uploadAvatar" "$file"; then
        sed -i "/public function uploadAvatar()/i \\
    /**\n     * Puja i actualitza l'avatar de l'usuari.\n     *\n     * @return void\n     */" "$file"
        echo "  📝 Comentari per a uploadAvatar()"
    fi
}

# Processar UserController
process_file "src/Controllers/UserController.php" "UserController" "Controlador del perfil d'usuari: visualització, edició i pujada d'avatar."

# Processar HomeController
process_file "src/Controllers/HomeController.php" "HomeController" "Controlador de la pàgina principal i de cerca."

# Processar PostController (cal afegir comentaris per a tots els mètodes)
process_file_post() {
    local file="src/Controllers/PostController.php"
    local backup_file="$BACKUP_DIR/PostController.php"
    cp "$file" "$backup_file"
    echo "📁 Backup creat: $backup_file"

    # Comentari de classe
    if ! grep -q "/\*\*.*PostController" "$file"; then
        sed -i "s/^\(class PostController\)/\/**\n * Controlador per a la gestió completa de posts (CRUD, publicació, edició, eliminació).\n *\n * @package Blog\\\Controllers\n *\/\n\1/" "$file"
        echo "✅ Comentari de classe afegit a PostController"
    fi

    # Llista de mètodes i les seves descripcions
    declare -A methods=(
        ["index"]="Llista tots els posts publicats (paginats)."
        ["show"]="Mostra un post individual pel seu slug i incrementa les visualitzacions."
        ["byAuthor"]="Llista els posts d'un autor específic."
        ["myPosts"]="Llista els posts de l'usuari autenticat (tots els estats)."
        ["create"]="Mostra el formulari per crear un nou post."
        ["store"]="Guarda un nou post (valida, genera slug i excerpt)."
        ["edit"]="Mostra el formulari d'edició d'un post (només autor)."
        ["update"]="Actualitza un post existent (només autor)."
        ["delete"]="Elimina un post (només autor)."
        ["publish"]="Commuta l'estat del post entre esborrany i publicat."
    )

    for method in "${!methods[@]}"; do
        if grep -q "public function $method(" "$file" && ! grep -q "@method $method" "$file"; then
            desc="${methods[$method]}"
            sed -i "/public function $method(/i \\
    /**\n     * $desc\n     *\n     * @return void\n     */" "$file"
            echo "  📝 Comentari per a $method()"
        fi
    done
}
process_file_post

# Processar AuthController
process_file_auth() {
    local file="src/Controllers/AuthController.php"
    local backup_file="$BACKUP_DIR/AuthController.php"
    cp "$file" "$backup_file"
    echo "📁 Backup creat: $backup_file"

    if ! grep -q "/\*\*.*AuthController" "$file"; then
        sed -i "s/^\(class AuthController\)/\/**\n * Controlador d'autenticació: registre, inici de sessió i tancament de sessió.\n *\n * @package Blog\\\Controllers\n *\/\n\1/" "$file"
        echo "✅ Comentari de classe afegit a AuthController"
    fi

    declare -A methods=(
        ["showLogin"]="Mostra el formulari d'inici de sessió."
        ["login"]="Processa les credencials i inicia la sessió."
        ["showRegister"]="Mostra el formulari de registre."
        ["register"]="Registra un nou usuari amb validacions i contrasenya xifrada."
        ["logout"]="Tanca la sessió de l'usuari."
    )

    for method in "${!methods[@]}"; do
        if grep -q "public function $method(" "$file" && ! grep -q "@method $method" "$file"; then
            desc="${methods[$method]}"
            sed -i "/public function $method(/i \\
    /**\n     * $desc\n     *\n     * @return void\n     */" "$file"
            echo "  📝 Comentari per a $method()"
        fi
    done
}
process_file_auth

echo ""
echo "🎉 Tots els controladors han estat comentats correctament."
echo "📂 Els originals s'han copiat a la carpeta $BACKUP_DIR"
echo "🔁 Si vols restaurar, executa: cp $BACKUP_DIR/*.php src/Controllers/"
