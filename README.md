# Gestor de Cafetería

Aplicación móvil desarrollada con Flutter para gestionar las operaciones de una cafetería, incluyendo la consulta y administración de pedidos mediante un cliente HTTP que se comunica con una API REST.

## Requisitos

Versiones utilizadas para verificar el proyecto:

- Flutter 3.47.4
- Dart 3.13.3
- Node.js 24.18.0 o superior para el backend
- Git

## Backend: mini_backend

El backend se encuentra en un repositorio independiente:

[https://github.com/DMI-2026/mini_backend](https://github.com/DMI-2026/mini_backend)

No es necesario copiarlo dentro de este proyecto.

### Versión probada

Node.js 24.18.0.

### Cómo ejecutar el backend

Clonar el repositorio:

```bash
git clone https://github.com/DMI-2026/mini_backend.git
cd mini_backend
```

Iniciar el servidor:

```bash
node server.js
```

El servidor utiliza el puerto 8000.

Para ejecutar sus pruebas:

```bash
node --test
```

## Aplicación Flutter

Clonar el proyecto:

```bash
git clone https://github.com/Aqquinou/gestor_cafeteria.git
cd gestor_cafeteria
```

Instalar dependencias:

```bash
flutter pub get
```

### Configuración de la API

La aplicación permite configurar la dirección del backend mediante `API_URL`.

Para Flutter Web:

```bash
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
```

Para un emulador Android:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000
```

Asegúrate de iniciar primero el backend.

## Pruebas

Ejecutar todas las pruebas:

```bash
flutter test
```

Analizar el proyecto:

```bash
flutter analyze
```

Las pruebas del cliente HTTP utilizan `MockClient`, por lo que no necesitan conectarse a un servidor real.

## Estructura del proyecto

```text
lib/
├── core/
│   ├── failure.dart
│   └── http_client.dart
└── features/
    └── orders/
        ├── data/
        ├── domain/
        └── ui/

test/
└── core/
    ├── failure_test.dart
    └── http_client_test.dart
```

## Versionamiento

El proyecto utiliza Git y ramas de trabajo para organizar las modificaciones.

- `main`: rama principal.
- `feature/error-mapping`: mapeo de errores HTTP.
- `feature/api-tests`: correcciones y pruebas unitarias del cliente HTTP.