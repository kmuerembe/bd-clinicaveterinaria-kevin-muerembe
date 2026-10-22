# Modelo Relacional — Clínica Veterinária (`clinica_vet`)

## 1. Notação textual das relações

- `DONO(id_dono PK, nome, nuit UNIQUE, telefone, email UNIQUE, morada, data_registo)`
- `VETERINARIO(id_veterinario PK, nome, nuit UNIQUE, numero_registo_profissional UNIQUE, especialidade, telefone, email UNIQUE, data_contratacao)`
- `TRATAMENTO(id_tratamento PK, nome UNIQUE, categoria, descricao, preco_base, duracao_minutos)`
- `ANIMAL(id_animal PK, nome, especie, raca, sexo, data_nascimento, peso_kg, microchip UNIQUE, id_dono FK -> DONO.id_dono)`
- `CONSULTA(id_consulta PK, data_hora, motivo, diagnostico, estado, valor_consulta, id_animal FK -> ANIMAL.id_animal, id_veterinario FK -> VETERINARIO.id_veterinario)`
- `CONSULTA_TRATAMENTO(id_consulta PK/FK -> CONSULTA.id_consulta, id_tratamento PK/FK -> TRATAMENTO.id_tratamento, quantidade, preco_aplicado, observacoes)`
- `VACINACAO(id_animal PK/FK -> ANIMAL.id_animal, numero_dose PK, data_aplicacao, vacina, lote, id_veterinario FK -> VETERINARIO.id_veterinario)`
- `UTILIZADOR(id_utilizador PK, email UNIQUE, password_hash, perfil, id_dono UNIQUE/FK -> DONO.id_dono, id_veterinario UNIQUE/FK -> VETERINARIO.id_veterinario, ativo, ultimo_login)`

> Tipos e restrições abaixo reproduzem a definição de `CREATE TABLE` no ficheiro `01_criacao_e_insercao.sql`. Nas colunas sem `NOT NULL` explícito, a coluna permite `NULL`.

## 2. Dicionário de dados

### 2.1 `DONO` — entidade forte
Dados de identificação e contacto dos donos dos animais.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_dono` | `INT AUTO_INCREMENT` | PK, NOT NULL | Identificador sequencial do dono. |
| `nome` | `VARCHAR(100)` | NOT NULL | Nome do dono. |
| `nuit` | `VARCHAR(9)` | NOT NULL, UNIQUE, CHECK `ck_dono_nuit` | NUIT com nove algarismos. |
| `telefone` | `VARCHAR(20)` | NOT NULL, CHECK `ck_dono_telefone` | Contacto no formato moçambicano definido pelo CHECK. |
| `email` | `VARCHAR(100)` | NOT NULL, UNIQUE | Endereço de correio electrónico. |
| `morada` | `VARCHAR(150)` | NOT NULL | Morada do dono. |
| `data_registo` | `DATE` | NOT NULL | Data de registo na clínica. |

PK: `pk_dono (id_dono)`. UNIQUE: `uq_dono_nuit (nuit)`, `uq_dono_email (email)`. FK: nenhuma.

### 2.2 `VETERINARIO` — entidade forte
Dados dos médicos veterinários e do seu registo profissional.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_veterinario` | `INT AUTO_INCREMENT` | PK, NOT NULL | Identificador sequencial do veterinário. |
| `nome` | `VARCHAR(100)` | NOT NULL | Nome do veterinário. |
| `nuit` | `VARCHAR(9)` | NOT NULL, UNIQUE, CHECK `ck_veterinario_nuit` | NUIT com nove algarismos. |
| `numero_registo_profissional` | `VARCHAR(20)` | NOT NULL, UNIQUE | Número de registo profissional. |
| `especialidade` | `VARCHAR(60)` | NOT NULL | Área de especialização. |
| `telefone` | `VARCHAR(20)` | NOT NULL, CHECK `ck_veterinario_telefone` | Contacto no formato moçambicano definido pelo CHECK. |
| `email` | `VARCHAR(100)` | NOT NULL, UNIQUE | Endereço de correio electrónico. |
| `data_contratacao` | `DATE` | NOT NULL | Data de contratação. |

PK: `pk_veterinario (id_veterinario)`. UNIQUE: `uq_veterinario_nuit (nuit)`, `uq_veterinario_registo (numero_registo_profissional)`, `uq_veterinario_email (email)`. FK: nenhuma.

### 2.3 `TRATAMENTO` — entidade forte
Catálogo de actos médicos, vacinas, exames e cirurgias.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_tratamento` | `INT AUTO_INCREMENT` | PK, NOT NULL | Identificador sequencial do tratamento. |
| `nome` | `VARCHAR(100)` | NOT NULL, UNIQUE | Designação do tratamento. |
| `categoria` | `VARCHAR(50)` | NOT NULL | Categoria do acto clínico. |
| `descricao` | `TEXT` | NOT NULL | Descrição do procedimento. |
| `preco_base` | `DECIMAL(8,2)` | NOT NULL, CHECK `ck_tratamento_preco_base` | Preço de base em meticais (MZN). |
| `duracao_minutos` | `INT` | NOT NULL, CHECK `ck_tratamento_duracao` | Duração estimada em minutos. |

PK: `pk_tratamento (id_tratamento)`. UNIQUE: `uq_tratamento_nome (nome)`. FK: nenhuma.

### 2.4 `ANIMAL` — entidade forte
Regista os animais acompanhados, cada qual associado obrigatoriamente a um dono.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_animal` | `INT AUTO_INCREMENT` | PK, NOT NULL | Identificador sequencial do animal. |
| `nome` | `VARCHAR(60)` | NOT NULL | Nome do animal. |
| `especie` | `VARCHAR(40)` | NOT NULL | Espécie do animal. |
| `raca` | `VARCHAR(60)` | NOT NULL | Raça ou variedade. |
| `sexo` | `VARCHAR(10)` | NOT NULL, CHECK `ck_animal_sexo` | Sexo: `Macho` ou `Fêmea`. |
| `data_nascimento` | `DATE` | NOT NULL | Data de nascimento, real ou estimada. |
| `peso_kg` | `DECIMAL(8,2)` | NOT NULL, CHECK `ck_animal_peso` | Peso em quilogramas, superior a zero. |
| `microchip` | `VARCHAR(15)` | NULL, UNIQUE | Código do microchip; pode ser nulo. |
| `id_dono` | `INT` | NOT NULL, FK `fk_animal_dono` | Dono a quem o animal está associado. |

PK: `pk_animal (id_animal)`. UNIQUE: `uq_animal_microchip (microchip)`. FK: `fk_animal_dono`.

### 2.5 `CONSULTA` — entidade forte
Regista o atendimento de um animal por um veterinário.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_consulta` | `INT AUTO_INCREMENT` | PK, NOT NULL | Identificador sequencial da consulta. |
| `data_hora` | `DATETIME` | NOT NULL | Data e hora do atendimento. |
| `motivo` | `VARCHAR(150)` | NOT NULL | Motivo da consulta. |
| `diagnostico` | `TEXT` | NULL | Diagnóstico; pode ficar por preencher. |
| `estado` | `VARCHAR(20)` | NOT NULL, CHECK `ck_consulta_estado` | Estado: `Agendada`, `Concluída` ou `Cancelada`. |
| `valor_consulta` | `DECIMAL(8,2)` | NOT NULL, CHECK `ck_consulta_valor` | Valor da consulta em MZN. |
| `id_animal` | `INT` | NOT NULL, FK `fk_consulta_animal` | Animal atendido. |
| `id_veterinario` | `INT` | NOT NULL, FK `fk_consulta_veterinario` | Veterinário responsável. |

PK: `pk_consulta (id_consulta)`. UNIQUE: nenhuma. FKs: `fk_consulta_animal`, `fk_consulta_veterinario`.

### 2.6 `CONSULTA_TRATAMENTO` — entidade associativa
Resolve a relação muitos-para-muitos (N:N) entre `CONSULTA` e `TRATAMENTO`, guardando ainda atributos próprios da aplicação do tratamento.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_consulta` | `INT` | NOT NULL, PK composta, FK `fk_ct_consulta` | Consulta a que pertence o tratamento. |
| `id_tratamento` | `INT` | NOT NULL, PK composta, FK `fk_ct_tratamento` | Tratamento aplicado na consulta. |
| `quantidade` | `INT` | NOT NULL, CHECK `ck_ct_quantidade` | Quantidade aplicada, superior a zero. |
| `preco_aplicado` | `DECIMAL(8,2)` | NOT NULL, CHECK `ck_ct_preco_aplicado` | Preço praticado em MZN. |
| `observacoes` | `TEXT` | NULL | Observações clínicas ou de aplicação. |

PK composta: `pk_consulta_tratamento (id_consulta, id_tratamento)`; esta chave também assegura unicidade do par. FKs: `fk_ct_consulta`, `fk_ct_tratamento`.

### 2.7 `VACINACAO` — entidade fraca
Regista doses administradas a um animal. A identificação de cada dose é local ao animal: a chave é composta pela chave de `ANIMAL` e pela chave parcial `numero_dose`.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_animal` | `INT` | NOT NULL, parte da PK, FK `fk_vacinacao_animal` | Animal cujo boletim vacinal recebe a dose. |
| `numero_dose` | `INT` | NOT NULL, parte da PK, CHECK `ck_vacinacao_dose` | Número de ordem da dose no plano vacinal do animal. |
| `data_aplicacao` | `DATE` | NOT NULL | Data em que a vacina foi administrada. |
| `vacina` | `VARCHAR(100)` | NOT NULL | Designação da vacina aplicada. |
| `lote` | `VARCHAR(20)` | NOT NULL | Lote para rastreabilidade. |
| `id_veterinario` | `INT` | NOT NULL, FK `fk_vacinacao_veterinario` | Veterinário responsável pela administração. |

PK composta: `pk_vacinacao (id_animal, numero_dose)`. `numero_dose` é a chave parcial, pois só distingue doses dentro do conjunto de doses de um animal. A participação de `VACINACAO` no relacionamento identificador com `ANIMAL` é total: cada vacinação tem de pertencer a um animal. A participação de `ANIMAL` é parcial, pois pode haver animais sem registo de vacinação.

**Porque é entidade fraca:** não tem identidade autónoma e uma dose não pode ser identificada apenas pelo seu número; é necessário conhecer o animal. O relacionamento com `ANIMAL` é identificador, e `ON DELETE CASCADE` garante que a eliminação do animal elimina o boletim vacinal dependente. Assim, `VACINACAO` não existe sem o animal a que pertence.

**Diferença para `CONSULTA_TRATAMENTO`:** `CONSULTA_TRATAMENTO` é uma entidade associativa que decompõe a relação N:N entre consulta e tratamento e regista atributos dessa associação. Embora use uma PK composta por FKs, a sua função conceptual é resolver essa relação N:N; não é a entidade fraca identificadora do modelo. A entidade fraca propriamente dita é `VACINACAO`, cuja identidade parcial depende de `ANIMAL`.

### 2.8 `UTILIZADOR` — entidade forte
Guarda as contas de acesso da aplicação, associadas opcionalmente a um dono ou veterinário conforme o perfil.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_utilizador` | `INT AUTO_INCREMENT` | PK, NOT NULL | Identificador sequencial da conta. |
| `email` | `VARCHAR(100)` | NOT NULL, UNIQUE | Identificador de acesso (login). |
| `password_hash` | `VARCHAR(100)` | NOT NULL | Hash da palavra-passe; nunca deve guardar texto simples. |
| `perfil` | `VARCHAR(20)` | NOT NULL, CHECK `ck_utilizador_perfil`, CHECK `ck_utilizador_vinculo` | Perfil de acesso permitido e coerência da associação. |
| `id_dono` | `INT` | NULL, UNIQUE, FK `fk_utilizador_dono`, CHECK `ck_utilizador_vinculo` | Dono associado quando o perfil é `Dono`. |
| `id_veterinario` | `INT` | NULL, UNIQUE, FK `fk_utilizador_veterinario`, CHECK `ck_utilizador_vinculo` | Veterinário associado quando o perfil é `Veterinario`. |
| `ativo` | `TINYINT(1)` | NOT NULL, DEFAULT 1, CHECK `ck_utilizador_ativo` | Indicador de conta activa (0 ou 1). |
| `ultimo_login` | `DATETIME` | NULL | Data e hora do último acesso; nulo se ainda não houve acesso. |

PK: `pk_utilizador (id_utilizador)`. UNIQUE: `uq_utilizador_email (email)`, `uq_utilizador_dono (id_dono)`, `uq_utilizador_veterinario (id_veterinario)`. FKs: `fk_utilizador_dono`, `fk_utilizador_veterinario`.

## 3. Resumo das chaves estrangeiras

| FK | Origem (coluna) | Referência | ON UPDATE | ON DELETE | Justificação |
|---|---|---|---|---|---|
| `fk_animal_dono` | `ANIMAL.id_dono` | `DONO.id_dono` | CASCADE | RESTRICT | Propaga uma alteração de identificador; impede apagar um dono com animais associados. |
| `fk_consulta_animal` | `CONSULTA.id_animal` | `ANIMAL.id_animal` | CASCADE | RESTRICT | Preserva o histórico clínico e impede apagar animais com consultas. |
| `fk_consulta_veterinario` | `CONSULTA.id_veterinario` | `VETERINARIO.id_veterinario` | CASCADE | RESTRICT | Preserva a rastreabilidade das consultas do veterinário. |
| `fk_ct_consulta` | `CONSULTA_TRATAMENTO.id_consulta` | `CONSULTA.id_consulta` | CASCADE | CASCADE | Os itens de tratamento dependem da consulta; ao apagá-la, apagam-se os itens. |
| `fk_ct_tratamento` | `CONSULTA_TRATAMENTO.id_tratamento` | `TRATAMENTO.id_tratamento` | CASCADE | RESTRICT | Impede retirar do catálogo um tratamento já utilizado no histórico. |
| `fk_vacinacao_animal` | `VACINACAO.id_animal` | `ANIMAL.id_animal` | CASCADE | CASCADE | Relacionamento identificador: a dose não existe sem o animal; elimina o boletim dependente. |
| `fk_vacinacao_veterinario` | `VACINACAO.id_veterinario` | `VETERINARIO.id_veterinario` | RESTRICT | RESTRICT | Não altera nem elimina um veterinário referido pelo registo de vacinação. |
| `fk_utilizador_dono` | `UTILIZADOR.id_dono` | `DONO.id_dono` | RESTRICT (implícito) | RESTRICT (implícito) | Sem acções referenciais explícitas; impede remover dono ainda associado a uma conta. |
| `fk_utilizador_veterinario` | `UTILIZADOR.id_veterinario` | `VETERINARIO.id_veterinario` | RESTRICT (implícito) | RESTRICT (implícito) | Sem acções referenciais explícitas; impede remover veterinário ainda associado a uma conta. |

## 4. Utilizadores e perfis

Os perfis permitidos por `ck_utilizador_perfil` são `Administrador`, `Veterinario` e `Dono`. `ck_utilizador_vinculo` garante que: (a) `Dono` tem `id_dono` preenchido e `id_veterinario` nulo; (b) `Veterinario` tem `id_veterinario` preenchido e `id_dono` nulo; (c) `Administrador` tem ambos os vínculos nulos. `ck_utilizador_ativo` restringe `ativo` a 0 ou 1. As restrições UNIQUE sobre `id_dono` e `id_veterinario` limitam cada pessoa a, no máximo, uma conta do respectivo tipo; por serem anuláveis, permitem várias contas administrativas com ambos os vínculos nulos.

**Limitação do MySQL:** o esquema usa `id_dono` e `id_veterinario` no `CHECK ck_utilizador_vinculo`. O MySQL proíbe acções referenciais de FK (`CASCADE`, `SET NULL`, `SET DEFAULT`) em colunas usadas por `CHECK` (erro 3823). Por isso, as duas FKs de `UTILIZADOR` não declaram `ON UPDATE` nem `ON DELETE`; no MySQL, a omissão equivale a `RESTRICT`/`NO ACTION`. Para apagar um dono ou veterinário ligado a uma conta, é necessário remover primeiro a associação/conta.

## 5. Restrições CHECK

As 16 restrições CHECK nomeadas no esquema são:

| Nome | Tabela | Regra |
|---|---|---|
| `ck_dono_nuit` | `DONO` | `nuit REGEXP '^[0-9]{9}$'` |
| `ck_dono_telefone` | `DONO` | `telefone REGEXP '^[+]258 8[2-7] [0-9]{3} [0-9]{4}$'` |
| `ck_veterinario_nuit` | `VETERINARIO` | `nuit REGEXP '^[0-9]{9}$'` |
| `ck_veterinario_telefone` | `VETERINARIO` | `telefone REGEXP '^[+]258 8[2-7] [0-9]{3} [0-9]{4}$'` |
| `ck_tratamento_preco_base` | `TRATAMENTO` | `preco_base >= 0` |
| `ck_tratamento_duracao` | `TRATAMENTO` | `duracao_minutos > 0` |
| `ck_animal_sexo` | `ANIMAL` | `sexo IN ('Macho', 'Fêmea')` |
| `ck_animal_peso` | `ANIMAL` | `peso_kg > 0` |
| `ck_consulta_estado` | `CONSULTA` | `estado IN ('Agendada', 'Concluída', 'Cancelada')` |
| `ck_consulta_valor` | `CONSULTA` | `valor_consulta >= 0` |
| `ck_ct_quantidade` | `CONSULTA_TRATAMENTO` | `quantidade > 0` |
| `ck_ct_preco_aplicado` | `CONSULTA_TRATAMENTO` | `preco_aplicado >= 0` |
| `ck_vacinacao_dose` | `VACINACAO` | `numero_dose > 0` |
| `ck_utilizador_perfil` | `UTILIZADOR` | `perfil IN ('Administrador', 'Veterinario', 'Dono')` |
| `ck_utilizador_ativo` | `UTILIZADOR` | `ativo IN (0, 1)` |
| `ck_utilizador_vinculo` | `UTILIZADOR` | Coerência do perfil com os vínculos `id_dono` e `id_veterinario`, conforme a secção 4. |

O MySQL só aplica CHECK a partir da versão 8.0.16.

## 6. Diagrama de dependências e ordem operacional

```text
DONO ──< ANIMAL ──< CONSULTA >── VETERINARIO
  │          │          │              │
  │          │          └──< CONSULTA_TRATAMENTO >── TRATAMENTO
  │          │
  │          └──< VACINACAO >────────────────────── VETERINARIO
  │
  └──< UTILIZADOR >──────────────────────────────── VETERINARIO
       (vínculos opcionais; CHECK define o perfil)

Legenda: A ──< B significa que B possui FK para A.
```

**Ordem de criação** (pais antes de filhas; entre pais independentes, a ordem é livre):
1. `DONO`, `VETERINARIO`, `TRATAMENTO`.
2. `ANIMAL`, `UTILIZADOR`.
3. `CONSULTA`, `VACINACAO`.
4. `CONSULTA_TRATAMENTO`.

**Ordem de inserção**: inserir primeiro em `DONO`, `VETERINARIO` e `TRATAMENTO`; depois em `ANIMAL` e `UTILIZADOR`; depois em `CONSULTA` e `VACINACAO`; por fim em `CONSULTA_TRATAMENTO`. Para `UTILIZADOR`, os registos de `DONO`/`VETERINARIO` referidos têm de existir. As relações entre pares do mesmo nível não impõem uma ordem entre si.

**Ordem segura de eliminação** (filhas antes dos pais; alguns registos dependentes de `ANIMAL` são eliminados por CASCADE):
1. `CONSULTA_TRATAMENTO` e `VACINACAO`.
2. `CONSULTA`, `UTILIZADOR` e `ANIMAL`.
3. `TRATAMENTO`, `VETERINARIO` e `DONO`.

## 7. O que mudou em relação à versão anterior

A versão anterior documentava seis tabelas. O esquema actual tem oito: foram acrescentadas `VACINACAO` e `UTILIZADOR`. `VACINACAO` separa o boletim vacinal do registo geral de tratamentos e representa correctamente uma entidade fraca, identificada por `(id_animal, numero_dose)` e dependente do animal. `UTILIZADOR` acrescenta as contas de acesso à aplicação, com perfis, vínculos opcionais a donos ou veterinários, hash de palavra-passe e estado da conta. Também foi clarificada a classificação de `CONSULTA_TRATAMENTO`: é entidade associativa para resolver a relação N:N, não a entidade fraca do modelo.
