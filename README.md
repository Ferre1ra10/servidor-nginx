# Servidor NGINX — Dois sites em portas diferentes

Servidor web local com **Nginx** no Windows, hospedando dois sites estáticos independentes a partir de uma única instalação — cada um em sua própria porta.

```
                NGINX
        ┌─────────┴─────────┐
   PORTA 8080          PORTA 8081
      TECH               SUPORTE
     tech/               suporte/
   index.html           index.html
```

| Site | Porta | URL | Pasta |
|------|-------|-----|-------|
| Tech | 8080 | http://localhost:8080 | `html/sites/tech` |
| Suporte | 8081 | http://localhost:8081 | `html/sites/suporte` |

---

## Objetivo

Demonstrar, de forma didática, como o Nginx serve arquivos estáticos e como um mesmo servidor pode hospedar múltiplos sites usando blocos `server` distintos.

---

## Como funciona

O Nginx é um **servidor web**: ele fica escutando portas do computador, espera requisições HTTP e devolve arquivos.

### O caminho de uma requisição

```
1. Você digita          http://localhost:8080
                                 ↓
2. Nginx recebe a conexão na PORTA 8080
                                 ↓
3. Procura qual bloco server escuta essa porta  →  server { listen 8080; }
                                 ↓
4. Lê o root desse bloco                        →  html/sites/tech
                                 ↓
5. Como o pedido foi "/", usa o index           →  index.html
                                 ↓
6. try_files procura o arquivo em disco         →  tech/index.html
                                 ↓
7. Encontrou?  → devolve o HTML (200 OK)
   Não achou?  → devolve 404 Not Found
```

A porta é o que separa os dois sites. Uma requisição na **8080** nunca chega na pasta `suporte`, e vice-versa — são dois blocos `server` totalmente independentes dentro do mesmo processo do Nginx.

### E os arquivos internos da página?

Depois de receber o HTML, o navegador pede os arquivos referenciados (CSS, imagens, JS). Cada pedido volta pelo mesmo caminho:

```
navegador pede  /estilo.css
        ↓
Nginx procura   root/estilo.css   →  html/sites/tech/estilo.css
        ↓
encontrou? → entrega o arquivo
não achou? → 404 Not Found
```

Neste projeto o CSS está embutido dentro do próprio `index.html`, então cada site é servido em **uma única requisição**.

### Quem faz o trabalho

O Nginx trabalha com **processos trabalhadores** (`worker_processes`). Aqui há apenas 1 trabalhador, que consegue atender até 1024 conexões simultâneas (`worker_connections`) — mais que suficiente para uso local. Ele não abre uma thread por visitante: um mesmo trabalhador gerencia todas as conexões ao mesmo tempo, e é por isso que o Nginx é leve.

---

## Como executar

### Pré-requisitos

- Windows
- Portas **8080** e **8081** livres
- Nenhuma instalação extra: o `nginx.exe` já vem no repositório

### Passo 1 — Baixar o projeto

```bash
git clone https://github.com/Ferre1ra10/servidor-nginx.git
```

Ou baixe o ZIP pelo botão **Code → Download ZIP** e extraia.

### Passo 2 — Ajustar os caminhos

Abra `nginx-1.31.3/conf/nginx.conf` e edite os dois `root` para a pasta onde você salvou o projeto:

```nginx
root C:/SEU/CAMINHO/nginx-1.31.3/html/sites/tech;
root C:/SEU/CAMINHO/nginx-1.31.3/html/sites/suporte;
```

Use sempre **barras normais** (`/`), mesmo no Windows.

> 💡 Alternativa: trocar por caminho relativo (`root html/sites/tech;`) faz o projeto rodar em qualquer máquina sem edição nenhuma.

### Passo 3 — Iniciar o servidor

**Opção A — script `.bat` (mais rápido)**

Duplo clique em `iniciar-nginx.bat`. Ele sobe o `nginx.exe` e mostra os endereços dos dois sites no terminal.

**Opção B — pelo CMD**

Abra o CMD dentro da pasta `nginx-1.31.3` e rode:

```bash
nginx.exe
```

O comando não devolve mensagem nenhuma quando dá certo — o servidor fica rodando em segundo plano.

### Passo 4 — Acessar

Abra no navegador:

- http://localhost:8080 → site **Tech**
- http://localhost:8081 → site **Suporte**

### Passo 5 — Parar

```bash
nginx -s stop
```

---

## Comandos úteis

| Comando | O que faz |
|---|---|
| `nginx.exe` | Inicia o servidor |
| `nginx -t` | Testa a configuração — **sempre rode antes de recarregar** |
| `nginx -s reload` | Aplica mudanças do `nginx.conf` sem derrubar o servidor |
| `nginx -s stop` | Para o servidor imediatamente |
| `nginx -s quit` | Para o servidor após finalizar as conexões abertas |
| `nginx -v` | Mostra a versão instalada |

Fluxo recomendado ao alterar a configuração:

```bash
nginx -t          # confere a sintaxe
nginx -s reload   # aplica sem derrubar
```

---

## Estrutura do repositório

```
servidor-nginx/
├── README.md
└── nginx-1.31.3/
    ├── nginx.exe              # executável do Nginx
    ├── iniciar-nginx.bat      # atalho para subir o servidor
    ├── conf/
    │   ├── nginx.conf         # arquivo principal de configuração
    │   ├── mime.types
    │   └── fastcgi_params, scgi_params, uwsgi_params, ...
    ├── html/
    │   ├── index.html         # página padrão do Nginx
    │   ├── 50x.html           # página de erro padrão
    │   └── sites/
    │       ├── tech/
    │       │   └── index.html
    │       └── suporte/
    │           └── index.html
    ├── logs/                  # access.log, error.log, nginx.pid
    ├── temp/                  # arquivos temporários
    ├── docs/                  # documentação e licenças
    └── contrib/               # recursos extras (syntax highlight para Vim, scripts)
```

| Pasta / Arquivo | Para que serve |
|---|---|
| `nginx.exe` | O programa que executa o Nginx |
| `iniciar-nginx.bat` | Script que inicia o servidor e mostra os endereços dos sites |
| `conf/nginx.conf` | Define como o Nginx funciona e quais sites ele serve |
| `html/` | Onde ficam os arquivos dos sites |
| `logs/` | Diário do servidor: acessos e erros |
| `temp/` | Arquivos temporários |
| `docs/` | Documentação e licenças |
| `contrib/` | Recursos adicionais |

---

## Configuração (`conf/nginx.conf`)

```nginx
worker_processes 1;

events {
    worker_connections 1024;
}

http {

    server {
        listen 8080;
        server_name localhost;

        root C:/Users/EFG/Downloads/nginx-1.31.3/nginx-1.31.3/html/sites/tech;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }

    server {
        listen 8081;
        server_name localhost;

        root C:/Users/EFG/Downloads/nginx-1.31.3/nginx-1.31.3/html/sites/suporte;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
```

### Explicação linha a linha

| Diretiva | O que faz |
|---|---|
| `worker_processes 1` | Quantos processos trabalhadores o Nginx vai usar |
| `events { }` | Como o Nginx recebe e controla as conexões |
| `worker_connections 1024` | Quantas conexões cada trabalhador atende ao mesmo tempo |
| `http { }` | Bloco onde ficam as configurações dos sites HTTP |
| `server { }` | Representa **um site**. Aqui existem dois |
| `listen 8080` | Porta em que o site responde |
| `server_name localhost` | Nome do servidor — roda na própria máquina |
| `root .../tech` | Pasta onde estão os arquivos daquele site |
| `index index.html` | Página inicial carregada ao acessar a raiz |
| `location / { }` | Como tratar as requisições que chegam à raiz do site |
| `try_files $uri $uri/ =404` | Procura o arquivo pedido; se não achar, devolve 404 |

Os dois blocos `server` são idênticos — mudam apenas a **porta** e o **root**.

---

## Sobre os sites

**Tech** (`html/sites/tech/index.html`) — página institucional de uma empresa de tecnologia. Paleta azul-escura (`#1d3557`), com header, seção de boas-vindas e botão "Conheça nossos serviços".

**Suporte** (`html/sites/suporte/index.html`) — central de atendimento. Paleta azul-média (`#457b9d`), mesma estrutura, com botão "Abrir chamado".

Ambos são HTML puro com CSS embutido em `<style>`, sem dependências externas.

---

## Problemas comuns

| Problema | Provável causa | Como resolver |
|---|---|---|
| Porta já em uso | Outro serviço ocupa a 8080/8081, ou há um `nginx.exe` rodando | `nginx -s stop`, ou troque a porta no `listen` |
| 404 ao acessar | Caminho do `root` errado ou `index.html` fora da pasta | Confira o `root` no `nginx.conf` |
| Alteração não aparece | Faltou recarregar, ou é cache do navegador | `nginx -s reload` + Ctrl+F5 |
| `nginx -t` falha | Erro de sintaxe no `nginx.conf` | A saída indica o arquivo e a linha |
| Servidor não sobe | Erro na inicialização | Veja `logs/error.log` |

---

## Tecnologias

- Nginx 1.31.3 (Windows)
- HTML5 + CSS3
- Batch script (`.bat`)
