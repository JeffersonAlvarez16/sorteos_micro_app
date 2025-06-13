# SorteosMicro App 🎲

Una aplicación móvil de sorteos diarios con premios en efectivo, desarrollada en Flutter.

## 📱 Características

### 🏠 Pantalla Principal
- Vista de sorteos activos y próximos
- Estadísticas en tiempo real
- Navegación intuitiva
- Notificaciones push

### 🔐 Autenticación
- Registro e inicio de sesión
- Autenticación con email y contraseña
- Recuperación de contraseña
- Verificación de cuenta

### 💰 Sistema de Depósitos
- Múltiples métodos de pago (Bizum, Transferencia, PayPal)
- Subida de comprobantes de pago
- Historial de transacciones
- Validación automática

### 🎯 Sorteos
- Sorteos diarios en 4 horarios
- Compra de boletos
- Estadísticas en tiempo real
- Historial de participaciones

### 👤 Perfil de Usuario
- Información personal
- Estadísticas de usuario
- Configuración de notificaciones
- Gestión de cuenta

## 🛠️ Tecnologías

- **Framework**: Flutter 3.10+
- **Estado**: GetX
- **Backend**: Supabase
- **Pagos**: Stripe
- **Notificaciones**: Firebase Cloud Messaging
- **Almacenamiento**: SharedPreferences
- **UI**: Material Design 3

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6                    # Gestión de estado
  supabase_flutter: ^2.0.0       # Backend
  flutter_stripe: ^10.1.0        # Pagos
  firebase_core: ^2.24.2         # Firebase
  google_fonts: ^6.1.0           # Tipografías
  cached_network_image: ^3.3.0   # Imágenes
  image_picker: ^1.0.4           # Selección de imágenes
  fl_chart: ^0.65.0              # Gráficos
```

## 🏗️ Arquitectura

El proyecto sigue el patrón **MVC** con **GetX**:

```
lib/
├── app/
│   ├── bindings/          # Inyección de dependencias
│   ├── config/            # Configuración de la app
│   ├── controllers/       # Lógica de negocio
│   ├── data/             # Modelos y repositorios
│   │   └── models/       # Modelos de datos
│   ├── routes/           # Navegación
│   ├── services/         # Servicios externos
│   ├── themes/           # Temas y estilos
│   ├── utils/            # Utilidades
│   ├── views/            # Pantallas
│   └── widgets/          # Widgets reutilizables
└── main.dart
```

## 🎨 Sistema de Temas

### Colores Principales
- **Primario**: Dorado (#FFD700)
- **Secundario**: Azul (#1E3A8A)
- **Éxito**: Verde (#10B981)
- **Error**: Rojo (#EF4444)
- **Advertencia**: Naranja (#F59E0B)

### Tipografía
- **Display**: Poppins (títulos principales)
- **Headings**: Poppins (encabezados)
- **Body**: Inter (texto general)
- **Labels**: Inter (etiquetas)

## 🚀 Configuración

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd sorteos_micro_app
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar variables de entorno
Edita `lib/app/config/app_config.dart`:

```dart
class AppConfig {
  static const String supabaseUrl = 'TU_SUPABASE_URL';
  static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';
  static const String stripePublishableKey = 'TU_STRIPE_PUBLISHABLE_KEY';
}
```

### 4. Configurar Firebase
- Añade `google-services.json` (Android)
- Añade `GoogleService-Info.plist` (iOS)

### 5. Ejecutar la aplicación
```bash
flutter run
```

## 📱 Pantallas Principales

### HomeView
- Lista de sorteos activos
- Estadísticas generales
- Acceso rápido a funciones

### AuthView
- Formularios de login/registro
- Validación en tiempo real
- Recuperación de contraseña

### DepositView
- Selección de método de pago
- Formulario de depósito
- Subida de comprobantes

### RaffleDetailView
- Información detallada del sorteo
- Compra de boletos
- Lista de participantes

### ProfileView
- Información del usuario
- Estadísticas personales
- Configuración de cuenta

## 🔧 Servicios

### AuthService
- Gestión de autenticación
- Manejo de sesiones
- Validación de tokens

### StorageService
- Almacenamiento local
- Caché de datos
- Preferencias de usuario

### NotificationService
- Notificaciones push
- Notificaciones locales
- Gestión de permisos

### PaymentService
- Integración con Stripe
- Procesamiento de pagos
- Validación de transacciones

### SupabaseService
- Conexión con backend
- Operaciones CRUD
- Tiempo real

## 🎯 Controladores

### HomeController
- Gestión de sorteos
- Estadísticas
- Navegación

### AuthController
- Autenticación
- Validación de formularios
- Gestión de estado

### DepositController
- Procesamiento de depósitos
- Validación de pagos
- Historial

### RaffleController
- Detalles de sorteos
- Compra de boletos
- Participantes

### ProfileController
- Información de usuario
- Configuración
- Estadísticas

## 🎨 Widgets Personalizados

### CustomTextField
- Campo de texto personalizado
- Validación integrada
- Estilos consistentes

### CustomButton
- Botones con estilos uniformes
- Estados de carga
- Feedback háptico

### RaffleCard
- Tarjeta de sorteo
- Información resumida
- Acciones rápidas

### DepositCard
- Tarjeta de depósito
- Estados visuales
- Información detallada

### StatCard
- Tarjetas de estadísticas
- Animaciones
- Datos en tiempo real

## 📊 Modelos de Datos

### UserModel
```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final double balance;
  final DateTime createdAt;
}
```

### RaffleModel
```dart
class RaffleModel {
  final String id;
  final String title;
  final double prize;
  final double ticketPrice;
  final DateTime drawDate;
  final RaffleStatus status;
  final int totalTickets;
  final int soldTickets;
}
```

### DepositModel
```dart
class DepositModel {
  final String id;
  final String userId;
  final double amount;
  final String paymentMethod;
  final DepositStatus status;
  final DateTime createdAt;
  final String? reference;
  final String? proofUrl;
}
```

## 🔒 Seguridad

- Validación de entrada en cliente y servidor
- Tokens JWT para autenticación
- Encriptación de datos sensibles
- Validación de permisos
- Sanitización de datos

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage
```

## 📱 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🚀 Deployment

### Play Store
1. Generar AAB: `flutter build appbundle --release`
2. Subir a Play Console
3. Configurar metadatos
4. Publicar

### App Store
1. Generar IPA: `flutter build ios --release`
2. Subir a App Store Connect
3. Configurar metadatos
4. Enviar para revisión

## 📝 Notas Importantes

### Configuración Requerida
- [ ] Configurar Supabase URL y keys
- [ ] Configurar Stripe keys
- [ ] Añadir archivos de Firebase
- [ ] Configurar permisos de cámara/galería
- [ ] Configurar notificaciones push

### Assets Necesarios
- [ ] Logo de la aplicación
- [ ] Iconos personalizados
- [ ] Imágenes de placeholder
- [ ] Animaciones Lottie
- [ ] Fuentes personalizadas

### Permisos
- Internet (automático)
- Cámara (image_picker)
- Galería (image_picker)
- Notificaciones (firebase_messaging)

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Soporte

- Email: soporte@sorteosmicro.com
- WhatsApp: +34 600 123 456
- Web: https://sorteosmicro.com

---

Desarrollado con ❤️ usando Flutter 