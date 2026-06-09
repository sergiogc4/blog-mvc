# Arquitectura MVC

- **Router** (`src/Core/Router.php`) – Gestiona les rutes i crida el controlador adequat.
- **Controller** – Rep la petició, interactua amb el model i retorna la vista.
- **Model** – Accedeix a la base de dades amb PDO (prepared statements).
- **View** – Plantilles amb PHP i Bootstrap 5.
- **Middleware** – AuthMiddleware i GuestMiddleware per controlar l'accés.
