
# App Cliente Delivery - Flutter Web PWA

Sistema completo de delivery estilo iFood desenvolvido em Flutter Web como PWA.

## 🚀 Configuração Inicial

### 1. Criar Projeto Flutter Web
```bash
flutter create delivery_app_cliente
cd delivery_app_cliente
```

### 2. Substituir pubspec.yaml
- Copie o conteúdo do arquivo `pubspec.yaml` fornecido
- Execute: `flutter pub get`

### 3. Configurar Firebase
- Instale Firebase CLI: `npm install -g firebase-tools`
- Execute: `firebase login`
- Execute: `flutterfire configure` (escolha seu projeto Firebase)
- Copie o arquivo `firebase_options.dart` para `lib/`

### 4. Copiar Estrutura de Arquivos
- Copie todos os arquivos `.dart` para suas respectivas pastas
- Copie arquivos `web/` para a pasta web do projeto
- Copie `firebase.json` para raiz do projeto

### 5. Build e Deploy
```bash
flutter build web --web-renderer html
firebase deploy --only hosting
```

## 📁 Estrutura de Pastas

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── router/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/
└── services/
    ├── auth_service.dart
    ├── firestore_service.dart
    ├── payment_service.dart
    └── notification_service.dart
```

## 🔥 Configuração Firebase

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Restaurants
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if request.auth != null && 
        (request.auth.token.admin == true || request.auth.uid == resource.data.ownerId);
    }
    
    // Orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || request.auth.token.admin == true);
    }
  }
}
```

### Cloud Functions Package.json
```json
{
  "name": "functions",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "start": "npm run serve",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^11.8.0",
    "firebase-functions": "^4.3.1",
    "mercadopago": "^1.5.17"
  },
  "devDependencies": {
    "typescript": "^4.9.0"
  }
}
```

## 💳 Integração Mercado Pago

### Configuração
1. Crie conta no Mercado Pago
2. Obtenha as chaves (sandbox e produção)
3. Configure no Firebase Functions
4. Configure webhook endpoints

## 🔔 Notificações Push

### Setup FCM
1. Configure Firebase Cloud Messaging
2. Baixe arquivo `firebase-messaging-sw.js`
3. Copie para pasta `web/`

## 📱 PWA Configuração

### Recursos Incluídos
- ✅ Manifest.json
- ✅ Service Worker
- ✅ Ícones PWA (192x192, 512x512)
- ✅ Offline fallback
- ✅ Cache estratégico

## 🎨 Design System

### Cores Principais
- Primary: #FF6B35 (Laranja delivery)
- Secondary: #2E8B57 (Verde)
- Background: #FAFAFA
- Surface: #FFFFFF
- Error: #F44336

### Tipografia
- Display: Roboto Bold
- Headline: Roboto Medium
- Body: Roboto Regular
- Caption: Roboto Light

## 🔧 Scripts Úteis

### Desenvolvimento
```bash
flutter run -d chrome
```

### Build Produção
```bash
flutter build web --release --web-renderer html
```

### Deploy Firebase
```bash
firebase deploy
```

## 📊 Monitoramento

### Analytics Implementado
- Eventos de navegação
- Conversões de pedidos
- Performance de restaurantes
- Comportamento do usuário

### Crashlytics
- Relatórios de crashes automáticos
- Logs personalizados
- Métricas de estabilidade

## 🧪 Testes

### Executar Testes
```bash
flutter test
```

### Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📚 Funcionalidades Implementadas

✅ Autenticação (Email/Senha, Google Sign-In)
✅ Perfil do Usuário
✅ Listagem de Restaurantes
✅ Cardápio Dinâmico
✅ Carrinho de Compras
✅ Sistema de Checkout
✅ Acompanhamento de Pedidos
✅ Avaliações
✅ Notificações Push
✅ Dark Mode
✅ Responsividade
✅ PWA
✅ Integração Firebase
✅ Sistema de Pagamentos
