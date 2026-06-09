#!/bin/bash

set -e  # Para que se detenga si hay error

cd ~/blog-mvc

echo "🚀 PREPARANT PROJECTE PER PUJAR A GITHUB"

# 1. Crear .gitignore si no existe
if [ ! -f .gitignore ]; then
    cat > .gitignore << 'GITIGNORE'
/vendor/
.env
.env.*
storage/logs/*.log
storage/uploads/*
.DS_Store
composer.phar
.phpunit.cache
.vscode/
.idea/
Thumbs.db
config/database.php
GITIGNORE
    echo "✅ .gitignore creat"
else
    echo "⚠️ .gitignore ja existeix. No es modifica."
fi

# 2. Substituir credencials reals per valors d'exemple
if [ -f config/database.php ]; then
    echo "🔐 Substituint credencials reals per valors d'exemple a config/database.php"
    cp config/database.php config/database.local.php
    cat > config/database.php << 'DBEXAMPLE'
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
DBEXAMPLE
    echo "✅ Credencials anonimitzades. S'ha guardat una còpia local a config/database.local.php"
fi

# 3. Inicialitzar git si no està inicialitzat
if [ ! -d .git ]; then
    git init
    echo "✅ Git inicialitzat"
fi

# 4. Afegir tots els fitxers (excepte els ignorats)
git add .
echo "✅ Fitxers afegits al staging"

# 5. Fer commit
git commit -m "Primera versió del projecte Blog MVC" || echo "⚠️ No s'ha pogut fer commit (potser ja existeix o no hi ha canvis)"

# 6. Configurar remote si no existeix
if ! git remote | grep -q origin; then
    git remote add origin https://github.com/sergiogc4/blog-mvc.git
    echo "✅ Remote origin afegit"
else
    echo "⚠️ Remote origin ja existeix"
fi

# 7. Pujar a GitHub
echo "📤 Pujant a GitHub..."
git push -u origin main || git push -u origin master

echo ""
echo "✅ Projecte pujat correctament a https://github.com/sergiogc4/blog-mvc"
echo "🔁 No oblidis restaurar les teves credencials locals:"
echo "   cp config/database.local.php config/database.php"
