#!/bin/bash
echo "=== Verificació de requisits del projecte Blog MVC ==="

# 1. Comprovar estructura de directoris
DIRS=("src/Controllers" "src/Models" "src/Views/layouts" "src/Core" "src/Middleware" "config" "database/migrations" "storage/uploads")
for dir in "${DIRS[@]}"; do
    [ -d "$dir" ] && echo "✅ $dir" || echo "❌ $dir"
done

# 2. Comprovar arxius clau
FILES=("public/index.php" "config/database.php" "config/routes.php" "src/Core/Router.php" "src/Core/Database.php" "src/Core/Controller.php")
for file in "${FILES[@]}"; do
    [ -f "$file" ] && echo "✅ $file" || echo "❌ $file"
done

# 3. Comprovar controladors
for ctrl in HomeController AuthController PostController UserController; do
    [ -f "src/Controllers/$ctrl.php" ] && echo "✅ $ctrl" || echo "❌ $ctrl"
done

# 4. Comprovar models
for model in User Post; do
    [ -f "src/Models/$model.php" ] && echo "✅ $model" || echo "❌ $model"
done

# 5. Comprovar middlewares
for mid in AuthMiddleware GuestMiddleware; do
    [ -f "src/Middleware/$mid.php" ] && echo "✅ $mid" || echo "❌ $mid"
done

# 6. Comprovar que la base de dades té dades
if mysql -u blog_user -pBlogMVC2024! -e "USE blog_mvc; SELECT COUNT(*) FROM users;" &>/dev/null; then
    USERS=$(mysql -u blog_user -pBlogMVC2024! -N -e "USE blog_mvc; SELECT COUNT(*) FROM users;")
    POSTS=$(mysql -u blog_user -pBlogMVC2024! -N -e "USE blog_mvc; SELECT COUNT(*) FROM posts;")
    echo "✅ Base de dades: $USERS usuaris, $POSTS posts"
else
    echo "⚠️ No s'ha pogut connectar a la BD. Prova manual: mysql -u blog_user -pBlogMVC2024!"
fi

echo "=== Fi de la verificació ==="
