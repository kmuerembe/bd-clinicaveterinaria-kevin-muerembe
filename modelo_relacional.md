# Modelo Relacional — Clínica Veterinária (`clinica_vet`)

## 1. Notação Textual das Relações

- `DONO(id_dono PK, nome, nif UNIQUE, telefone, email UNIQUE, morada, data_registo)`
- `VETERINARIO(id_veterinario PK, nome, nif UNIQUE, cedula_profissional UNIQUE, especialidade, telefone, email UNIQUE, data_contratacao)`
- `TRATAMENTO(id_tratamento PK, nome UNIQUE, categoria, descricao, preco_base, duracao_minutos)`
- `ANIMAL(id_animal PK, nome, especie, raca, sexo, data_nascimento, peso_kg, microchip UNIQUE, id_dono FK -> DONO.id_dono)`
- `CONSULTA(id_consulta PK, data_hora, motivo, diagnostico, estado, valor_consulta, id_animal FK -> ANIMAL.id_animal, id_veterinario FK -> VETERINARIO.id_veterinario)`
- `CONSULTA_TRATAMENTO(id_consulta PK FK -> CONSULTA.id_consulta, id_tratamento PK FK -> TRATAMENTO.id_tratamento, quantidade, preco_aplicado, observacoes)`

---

## 2. Dicionário e Estrutura Detalhada das Tabelas

### 2.1 Tabela `DONO` (Entidade Forte)

Armazena os dados de identificação fiscal, contacto e morada dos proprietários dos animais registados na clínica.

| Coluna | Tipo de Dados | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_dono` | `INT AUTO_INCREMENT` | `PRIMARY KEY`, `NOT NULL` | Identificador único sequencial do dono |
| `nome` | `VARCHAR(100)` | `NOT NULL` | Nome completo do proprietário |
| `nif` | `VARCHAR(9)` | `NOT NULL`, `UNIQUE` | Número de Identificação Fiscal (9 dígitos únicos) |
| `telefone` | `VARCHAR(15)` | `NOT NULL` | Contacto telefónico principal |
| `email` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Endereço de correio eletrónico único (acesso ao portal web) |
| `morada` | `VARCHAR(150)` | `NOT NULL` | Morada completa do proprietário |
| `data_registo` | `DATE` | `NOT NULL` | Data de inscrição do cliente na clínica |

- **Chave Primária (PK):** `pk_dono (id_dono)`
- **Chaves Únicas (UNIQUE):** `uq_dono_nif (nif)`, `uq_dono_email (email)`
- **Chaves Estrangeiras (FK):** Nenhuma

---

### 2.2 Tabela `VETERINARIO` (Entidade Forte)

Armazena o corpo clínico da clínica veterinária, incluindo cédula profissional da Ordem dos Médicos Veterinários (OMV) e área de especialização.

| Coluna | Tipo de Dados | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_veterinario` | `INT AUTO_INCREMENT` | `PRIMARY KEY`, `NOT NULL` | Identificador único sequencial do médico veterinário |
| `nome` | `VARCHAR(100)` | `NOT NULL` | Nome completo do médico veterinário |
| `nif` | `VARCHAR(9)` | `NOT NULL`, `UNIQUE` | Número de Identificação Fiscal (9 dígitos únicos) |
| `cedula_profissional` | `VARCHAR(15)` | `NOT NULL`, `UNIQUE` | Número da cédula profissional emitida pela OMV |
| `especialidade` | `VARCHAR(60)` | `NOT NULL` | Área clínica de especialidade médica |
| `telefone` | `VARCHAR(15)` | `NOT NULL` | Contacto telefónico profissional |
| `email` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Correio eletrónico institucional do médico veterinário |
| `data_contratacao` | `DATE` | `NOT NULL` | Data de entrada ao serviço na clínica |

- **Chave Primária (PK):** `pk_veterinario (id_veterinario)`
- **Chaves Únicas (UNIQUE):** `uq_veterinario_nif (nif)`, `uq_veterinario_cedula (cedula_profissional)`, `uq_veterinario_email (email)`
- **Chaves Estrangeiras (FK):** Nenhuma

---

### 2.3 Tabela `TRATAMENTO` (Entidade Forte)

Armazena o catálogo oficial de atos médicos, vacinas, meios complementares de diagnóstico, cirurgias e terapias praticados pela clínica.

| Coluna | Tipo de Dados | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_tratamento` | `INT AUTO_INCREMENT` | `PRIMARY KEY`, `NOT NULL` | Identificador único sequencial do tratamento |
| `nome` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Designação oficial única do ato clínico |
| `categoria` | `VARCHAR(50)` | `NOT NULL` | Categoria clínica (Vacinação, Cirurgia, Diagnóstico, Preventivo) |
| `descricao` | `TEXT` | `NOT NULL` | Descrição técnica detalhada do procedimento |
| `preco_base` | `DECIMAL(8,2)` | `NOT NULL` | Preço unitário de tabela em meticais moçambicanos (MZN) |
| `duracao_minutos` | `INT` | `NOT NULL` | Duração média estimada em minutos |

- **Chave Primária (PK):** `pk_tratamento (id_tratamento)`
- **Chaves Únicas (UNIQUE):** `uq_tratamento_nome (nome)`
- **Chaves Estrangeiras (FK):** Nenhuma

---

### 2.4 Tabela `ANIMAL` (Entidade Forte)

Armazena os animais de companhia acompanhados na clínica, garantindo que cada paciente pertence obrigatoriamente a um único proprietário registado.

| Coluna | Tipo de Dados | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_animal` | `INT AUTO_INCREMENT` | `PRIMARY KEY`, `NOT NULL` | Identificador único sequencial do animal |
| `nome` | `VARCHAR(60)` | `NOT NULL` | Nome próprio do animal |
| `especie` | `VARCHAR(40)` | `NOT NULL` | Espécie biológica (Cão, Gato, Coelho, Ave, Tartaruga, Hamster) |
| `raca` | `VARCHAR(60)` | `NOT NULL` | Raça ou variedade do animal |
| `sexo` | `VARCHAR(10)` | `NOT NULL` | Sexo biológico (`Macho` ou `Fêmea`) |
| `data_nascimento` | `DATE` | `NOT NULL` | Data de nascimento (real ou estimada clinicamente) |
| `peso_kg` | `DECIMAL(8,2)` | `NOT NULL` | Peso corporal atual expresso em quilogramas |
| `microchip` | `VARCHAR(15)` | `UNIQUE` | Código eletrónico ISO de 15 dígitos (opcional em exóticos de pequeno porte) |
| `id_dono` | `INT` | `NOT NULL`, `FOREIGN KEY` | Referência ao proprietário na tabela `DONO` |

- **Chave Primária (PK):** `pk_animal (id_animal)`
- **Chaves Únicas (UNIQUE):** `uq_animal_microchip (microchip)`
- **Chaves Estrangeiras (FK):**
  - `fk_animal_dono`: `id_dono` referencia `DONO(id_dono)` com `ON UPDATE CASCADE` e `ON DELETE RESTRICT`

---

### 2.5 Tabela `CONSULTA` (Entidade Forte)

Regista todos os atos de consulta agendados, concluídos ou cancelados, associando o animal atendido ao médico veterinário responsável.

| Coluna | Tipo de Dados | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_consulta` | `INT AUTO_INCREMENT` | `PRIMARY KEY`, `NOT NULL` | Identificador único sequencial da consulta |
| `data_hora` | `DATETIME` | `NOT NULL` | Data e hora marcadas ou realizadas da consulta |
| `motivo` | `VARCHAR(150)` | `NOT NULL` | Queixa principal ou motivo do agendamento |
| `diagnostico` | `TEXT` | `NULL` | Diagnóstico clínico (preenchido após realização; nulo enquanto agendada/cancelada) |
| `estado` | `VARCHAR(20)` | `NOT NULL` | Estado atual (`Agendada`, `Concluída`, `Cancelada`) |
| `valor_consulta` | `DECIMAL(8,2)` | `NOT NULL` | Taxa base do ato de consulta médica em meticais moçambicanos (MZN) |
| `id_animal` | `INT` | `NOT NULL`, `FOREIGN KEY` | Referência ao animal atendido na tabela `ANIMAL` |
| `id_veterinario` | `INT` | `NOT NULL`, `FOREIGN KEY` | Referência ao médico responsável na tabela `VETERINARIO` |

- **Chave Primária (PK):** `pk_consulta (id_consulta)`
- **Chaves Únicas (UNIQUE):** Nenhuma
- **Chaves Estrangeiras (FK):**
  - `fk_consulta_animal`: `id_animal` referencia `ANIMAL(id_animal)` com `ON UPDATE CASCADE` e `ON DELETE RESTRICT`
  - `fk_consulta_veterinario`: `id_veterinario` referencia `VETERINARIO(id_veterinario)` com `ON UPDATE CASCADE` e `ON DELETE RESTRICT`

---

### 2.6 Tabela `CONSULTA_TRATAMENTO` (Entidade Fraca / Associativa)

Materializa a relação `N:N` entre `CONSULTA` e `TRATAMENTO`. É uma **entidade fraca/associativa** porque a sua chave primária composta `(id_consulta, id_tratamento)` depende diretamente das chaves primárias das entidades fortes que relaciona, e a sua existência depende da consulta em que o tratamento foi realizado (`ON DELETE CASCADE` em `id_consulta`).

| Coluna | Tipo de Dados | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_consulta` | `INT` | `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL` | Identificador da consulta a que pertence o item |
| `id_tratamento` | `INT` | `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL` | Identificador do tratamento aplicado |
| `quantidade` | `INT` | `NOT NULL` | Número de unidades/doses aplicadas na consulta |
| `preco_aplicado` | `DECIMAL(8,2)` | `NOT NULL` | Preço unitário efetivamente praticado na data da consulta, em meticais moçambicanos (MZN) |
| `observacoes` | `TEXT` | `NULL` | Posologia, lote vacinal ou observações clínicas específicas |

- **Chave Primária Composta (PK):** `pk_consulta_tratamento (id_consulta, id_tratamento)`
- **Chaves Únicas (UNIQUE):** Garantida pela chave primária composta `(id_consulta, id_tratamento)`
- **Chaves Estrangeiras (FK):**
  - `fk_ct_consulta`: `id_consulta` referencia `CONSULTA(id_consulta)` com `ON UPDATE CASCADE` e `ON DELETE CASCADE`
  - `fk_ct_tratamento`: `id_tratamento` referencia `TRATAMENTO(id_tratamento)` com `ON UPDATE CASCADE` e `ON DELETE RESTRICT`

---

## 3. Resumo Global de Chaves e Política de Integridade Referencial

| Tabela Origem (Filha) | Coluna FK | Tabela Destino (Mãe) | Coluna PK | `ON UPDATE` | `ON DELETE` | Justificação da Regra de Negócio |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `ANIMAL` | `id_dono` | `DONO` | `id_dono` | `CASCADE` | `RESTRICT` | Impede eliminar um dono enquanto existirem animais associados à sua ficha |
| `CONSULTA` | `id_animal` | `ANIMAL` | `id_animal` | `CASCADE` | `RESTRICT` | Protege o historial clínico impedindo apagar animais com consultas registadas |
| `CONSULTA` | `id_veterinario` | `VETERINARIO` | `id_veterinario` | `CASCADE` | `RESTRICT` | Mantém a rastreabilidade médica das consultas realizadas por cada veterinário |
| `CONSULTA_TRATAMENTO` | `id_consulta` | `CONSULTA` | `id_consulta` | `CASCADE` | `CASCADE` | Dependência de existência da entidade fraca: removida a consulta, removem-se os seus itens |
| `CONSULTA_TRATAMENTO` | `id_tratamento` | `TRATAMENTO` | `id_tratamento` | `CASCADE` | `RESTRICT` | Impede remover do catálogo tratamentos já aplicados em consultas anteriores |

---

## 4. Diagrama Textual de Dependências Referenciais

```text
+---------------+
|     DONO      |
|  id_dono (PK) |
+---------------+
        ^
        |  id_dono (FK - ON DELETE RESTRICT)
        |
+---------------+          +----------------------+
|    ANIMAL     |          |     VETERINARIO      |
|id_animal (PK) |          | id_veterinario (PK)  |
+---------------+          +----------------------+
        ^                             ^
        | id_animal (FK)              | id_veterinario (FK)
        | (ON DELETE RESTRICT)        | (ON DELETE RESTRICT)
        +--------------+--------------+
                       |
               +---------------+                        +--------------------+
               |   CONSULTA    |                        |     TRATAMENTO     |
               |id_consulta(PK)|                        | id_tratamento (PK) |
               +---------------+                        +--------------------+
                       ^                                          ^
                       | id_consulta (PK, FK)                     | id_tratamento (PK, FK)
                       | (ON DELETE CASCADE)                      | (ON DELETE RESTRICT)
                       +--------------------+---------------------+
                                            |
                             +-------------------------------+
                             |     CONSULTA_TRATAMENTO       |
                             | (id_consulta, id_tratamento)  |
                             +-------------------------------+

Ordem obrigatória de CRIAÇÃO / INSERÇÃO:
  1. DONO  ->  2. VETERINARIO  ->  3. TRATAMENTO  ->  4. ANIMAL  ->  5. CONSULTA  ->  6. CONSULTA_TRATAMENTO

Ordem segura de ELIMINAÇÃO (inversa às dependências):
  1. CONSULTA_TRATAMENTO  ->  2. CONSULTA  ->  3. ANIMAL  ->  4. TRATAMENTO / VETERINARIO / DONO
```
