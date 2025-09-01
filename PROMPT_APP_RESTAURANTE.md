
# 🍕 Prompt para App Restaurante - Flutter Web PWA

**CONTEXTO COMPLETO**: Desenvolver App Restaurante Flutter Web PWA como parte 2 do sistema de delivery. O App Cliente (parte 1) já foi desenvolvido e está funcionando.

## 🔥 **Firebase Project Existente**

### Coleções Firestore Já Criadas:
- **users**: Clientes cadastrados
- **restaurants**: Dados dos restaurantes  
- **orders**: Pedidos com status em tempo real
- **products**: Cardápios dos restaurantes
- **categories**: Categorias de produtos
- **coupons**: Cupons de desconto

### Services Firebase Implementados:
- **Authentication**: Email/senha + Google Sign-In
- **Cloud Functions**: Pagamentos MercadoPago + webhooks
- **Cloud Messaging**: Notificações push
- **Analytics & Crashlytics**: Monitoramento

### Estrutura de Orders (Pedidos):
```json
{
  "id": "order_id",
  "userId": "client_user_id", 
  "restaurantId": "restaurant_id",
  "items": [
    {
      "productId": "product_id",
      "name": "Product Name",
      "price": 25.90,
      "quantity": 2,
      "selectedOptions": [],
      "selectedAddons": [],
      "notes": "Observações do cliente"
    }
  ],
  "subtotal": 51.80,
  "deliveryFee": 5.99,
  "total": 57.79,
  "status": "pending|confirmed|preparing|ready|onTheWay|delivered|cancelled",
  "paymentMethod": "pix|creditCard|debitCard|cash",
  "deliveryAddress": {
    "street": "Rua X", 
    "number": "123",
    "neighborhood": "Bairro",
    "city": "Cidade"
  },
  "orderTime": "timestamp",
  "estimatedDeliveryTime": "timestamp",
  "trackingCode": "TRK20250830001"
}
```

## 🎨 **Design System Estabelecido**

### Cores:
- **Primary**: #FF6B35 (Laranja delivery)
- **Secondary**: #2E8B57 (Verde)  
- **Background**: #FAFAFA
- **Surface**: #FFFFFF
- **Error**: #F44336

### Arquitetura Modular:
- **Presentation**: Pages, Widgets, Providers
- **Domain**: Entities, Repositories, UseCases
- **Data**: Repositories Impl, DataSources
- **Services**: Auth, Firestore, Notification, Payment

## 🏪 **Funcionalidades App Restaurante**

### **Autenticação Restaurante**
- Login específico para donos de restaurante
- Vincular conta ao restaurantId
- Perfil do restaurante (nome, dados, cardápio)

### **Recebimento de Pedidos** ⭐
- **Stream em tempo real** dos novos pedidos
- **Notificação sonora persistente** até aceitar/recusar
- **Push notification web** + som de alerta
- Badge/contador de pedidos pendentes

### **Gestão de Pedidos**
- **Aceitar/Recusar** pedidos com motivo
- **Atualizar status**: confirmed → preparing → ready → onTheWay
- **Tempo de preparo** estimado
- **Comunicação com cliente** (WhatsApp integration)

### **Impressão Térmica POS-58** ⭐⭐
- **Gerar layout otimizado** para impressora térmica
- **Mínimo uso de papel** 
- **Dados essenciais**:
  - Número do pedido e tracking code
  - Dados do cliente (nome, telefone)
  - Endereço completo de entrega
  - Lista de itens (nome, qtd, opções, addons)
  - Método de pagamento
  - Observações
  - Total e taxas
- **Botão "Imprimir Pedido"** após aceitar
- **Preview antes de imprimir**

### **Gestão de Cardápio**
- **CRUD completo** de produtos
- **Categorias** e organização
- **Disponibilidade** (ativar/desativar itens)
- **Preços e promoções**
- **Upload de imagens**

### **Dashboard Restaurante**
- **Estatísticas do dia**: pedidos, faturamento
- **Pedidos em andamento** com tempos
- **Histórico de pedidos**
- **Avalições recebidas**

### **Configurações**
- **Horário de funcionamento**
- **Status online/offline**
- **Taxa de entrega**
- **Tempo médio de preparo**
- **Dados do restaurante**

## 🔔 **Sistema de Notificações Específico**

### **Som de Alerta Persistente**
- **Audio loop** até interação do usuário
- **Volume configurável** 
- **Diferentes sons** para: novo pedido, cancelamento, urgente
- **Notificação visual** + badge + som

### **Tipos de Notificação**
- 🔔 **Novo pedido**: Som persistente + modal
- ⚡ **Pedido cancelado**: Alerta sonoro
- 💰 **Pagamento confirmado**: Notificação discreta
- ⏰ **Tempo limite**: Alerta se não aceitar em X minutos

## 🖨️ **Layout Impressão POS-58**

### **Template Otimizado** (58mm largura):
```
========================================
           NOVO PEDIDO
========================================
Pedido: #TRK20250830001
Data: 30/08/2025 - 14:30

CLIENTE:
Nome: João Silva
Tel: (11) 99999-9999

ENTREGA:
Rua das Flores, 123, Apt 45
Bairro Centro - São Paulo/SP
CEP: 01234-567

----------------------------------------
ITENS:
----------------------------------------
2x Pizza Margherita (Grande)
   + Borda recheada
   + Bacon extra
   Obs: Sem cebola
                          R$ 89,80

1x Coca-Cola 350ml
                          R$ 6,90

----------------------------------------
PAGAMENTO: PIX
Subtotal:                 R$ 96,70
Taxa entrega:             R$ 0,00
TOTAL:                    R$ 96,70

OBS. GERAIS:
Entregar no portão azul

========================================
        Tempo prep.: 35 min
========================================
```

## 📱 **Interface Específica Restaurante**

### **Tela Principal**
- **Lista de pedidos pendentes** (cards grandes)
- **Botões grandes**: ACEITAR / RECUSAR
- **Timer** de quanto tempo o pedido está pendente
- **Botão emergência**: "Restaurante fechado"

### **Fluxo de Aceite**
1. **Modal com detalhes** completos do pedido
2. **Tempo de preparo** (input personalizado)
3. **Botões**: Aceitar / Recusar
4. **Se recusar**: Campo obrigatório do motivo
5. **Se aceitar**: Gerar impressão automaticamente

### **Gestão Ativa**
- **Pedidos em preparo** com cronômetro
- **Marcar como pronto** 
- **Notificar entregador/cliente**
- **Chat rápido** com cliente

## 🔧 **Integrações Necessárias**

### **Impressão Web**
- **Web Print API** para impressoras USB/rede
- **Layout CSS** específico para 58mm
- **Fallback**: Download PDF se impressão falhar

### **Audio/Som**
- **Web Audio API** para sons personalizados
- **Permissões de som** no browser
- **Controle de volume**

### **Real-time Firebase**
- **Firestore onSnapshot** para novos pedidos
- **Cloud Functions triggers** para notificações
- **Status sync** automático

## 📋 **Entidades Específicas**

### **RestaurantUser** (extends User)
```dart
class RestaurantUser extends User {
  final String restaurantId;
  final String role; // 'owner', 'manager', 'staff'
  final List<String> permissions;
  final bool isActive;
}
```

### **PrintSettings**
```dart
class PrintSettings {
  final String printerName;
  final int paperWidth; // 58mm
  final bool autoPrint;
  final int copies;
  final String template;
}
```

### **NotificationSettings**
```dart
class NotificationSettings {
  final bool soundEnabled;
  final String soundFile;
  final int volume;
  final bool persistentAlert;
  final int timeoutMinutes;
}
```

## 🎯 **Deliverables App Restaurante**

1. ✅ **Flutter Web PWA completo**
2. ✅ **Mesmo padrão arquitetural** do cliente
3. ✅ **Integração Firebase** total
4. ✅ **Sistema de impressão** POS-58
5. ✅ **Notificações sonoras** persistentes
6. ✅ **Interface otimizada** para restaurantes
7. ✅ **Real-time sync** com App Cliente
8. ✅ **PWA instalável** e offline-ready

## 🚀 **Comando para Próxima Conversa**

```markdown
Desenvolver App Restaurante Flutter Web PWA para sistema delivery existente.

CONTEXTO: App Cliente já criado com Firebase configurado. Preciso do App Restaurante compatível.

ARQUITETURA: Presentation/Domain/Data/Services (mesma estrutura)

DESIGN: Cores #FF6B35 (primary), #2E8B57 (secondary), tema claro/escuro

FIREBASE: Usar mesmas coleções (orders, restaurants, products, users)

FUNCIONALIDADES:
- Recebimento pedidos tempo real
- Notificações sonoras persistentes  
- Aceite/recusa com motivos
- Impressão otimizada POS-58 (58mm)
- Gestão cardápio completa
- Dashboard vendas
- Status online/offline
- Histórico pedidos

INTEGRAÇÕES:
- Firebase Auth/Firestore/Functions  
- Impressão térmica web
- Audio alerts persistentes
- Real-time updates
- PWA instalável

DELIVERABLE: App completo funcional como Flutter Web PWA.
```

**💡 Copie este prompt e use na próxima conversa!**

---

**🎯 Dessa forma garanto 100% compatibilidade e integração perfeita entre os apps!**
