<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: #f8f9fa; font-family: system-ui; }
        .navbar { background: white; border-bottom: 1px solid #dee2e6; }
        footer { background: white; border-top: 1px solid #dee2e6; margin-top: 3rem; padding: 1.5rem 0; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="/">Blog MVC</a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="/login">Iniciar sessió</a></li>
                    <li class="nav-item"><a class="nav-link" href="/register">Registre</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <main class="container my-4">
        
    </main>
    <footer class="text-center">
        <div class="container">&copy; <?php echo date('Y'); ?> Blog MVC</div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
