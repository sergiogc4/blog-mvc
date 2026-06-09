#!/bin/bash

# Script de desplegament final a GitHub
# No puja credencials reals, backups ni fitxers temporals

set -e

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'

echo -e "${COLOR_GREEN}Preparant el projecte per pujar a GitHub...${COLOR_RESET}"

# 1. Eliminar backups i carpetes temporals
rm -rf backup_controllers/ src_with_docs/ 2>/dev/null || true
rm -f add_docblocks.sh finalize_and_push.sh generate_docblocks.sh add_comments_to_controllers.sh 2>/dev/null || true

# 2. Buidar storage/uploads però mantenir el directori (no volem pujar avatars locals)
rm -rf storage/uploads/* 2>/dev/null || true
echo "storage/uploads buidat."

# 3. Assegurar credentials de demostració a config/database.php
cat > config/database.php << 'DB'
<?php
return [
    'host' => 'localhost',
    'port' => '3306',
    'database' => 'blog_mvc',
    'username' => 'el_teu_usuari',
    'password' => 'la_teva_contrasenya',
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]
];
DB
echo -e "${COLOR_GREEN}Credencials de base de dades canviades per valors de demostració.${COLOR_RESET}"

# 4. Crear .gitignore
cat > .gitignore << 'GITIGNORE'
/vendor/
.env
.env.*
storage/logs/*.log
storage/uploads/*
composer.phar
.DS_Store
.idea/
.vscode/
Thumbs.db
backup_controllers/
src_with_docs/
*.sh
GITIGNORE
echo -e "${COLOR_GREEN}.gitignore creat.${COLOR_RESET}"

# 5. Inicialitzar repositori Git si no existeix
if [ ! -d .git ]; then
    git init
    echo -e "${COLOR_GREEN}Repositori Git inicialitzat.${COLOR_RESET}"
else
    echo -e "${COLOR_GREEN}Ja existeix repositori Git.${COLOR_RESET}"
fi

# 6. Afegir tots els fitxers (excepte els ignorats) i fer commit
git add .
git commit -m "Primera versió estable del Blog MVC amb documentació i comentaris PHPDoc"

# 7. Configurar remote (HTTPS) i pujar
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/sergiogc4/blog-mvc.git
echo -e "${COLOR_GREEN}Remote configurat: https://github.com/sergiogc4/blog-mvc.git${COLOR_RESET}"

# 8. Pujar a la branca principal
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    BRANCH="main"
    git checkout -b main
fi
git push -u origin $BRANCH

if [ $? -eq 0 ]; then
    echo -e "${COLOR_GREEN}✅ Projecte pujat correctament a https://github.com/sergiogc4/blog-mvc${COLOR_RESET}"
else
    echo -e "${COLOR_YELLOW}⚠️ No s'ha pogut pujar via HTTPS. Comprova la connexió o utilitza SSH.${COLOR_RESET}"
    echo -e "Pots configurar SSH manualment:"
    echo "   git remote set-url origin git@github.com:sergiogc4/blog-mvc.git"
    echo "   git push -u origin main"
fi
