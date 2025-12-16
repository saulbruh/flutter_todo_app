# flutter_todo_app
Proyecto Final – Aplicación de Listas de Todos con Categorías

Descripción general de la aplicación
Esta aplicación es una app móvil desarrollada en Flutter y Dart que permite al usuario organizar
tareas (Todos) utilizando categorías personalizadas. La aplicación está pensada como una
herramienta sencilla de organización personal, académica o laboral.

El usuario puede crear categorías (por ejemplo: Universidad, Trabajo, Personal) y, dentro de
cada una, crear tareas con una descripción, una fecha límite opcional y un estado de completado.
La app muestra resúmenes por categoría indicando cuántas tareas hay en total, cuántas están
pendientes y cuántas han sido completadas.

Cómo ejecutar la aplicación:

Requisitos:
• Tener Flutter instalado (versión estable recomendada).
• Tener un emulador Android/iOS o un dispositivo físico conectado.
• Tener Visual Studio Code o Android Studio.

Pasos para ejecutar:
1. Abrir una terminal en la raíz del proyecto.
2. Ejecutar el comando: flutter pub get
3. Luego ejecutar: flutter run

Funcionalidades principales

• Crear, editar y eliminar categorías.

• Ver por cada categoría:
o Cantidad total de Todos.
o Cantidad de Todos pendientes.
o Cantidad de Todos completados.

• Crear, editar, completar y eliminar Todos.

• Asignar una fecha límite a cada Todo.

• Filtrar Todos por:
o Todos
o Pendientes
o Completados
o Vencidos (overdue)

• Persistencia local de datos utilizando Hive.