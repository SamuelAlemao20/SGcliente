
# 🏢 Prompt para Painel Administrativo - Flutter Web PWA

**CONTEXTO COMPLETO**: Desenvolver Painel Administrativo Flutter Web PWA como parte 3 do sistema de delivery. App Cliente (parte 1) e App Restaurante (parte 2) já foram desenvolvidos e estão funcionando.

## 🔥 **Firebase Project Existente - Sistema Completo**

### Coleções Firestore Já Criadas:
- **users**: Clientes e usuários do sistema
- **restaurants**: Dados completos dos restaurantes
- **orders**: Todos os pedidos do sistema
- **products**: Cardápios de todos restaurantes
- **categories**: Categorias de produtos
- **coupons**: Cupons de desconto
- **delivery_areas**: Áreas de entrega
- **admin_users**: Usuários administrativos

### Services Firebase Implementados:
- **Authentication**: Email/senha + Google Sign-In
- **Cloud Functions**: Pagamentos + webhooks + relatórios
- **Cloud Messaging**: Notificações push
- **Analytics & Crashlytics**: Monitoramento completo
- **Cloud Storage**: Upload de imagens

### Estrutura de Dados Consolidada:

#### **Users (Clientes)**
```json
{
  "id": "user_id",
  "name": "João Silva",
  "email": "joao@email.com",
  "phone": "+5511999999999",
  "addresses": [...],
  "totalOrders": 15,
  "totalSpent": 450.80,
  "status": "active|suspended|blocked",
  "createdAt": "timestamp",
  "lastOrderAt": "timestamp"
}
```

#### **Restaurants (Completo)**
```json
{
  "id": "restaurant_id",
  "name": "Pizza Express",
  "email": "contato@pizzaexpress.com",
  "phone": "+5511888888888",
  "address": {...},
  "category": "pizza",
  "rating": 4.8,
  "totalOrders": 1250,
  "totalRevenue": 89500.90,
  "isActive": true,
  "isOnline": true,
  "deliveryFee": 5.99,
  "minOrderValue": 25.00,
  "avgDeliveryTime": 35,
  "commission": 0.12, // 12% comissão plataforma
  "openingHours": {...},
  "paymentMethods": ["pix", "card", "cash"],
  "documents": {
    "cnpj": "12345678000199",
    "license": "verified"
  },
  "bankAccount": {
    "bank": "341",
    "agency": "1234",
    "account": "12345-6"
  },
  "createdAt": "timestamp"
}
```

#### **Orders (Sistema Completo)**
```json
{
  "id": "order_id",
  "trackingCode": "TRK20250830001",
  "userId": "client_id",
  "restaurantId": "restaurant_id",
  "items": [...],
  "subtotal": 51.80,
  "deliveryFee": 5.99,
  "platformFee": 2.00, // Taxa da plataforma
  "restaurantRevenue": 49.80, // Após comissão
  "total": 59.79,
  "commission": 6.20, // 12% sobre subtotal
  "status": "pending|confirmed|preparing|ready|onTheWay|delivered|cancelled",
  "paymentMethod": "pix|creditCard|debitCard|cash",
  "paymentStatus": "pending|paid|failed|refunded",
  "deliveryAddress": {...},
  "orderTime": "timestamp",
  "acceptedAt": "timestamp",
  "deliveredAt": "timestamp",
  "cancelledAt": "timestamp",
  "cancelReason": "motivo se cancelado",
  "rating": 4.5,
  "review": "Excelente!",
  "deliveryBoy": "entregador_id"
}
```

## 🎨 **Design System Consolidado**

### Cores Sistema:
- **Primary**: #FF6B35 (Laranja delivery)
- **Secondary**: #2E8B57 (Verde)
- **Admin**: #1E40AF (Azul admin)
- **Success**: #10B981
- **Warning**: #F59E0B
- **Error**: #F44336
- **Background**: #F8FAFC
- **Surface**: #FFFFFF

### Tema Admin Específico:
- **Sidebar escura** com navegação
- **Dashboard cards** com métricas
- **Tabelas responsivas** para dados
- **Gráficos** e relatórios visuais

## 🏢 **Funcionalidades Painel Administrativo**

### **Dashboard Principal** 📊
- **KPIs em tempo real**:
  - Total de pedidos hoje/semana/mês
  - Faturamento bruto/líquido
  - Comissões geradas
  - Restaurantes ativos/inativos
  - Usuários ativos
  - Taxa de conversão
  - Ticket médio
  - Tempo médio de entrega

- **Gráficos**:
  - Vendas por período (linha)
  - Pedidos por restaurante (barras)
  - Métodos de pagamento (pizza)
  - Horários de pico (heatmap)
  - Crescimento de usuários (área)

### **Gestão de Restaurantes** 🏪
- **Lista completa** com filtros e busca
- **Aprovar/reprovar** novos restaurantes
- **Editar dados** do restaurante
- **Ativar/desativar** restaurantes
- **Configurar comissões** individuais
- **Histórico de vendas** por restaurante
- **Documentos** e verificações
- **Chat** com restaurantes

### **Gestão de Usuários** 👥
- **Lista de clientes** com histórico
- **Banir/desbanir** usuários
- **Histórico de pedidos** por usuário
- **Suporte ao cliente** (chat/tickets)
- **Perfis administrativos**
- **Permissões** por usuário

### **Gestão de Pedidos** 📦
- **Monitor em tempo real** de todos pedidos
- **Filtros avançados**: status, restaurante, período
- **Intervir em problemas**: cancelar, reembolsar
- **Histórico completo** de alterações
- **Relatórios de entrega**
- **Problemas reportados**

### **Relatórios Avançados** 📈
- **Relatório financeiro**: receitas, comissões, repasses
- **Performance restaurantes**: ranking, métricas
- **Análise de produtos**: mais vendidos, categoria
- **Relatório de entregas**: tempos, problemas
- **Satisfação cliente**: ratings, reviews
- **Relatórios personalizados** com filtros
- **Exportação**: PDF, Excel, CSV

### **Gestão Financeira** 💰
- **Dashboard financeiro**:
  - Receita bruta/líquida
  - Comissões por restaurante
  - Repasses pendentes
  - Taxas e impostos
  - Fluxo de caixa

- **Pagamentos Restaurantes**:
  - Cálculo automático de repasses
  - Agendar pagamentos
  - Histórico de repasses
  - Relatórios de comissão

- **Gestão de Cupons**:
  - Criar/editar cupons
  - Limites de uso
  - Rastreamento de uso
  - ROI dos cupons

### **Configurações do Sistema** ⚙️
- **Configurações gerais**:
  - Taxa de entrega padrão
  - Comissão padrão
  - Tempo limite pedidos
  - Horários de funcionamento
  - Áreas de entrega

- **Integrações**:
  - MercadoPago (configurações)
  - SMS/WhatsApp APIs
  - Email templates
  - Push notifications

- **Usuários Admin**:
  - Criar/gerenciar admins
  - Níveis de permissão
  - Logs de ações
  - Auditoria de sistema

### **Monitoramento e Suporte** 🛠️
- **Monitor sistema**:
  - Status dos services
  - Performance das APIs
  - Logs de erro em tempo real
  - Métricas de uso

- **Suporte Cliente**:
  - Tickets de suporte
  - Chat com clientes
  - FAQ management
  - Base de conhecimento

- **Notificações Sistema**:
  - Alertas de problemas
  - Métricas críticas
  - Relatórios automáticos
  - Status dos restaurantes

## 📱 **Interface Admin Específica**

### **Layout Principal**
- **Sidebar fixa** com navegação
- **Header** com usuário admin + notificações
- **Dashboard** com cards de métricas
- **Tabelas responsivas** com paginação
- **Modais** para ações rápidas

### **Navegação Sidebar**
```
📊 Dashboard
🏪 Restaurantes
👥 Usuários
📦 Pedidos
💰 Financeiro
📈 Relatórios
🎟️ Cupons
⚙️ Configurações
🛠️ Suporte
📱 Sistema
```

### **Dashboard Cards**
- **Métricas principais** em cards grandes
- **Gráficos interativos** (Chart.js/Recharts)
- **Tabela** de pedidos recentes
- **Lista** de restaurantes online
- **Alertas** do sistema

## 🔧 **Integrações Admin Específicas**

### **Relatórios Excel/PDF**
- **Biblioteca**: `excel` + `pdf`
- **Templates** profissionais
- **Filtros avançados**
- **Agendamento** de relatórios

### **Notificações Admin**
- **Email automático** para eventos críticos
- **Dashboard alerts** em tempo real
- **WhatsApp** para urgências
- **Push notifications** web

### **Backup e Auditoria**
- **Logs de todas ações** administrativas
- **Backup automático** de dados críticos
- **Rastreamento** de alterações
- **Histórico** de configurações

## 📋 **Entidades Admin Específicas**

### **AdminUser**
```dart
class AdminUser extends User {
  final String role; // 'super_admin', 'admin', 'support', 'financial'
  final List<String> permissions;
  final DateTime lastLogin;
  final bool isActive;
  final String department;
}
```

### **SystemMetrics**
```dart
class SystemMetrics {
  final int totalOrders;
  final double totalRevenue;
  final int activeRestaurants;
  final int activeUsers;
  final double avgDeliveryTime;
  final double platformCommission;
  final DateTime timestamp;
}
```

### **AdminAction**
```dart
class AdminAction {
  final String adminId;
  final String action; // 'approve_restaurant', 'ban_user', etc
  final String targetId;
  final String details;
  final DateTime timestamp;
}
```

## 🎯 **Dashboards Específicos**

### **Dashboard Executivo**
- **Métricas estratégicas**
- **Comparativos** período anterior
- **Projeções** e metas
- **ROI** da plataforma

### **Dashboard Operacional**
- **Pedidos em tempo real**
- **Problemas** que precisam atenção
- **Restaurantes offline**
- **Entregas atrasadas**

### **Dashboard Financeiro**
- **Fluxo de caixa** detalhado
- **Comissões** por restaurante
- **Repasses pendentes**
- **Impostos** e taxas

## 🔐 **Segurança e Permissões**

### **Níveis de Acesso**
- **Super Admin**: Acesso total
- **Admin**: Gestão geral (sem configurações críticas)
- **Financial**: Apenas área financeira
- **Support**: Apenas suporte e relatórios
- **Viewer**: Apenas visualização

### **Auditoria Completa**
- **Log de todas ações** com usuário, IP, timestamp
- **Backup automático** antes de alterações críticas
- **Rastreamento** de modificações de dados
- **Alertas** para ações sensíveis

## 📊 **Relatórios Avançados**

### **Relatórios Executivos**
- **Performance geral** da plataforma
- **Crescimento** de usuários e restaurantes
- **Análise de mercado** por região
- **Competitividade** e benchmarks

### **Relatórios Operacionais**
- **Eficiência de entregas**
- **Performance restaurantes**
- **Satisfação do cliente**
- **Problemas operacionais**

### **Relatórios Financeiros**
- **Demonstrativo** de resultados
- **Comissões** detalhadas
- **Repasses** e pagamentos
- **Projeções** financeiras

## 🎯 **Funcionalidades Críticas Admin**

### **Monitoramento Real-time** ⭐
- **Mapa de entregas** em tempo real
- **Status de todos restaurantes**
- **Pedidos em andamento**
- **Alertas automáticos** para problemas

### **Gestão de Crises** ⭐⭐
- **Botão emergência**: pausar sistema
- **Comunicação em massa** (clientes/restaurantes)
- **Suporte prioritário**
- **Backup de dados** críticos

### **Analytics Avançado** ⭐⭐
- **Machine Learning insights**
- **Previsão de demanda**
- **Otimização de rotas**
- **Recomendações** estratégicas

### **Configurações Globais** ⚙️
- **Parâmetros do sistema**
- **Algoritmos de matching**
- **Políticas de comissão**
- **Integrações externas**

## 🏢 **Interface Admin Profissional**

### **Layout Executivo**
- **Sidebar colapsável** com ícones
- **Header** com breadcrumbs + user menu
- **Grid responsivo** para dashboards
- **Modais** e drawers para ações
- **Dark mode** profissional

### **Componentes Específicos**
- **DataTable** avançada (filtros, ordenação, paginação)
- **Charts** interativos (múltiplos tipos)
- **KPI Cards** com variação percentual
- **Map** para visualização geográfica
- **Calendar** para agendamentos

### **UX Admin Otimizada**
- **Shortcuts** de teclado
- **Busca global** (usuários, restaurantes, pedidos)
- **Notificações** discretas no canto
- **Loading states** profissionais
- **Feedback** visual para todas ações

## 🔔 **Sistema de Alertas Admin**

### **Alertas Críticos**
- 🚨 **Sistema fora do ar**
- 🚨 **Pagamento falhou** (alta quantidade)
- 🚨 **Restaurante** com muitos cancelamentos
- 🚨 **Entrega** muito atrasada

### **Alertas Importantes**
- ⚠️ **Novo restaurante** aguardando aprovação
- ⚠️ **Reclamação** de cliente
- ⚠️ **Meta** não atingida
- ⚠️ **Problema** técnico reportado

### **Notificações Informativas**
- ℹ️ **Relatório** gerado com sucesso
- ℹ️ **Backup** executado
- ℹ️ **Novo usuário** cadastrado
- ℹ️ **Atualização** de configuração

## 📋 **Funcionalidades Específicas Detalhadas**

### **1. Aprovação de Restaurantes** ✅
- **Fila de aprovação** com documentos
- **Verificação automática** de dados
- **Checklist** de aprovação
- **Comunicação** com solicitante
- **Histórico** de aprovações/negações

### **2. Gestão de Disputas** ⚖️
- **Centro de disputa** cliente vs restaurante
- **Mediação** de conflitos
- **Reembolsos** e compensações
- **Blacklist** automático
- **Relatórios** de disputas

### **3. Análise de Fraudes** 🔍
- **Detecção automática** de padrões suspeitos
- **Múltiplas contas** mesmo usuário
- **Pedidos** cancelados em excesso
- **Pagamentos** fraudulentos
- **Ações preventivas**

### **4. Marketing e Promoções** 📢
- **Campanhas** de marketing
- **Push notifications** em massa
- **Email marketing**
- **Cupons** estratégicos
- **A/B testing** de promoções

### **5. Gestão de Entregadores** 🚴
- **Cadastro** e aprovação
- **Rastreamento** em tempo real
- **Performance** individual
- **Pagamentos** por entrega
- **Avaliações** dos entregadores

## 📊 **Dashboards Específicos**

### **Dashboard C-Level** (Executivo)
```dart
// Widgets principais
- RevenueChart (mensal/anual)
- GrowthMetrics (usuários, restaurantes)
- MarketShareCard
- ProfitabilityCard
- ExpansionMap (novas cidades)
```

### **Dashboard Operacional**
```dart
// Widgets operacionais  
- LiveOrdersMap
- RestaurantStatusGrid
- DeliveryPerformanceChart
- IssuesAlert
- SupportTicketsWidget
```

### **Dashboard Financeiro**
```dart
// Widgets financeiros
- CashFlowChart
- CommissionBreakdown
- PendingPayouts
- RevenueByRestaurant
- TaxSummary
```

## 🔧 **Integrações Admin Específicas**

### **Business Intelligence**
- **Google Analytics** integrado
- **Firebase Analytics** avançado
- **Custom events** tracking
- **Conversion funnels**
- **Cohort analysis**

### **Comunicação**
- **WhatsApp Business API**
- **SendGrid** para emails
- **Firebase FCM** para push
- **SMS** para alertas críticos

### **Exportação de Dados**
- **Excel** avançado com fórmulas
- **PDF** profissional com gráficos
- **CSV** para análises externas
- **API endpoints** para integrações

## 🏗️ **Arquitetura Admin**

### **Estrutura de Pastas**
```
lib/
├── core/
│   ├── constants/admin_constants.dart
│   ├── themes/admin_theme.dart
│   └── permissions/admin_permissions.dart
├── features/
│   ├── dashboard/
│   ├── restaurants/
│   ├── users/
│   ├── orders/
│   ├── financial/
│   ├── reports/
│   ├── settings/
│   └── support/
├── shared/
│   ├── widgets/admin_widgets.dart
│   ├── services/admin_services.dart
│   └── utils/admin_utils.dart
└── main.dart
```

### **Services Admin**
```dart
// Services específicos
- AdminAuthService
- SystemMetricsService  
- ReportService
- NotificationService
- AuditService
- BackupService
```

## 🎯 **Deliverables Painel Admin**

1. ✅ **Flutter Web PWA completo** com interface profissional
2. ✅ **Dashboard executivo** com KPIs em tempo real
3. ✅ **Gestão completa** de restaurantes e usuários
4. ✅ **Sistema de relatórios** avançado com exportação
5. ✅ **Monitoramento** real-time do sistema
6. ✅ **Gestão financeira** com comissões e repasses
7. ✅ **Sistema de alertas** e notificações
8. ✅ **Auditoria** e logs de segurança
9. ✅ **Backup** e recuperação de dados
10. ✅ **PWA instalável** e offline-ready

## 🚀 **Comando para Próxima Conversa**

```markdown
Desenvolver Painel Administrativo Flutter Web PWA para sistema delivery existente.

CONTEXTO: Sistema completo com App Cliente e App Restaurante já funcionando no mesmo Firebase project. Preciso do Painel Admin compatível.

ARQUITETURA: Presentation/Domain/Data/Services (mesma estrutura dos outros apps)

DESIGN: Tema admin profissional com cores #FF6B35 (primary), #1E40AF (admin blue), sidebar escura, dashboard cards

FIREBASE: Usar mesmas coleções + novas específicas admin (admin_users, system_metrics, audit_logs)

FUNCIONALIDADES PRINCIPAIS:
- Dashboard executivo com KPIs tempo real
- Gestão restaurantes (aprovar, configurar comissões)
- Gestão usuários (banir, suporte)
- Monitor pedidos tempo real + intervenção
- Relatórios avançados (financeiro, performance, exportação)
- Gestão financeira (comissões, repasses)
- Sistema alertas/notificações críticas
- Configurações globais sistema
- Auditoria e logs segurança
- Backup automático dados

INTEGRACOES:
- Firebase Auth/Firestore/Functions/Analytics
- Relatórios Excel/PDF export
- WhatsApp/Email comunicação massa  
- Charts/graphs interativos
- Real-time monitoring
- PWA instalável

INTERFACE:
- Layout profissional sidebar + header
- DataTables avançadas filtros/busca
- Dashboards múltiplos (executivo/operacional/financeiro)
- Mapas tempo real entregas
- Sistema permissões por usuário

DELIVERABLE: Painel Admin completo funcional como Flutter Web PWA integrado ao sistema existente.

IMPORTANTE: Deve funcionar como sistema administrativo profissional para gerenciar toda a operação de delivery em tempo real.
```

## 💡 **Pontos de Integração Garantida**

### **Com App Cliente:**
- ✅ Monitorar todos pedidos clientes
- ✅ Gerenciar perfis e problemas
- ✅ Analytics de comportamento
- ✅ Suporte em tempo real

### **Com App Restaurante:**
- ✅ Aprovar novos restaurantes
- ✅ Configurar comissões individuais
- ✅ Monitorar performance
- ✅ Resolver disputas

### **Sistema Unificado:**
- ✅ **Mesmo Firebase** (dados sincronizados)
- ✅ **Mesmas regras** de negócio
- ✅ **Design consistente** (variação admin)
- ✅ **Permissões** centralizadas

---

**🎯 Copie este prompt completo e use na próxima conversa para o Painel Administrativo!**

**🔥 Garanto integração perfeita com Apps Cliente e Restaurante existentes!**
