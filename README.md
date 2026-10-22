# Base de Dados — Clínica Veterinária

## Identificação do Projeto

- **Estudante:** Kevin Muerembe
- **Curso:** Licenciatura em Informática — 2.º Ano
- **Disciplina:** Tecnologias de Base de Dados
- **SGBD:** MySQL 8 (Motor InnoDB)
- **Repositório GitHub:** `bd-clinicaveterinaria-kevin-muerembe`
- **Link da Apresentação em Vídeo:** [https://youtu.be/s9OCBo_masc?si=-XYJt_kgVYL_xjfK]

---

## 1. Tema e Justificação da Escolha

O tema deste projeto é a conceção e implementação de uma base de dados relacional para a gestão de uma clínica veterinária (`clinica_vet`), em MySQL 8. A base de dados regista donos, animais, veterinários, consultas, tratamentos, vacinações e as contas de acesso ao sistema.

A escolha do tema tem três razões:

1. É um domínio diferente dos exemplos usados habitualmente nas aulas (biblioteca, universidade, vendas) e tem dados suficientes para um trabalho completo, sem ser demasiado grande para o âmbito da disciplina.
2. Permite aplicar os conteúdos principais da disciplina com exemplos concretos: entidades fortes, uma entidade fraca (`VACINACAO`), uma entidade associativa para resolver uma relação N:N (`CONSULTA_TRATAMENTO`), relações 1:N, uma relação 1:1 opcional entre pessoas e contas (`UTILIZADOR`), chaves únicas, restrições `CHECK` e chaves estrangeiras com `ON DELETE RESTRICT` e `ON DELETE CASCADE`.
3. A mesma base de dados pode ser reutilizada na disciplina de Programação Web, porque já inclui as contas de utilizador com perfis de acesso. Assim, o trabalho feito aqui não precisa de ser refeito quando for construída a aplicação web descrita na secção 5.

---

## 2. Descrição do Problema e Funcionamento do Sistema

Considera-se uma clínica veterinária em Maputo que atende diariamente animais de companhia de vários clientes e trabalha com uma equipa de veterinários com especialidades diferentes. Num cenário inicial, o registo da atividade é feito em fichas de papel e em folhas de cálculo separadas. Daí resultam problemas conhecidos: o mesmo cliente pode ficar registado duas vezes; encontrar o histórico de consultas e de vacinas de um animal demora tempo; o número de microchip pode ser escrito com erros ou repetido em dois animais; e não é fácil saber, para cada consulta, que tratamentos foram feitos e por que veterinário. Quando o preço de um tratamento muda, perde-se também o preço que foi praticado nas consultas anteriores.

A base de dados `clinica_vet` guarda esta informação uma única vez e de forma relacionada. Quando um cliente chega pela primeira vez, é registado como dono, com nome, NUIT (Número Único de Identificação Tributária), telefone, email, morada e data de registo. Cada animal fica associado a um único dono e é caracterizado pelo nome, espécie, raça, sexo, data de nascimento, peso e, quando existe, número de microchip. Um dono pode ter vários animais, ou ainda nenhum, quando a ficha é aberta antes da primeira consulta. Do lado da clínica ficam registados os veterinários (NUIT, número de registo profissional, especialidade e contactos) e o catálogo de tratamentos, com categoria, descrição, preço base em meticais (MZN) e duração estimada.

Sempre que um animal é atendido, regista-se uma consulta com data e hora, motivo, veterinário responsável, valor e estado (`Agendada`, `Concluída` ou `Cancelada`); o diagnóstico pode ficar vazio até ao atendimento. Numa consulta podem ser feitos vários tratamentos do catálogo, ou nenhum, quando a visita é só de observação. Como um tratamento também pode ser aplicado em muitas consultas, esta relação é guardada em `CONSULTA_TRATAMENTO`, com a quantidade aplicada, o preço praticado nessa data e observações. Assim, se o preço base for atualizado mais tarde, as consultas antigas mantêm o preço que foi aplicado.

A vacinação é tratada separadamente, porque funciona por doses e forma o boletim vacinal de cada animal. Em `VACINACAO`, cada linha é uma dose: número de Ordem da dose dentro do boletim desse animal, data de aplicação, vacina, lote e veterinário que a administrou. Para saber que doses um animal já recebeu basta consultar as suas linhas por Ordem. Uma dose isolada não tem significado — dizer apenas «dose 2» não chega; é preciso saber a que animal pertence. É esta dependência que faz de `VACINACAO` a entidade fraca do modelo (secções 3 e 4).

Por fim, o acesso ao sistema é feito com contas registadas em `UTILIZADOR`. Cada conta tem um email, que serve de identificação para iniciar sessão (login), o *hash* da palavra-passe, um perfil (`Administrador`, `Veterinario` ou `Dono`), indicação de conta ativa ou inativa e a data do último acesso. As contas `Dono` ficam ligadas à ficha de um dono e as contas `Veterinario` à ficha de um veterinário; as contas de administração, usadas pela receção e pela administração da clínica, não ficam ligadas a nenhuma ficha. Nem todos os donos e veterinários precisam de ter conta, mas cada um pode ter no máximo uma. É esta tabela que permitirá controlar, na futura aplicação web, quem pode ver e alterar cada tipo de informação.

---

## 3. Regras de Negócio

As regras abaixo correspondem às restrições definidas em `01_criacao_e_insercao.sql`. O dicionário de dados completo, com todas as chaves estrangeiras e restrições `CHECK` nomeadas, está em [`modelo_relacional.md`](modelo_relacional.md).

1. **RN01 — Identificação única dos donos (`DONO`):** Cada dono tem `nuit` e `email` únicos, sem registos duplicados. O `nuit` tem de ter exatamente 9 dígitos (`ck_dono_nuit`) e o `telefone` tem de seguir o formato moçambicano definido na restrição `ck_dono_telefone`.
2. **RN02 — Relação entre dono e animais (1:N):** Um dono pode ter zero, um ou vários animais (participação parcial, mínimo 0), mas cada animal pertence obrigatoriamente a um e um só dono (participação total, mínimo e máximo 1).
3. **RN03 — Proteção das fichas de donos:** Não é permitido eliminar um dono enquanto tiver animais associados (`fk_animal_dono` com `ON DELETE RESTRICT`).
4. **RN04 — Dados do animal (`ANIMAL`):** O `sexo` só pode ser `Macho` ou `Fêmea` (`ck_animal_sexo`) e o `peso_kg` tem de ser superior a zero (`ck_animal_peso`). O `microchip` pode ficar por preencher (por exemplo, em animais de pequeno porte), mas, quando preenchido, não pode repetir-se em dois animais (`uq_animal_microchip`).
5. **RN05 — Identificação única dos veterinários (`VETERINARIO`):** Cada veterinário tem `nuit`, `email` e `numero_registo_profissional` únicos. Valem as mesmas validações de formato do dono: NUIT com 9 dígitos (`ck_veterinario_nuit`) e telefone no formato definido (`ck_veterinario_telefone`).
6. **RN06 — Paciente e veterinário obrigatórios na consulta:** Toda a consulta refere obrigatoriamente um animal existente e um veterinário responsável (participação total de `CONSULTA` nas duas relações 1:N). No sentido inverso, um animal ou um veterinário podem ainda não ter consultas (participação parcial, mínimo 0).
7. **RN07 — Preservação do histórico de consultas:** Não é permitido eliminar um animal nem um veterinário que já tenham consultas registadas (`ON DELETE RESTRICT` nas duas chaves estrangeiras de `CONSULTA`).
8. **RN08 — Estado e valores da consulta:** O `estado` só pode ser `Agendada`, `Concluída` ou `Cancelada` (`ck_consulta_estado`). O `diagnostico` pode ficar nulo enquanto a consulta não estiver concluída, e o `valor_consulta` não pode ser negativo (`ck_consulta_valor`).
9. **RN09 — Entidade associativa `CONSULTA_TRATAMENTO` (relação N:N):** Uma consulta pode incluir zero, um ou vários tratamentos e um tratamento pode ser aplicado em zero, uma ou várias consultas. Esta relação N:N é decomposta na entidade associativa `CONSULTA_TRATAMENTO`, com chave primária composta `(id_consulta, id_tratamento)`, pelo que o mesmo tratamento não aparece duas vezes na mesma consulta — repetições registam-se no campo `quantidade` (sempre superior a zero, `ck_ct_quantidade`). Se uma consulta for eliminada, as suas linhas de tratamentos são eliminadas com ela (`fk_ct_consulta` com `ON DELETE CASCADE`).
10. **RN10 — Catálogo e preços históricos (`TRATAMENTO`):** No catálogo, o `nome` é único, o `preco_base` não pode ser negativo (`ck_tratamento_preco_base`) e a `duracao_minutos` tem de ser superior a zero (`ck_tratamento_duracao`). Cada aplicação guarda o `preco_aplicado` (também não negativo, `ck_ct_preco_aplicado`) na data do ato, para que alterações futuras ao `preco_base` não mudem os valores das consultas antigas. Um tratamento que já tenha sido usado não pode ser eliminado do catálogo (`fk_ct_tratamento` com `ON DELETE RESTRICT`).
11. **RN11 — Entidade fraca `VACINACAO` (vacinação por doses):** Cada dose é identificada pelo par `(id_animal, numero_dose)`, em que `numero_dose` é a chave parcial: só distingue doses dentro do boletim de um mesmo animal e tem de ser superior a zero (`ck_vacinacao_dose`). Cada dose pertence obrigatoriamente a um animal (participação total) e é administrada por um veterinário; um animal pode ter zero, uma ou várias doses. Se o animal for eliminado, o seu boletim vacinal é eliminado com ele (`fk_vacinacao_animal` com `ON DELETE CASCADE`), e um veterinário referenciado numa dose não pode ser eliminado (`fk_vacinacao_veterinario` com `ON DELETE RESTRICT`).
12. **RN12 — Contas de acesso (`UTILIZADOR`):** O `email` é único e serve como identificação de login. A palavra-passe nunca é guardada em texto simples, apenas o seu *hash* em `password_hash`. O `perfil` só pode ser `Administrador`, `Veterinario` ou `Dono` (`ck_utilizador_perfil`), o campo `ativo` só pode ser 0 ou 1 (`ck_utilizador_ativo`) e `ultimo_login` fica nulo até ao primeiro acesso.
13. **RN13 — Ligação entre conta e perfil:** A conta tem de ser coerente com o perfil (`ck_utilizador_vinculo`): perfil `Dono` exige `id_dono` preenchido e `id_veterinario` nulo; perfil `Veterinario` exige o contrário; perfil `Administrador` exige os dois vínculos nulos. Cada dono e cada veterinário podem ter no máximo uma conta (restrições únicas sobre `id_dono` e `id_veterinario`) e podem também não ter nenhuma, ou seja, a relação é (0,1):(0,1) dos dois lados. Um dono ou veterinário com conta associada não pode ser eliminado antes de a conta ser removida.

---

## 4. Diagrama Entidade-Relacionamento

O diagrama seguinte representa as 8 entidades da base de dados, com os respetivos atributos, tipos e chaves (PK — chave primária, FK — chave estrangeira, UK — chave única). A imagem foi Gerada a partir do código Mermaid mais abaixo, guardado em [`diagrama_er.mmd`](diagrama_er.mmd), para que a imagem e o código coincidam.

![Diagrama Entidade-Relacionamento — Clínica Veterinária](diagrama_er.png)

**Código Mermaid (`diagrama_er.mmd`):**

```mermaid
erDiagram
    %% ============================================================
    %% Diagrama Entidade-Relacionamento - Clínica Veterinária
    %% Base de dados: clinica_vet (MySQL 8) | Autor: Kevin Muerembe
    %% Ficheiro: diagrama_er.mmd (Mermaid erDiagram)
    %% Os atributos, tipos e chaves reproduzem o ficheiro
    %% 01_criacao_e_insercao.sql.
    %% ---
    %% Leitura das relações:
    %% linha contínua (--) = relacionamento identificador
    %% linha tracejada (..) = relacionamento não identificador
    %% Os pares (min,max) nos rótulos seguem a ordem das entidades
    %% na linha e indicam quantas vezes cada ocorrência dessa
    %% entidade participa na relação (participação e cardinalidade).
    %% ---
    %% VACINACAO é uma ENTIDADE FRACA: não tem chave própria; é
    %% identificada por (id_animal, numero_dose), em que
    %% numero_dose é a chave parcial (discriminador) dentro de
    %% cada animal. O seu relacionamento com ANIMAL é
    %% identificador (linha contínua).
    %% CONSULTA_TRATAMENTO é uma ENTIDADE ASSOCIATIVA: decompõe a
    %% relação N:N entre CONSULTA e TRATAMENTO e guarda atributos
    %% próprios dessa associação (quantidade, preco_aplicado,
    %% observacoes).
    %% ============================================================

    DONO {
        INT id_dono PK
        VARCHAR(100) nome
        VARCHAR(9) nuit UK "9 dígitos"
        VARCHAR(20) telefone
        VARCHAR(100) email UK
        VARCHAR(150) morada
        DATE data_registo
    }

    VETERINARIO {
        INT id_veterinario PK
        VARCHAR(100) nome
        VARCHAR(9) nuit UK "9 dígitos"
        VARCHAR(20) numero_registo_profissional UK
        VARCHAR(60) especialidade
        VARCHAR(20) telefone
        VARCHAR(100) email UK
        DATE data_contratacao
    }

    TRATAMENTO {
        INT id_tratamento PK
        VARCHAR(100) nome UK
        VARCHAR(50) categoria
        TEXT descricao
        DECIMAL(8,2) preco_base "em MZN"
        INT duracao_minutos
    }

    ANIMAL {
        INT id_animal PK
        VARCHAR(60) nome
        VARCHAR(40) especie
        VARCHAR(60) raca
        VARCHAR(10) sexo "Macho ou Fêmea"
        DATE data_nascimento
        DECIMAL(8,2) peso_kg
        VARCHAR(15) microchip UK "opcional"
        INT id_dono FK
    }

    CONSULTA {
        INT id_consulta PK
        DATETIME data_hora
        VARCHAR(150) motivo
        TEXT diagnostico "opcional"
        VARCHAR(20) estado "Agendada, Concluída ou Cancelada"
        DECIMAL(8,2) valor_consulta "em MZN"
        INT id_animal FK
        INT id_veterinario FK
    }

    %% CONSULTA_TRATAMENTO: entidade associativa (resolve a relação
    %% N:N entre CONSULTA e TRATAMENTO, com atributos próprios).
    CONSULTA_TRATAMENTO {
        INT id_consulta PK, FK
        INT id_tratamento PK, FK
        INT quantidade
        DECIMAL(8,2) preco_aplicado "em MZN"
        TEXT observacoes "opcional"
    }

    %% VACINACAO: entidade fraca (sem chave própria; identificada
    %% por id_animal + numero_dose, a sua chave parcial).
    VACINACAO {
        INT id_animal PK, FK
        INT numero_dose PK "chave parcial"
        DATE data_aplicacao
        VARCHAR(100) vacina
        VARCHAR(20) lote
        INT id_veterinario FK
    }

    UTILIZADOR {
        INT id_utilizador PK
        VARCHAR(100) email UK "login"
        VARCHAR(100) password_hash
        VARCHAR(20) perfil "Administrador, Veterinario ou Dono"
        INT id_dono FK, UK "apenas perfil Dono"
        INT id_veterinario FK, UK "apenas perfil Veterinario"
        TINYINT(1) ativo "0 ou 1"
        DATETIME ultimo_login "opcional"
    }

    %% Relacionamentos não identificadores (linha tracejada: ..)
    DONO ||..o{ ANIMAL : "possui (0,N):(1,1)"
    ANIMAL ||..o{ CONSULTA : "tem (0,N):(1,1)"
    VETERINARIO ||..o{ CONSULTA : "realiza (0,N):(1,1)"
    CONSULTA ||..o{ CONSULTA_TRATAMENTO : "inclui (0,N):(1,1)"
    TRATAMENTO ||..o{ CONSULTA_TRATAMENTO : "aplicado em (0,N):(1,1)"
    VETERINARIO ||..o{ VACINACAO : "administra (0,N):(1,1)"
    DONO |o..o| UTILIZADOR : "tem conta (0,1):(0,1)"
    VETERINARIO |o..o| UTILIZADOR : "tem conta (0,1):(0,1)"

    %% Relacionamento identificador (linha contínua: --)
    %% VACINACAO (entidade fraca) depende de ANIMAL para existir.
    ANIMAL ||--o{ VACINACAO : "recebe (0,N):(1,1)"
```

### Leitura do diagrama

- **Linha contínua (`--`)** indica um **relacionamento identificador** e aparece apenas entre `ANIMAL` e `VACINACAO`, porque a dose só é identificada com o animal (RN11). **Linha tracejada (`..`)** indica um relacionamento não identificador, usado em todas as restantes relações.
- Os símbolos nas extremidades seguem a notação de pé-de-galinha do Mermaid: `||` = exatamente um; `|o` / `o|` = zero ou um; `o{` = zero, um ou vários. Os pares (mínimo, máximo) nos rótulos seguem a Ordem das entidades em cada linha e indicam quantas vezes cada ocorrência dessa entidade participa na relação.
- `VACINACAO` é a **entidade fraca** do modelo: não tem chave própria e usa a chave composta `(id_animal, numero_dose)`, sendo `numero_dose` a chave parcial. `CONSULTA_TRATAMENTO` é uma **entidade associativa**: existe para decompor a relação N:N entre `CONSULTA` e `TRATAMENTO` e guarda os atributos próprios dessa associação (`quantidade`, `preco_aplicado`, `observacoes`).

| Relação | (mín., máx.) | Leitura |
|---|---|---|
| `DONO` — `ANIMAL` | `DONO` (0,N) : `ANIMAL` (1,1) | Um dono pode ter vários animais ou nenhum; cada animal tem um só dono. |
| `ANIMAL` — `CONSULTA` | `ANIMAL` (0,N) : `CONSULTA` (1,1) | Um animal pode ter várias consultas ou nenhuma; cada consulta é de um só animal. |
| `VETERINARIO` — `CONSULTA` | `VETERINARIO` (0,N) : `CONSULTA` (1,1) | Um veterinário pode realizar várias consultas ou nenhuma; cada consulta tem um só veterinário responsável. |
| `CONSULTA` — `CONSULTA_TRATAMENTO` | `CONSULTA` (0,N) : `CONSULTA_TRATAMENTO` (1,1) | Uma consulta pode incluir vários tratamentos ou nenhum; cada linha pertence a uma só consulta. |
| `TRATAMENTO` — `CONSULTA_TRATAMENTO` | `TRATAMENTO` (0,N) : `CONSULTA_TRATAMENTO` (1,1) | Um tratamento pode ser aplicado em várias consultas ou em nenhuma; cada linha refere um só tratamento. Em conjunto com a relação anterior, decompõe a relação N:N entre consulta e tratamento: (0,N):(0,N). |
| `ANIMAL` — `VACINACAO` (identificador) | `ANIMAL` (0,N) : `VACINACAO` (1,1) | Um animal pode ter várias doses ou nenhuma; cada dose pertence a um só animal e só existe com ele. |
| `VETERINARIO` — `VACINACAO` | `VETERINARIO` (0,N) : `VACINACAO` (1,1) | Um veterinário pode administrar várias doses ou nenhuma; cada dose é administrada por um só veterinário. |
| `DONO` — `UTILIZADOR` | `DONO` (0,1) : `UTILIZADOR` (0,1) | Um dono pode ter uma conta ou nenhuma; uma conta está associada a um dono apenas quando o perfil é `Dono`. |
| `VETERINARIO` — `UTILIZADOR` | `VETERINARIO` (0,1) : `UTILIZADOR` (0,1) | Um veterinário pode ter uma conta ou nenhuma; uma conta está associada a um veterinário apenas quando o perfil é `Veterinario`. |

A notação textual das relações, o dicionário de dados e o resumo de chaves estrangeiras e restrições `CHECK` encontram-se em [`modelo_relacional.md`](modelo_relacional.md).

---

## 5. Sistema Web Previsto (Ligação a Programação Web)

Esta base de dados servirá de suporte à aplicação web **VetGest Web**, a desenvolver na disciplina de Programação Web. O acesso é feito com as contas da tabela `UTILIZADOR`: o utilizador inicia sessão com o seu `email` e palavra-passe (comparada com `password_hash`), as contas com `ativo = 0` não podem entrar e cada acesso atualiza `ultimo_login`.

### Perfis de Utilizadores

- **`Administrador`** (receção/administração da clínica): regista e edita donos (`DONO`), animais (`ANIMAL`), veterinários (`VETERINARIO`) e o catálogo de tratamentos (`TRATAMENTO`); marca, remarca e cancela consultas (`CONSULTA`); cria, ativa e desativa contas de acesso (`UTILIZADOR`); consulta históricos e boletins vacinais.
- **`Veterinario`** (conta ligada a uma ficha de `VETERINARIO`): consulta a sua agenda e o histórico de cada animal; regista o diagnóstico e conclui consultas; indica os tratamentos realizados em cada consulta (`CONSULTA_TRATAMENTO`); regista as doses aplicadas no boletim vacinal (`VACINACAO`).
- **`Dono`** (conta ligada a uma ficha de `DONO`): consulta apenas a sua própria informação — dados dos seus animais, consultas passadas e agendadas, tratamentos realizados e boletim vacinal — sem alterar registos clínicos.

### Funcionalidades Principais (CRUD Completo)

- **Registar (`INSERT`):** Formulários para novos donos, animais, veterinários e tratamentos; marcação de consultas; tratamentos realizados em cada consulta; nova dose no boletim vacinal de um animal (com o `numero_dose` seguinte); criação de contas de utilizador.
- **Listar (`SELECT` com `JOIN`):** Agenda de consultas por dia e por veterinário; lista de donos com os respetivos animais; veterinários por especialidade; catálogo de tratamentos; histórico completo de um animal (consultas, tratamentos e vacinações por Ordem cronológica); lista de contas com perfil, estado e último acesso, sem mostrar `password_hash`.
- **Pesquisar (`SELECT` com `WHERE`):** Pesquisa por NUIT ou nome do dono, por nome ou microchip do animal, por espécie/raça, por especialidade do veterinário, por intervalo de datas, por estado da consulta e, na gestão de contas, por perfil e por contas ativas/inativas.
- **Alterar (`UPDATE`):** Edição de telefone, email e morada dos donos; atualização de peso e microchip do animal; registo do diagnóstico e mudança de estado da consulta para `Concluída` ou `Cancelada`; atualização do preço base no catálogo; ativação/desativação de contas (`ativo`) e alteração da palavra-passe, guardando sempre o novo *hash*.
- **Eliminar (`DELETE`):** Eliminação apenas de registos sem dependentes, respeitando as chaves estrangeiras: por exemplo, um tratamento do catálogo nunca utilizado. A base de dados recusa eliminar donos, animais ou veterinários com registos associados (RN03, RN07, RN11 e RN13). Para contas de acesso, usa-se a desativação (`ativo = 0`) em vez da eliminação, para manter o registo de quem teve acesso ao sistema.

---

## 6. Estrutura do Repositório

```text
bd-clinicaveterinaria-kevin-muerembe/
├── README.md
├── diagrama_er.png
├── diagrama_er.mmd
├── modelo_relacional.md
├── 01_criacao_e_insercao.sql
└── 02_manipulacao.sql
```

- `README.md` — apresentação do projeto (este ficheiro).
- `diagrama_er.png` — imagem do Diagrama Entidade-Relacionamento, Gerada a partir de `diagrama_er.mmd`.
- `diagrama_er.mmd` — código Mermaid (`erDiagram`) do diagrama, idêntico ao bloco da secção 4.
- `modelo_relacional.md` — notação textual das relações, dicionário de dados, chaves estrangeiras, restrições `CHECK` e Ordem de criação/inserção/eliminação das tabelas.
- `01_criacao_e_insercao.sql` — criação da base de dados `clinica_vet`, das 8 tabelas com as suas restrições e inserção dos dados de teste.
- `02_manipulacao.sql` — comandos de manipulação: consultas `SELECT` simples e com `JOIN`, atualizações `UPDATE`, eliminação `DELETE` e Teste de integridade referencial. Deve ser executado depois de `01_criacao_e_insercao.sql`.

---

## 7. Tecnologias Utilizadas

- **MySQL 8 (InnoDB):** SGBD utilizado (é necessária a versão 8.0.16 ou superior para as restrições `CHECK` serem aplicadas). Criação do esquema com chaves primárias, estrangeiras e únicas, em `utf8mb4`, e manipulação de dados com SQL.
- **MySQL Workbench 8:** execução e validação dos scripts SQL.
- **Mermaid (`erDiagram`):** representação do Diagrama Entidade-Relacionamento em texto, no ficheiro `diagrama_er.mmd`; o GitHub desenha o diagrama a partir do bloco da secção 4 e a imagem `diagrama_er.png` foi Gerada a partir do mesmo código.
- **Markdown, Git e GitHub:** documentação do projeto, controlo de versões e alojamento do repositório.
