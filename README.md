# Torre de Controle · Sistema Operacional Logístico

Sistema completo de controle da operação (clientes, ocorrências, escalas,
equipe, frota, passagem de turno, rotas e histórico de pedidos), com **login
de usuários** e **importação/exportação de planilhas Excel**.

- **Frontend:** `index.html` (arquivo único, sem instalação)
- **Banco de dados:** Supabase (já conectado ao seu projeto)
- **Hospedagem:** GitHub Pages

---

## Suas respostas rápidas

**1) Posso exportar e importar a planilha?**
Sim. Toda tela tem os botões **Importar** e **Exportar** (formato .xlsx). Além
disso, a tela de **Clientes** tem um botão extra **"Sincronizar planilha"**
que lê um arquivo com abas "Granel" e "Cilindro" — igual ao formato da sua
planilha original — e atualiza a base sem duplicar (ele usa o código do
cliente para saber se já existe).

**2) Login com senha master para gerenciar usuários?**
Sim, já está pronto. Cada pessoa cria a própria conta (e-mail + senha) e fica
com o status **"Pendente"** até você aprovar. A **sua conta**, depois de você
mesmo se tornar administrador (passo 5 abaixo), funciona como a **conta
master**: só ela enxerga a aba **Usuários**, onde dá para aprovar, bloquear
ou promover qualquer colaborador a administrador também.

> Detalhe técnico honesto: por segurança, ninguém consegue apagar de vez a
> conta de outra pessoa direto pelo site (isso exigiria uma chave secreta do
> banco, que nunca deve ficar exposta num site). Em vez disso, o admin
> **bloqueia** o acesso (o efeito prático é o mesmo — a pessoa não consegue
> mais ver nada do sistema). Se um dia precisar apagar de verdade, é um
> comando simples no painel do Supabase, aviso quando precisar.

**3) Passo a passo — já vai direto abaixo.** 👇

---

## Passo a passo completo

### Parte A — Preparar o banco de dados (Supabase)

Suas credenciais já estão **fixas dentro do `index.html`**, então você não
precisa digitar nada disso depois. Só falta criar as tabelas no banco.

1. Acesse [supabase.com](https://supabase.com) e entre no projeto (o mesmo da
   URL `gmiyyzslgfbsdbbcdlvk`).
2. No menu da esquerda, clique em **SQL Editor**.
3. Clique em **New query**.
4. Abra o arquivo `schema.sql` (que te enviei), copie **todo** o conteúdo e
   cole na caixa de texto do Supabase.
5. Clique no botão **Run** (ou `Ctrl+Enter`). Deve aparecer "Success. No rows
   returned". Isso cria todas as tabelas, as regras de segurança e o sistema
   de login.
6. Clique em **New query** de novo (uma nova aba em branco).
7. Abra o arquivo `seed_data.sql`, copie tudo, cole e clique em **Run**. Esse
   arquivo é grande (tem todos os seus ~1.950 clientes, pedidos, equipe etc.)
   — pode demorar de 10 a 60 segundos, é normal.

Pronto, o banco está populado com todos os dados da sua planilha.

### Parte B — Criar sua conta e virar administrador

1. Abra o arquivo `index.html` (duplo clique nele — ele abre no navegador).
2. Na tela de login, clique na aba **"Criar conta"**.
3. Preencha seu nome, e-mail e uma senha (mínimo 6 caracteres) e clique em
   **Criar conta**.
4. Você vai cair numa tela de **"Aguardando aprovação"** — isso é esperado,
   toda conta nova começa bloqueada, inclusive a sua.
5. Volte ao **SQL Editor** do Supabase, abra uma **New query** e rode o
   comando abaixo, trocando pelo e-mail que você acabou de cadastrar:

   ```sql
   update perfis set papel = 'admin', ativo = true where email = 'seu-email@exemplo.com';
   ```

6. Volte no `index.html`, saia e entre de novo (ou apenas atualize a página e
   faça login). Agora você entra normalmente e já vê a aba **Usuários** no
   menu — essa é a sua conta master.

Da próxima vez que outra pessoa da equipe criar uma conta, ela vai aparecer
"Pendente" na aba **Usuários**, e você clica em **Aprovar**.

> Se o Supabase pedir confirmação de e-mail ao criar a conta: vá em
> **Authentication → Providers → Email** no painel do Supabase e desative a
> opção **"Confirm email"** para simplificar (ou peça para cada pessoa
> confirmar o e-mail recebido antes do primeiro login).

### Parte C — Publicar no GitHub Pages (para todo mundo acessar por um link)

1. Crie uma conta em [github.com](https://github.com) caso ainda não tenha.
2. Clique no **+** no canto superior direito → **New repository**.
3. Dê um nome (ex: `torre-de-controle`), marque como **Private** se quiser
   restringir quem vê o código-fonte, e clique em **Create repository**.
4. Na página do repositório vazio, clique no link **"uploading an existing
   file"**.
5. Arraste os arquivos `index.html`, `schema.sql`, `seed_data.sql` e
   `README.md` para a área indicada.
6. Role para baixo e clique em **Commit changes**.
7. Vá em **Settings** (aba do repositório) → **Pages** (menu à esquerda).
8. Em **Source**, selecione **Deploy from a branch**.
9. Em **Branch**, selecione `main` e a pasta `/ (root)`, depois **Save**.
10. Aguarde 1–2 minutos e atualize a página — vai aparecer um link do tipo:
    `https://seu-usuario.github.io/torre-de-controle/`

Esse é o link que você compartilha com a equipe. Cada pessoa acessa, cria a
própria conta e você aprova pela aba Usuários.

---

## O que cada tela faz

| Tela | O que tem |
|---|---|
| **Dashboard** | Indicadores em tempo real, gráficos de clientes por cidade, Granel × Cilindro e status da escala do dia |
| **Clientes** | Busca, filtro, cadastro/edição/exclusão + importar/exportar + sincronizar planilha mestre |
| **Ocorrências** | Registro e status (Aberta / Em andamento / Resolvida) |
| **Escalas** | Escala Diária, Escala de Sábado, Viagens fixas semanais, Grade mensal de sábados |
| **Equipe & Frota** | Motoristas, ajudantes, veículos (placas, PDA, tara, lotação) e contatos de frota |
| **Passagem de Turno** | Checklist diário (ocorrências pendentes, veículos com problema, folgas etc.) |
| **Rotas & Referências** | Regiões por dia da semana, motivos de recusa e de reprogramação |
| **Histórico de Pedidos** | Base histórica completa, com busca e paginação |
| **Notas de Acesso** | Portaria, zeladoria, senhas e chaves de acesso aos clientes |
| **Usuários** *(só admin)* | Aprovar, bloquear ou promover colaboradores |

Todas as telas de listagem têm: busca, filtros, paginação, **Importar**,
**Exportar** e os botões de **Novo / Editar / Excluir**.

---

## Sobre segurança

Antes, qualquer pessoa com o link conseguia ver e editar tudo. Agora não:
os dados só ficam visíveis para quem tem conta **aprovada** por um
administrador. A chave do Supabase que está escrita dentro do `index.html`
é pública por natureza (é assim que o Supabase funciona em sites estáticos)
— quem protege os dados de verdade são as regras de acesso que criamos no
banco (`schema.sql`), não o segredo da chave.

---

## Próximos passos sugeridos (opcional)

- Exportar relatórios em PDF direto da tela de Clientes ou Pedidos.
- Notificações automáticas quando uma ocorrência ficar aberta por muito tempo.
- Recuperação de senha por e-mail (o Supabase já suporta, posso ligar isso).

Qualquer dúvida durante os passos acima ou ajuste que precisar, é só chamar.
