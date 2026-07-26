# Torre de Controle · Sistema Operacional Logístico

Sistema web completo para controle da operação logística (clientes, ocorrências,
escalas de motoristas, equipe, frota, passagem de turno, rotas e histórico de
pedidos), construído a partir da planilha `Operacional_logistica_2.0.xlsx`.

- **Frontend:** HTML + Tailwind + Chart.js (arquivo único `index.html`, sem build)
- **Banco de dados:** Supabase (Postgres)
- **Hospedagem:** GitHub Pages (estático)

---

## 1. Estrutura dos arquivos

```
├── index.html       → o sistema (dashboard + todos os módulos)
├── schema.sql        → cria todas as tabelas no Supabase
├── seed_data.sql      → carrega todos os dados reais da planilha (gerado automaticamente)
└── README.md
```

Todas as 12 abas da planilha original foram mapeadas em **16 tabelas**:

| Aba da planilha              | Tabela no banco                          |
|-------------------------------|-------------------------------------------|
| Resumo Geral                  | calculado ao vivo no Dashboard             |
| Granel + Cilindro              | `clientes` (campo `tipo_atendimento`)     |
| Ocorrências                    | `ocorrencias`                             |
| Escala Diária                  | `escala_diaria` + `escala_viagens`        |
| Escala Sábado                  | `escala_sabado`                           |
| Escalas Sábados (grade mensal) | `escala_sabado_mensal`                    |
| Equipes                        | `equipe` + `veiculos` + `contatos_frota`  |
| Passagem Turno                 | `passagem_turno` + `passagem_turno_ocorrencias` |
| Rotas                          | `rotas_semanais` + `motivos_recusa` + `motivos_reprogramacao` |
| Planilha1                      | `pedidos_historico`                       |
| apenas números                 | `notas_acesso`                            |

---

## 2. Configurar o Supabase

1. Crie um projeto gratuito em [supabase.com](https://supabase.com).
2. No painel, vá em **SQL Editor → New query**.
3. Cole o conteúdo de `schema.sql` e clique em **Run**. Isso cria todas as tabelas,
   índices, RLS (Row Level Security) e triggers de `updated_at`.
4. Abra uma nova query, cole o conteúdo de `seed_data.sql` e rode. Esse arquivo tem
   ~4.400 linhas (todos os clientes, pedidos, equipe, etc. da planilha) — pode levar
   alguns segundos para rodar.
5. Vá em **Project Settings → API** e copie:
   - **Project URL**
   - **anon public key**

> **Sobre segurança:** como o app é hospedado de forma estática (GitHub Pages),
> a chave `anon` fica visível no navegador — isso é normal e esperado no Supabase,
> pois o controle de acesso é feito pelas políticas de **Row Level Security** (RLS),
> não pelo sigilo da chave. O `schema.sql` já libera leitura/escrita geral para
> uso interno da equipe. Se quiser exigir login antes de usar o sistema, me avise
> que ajusto para usar o Supabase Auth.

---

## 3. Rodar localmente

Basta abrir o `index.html` no navegador (duplo clique) ou usar qualquer servidor
estático, por exemplo:

```bash
python3 -m http.server 8000
```

Na primeira tela, cole a **Project URL** e a **anon key** do Supabase. Isso fica
salvo no `localStorage` do navegador — não precisa digitar de novo.

---

## 4. Publicar no GitHub Pages

1. Crie um repositório novo no GitHub (pode ser privado).
2. Suba os arquivos `index.html`, `schema.sql`, `seed_data.sql` e este `README.md`
   para a raiz do repositório.
3. Vá em **Settings → Pages**.
4. Em **Source**, selecione a branch `main` e a pasta `/ (root)`.
5. Salve. Em alguns minutos o site estará disponível em
   `https://SEU-USUARIO.github.io/SEU-REPOSITORIO/`.

Como o app conecta direto ao Supabase pelo navegador, não precisa de nenhum
servidor backend — o GitHub Pages só serve o arquivo HTML.

---

## 5. O que o sistema já faz

- **Dashboard** com indicadores em tempo real (clientes Granel/Cilindro,
  ocorrências abertas, veículos em rota), gráfico de clientes por cidade,
  proporção Granel × Cilindro e status da escala do dia.
- **Clientes:** busca, filtro por tipo, cadastro/edição/exclusão — todos os
  ~1.950 clientes reais da planilha já carregados.
- **Ocorrências:** registro e acompanhamento com status (Aberta / Em andamento / Resolvida).
- **Escalas:** Escala Diária, Escala de Sábado, Viagens fixas semanais e a
  grade mensal (Janeiro a Agosto) de sábados.
- **Equipe & Frota:** motoristas, ajudantes, veículos (placas, PDA, tara, lotação)
  e contatos de frota.
- **Passagem de Turno:** checklist diário (ocorrências pendentes, veículos com
  problema, folgas, caminhões retornados etc.).
- **Rotas & Referências:** regiões atendidas por dia da semana, motivos de recusa
  e de reprogramação de entrega.
- **Histórico de Pedidos** e **Notas de Acesso** (portaria, zeladoria, senhas,
  chaves): bases históricas completas, com busca e paginação.

Todas as telas de listagem têm busca, filtros, paginação e os botões de
**Novo / Editar / Excluir** — os dados salvos vão direto para o Supabase e
aparecem para qualquer pessoa que acessar o link do sistema.

---

## 6. Próximos passos sugeridos (opcional)

- Adicionar login (Supabase Auth) para cada colaborador ter seu próprio acesso.
- Exportar relatórios em PDF/Excel direto da tela de Clientes ou Pedidos.
- Notificações automáticas quando uma ocorrência ficar aberta por muito tempo.

Qualquer ajuste de layout, campos ou regras de negócio, é só pedir.
