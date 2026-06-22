# Carona Segura Universitária

## Download do Aplicativo

O APK é gerado automaticamente a cada push via GitHub Actions.

[![Download APK](https://img.shields.io/badge/Download-APK%20Android-brightgreen?style=for-the-badge&logo=android)](https://github.com/carona-segura/carona-segura-universitaria/releases/download/v8/carona-segura.apk)

> Antes de instalar, habilite **"Fontes desconhecidas"** em Configurações → Segurança no seu celular Android.

[![Build Flutter APK](https://github.com/carona-segura/carona-segura-universitaria/actions/workflows/build-apk.yml/badge.svg)](https://github.com/carona-segura/carona-segura-universitaria/actions/workflows/build-apk.yml)

---

## Descrição

App de caronas exclusivo para alunos universitários com validação de e-mail institucional. A plataforma conecta motoristas e passageiros dentro da mesma instituição de ensino, garantindo segurança e confiabilidade por meio da verificação do vínculo acadêmico.

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App (Mobile)                │
└──────────────────────────┬──────────────────────────────┘
                           │ REST / HTTP
              ┌────────────┴────────────┐
              │                         │
   ┌──────────▼──────────┐   ┌──────────▼──────────┐
   │   MS-Usuarios       │   │   MS-Viagens         │
   │   :8081             │   │   :8082              │
   │   (Spring Boot)     │   │   (Spring Boot)      │
   └──────────┬──────────┘   └──────────┬───────────┘
              │                         │
              └────────────┬────────────┘
                           │ RabbitMQ (AMQP)
              ┌────────────▼────────────┐
              │   MS-Notificacoes       │
              │   :8083                 │
              │   (Spring Boot)         │
              └─────────────────────────┘

Todos os microsserviços → PostgreSQL (Neon DB)
```

---

## Tecnologias

| Camada       | Tecnologia                              |
|--------------|-----------------------------------------|
| Backend      | Java 17 + Spring Boot 3.5.x             |
| Banco de dados | PostgreSQL via Neon DB (gratuito)     |
| Mensageria   | RabbitMQ via CloudAMQP (gratuito)       |
| Mobile       | Flutter + Provider                      |
| Deploy       | Render (plano gratuito)                 |
| CI/CD        | GitHub Actions                          |

---

## Como Executar Localmente

### Pré-requisitos

- Java 17+
- Maven (ou use o wrapper `./mvnw`)
- Flutter 3.22+
- Conta no Neon DB e CloudAMQP (ou instâncias locais)

### Variáveis de Ambiente

Crie um arquivo `.env` ou configure as variáveis no sistema antes de iniciar cada serviço:

```bash
export NEON_DB_URL=jdbc:postgresql://<host>/<database>
export NEON_DB_USERNAME=<usuario>
export NEON_DB_PASSWORD=<senha>
export RABBITMQ_URL=amqps://<usuario>:<senha>@<host>/<vhost>
export JWT_SECRET=<chave-secreta-jwt>
```

### Rodando os Microsserviços

```bash
# MS-Usuarios (porta 8081)
cd ms-usuarios
./mvnw spring-boot:run

# MS-Viagens (porta 8082)
cd ms-viagens
./mvnw spring-boot:run

# MS-Notificacoes (porta 8083)
cd ms-notificacoes
./mvnw spring-boot:run
```

### Rodando o App Flutter

```bash
cd mobile
flutter pub get
flutter run
```

---

## Deploy

### Pipeline CI/CD

O deploy é totalmente automatizado via GitHub Actions:

1. **Push na branch `main`** dispara o workflow correspondente
2. **Backend** (`ms-usuarios/**`, `ms-viagens/**`, `ms-notificacoes/**`):
   - GitHub Actions faz o build do JAR com Maven (`./mvnw clean package -DskipTests`)
   - O Render detecta o push e executa o Docker build usando o `Dockerfile` de cada serviço (multi-stage build)
   - Um webhook via API do Render aciona o re-deploy de cada serviço em sequência: **Usuarios → Viagens → Notificacoes**
3. **Mobile** (`mobile/**`):
   - GitHub Actions instala o Flutter e executa `flutter build apk --release`
   - O APK gerado fica disponível como artefato por 30 dias na aba **Actions** do repositório

### Configuração no Render

1. Conecte o repositório GitHub ao Render
2. O arquivo `render.yaml` na raiz configura automaticamente os 3 serviços
3. Configure manualmente no dashboard do Render as variáveis com `sync: false`:
   - `NEON_DB_URL`, `NEON_DB_USERNAME`, `NEON_DB_PASSWORD`
   - `RABBITMQ_URL`, `JWT_SECRET`
   - `MS_USUARIOS_URL` (apenas no ms-viagens)

### Secrets necessários no GitHub

Adicione em **Settings → Secrets and variables → Actions**:

| Secret                        | Descrição                                      |
|-------------------------------|------------------------------------------------|
| `NEON_DB_URL`                 | URL JDBC do banco PostgreSQL no Neon           |
| `NEON_DB_USERNAME`            | Usuário do banco                               |
| `NEON_DB_PASSWORD`            | Senha do banco                                 |
| `RABBITMQ_URL`                | URL amqps:// do CloudAMQP                      |
| `RENDER_API_KEY`              | Chave de API do Render                         |
| `RENDER_SERVICE_ID_USUARIOS`  | ID do serviço ms-usuarios no Render            |
| `RENDER_SERVICE_ID_VIAGENS`   | ID do serviço ms-viagens no Render             |
| `RENDER_SERVICE_ID_NOTIFICACOES` | ID do serviço ms-notificacoes no Render    |

---

## Variáveis de Ambiente

| Variável               | Serviço(s)                        | Descrição                                      |
|------------------------|-----------------------------------|------------------------------------------------|
| `NEON_DB_URL`          | todos                             | URL JDBC do PostgreSQL (Neon DB)               |
| `NEON_DB_USERNAME`     | todos                             | Usuário do banco de dados                      |
| `NEON_DB_PASSWORD`     | todos                             | Senha do banco de dados                        |
| `RABBITMQ_URL`         | todos                             | URL de conexão amqps:// do RabbitMQ            |
| `JWT_SECRET`           | ms-usuarios, ms-viagens           | Chave secreta para assinar tokens JWT          |
| `SPRING_PROFILES_ACTIVE` | ms-usuarios                     | Perfil ativo do Spring (`prod`)                |
| `MS_USUARIOS_URL`      | ms-viagens                        | URL base do ms-usuarios para comunicação interna |

---

## Dificuldades e Lições Aprendidas

### 1. Configuração do Spring Security com JWT

A anotação `@EnableWebSecurity` precisou ser declarada explicitamente na classe de configuração de segurança. No Spring Boot 3.x com Spring Security 6, o comportamento padrão mudou: sem a anotação explícita em conjunto com o `SecurityFilterChain` como bean, as rotas ficavam bloqueadas mesmo para endpoints públicos. A solução foi garantir que a classe `SecurityConfig` tivesse `@EnableWebSecurity` e `@Configuration`, e que o bean `SecurityFilterChain` retornasse a cadeia de filtros corretamente configurada com `http.csrf().disable()` e as permissões por rota.

### 2. Comunicação entre Microsserviços

O `ms-viagens` precisa validar tokens e consultar dados de usuários no `ms-usuarios` via `WebClient`. Para isso funcionar, a rota `/api/usuarios/**` precisou ser explicitamente liberada no `SecurityConfig` do `ms-usuarios` usando `.requestMatchers("/api/usuarios/**").permitAll()`. Sem isso, as requisições internas entre serviços retornavam 403 Forbidden, mesmo com token JWT válido, pois o contexto de autenticação não era propagado automaticamente entre serviços distintos.

### 3. Docker Não Disponível Localmente

A máquina de desenvolvimento não possui Docker instalado (placa mãe incompatível), o que impossibilitou testar as imagens localmente antes do deploy. A solução foi utilizar o Docker **somente na pipeline do GitHub Actions**, onde o ambiente Ubuntu já possui o Docker disponível. Os Dockerfiles usam multi-stage build: a primeira etapa compila o projeto com Maven (imagem `eclipse-temurin:17-jdk-alpine`) e a segunda etapa copia apenas o JAR final para uma imagem mais leve (imagem `eclipse-temurin:17-jre-alpine`), reduzindo o tamanho final da imagem em aproximadamente 60%.

### 4. RabbitMQ com SSL (amqps://)

O CloudAMQP fornece URLs de conexão no formato `amqps://` (com SSL), mas a configuração padrão do Spring AMQP via `spring.rabbitmq.host`, `spring.rabbitmq.port` e `spring.rabbitmq.username` não lida automaticamente com SSL quando separadas. A solução foi usar a propriedade `spring.rabbitmq.addresses` com a URL completa `amqps://usuario:senha@host/vhost`, que o Spring interpreta corretamente e configura o SSL automaticamente, sem necessidade de configuração manual do `SSLContext`.
