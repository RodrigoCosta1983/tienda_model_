# Gelo Gestor - Sistema de Gestão para Distribuidoras v1.1.6

![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart)
![Status](https://img.shields.io/badge/Status-Completo-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)

> Um sistema de gestão completo e multiplataforma para distribuidoras de gelo, construído com Flutter e Firebase, com foco em controle de vendas, clientes, finanças e estoque.

---

## 📖 Sobre o Projeto

**Gelo Gestor** é um aplicativo completo que serve como uma solução de gestão de ponta a ponta para distribuidoras de gelo. O projeto foi concebido para digitalizar e otimizar operações diárias, substituindo controles manuais por um sistema centralizado, reativo e acessível em dispositivos móveis e na web.

O principal objetivo é fornecer ao proprietário do negócio uma ferramenta poderosa para gerenciar vendas, clientes, estoque e finanças, com funcionalidades avançadas como análise de performance de produtos (Curva ABC) e um sistema de vendas a prazo (fiado) totalmente configurável.

<br>

## ✨ Funcionalidades Principais

#### 🔑 **Autenticação e Gestão de Conta**
* **Sistema de Login Completo:** Autenticação segura de usuários com E-mail e Senha via **Firebase Authentication**.
* **Arquitetura Multi-Tenant:** Dados de cada usuário (loja) completamente isolados e protegidos no banco de dados.
* **✨ Gestão de Perfil e Segurança:** Tela dedicada de configurações que permite:
  * **Editar Dados do Perfil:** Nome Completo/Razão Social, CPF/CNPJ e Telefone.
  * **Alterar Credenciais:** Mudança de e-mail (com verificação) e senha, exigindo reautenticação para maior segurança.

#### 📦 **Gestão de Estoque Avançada**
* **Controle de Estoque:** Cadastro de quantidade de produtos com baixa automática a cada venda, utilizando Transações do Firestore.
* **✨ Alertas de Reposição de Estoque:**
  * **Estoque Mínimo Configurável:** Define quantidade mínima para alerta por produto.
  * **Alertas Visuais Proativos:** Destaque automático para itens no estoque mínimo.
* **Gerenciamento de Produtos (CRUD):** Criar, Ler, Editar e Excluir produtos com upload de imagens no Firebase Storage.
* **Gerenciamento de Clientes (CRUD):** Cadastro e manutenção de clientes.
* **Busca Inteligente:** Funcionalidade de busca *case-insensitive* em tempo real para encontrar produtos e clientes.

#### 💰 **Fluxo de Venda e Financeiro Flexível**
* **Ponto de Venda (PDV) Reativo:** Tela de "Nova Venda" que lê o catálogo de produtos (com imagens e estoque) em tempo real do Firestore.
* **✨ Sistema de Venda "Fiado" (a Crédito) Opcional:**
  * **Configuração Simples:** Ativado/desativado pelo dono da loja.
  * **Fluxo Completo:** Registro de vendas a prazo, com cliente e vencimento.
  * **Controle de Pagamentos:** Marcar contas como pagas, atualizando o caixa.
* **✨ Emissão de Recibos em PDF:**
  * **Geração Profissional:** Crie recibos em PDF detalhados para qualquer venda diretamente do histórico.
  * **Informações Completas:** O recibo inclui dados do vendedor, do cliente, lista de produtos com valores, total e **data de vencimento (para vendas a prazo)**.
  * **Compartilhamento Fácil:** Use a função de compartilhamento nativa do celular para enviar o PDF via WhatsApp, E-mail, etc.

* **Múltiplos Meios de Pagamento:** Dinheiro, Cartão e PIX.
* **Histórico de Vendas Detalhado:** Lista de todas as vendas salvas no Firestore, com filtros e detalhes expansíveis.
* **Alertas Visuais:** O histórico destaca automaticamente vendas vencidas e não pagas.

#### 📊 **Dashboard & Relatórios Estratégicos**
* **Painel de Controle Interativo:** Dashboard com métricas de negócio em tempo real (Vendas do Período, Caixa, Contas a Receber, Contas Vencidas).
* **Filtros de Período:** Análise de performance de vendas com filtros por **Hoje, Semana e Mês**.
* **Gráficos Dinâmicos:** Visualização de dados de vendas em gráficos de barra para análises semanais e mensais.
* **Navegação por Atalhos:** Cards da dashboard que funcionam como atalhos para listas já filtradas.
* **✨ Análise de Produtos (Curva ABC):**
  * **Relatório Estratégico:** Classificação dos produtos em A, B e C pela contribuição na receita.
  * **Filtros por Período:** Últimos 7 dias, 30 dias ou histórico completo.

#### 🎨 **Experiência do Usuário (UI/UX)**
* **Interface Adaptativa:** O layout se adapta automaticamente para diferentes tamanhos de tela, funcionando bem em celulares (retrato/paisagem) e na web.
* **Suporte a Temas:** Interface totalmente funcional em **Modo Claro** e **Modo Escuro**.
* **Performance Otimizada:** Splash screen na inicialização e pré-carregamento de imagens para uma experiência mais fluida.

## 🛠️ Tecnologias e Arquitetura

* **Framework Principal:** **[Flutter](https://flutter.dev/)**
* **Linguagem:** **[Dart](https://dart.dev/)** (com Sound Null Safety)
* **Backend (BaaS):** **[Firebase](https://firebase.google.com/)**
  * **Autenticação:** Firebase Authentication
  * **Banco de Dados:** Cloud Firestore (com Transações para consistência de dados)
  * **Armazenamento de Arquivos:** Firebase Storage
* **Gerenciamento de Estado:** **[Provider](https://pub.dev/packages/provider)**
* **UI Reativa:** O aplicativo foi construído em torno do widget **`StreamBuilder`**, permitindo que a interface reaja e se atualize instantaneamente a qualquer mudança nos dados do Firestore.
* **Bibliotecas Adicionais Notáveis:**
  * **`fl_chart`**: Para a criação dos gráficos dinâmicos.
  * **`shared_preferences`**: Para salvar as configurações locais do app.
  * **`image_picker`**: Para a seleção de imagens da galeria.
  * **`pdf`** e **`printing`**: Para criar, visualizar e compartilhar recibos em PDF.
  * **`intl`**, **`package_info_plus`**, **`url_launcher`**.

<hr>

## 🔥 Configuração para Execução

Este projeto depende totalmente dos serviços do Firebase. Para executá-lo localmente:

1.  Crie um novo projeto no [Firebase Console](https://console.firebase.google.com/).
2.  Ative os serviços **Authentication** (provedor "E-mail/senha"), **Firestore Database** (no modo de teste) e **Storage**.
3.  Ajuste as **Regras de Segurança** do Firestore e do Storage para permitir leitura e escrita para usuários autenticados.
4.  Use a **FlutterFire CLI** (`flutterfire configure`) para conectar seu app ao projeto, o que irá gerar o arquivo `lib/firebase_options.dart`.
5.  Crie os índices compostos do Firestore que serão solicitados no console de depuração ao executar as buscas e filtros pela primeira vez.

<hr>

## 🚀 Como Executar o Projeto


# 1. Clone o repositório
git clone [https://github.com/RodrigoCosta1983/tienda_model_.git](https://github.com/RodrigoCosta1983/tienda_model_.git)

# 2. Navegue para a pasta do projeto
cd tienda_model_

# 3. Instale as dependências
flutter pub get

# 4. Execute o aplicativo
flutter run
👨‍💻 Autor
RodrigoCostaDEV

GitHub: @RodrigoCosta1983

Website: rodrigocosta-dev.com

=================================================================================================================

# Gelo Gestor - Management System for Distributors v1.1.6

![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart)
![Status](https://img.shields.io/badge/Status-Completo-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)

> A complete, multi-platform management system for ice distributors, built with Flutter and Firebase, focusing on sales, customer, financial, and inventory control.

---

## 📖 About the Project

**Gelo Gestor** is a complete application that serves as an end-to-end management solution for ice distributors. The project was designed to digitize and optimize daily operations, replacing manual controls with a centralized, responsive system that's accessible on mobile devices and the web.

The main objective is to provide business owners with a powerful tool for managing sales, customers, inventory, and finances, with a specialized focus on credit sales management, one of the biggest pain points in the industry.

<br>

## ✨ Main Features

#### 🔑 **Authentication & Account Management**
* **Full Login System:** Secure user authentication with email and password via **Firebase Authentication**.
* **Multi-Tenant Architecture:** Each user's (store's) data is completely isolated and protected in the database.
* **✨ Profile & Security Management:** Dedicated settings screen that allows:
  * **Edit Profile Data:** Full Name/Business Name, CPF/CNPJ (or tax ID), and Phone.
  * **Change Credentials:** Change email (with verification) and password, requiring reauthentication for enhanced security.

#### 📦 **Advanced Inventory Management**
* **Inventory Control:** Register product quantities with automatic deduction for each sale, using Firestore Transactions.
* **✨ Stock Replenishment Alerts:**
  * **Configurable Minimum Stock:** Define a minimum quantity alert for each product.
  * **Proactive Visual Alerts:** Automatically highlights items that have reached minimum stock.
* **Product Management (CRUD):** Create, Read, Update, and Delete products with image upload to Firebase Storage.
* **Customer Management (CRUD):** Register and maintain store customers.
* **Smart Search:** Real-time, case-insensitive search functionality to find products and customers.

#### 💰 **Flexible Sales & Financial Flow**
* **Reactive Point of Sale (POS):** "New Sale" screen that reads the product catalog (with images and stock) in real time from Firestore.
* **✨ Optional "Credit Sales" System:**
  * **Simple Configuration:** Can be enabled/disabled by the store owner.
  * **Complete Flow:** Register installment/credit sales with customer and due date.
  * **Payment Control:** Mark accounts as paid, updating the cash register.
* **✨ PDF Receipt Issuance:**
  * **Professional Generation:** Create detailed PDF receipts for any sale directly from the history.
  * **Complete Information:** The receipt includes seller and customer details, product list with prices, total amount, and **due date (for credit sales)**.
  * **Easy Sharing:** Use the phone’s native sharing function to send the PDF via WhatsApp, Email, etc.
* **Multiple Payment Methods:** Cash, Card, and PIX.
* **Detailed Sales History:** List of all sales saved in Firestore, with filters and expandable details.
* **Visual Alerts:** The history automatically highlights overdue and unpaid sales.

#### 📊 **Dashboard & Strategic Reports**
* **Interactive Control Panel:** Dashboard with real-time business metrics (Sales for the Period, Cash, Accounts Receivable, Overdue Accounts).
* **Period Filters:** Sales performance analysis with filters for **Today, Week, and Month**.
* **Dynamic Charts:** Visualization of sales data in bar charts for weekly and monthly analysis.
* **Shortcut Navigation:** Dashboard cards that function as shortcuts to pre-filtered lists.
* **✨ Product Analysis (ABC Curve):**
  * **Strategic Report:** Classifies products into A, B, and C based on revenue contribution.
  * **Period Filters:** Last 7 days, last 30 days, or full history.

#### 🎨 **User Experience (UI/UX)**
* **Adaptive Interface:** Layout automatically adapts to different screen sizes, working well on mobile (portrait/landscape) and web.
* **Theme Support:** Fully functional interface in **Light Mode** and **Dark Mode**.
* **Optimized Performance:** Splash screen on startup and image preloading for a smoother experience.

## 🛠️ Technologies and Architecture

* **Main Framework:** **[Flutter](https://flutter.dev/)**
* **Language:** **[Dart](https://dart.dev/)** (with Sound Null Safety)
* **Backend (BaaS):** **[Firebase](https://firebase.google.com/)**
* **Authentication:** Firebase Authentication
* **Database:** Cloud Firestore (with Transactions for data consistency)
* **File Storage:** Firebase Storage
* **State Management:** **[Provider](https://pub.dev/packages/provider)**
* **Reactive UI:** The application is built around the **`StreamBuilder`** widget, allowing the interface to react and update instantly to any changes in Firestore data. * **Notable Additional Libraries:**
* **`fl_chart`**: For creating dynamic charts.
* **`image_picker`**: For selecting images from the gallery.
* **`intl`**, **`package_info_plus`**, **`url_launcher`**.

<hr>

## 🔥 Runtime Configuration

This project fully relies on Firebase services. To run it locally:

1. Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable the **Authentication** ("Email/Password" provider), **Firestore Database** (in test mode), and **Storage** services.
3. Adjust the **Security Rules** for Firestore and Storage to allow reading and writing for authenticated users. 4. Use the FlutterFire CLI (flutterfire configure) to connect your app to the project, which will generate the lib/firebase_options.dart file.
5. Create the Firestore composite indexes that will be requested in the debug console when running searches and filters for the first time.

<hr>

## 🚀 How to Run the Project

```bash
# 1. Clone the repository
git clone [https://github.com/RodrigoCosta1983/tienda_model_.git](https://github.com/RodrigoCosta1983/tienda_model_.git)

# 2. Navigate to the project folder
cd tienda_model_

# 3. Install the dependencies
flutter pub get

# 4. Run the application
flutter run
👨‍💻 Author
RodrigoCostaDEV

GitHub: @RodrigoCosta1983

Website: rodrigocosta-dev.com
