<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .auth-card { max-width: 500px; margin: 50px auto; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .auth-card .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px 15px 0 0; padding: 20px; text-align: center; }
        .auth-card .card-body { padding: 30px; background: white; border-radius: 0 0 15px 15px; }
        .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; }
        .btn-primary:hover { opacity: 0.9; transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-md-8 mx-auto auth-card">
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-blog"></i> <?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></h3>
                    </div>
                    <div class="card-body">
                        <?php require_once $viewPath; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
