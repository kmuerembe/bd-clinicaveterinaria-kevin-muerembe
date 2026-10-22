-- =========================================================================
-- PROJETO DE TECNOLOGIAS DE BASE DE DADOS (2.º ANO — LICENCIATURA EM INFORMÁTICA)
-- UNIVERSIDADE LICUNGO — MOÇAMBIQUE
-- ESTUDANTE: Kevin Muerembe
-- TEMA: CLÍNICA VETERINÁRIA (clinica_vet)
-- FICHEIRO: 01_criacao_e_insercao.sql
-- SGBD: MySQL 8.0.16 ou superior (motor InnoDB)
--         (a partir da versão 8.0.16 o MySQL passa a APLICAR as restrições CHECK;
--          nas versões anteriores elas são apenas analisadas e ignoradas)
-- -------------------------------------------------------------------------
-- DESCRIÇÃO: Criação de raiz da base de dados, das 8 tabelas com as respetivas
--            restrições de integridade (PRIMARY KEY, UNIQUE, FOREIGN KEY e
--            CHECK nomeadas) e inserção de 20 ou mais registos em cada tabela.
--
-- TABELAS (8): DONO, VETERINARIO, TRATAMENTO, ANIMAL, CONSULTA,
--              CONSULTA_TRATAMENTO, VACINACAO, UTILIZADOR
--
-- MOEDA:     Todos os valores monetários (preco_base, valor_consulta,
--            preco_aplicado) estão expressos em meticais moçambicanos (MZN).
--            AVISO: os preços são APROXIMADOS e meramente ILUSTRATIVOS, usados
--            apenas para dar uma ordem de grandeza realista ao exercício
--            académico. Não constituem um preçário real de nenhuma clínica.
--            Ordens de grandeza adotadas:
--              • consulta        ->  500 a 1 500 MZN
--              • vacinas         ->  600 a 2 000 MZN
--              • cirurgias       -> 5 000 a 20 000 MZN
--              • exames/prevenção ->  400 a 5 000 MZN
--
-- DADOS:     TODOS os nomes, moradas, NUIT, telefones, emails, números de
--            registo profissional, microchips, lotes vacinais e palavras-passe
--            são FICTÍCIOS, criados exclusivamente para fins académicos.
--            As password_hash são texto inventado com o aspeto de um hash
--            bcrypt ($2b$12$...); não correspondem a nenhuma palavra-passe real.
--
-- DATA DE REFERÊNCIA DO EXERCÍCIO: 22 de outubro de 2026.
-- =========================================================================

-- Remover a base de dados caso já exista, garantindo execução limpa de raiz
DROP DATABASE IF EXISTS clinica_vet;

-- Criar a base de dados com suporte completo a caracteres portugueses (UTF-8)
CREATE DATABASE clinica_vet
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Selecionar a base de dados criada
USE clinica_vet;

-- Garantir que o cliente comunica com o servidor em UTF-8 (protege os acentos
-- de "Concluída", "Fêmea", "Óscar", etc., quando o script corre por consola)
SET NAMES utf8mb4;


-- =========================================================================
-- 1. CRIAÇÃO DAS TABELAS (ORDEM RESPEITANDO AS CHAVES ESTRANGEIRAS)
--
-- Ordem de criação:
--   1. DONO  ->  2. VETERINARIO  ->  3. TRATAMENTO  ->  4. ANIMAL
--   5. CONSULTA  ->  6. CONSULTA_TRATAMENTO  ->  7. VACINACAO  ->  8. UTILIZADOR
--
-- NOTA SOBRE AS RESTRIÇÕES CHECK (MySQL 8.0.16+):
--   Todas as restrições CHECK deste esquema têm NOME próprio (prefixo ck_),
--   o que permite identificá-las facilmente na mensagem de erro quando uma
--   inserção é rejeitada e facilita a sua remoção com ALTER TABLE.
-- =========================================================================

-- -------------------------------------------------------------------------
-- Tabela 1: DONO (entidade forte)
-- Armazena os dados pessoais e de contacto dos proprietários dos animais.
-- O antigo campo "nif" passa a chamar-se "nuit" (Número Único de Identificação
-- Tributária, usado em Moçambique), com 9 dígitos validados por REGEXP.
-- -------------------------------------------------------------------------
CREATE TABLE DONO (
    id_dono INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    nuit VARCHAR(9) NOT NULL COMMENT 'Número Único de Identificação Tributária (9 dígitos, fictício)',
    telefone VARCHAR(20) NOT NULL COMMENT 'Formato +258 8X XXX XXXX',
    email VARCHAR(100) NOT NULL,
    morada VARCHAR(150) NOT NULL,
    data_registo DATE NOT NULL,
    CONSTRAINT pk_dono PRIMARY KEY (id_dono),
    CONSTRAINT uq_dono_nuit UNIQUE (nuit),
    CONSTRAINT uq_dono_email UNIQUE (email),
    CONSTRAINT ck_dono_nuit CHECK (nuit REGEXP '^[0-9]{9}$'),
    CONSTRAINT ck_dono_telefone CHECK (telefone REGEXP '^[+]258 8[2-7] [0-9]{3} [0-9]{4}$')
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 2: VETERINARIO (entidade forte)
-- Armazena os médicos veterinários da clínica e a sua área de especialização.
-- O antigo campo "cedula_profissional" passa a chamar-se
-- "numero_registo_profissional", por se tratar de um número de registo
-- profissional genérico (não é citada nenhuma ordem ou instituição concreta).
-- -------------------------------------------------------------------------
CREATE TABLE VETERINARIO (
    id_veterinario INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    nuit VARCHAR(9) NOT NULL COMMENT 'Número Único de Identificação Tributária (9 dígitos, fictício)',
    numero_registo_profissional VARCHAR(20) NOT NULL COMMENT 'Número de registo profissional (fictício)',
    especialidade VARCHAR(60) NOT NULL,
    telefone VARCHAR(20) NOT NULL COMMENT 'Formato +258 8X XXX XXXX',
    email VARCHAR(100) NOT NULL,
    data_contratacao DATE NOT NULL,
    CONSTRAINT pk_veterinario PRIMARY KEY (id_veterinario),
    CONSTRAINT uq_veterinario_nuit UNIQUE (nuit),
    CONSTRAINT uq_veterinario_registo UNIQUE (numero_registo_profissional),
    CONSTRAINT uq_veterinario_email UNIQUE (email),
    CONSTRAINT ck_veterinario_nuit CHECK (nuit REGEXP '^[0-9]{9}$'),
    CONSTRAINT ck_veterinario_telefone CHECK (telefone REGEXP '^[+]258 8[2-7] [0-9]{3} [0-9]{4}$')
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 3: TRATAMENTO (entidade forte)
-- Catálogo de atos médicos, vacinas, exames e cirurgias disponíveis na clínica.
-- -------------------------------------------------------------------------
CREATE TABLE TRATAMENTO (
    id_tratamento INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    preco_base DECIMAL(8,2) NOT NULL COMMENT 'Preço base de tabela em meticais (MZN) — valor APROXIMADO e ilustrativo',
    duracao_minutos INT NOT NULL,
    CONSTRAINT pk_tratamento PRIMARY KEY (id_tratamento),
    CONSTRAINT uq_tratamento_nome UNIQUE (nome),
    CONSTRAINT ck_tratamento_preco_base CHECK (preco_base >= 0),
    CONSTRAINT ck_tratamento_duracao CHECK (duracao_minutos > 0)
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 4: ANIMAL (entidade forte)
-- Regista cada animal de companhia, associado obrigatoriamente a um DONO.
-- ON DELETE RESTRICT impede eliminar um dono que ainda tenha animais registados.
-- O microchip segue a norma ISO 11784/11785 e começa pelo prefixo 508, que é o
-- código numérico ISO 3166-1 de Moçambique (valores fictícios).
-- -------------------------------------------------------------------------
CREATE TABLE ANIMAL (
    id_animal INT AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    especie VARCHAR(40) NOT NULL,
    raca VARCHAR(60) NOT NULL,
    sexo VARCHAR(10) NOT NULL,
    data_nascimento DATE NOT NULL,
    peso_kg DECIMAL(8,2) NOT NULL,
    microchip VARCHAR(15) COMMENT 'Código ISO 11784/11785 de 15 dígitos; nulo em exóticos de pequeno porte',
    id_dono INT NOT NULL,
    CONSTRAINT pk_animal PRIMARY KEY (id_animal),
    CONSTRAINT uq_animal_microchip UNIQUE (microchip),
    CONSTRAINT ck_animal_sexo CHECK (sexo IN ('Macho', 'Fêmea')),
    CONSTRAINT ck_animal_peso CHECK (peso_kg > 0),
    CONSTRAINT fk_animal_dono FOREIGN KEY (id_dono)
        REFERENCES DONO (id_dono)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 5: CONSULTA (entidade forte)
-- Regista os atendimentos clínicos realizados por um VETERINARIO a um ANIMAL.
-- ON DELETE RESTRICT preserva o histórico clínico de animais e veterinários.
-- -------------------------------------------------------------------------
CREATE TABLE CONSULTA (
    id_consulta INT AUTO_INCREMENT,
    data_hora DATETIME NOT NULL,
    motivo VARCHAR(150) NOT NULL,
    diagnostico TEXT COMMENT 'Preenchido apenas quando a consulta passa a Concluída',
    estado VARCHAR(20) NOT NULL,
    valor_consulta DECIMAL(8,2) NOT NULL COMMENT 'Valor da consulta em meticais (MZN) — valor APROXIMADO e ilustrativo',
    id_animal INT NOT NULL,
    id_veterinario INT NOT NULL,
    CONSTRAINT pk_consulta PRIMARY KEY (id_consulta),
    CONSTRAINT ck_consulta_estado CHECK (estado IN ('Agendada', 'Concluída', 'Cancelada')),
    CONSTRAINT ck_consulta_valor CHECK (valor_consulta >= 0),
    CONSTRAINT fk_consulta_animal FOREIGN KEY (id_animal)
        REFERENCES ANIMAL (id_animal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_veterinario FOREIGN KEY (id_veterinario)
        REFERENCES VETERINARIO (id_veterinario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 6: CONSULTA_TRATAMENTO (ENTIDADE ASSOCIATIVA)
--
-- Designação correta: trata-se de uma ENTIDADE ASSOCIATIVA (também chamada
-- "tabela de junção" ou "entidade associativa com atributos próprios"), porque
-- a sua função é resolver/decompor a relação N:N entre CONSULTA e TRATAMENTO,
-- transportando ainda atributos que pertencem à própria relação (quantidade,
-- preco_aplicado, observacoes).
--
-- Não é classificada como "entidade fraca" neste projeto: a entidade fraca
-- verdadeira do modelo é a tabela VACINACAO (ver tabela 7), que só existe por
-- causa do ANIMAL e cuja chave parcial é herdada dele.
--
-- Política de integridade:
--   • ON DELETE CASCADE em id_consulta  -> apagada a consulta, apagam-se os itens;
--   • ON DELETE RESTRICT em id_tratamento -> não se pode retirar do catálogo um
--     tratamento já aplicado numa consulta (preserva o histórico de faturação).
-- -------------------------------------------------------------------------
CREATE TABLE CONSULTA_TRATAMENTO (
    id_consulta INT NOT NULL,
    id_tratamento INT NOT NULL,
    quantidade INT NOT NULL,
    preco_aplicado DECIMAL(8,2) NOT NULL COMMENT 'Preço praticado na data do ato, em meticais (MZN) — valor APROXIMADO e ilustrativo',
    observacoes TEXT,
    CONSTRAINT pk_consulta_tratamento PRIMARY KEY (id_consulta, id_tratamento),
    CONSTRAINT ck_ct_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_ct_preco_aplicado CHECK (preco_aplicado >= 0),
    CONSTRAINT fk_ct_consulta FOREIGN KEY (id_consulta)
        REFERENCES CONSULTA (id_consulta)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_ct_tratamento FOREIGN KEY (id_tratamento)
        REFERENCES TRATAMENTO (id_tratamento)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 7: VACINACAO  ***  ENTIDADE FRACA (verdadeira)  ***
--
-- É uma entidade fraca porque NÃO tem chave primária própria: a sua chave é
-- composta pela chave primária da entidade forte ANIMAL (id_animal) mais um
-- atributo discriminador local (numero_dose). Uma linha de VACINACAO não tem
-- qualquer significado fora do animal a que pertence — "dose 2" só faz sentido
-- quando sabemos de que animal se trata.
--
-- DEPENDÊNCIA DE EXISTÊNCIA: a FK de id_animal usa ON DELETE CASCADE. Se o
-- animal for eliminado da base de dados, o seu boletim vacinal desaparece
-- automaticamente com ele, exatamente como exige uma entidade fraca.
--
-- Relação: ANIMAL (1) ---< (0,N) VACINACAO  — participação TOTAL de VACINACAO
-- e PARCIAL de ANIMAL (há animais, sobretudo exóticos, sem vacinação).
--
-- A FK de id_veterinario é uma relação normal 1:N (NÃO é parte da identidade
-- da entidade), pelo que usa ON DELETE RESTRICT: não se apaga um médico que já
-- tenha vacinas registadas em seu nome.
--
-- CONVENÇÃO ADOTADA PARA numero_dose: é o número de ordem da dose no PLANO
-- VACINAL GLOBAL do animal (1.ª, 2.ª, 3.ª...), independentemente da vacina.
-- Esta convenção é necessária porque a chave primária (id_animal, numero_dose)
-- só permite uma linha por número de dose em cada animal.
-- -------------------------------------------------------------------------
CREATE TABLE VACINACAO (
    id_animal INT NOT NULL,
    numero_dose INT NOT NULL COMMENT 'N.º de ordem da dose no plano vacinal do animal',
    data_aplicacao DATE NOT NULL,
    vacina VARCHAR(100) NOT NULL COMMENT 'Designação da vacina aplicada (corresponde a uma entrada do catálogo TRATAMENTO)',
    lote VARCHAR(20) NOT NULL COMMENT 'Lote do fabricante (fictício), para rastreabilidade',
    id_veterinario INT NOT NULL,
    CONSTRAINT pk_vacinacao PRIMARY KEY (id_animal, numero_dose),
    CONSTRAINT ck_vacinacao_dose CHECK (numero_dose > 0),
    CONSTRAINT fk_vacinacao_animal FOREIGN KEY (id_animal)
        REFERENCES ANIMAL (id_animal)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_vacinacao_veterinario FOREIGN KEY (id_veterinario)
        REFERENCES VETERINARIO (id_veterinario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 8: UTILIZADOR (entidade forte) — suporte ao LOGIN da aplicação web
--
-- Regras de negócio implementadas por CHECK:
--   1. perfil só aceita 'Administrador', 'Veterinario' ou 'Dono';
--   2. coêrencia do vínculo:
--        • perfil = 'Dono'          -> id_dono preenchido e id_veterinario NULO;
--        • perfil = 'Veterinario'   -> id_veterinario preenchido e id_dono NULO;
--        • perfil = 'Administrador' -> AMBOS os campos a NULO (utilizador interno,
--                                      não é cliente nem médico);
--   3. ativo só aceita 0 (desativado) ou 1 (ativo).
--
-- *** AVISO TÉCNICO IMPORTANTE SOBRE O MYSQL 8 ***
-- As colunas id_dono e id_veterinario são usadas na restrição CHECK
-- ck_utilizador_vinculo. O manual do MySQL 8 (secção 15.1.20.6, "CHECK
-- Constraints") diz textualmente:
--   "Foreign key referential actions (ON UPDATE, ON DELETE) are prohibited on
--    columns used in CHECK constraints. Likewise, CHECK constraints are
--    prohibited on columns used in foreign key referential actions."
-- Se estas duas FK usarem CASCADE, SET NULL ou SET DEFAULT, a criação da tabela
-- é recusada com o ERRO 3823
-- (ER_CHECK_CONSTRAINT_CLAUSE_USING_FK_REFER_ACTION_COLUMN).
--
-- SOLUÇÃO ADOTADA: as duas FK são declaradas SEM cláusulas ON UPDATE/ON DELETE.
-- O próprio manual esclarece que "Specifying RESTRICT (or NO ACTION) is the same
-- as omitting the ON DELETE or ON UPDATE clause", pelo que a ação efetiva é
-- RESTRICT — a única compatível com uma coluna usada num CHECK — e a tabela é
-- criada sem erros.
--
-- Consequência prática (regra de negócio): para eliminar um dono ou um
-- veterinário é preciso, primeiro, remover/desativar a conta de UTILIZADOR
-- associada. É exatamente isso que se pretende num sistema real com login.
--
-- SEGURANÇA: password_hash guarda apenas o hash (nunca a palavra-passe em
-- texto simples). Os valores abaixo são HASHES FICTÍCIOS com o formato visual
-- de bcrypt ($2b$12$ + 53 caracteres), inventados para o exercício.
-- -------------------------------------------------------------------------
CREATE TABLE UTILIZADOR (
    id_utilizador INT AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL COMMENT 'Identificador de acesso (login)',
    password_hash VARCHAR(100) NOT NULL COMMENT 'Hash fictício com aspeto de bcrypt — nunca guardar a palavra-passe real',
    perfil VARCHAR(20) NOT NULL,
    id_dono INT NULL COMMENT 'Preenchido apenas quando perfil = Dono',
    id_veterinario INT NULL COMMENT 'Preenchido apenas quando perfil = Veterinario',
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    ultimo_login DATETIME NULL COMMENT 'NULO enquanto o utilizador nunca tiver iniciado sessão',
    CONSTRAINT pk_utilizador PRIMARY KEY (id_utilizador),
    CONSTRAINT uq_utilizador_email UNIQUE (email),
    CONSTRAINT uq_utilizador_dono UNIQUE (id_dono),
    CONSTRAINT uq_utilizador_veterinario UNIQUE (id_veterinario),
    CONSTRAINT ck_utilizador_perfil CHECK (perfil IN ('Administrador', 'Veterinario', 'Dono')),
    CONSTRAINT ck_utilizador_ativo CHECK (ativo IN (0, 1)),
    CONSTRAINT ck_utilizador_vinculo CHECK (
        (perfil = 'Dono'          AND id_dono IS NOT NULL AND id_veterinario IS NULL) OR
        (perfil = 'Veterinario'   AND id_veterinario IS NOT NULL AND id_dono IS NULL) OR
        (perfil = 'Administrador' AND id_dono IS NULL AND id_veterinario IS NULL)
    ),
    CONSTRAINT fk_utilizador_dono FOREIGN KEY (id_dono)
        REFERENCES DONO (id_dono),
    CONSTRAINT fk_utilizador_veterinario FOREIGN KEY (id_veterinario)
        REFERENCES VETERINARIO (id_veterinario)
) ENGINE=InnoDB;


-- =========================================================================
-- 2. INSERÇÃO DE DADOS (20 OU MAIS REGISTOS EM CADA UMA DAS 8 TABELAS)
--
-- Ordem das inserções (respeita as dependências das chaves estrangeiras):
--   DONO -> VETERINARIO -> TRATAMENTO -> ANIMAL -> CONSULTA
--        -> CONSULTA_TRATAMENTO -> VACINACAO -> UTILIZADOR
--
-- Data de referência do exercício: 22-10-2026.
-- Coerência temporal imposta aos dados:
--   • CONSULTA 'Concluída' -> data_hora SEMPRE no passado;
--   • CONSULTA 'Cancelada' -> data_hora no passado;
--   • CONSULTA 'Agendada'  -> data_hora no futuro (consultas 18, 19 e 20);
--   • EXCEÇÃO DELIBERADA: a consulta com id_consulta = 18 está 'Agendada' com
--     data de ONTEM (21-10-2026 15:30). Representa um atendimento que já
--     aconteceu mas cujo fecho clínico ainda não foi registado no sistema — é
--     exatamente esta a consulta que o UPDATE n.º 1 do 02_manipulacao.sql conclui.
--   • data_aplicacao de VACINACAO -> sempre posterior à data_nascimento do
--     animal e posterior à data_contratacao do veterinário que a aplicou.
-- =========================================================================

-- -------------------------------------------------------------------------
-- Inserção na tabela DONO (21 registos: IDs 1 a 21)
-- Moradas em Maputo, Matola, Beira, Nampula, Quelimane, Chimoio, Tete, Pemba,
-- Xai-Xai e Inhambane. NUIT, telefones e emails FICTÍCIOS.
-- Nota: os donos 19, 20 e 21 foram registados recentemente e ainda não têm
--       animais, ilustrando a participação PARCIAL de DONO na relação com ANIMAL.
--       Os donos 1 e 3 têm dois animais cada (relação 1:N).
-- -------------------------------------------------------------------------
INSERT INTO DONO (nome, nuit, telefone, email, morada, data_registo) VALUES
('Amélia Chirinza Sitoe',       '401258736', '+258 84 217 5590', 'amelia.sitoe@gmail.com',            'Bairro da Polana Caniço, Av. Eduardo Mondlane, n.º 1452, Maputo',  '2023-02-14'),
('Celso Mavie Nhaca',            '402176548', '+258 82 445 1187', 'celso.nhaca@outlook.com',           'Bairro T3, Av. das FPLM, n.º 87, Matola',                          '2023-03-21'),
('Dércio Loforte Tembe',         '403291874', '+258 85 630 2241', 'dercio.tembe@gmail.com',            'Bairro da Ponta-Gêa, Av. Marginal, n.º 340, Beira',                '2023-05-09'),
('Elísio Guambe Matsinhe',       '404158263', '+258 86 117 9034', 'elisio.matsinhe@outlook.com',       'Bairro de Marrere, Av. de Moçambique, n.º 2210, Nampula',          '2023-06-18'),
('Filipe Bacar Mussá',           '405264918', '+258 87 104 6628', 'filipe.mussa@gmail.com',            'Bairro Brandão, Av. 1.º de Maio, n.º 108, Quelimane',              '2023-08-03'),
('Graça Zitha Cossa',            '406183592', '+258 84 662 3391', 'graca.cossa@gmail.com',             'Bairro Chicamba, Rua de Manica, n.º 15, Chimoio',                  '2023-09-15'),
('Hélder Sumbane Mondlane',      '407294186', '+258 82 907 4415', 'helder.mondlane@outlook.com',       'Bairro Josina Machel, Av. 25 de Junho, n.º 61, Tete',              '2023-11-02'),
('Idalina Jussub Abdula',        '408371254', '+258 83 331 7762', 'idalina.abdula@mercadoxai.co.mz',   'Bairro Chail, Rua de Gaza, n.º 33, Xai-Xai',                       '2024-01-12'),
('Kelson Vilanculo Bila',        '409158463', '+258 86 448 2209', 'kelson.bila@gmail.com',             'Bairro Camissone, Rua do Comércio, n.º 74, Inhambane',             '2024-02-25'),
('Luís Machatine Novela',        '410276183', '+258 87 225 9934', 'luis.novela@outlook.com',           'Bairro da Paz, Av. Marginal, n.º 219, Pemba',                      '2024-04-08'),
('Marta Nhantumbo Machava',      '411394725', '+258 84 118 6620', 'marta.machava@gmail.com',           'Bairro do Alto Maé, Av. Kim Il Sung, n.º 505, Maputo',             '2024-05-19'),
('Nádia Sacur Macuácua',         '412483169', '+258 83 736 4408', 'nadia.macuacua@padariabeira.co.mz', 'Bairro do Inhamizua, Av. Marginal, n.º 92, Beira',                 '2024-07-04'),
('Orlando Chirindza Munguambe',  '413265917', '+258 85 902 1173', 'orlando.munguambe@gmail.com',       'Bairro Boquisso, Estrada Nacional n.º 4, n.º 122, Matola',         '2024-08-29'),
('Paula Cuambe Manjate',         '414193472', '+258 86 314 8827', 'paula.manjate@outlook.com',         'Bairro de Natikire, Rua de Nacala, n.º 46, Nampula',               '2024-10-11'),
('Quitéria Tivane Zandamela',    '415284736', '+258 87 620 5541', 'quiria.zandamela@gmail.com',        'Bairro Icídua, Av. Samuel Magaia, n.º 17, Quelimane',              '2025-01-17'),
('Rogério Dauto Faquir',         '416371298', '+258 84 733 2296', 'rogerio.faquir@outlook.com',        'Baixa da Cidade, Rua da Sé, n.º 128, Maputo',                      '2025-03-06'),
('Sérgia Miambo Chongo',         '417294835', '+258 85 226 4470', 'sergia.chongo@gmail.com',           'Bairro Fomento, Rua de Nampula, n.º 45, Matola',                   '2025-06-22'),
('Telma Nhambirre Mulhovo',      '418362174', '+258 83 447 9913', 'telma.mulhovo@outlook.com',         'Bairro Nhaurire, Av. dos Combatentes, n.º 8, Chimoio',             '2025-09-30'),
('Valdemiro Matsenha Cumbana',   '419275841', '+258 86 903 7752', 'valdemiro.cumbana@gmail.com',       'Bairro da Costa do Sol, Av. Marginal, n.º 3104, Maputo',           '2026-07-14'),
('Yolanda Nuvunga Mabunda',      '420183469', '+258 87 526 1104', 'yolanda.mabunda@outlook.com',       'Bairro Liberdade, Av. Angolana, n.º 640, Matola',                  '2026-09-18'),
('Zacarias Djedje Omar',         '421394178', '+258 84 318 6627', 'zacarias.omar@sulnet.co.mz',        'Bairro Mahate, Rua de Cabo Delgado, n.º 21, Pemba',                '2026-10-09');

-- -------------------------------------------------------------------------
-- Inserção na tabela VETERINARIO (20 registos: IDs 1 a 20)
-- O campo numero_registo_profissional é um número de registo profissional
-- genérico e FICTÍCIO (não é citada nenhuma ordem ou associação concreta).
-- Nota: os veterinários 13, 16, 17, 19 e 20 ainda não realizaram consultas
--       nesta base de dados (participação PARCIAL em CONSULTA).
-- -------------------------------------------------------------------------
INSERT INTO VETERINARIO (nome, nuit, numero_registo_profissional, especialidade, telefone, email, data_contratacao) VALUES
('Dr. Edson Macuácua Chissale',    '301458726', 'MV-MZ-0417', 'Clínica Geral',                    '+258 84 512 7701', 'e.chissale@clinicavet.co.mz',  '2016-03-02'),
('Dra. Lúcia Nuvunga Amaral',      '302476189', 'MV-MZ-0463', 'Cirurgia de Tecidos Moles',        '+258 82 640 1188', 'l.amaral@clinicavet.co.mz',    '2016-09-15'),
('Dr. Hermenegildo Cossa Bila',    '303291745', 'MV-MZ-0512', 'Ortopedia e Traumatologia',        '+258 83 337 9024', 'h.bila@clinicavet.co.mz',      '2017-01-11'),
('Dra. Marta Ismael Guambe',       '304158392', 'MV-MZ-0578', 'Dermatologia Veterinária',         '+258 85 219 4407', 'm.guambe@clinicavet.co.mz',    '2017-05-24'),
('Dr. Ricardo Sitoe Machava',      '305283914', 'MV-MZ-0621', 'Cardiologia Veterinária',          '+258 86 450 3312', 'r.machava@clinicavet.co.mz',   '2018-02-06'),
('Dra. Vera Lúcia Tembe',          '306391478', 'MV-MZ-0688', 'Medicina Felina',                  '+258 87 726 5590', 'v.tembe@clinicavet.co.mz',     '2018-08-14'),
('Dr. André Filipe Bacar',         '307418265', 'MV-MZ-0733', 'Animais Exóticos',                 '+258 84 318 4471', 'a.bacar@clinicavet.co.mz',     '2019-06-01'),
('Dra. Sara Cristina Nhaca',       '308264917', 'MV-MZ-0790', 'Oftalmologia Veterinária',         '+258 82 604 2288', 's.nhaca@clinicavet.co.mz',     '2020-10-17'),
('Dr. Bruno Alexandre Mondlane',   '309175384', 'MV-MZ-0846', 'Estomatologia Veterinária',        '+258 83 437 1195', 'b.mondlane@clinicavet.co.mz',  '2021-01-09'),
('Dra. Rita Sofia Matsinhe',       '310284761', 'MV-MZ-0902', 'Imagiologia e Ecografia',          '+258 85 215 6630', 'r.matsinhe@clinicavet.co.mz',  '2021-04-03'),
('Dr. Nuno Miguel Chirindza',      '311392845', 'MV-MZ-0958', 'Clínica Geral',                    '+258 86 903 1274', 'n.chirindza@clinicavet.co.mz', '2022-09-11'),
('Dra. Joana Patrícia Cumbana',    '312418293', 'MV-MZ-1014', 'Medicina Interna',                 '+258 87 746 5509', 'j.cumbana@clinicavet.co.mz',   '2023-01-15'),
('Dr. Pedro Afonso Langa',         '313284917', 'MV-MZ-1071', 'Neurologia Veterinária',           '+258 84 129 3346', 'p.langa@clinicavet.co.mz',     '2023-04-22'),
('Dra. Filipa Alexandra Zucula',   '314391276', 'MV-MZ-1128', 'Oncologia Veterinária',            '+258 82 318 7752', 'f.zucula@clinicavet.co.mz',    '2024-08-05'),
('Dr. Tomás Guilherme Nhantumbo',  '315274819', 'MV-MZ-1184', 'Urgências e Cuidados Intensivos',  '+258 83 640 2218', 't.nhantumbo@clinicavet.co.mz', '2025-01-06'),
('Dra. Carolina Beatriz Satar',    '316418923', 'MV-MZ-1240', 'Reabilitação e Fisioterapia',      '+258 85 317 8864', 'c.satar@clinicavet.co.mz',     '2025-05-12'),
('Dr. Vasco Manuel Sacur',         '317284196', 'MV-MZ-1297', 'Anestesiologia Veterinária',       '+258 86 905 4431', 'v.sacur@clinicavet.co.mz',     '2025-09-01'),
('Dra. Mafalda Inês Mulhovo',      '318391742', 'MV-MZ-1353', 'Clínica Geral',                    '+258 87 428 6617', 'm.mulhovo@clinicavet.co.mz',   '2026-01-12'),
('Dr. Lourenço Dinis Vilanculo',   '319276418', 'MV-MZ-1409', 'Nutrição Clínica',                 '+258 84 713 2295', 'l.vilanculo@clinicavet.co.mz', '2026-09-21'),
('Dra. Matilde Leonor Djedje',     '320184763', 'MV-MZ-1465', 'Comportamento Animal',             '+258 82 526 9914', 'm.djedje@clinicavet.co.mz',    '2026-10-01');

-- -------------------------------------------------------------------------
-- Inserção na tabela TRATAMENTO (21 registos: IDs 1 a 21)
-- Preços em MZN, APROXIMADOS e ilustrativos (vacinas 600-2000; cirurgias
-- 5000-20000; exames e preventivos 400-5000).
-- Nota: os tratamentos 4, 16 e 21 ainda não foram aplicados em nenhuma
--       consulta. O tratamento 21 é o alvo do DELETE do ficheiro 02, que assim
--       pode ser executado sem violar nenhuma chave estrangeira.
-- -------------------------------------------------------------------------
INSERT INTO TRATAMENTO (nome, categoria, descricao, preco_base, duracao_minutos) VALUES
('Vacina Polivalente Canina (V8)',                    'Vacinação',      'Imunização contra esgana, parvovirose, hepatite infeciosa, leptospirose e parainfluenza canina.', 1200.00, 20),
('Vacina Antirrábica',                                'Vacinação',      'Vacinação contra o vírus da raiva em cães e gatos a partir dos três meses de idade, com registo no boletim sanitário do animal.', 900.00, 15),
('Vacina Tríplice Felina',                            'Vacinação',      'Proteção contra panleucopenia, rinotraqueíte viral felina e calicivirose.', 1100.00, 20),
('Vacina Contra a Tosse do Canil',                    'Vacinação',      'Imunização contra Bordetella bronchiseptica e vírus da parainfluenza canina, recomendada para animais em contacto com matilhas.', 800.00, 15),
('Desparasitação Interna Completa',                   'Preventivo',     'Administração oral de antiparasitário de largo espetro ajustado ao peso corporal do animal.', 450.00, 15),
('Desparasitação Externa Spot-On',                    'Preventivo',     'Aplicação tópica mensal contra pulgas, carraças e mosquitos vetores de dirofilariose.', 600.00, 15),
('Colocação de Microchip e Registo de Identificação', 'Identificação',  'Implantação subcutânea de transponder ISO 11784/11785 e preenchimento do registo de identificação eletrónica do animal.', 1500.00, 20),
('Hemograma Completo e Bioquímica Sanguínea',         'Diagnóstico',    'Colheita de sangue venoso e análise laboratorial da função renal, hepática e do perfil eletrolítico.', 2500.00, 30),
('Ecografia Abdominal',                               'Diagnóstico',    'Exame ecográfico detalhado dos órgãos abdominais com relatório imagiológico.', 3000.00, 40),
('Radiografia Digital Torácica',                      'Diagnóstico',    'Estudo radiográfico em duas projeções para avaliação pulmonar e da silhueta cardíaca.', 2200.00, 30),
('Ecocardiograma com Doppler a Cores',                'Diagnóstico',    'Avaliação morfológica e funcional das válvulas e câmaras cardíacas com Doppler a cores.', 4500.00, 45),
('Teste de Fluoresceína Ocular',                      'Oftalmologia',   'Avaliação da integridade da córnea para deteção precoce de úlceras corneanas.', 900.00, 20),
('Destartarização e Polimento Dentário',              'Estomatologia',  'Remoção de tártaro por ultrassons e polimento dentário sob sedação monitorizada.', 5500.00, 60),
('Esterilização Felina (Ovariohisterectomia)',        'Cirurgia',       'Intervenção cirúrgica eletiva em gata sob anestesia geral inalatória e analgesia multimodal.', 8500.00, 75),
('Orquiectomia Canina',                               'Cirurgia',       'Castração cirúrgica eletiva de cão macho com monitorização multiparamétrica.', 7500.00, 60),
('Cesariana de Urgência',                             'Cirurgia',       'Intervenção obstétrica de urgência com suporte anestésico e cuidados intensivos pós-operatórios.', 18000.00, 120),
('Citologia Dermatológica com Raspagem',              'Dermatologia',   'Colheita e observação microscópica para pesquisa de ácaros, fungos, bactérias e leveduras.', 1300.00, 25),
('Limpeza Auricular e Terapia de Otite',              'Dermatologia',   'Lavagem otoscópica do canal auditivo externo e aplicação tópica anti-inflamatória.', 1100.00, 25),
('Corte Técnico de Bico e Unhas (Exóticos)',          'Exóticos',       'Aparagem clínica segura do bico ou das unhas em aves, coelhos e pequenos mamíferos.', 700.00, 20),
('Fluidoterapia Endovenosa (Sessão)',                 'Urgência',       'Reposição hidroeletrolítica endovenosa com bomba de infusão contínua.', 1800.00, 90),
('Sessão de Fisioterapia e Acupuntura Veterinária',   'Reabilitação',   'Estimulação de pontos neuro-reativos e exercícios assistidos para controlo da dor crónica osteoarticular.', 2000.00, 45);

-- -------------------------------------------------------------------------
-- Inserção na tabela ANIMAL (20 registos: IDs 1 a 20)
-- Microchips fictícios com o prefixo 508 (código ISO 3166-1 de Moçambique).
-- O microchip é NULO nos exóticos de pequeno porte (coelho, ave, tartaruga e
-- hamster), o que é permitido porque a coluna é opcional.
-- Nota: os donos 1 e 3 têm dois animais cada (IDs 1 e 19; IDs 3 e 20).
--       Os animais 18, 19 e 20 ainda não têm consultas registadas.
-- -------------------------------------------------------------------------
INSERT INTO ANIMAL (nome, especie, raca, sexo, data_nascimento, peso_kg, microchip, id_dono) VALUES
('Max',       'Cão',       'Pastor Alemão',                  'Macho', '2020-05-14', 31.40, '508200000000001', 1),
('Luna',      'Gato',      'Gato Doméstico de Pelo Curto',   'Fêmea', '2021-08-22',  4.20, '508200000000002', 2),
('N''weti',   'Cão',       'Boerboel',                       'Macho', '2019-11-03', 45.80, '508200000000003', 3),
('Mia',       'Gato',      'Persa',                          'Fêmea', '2022-02-17',  3.90, '508200000000004', 4),
('Kanimambo', 'Cão',       'Rottweiler',                     'Macho', '2018-07-09', 38.60, '508200000000005', 5),
('Kika',      'Cão',       'Bulldog Francês',                'Fêmea', '2021-04-30', 11.80, '508200000000006', 6),
('Xiluva',    'Gato',      'Siamês',                         'Macho', '2020-09-12',  4.85, '508200000000007', 7),
('Pantufa',   'Coelho',    'Coelho Anão Holandês',           'Fêmea', '2023-03-19',  1.35, NULL,              8),
('Bobi',      'Cão',       'Rafeiro Comum (Sem Raça Definida)','Macho','2019-03-28', 22.40, '508200000000009', 9),
('Nala',      'Gato',      'Maine Coon',                     'Fêmea', '2021-12-05',  5.60, '508200000000010', 10),
('Thor',      'Cão',       'Golden Retriever',               'Macho', '2020-01-25', 33.10, '508200000000011', 11),
('Pipoca',    'Ave',       'Caturra',                        'Fêmea', '2022-10-10',  0.10, NULL,              12),
('Txova',     'Cão',       'Beagle',                         'Macho', '2022-06-14', 13.70, '508200000000013', 13),
('Amora',     'Cão',       'Cocker Spaniel Inglês',          'Fêmea', '2021-01-18', 14.20, '508200000000014', 14),
('Óscar',     'Gato',      'Gato Doméstico de Pelo Longo',   'Macho', '2023-05-02',  5.10, '508200000000015', 15),
('Estrela',   'Tartaruga', 'Tartaruga-de-Esporas Africana',  'Fêmea', '2017-08-01',  4.15, NULL,              16),
('Duque',     'Cão',       'Labrador Retriever',             'Macho', '2019-06-21', 29.90, '508200000000017', 17),
('Bolacha',   'Hamster',   'Hamster Sírio',                  'Macho', '2025-04-11',  0.14, NULL,              18),
('Nhlamvu',   'Gato',      'Gato Doméstico de Pelo Curto',   'Fêmea', '2025-11-20',  3.40, '508200000000019', 1),
('Tintswalo', 'Cão',       'Pinscher',                       'Macho', '2025-09-08',  9.60, '508200000000020', 3);

-- -------------------------------------------------------------------------
-- Inserção na tabela CONSULTA (21 registos: IDs 1 a 21)
--
-- Os registos são inseridos por ordem cronológica, pelo que os IDs automáticos
-- coincidem com essa ordenação. Coerência temporal face a 22-10-2026:
--   • IDs 1 a 16  -> 'Concluída' , datas entre 15-01-2026 e 06-10-2026 (passado)
--   • ID  17      -> 'Cancelada' , data 09-10-2026 (passado)
--   • ID  18      -> 'Agendada'  , data 21-10-2026 15:30 (ONTEM)
--                    Exceção deliberada e documentada: representa o atendimento
--                    que já decorreu mas cujo fecho clínico ainda falta registar
--                    no sistema. É exatamente esta a consulta que o UPDATE n.º 1
--                    do ficheiro 02_manipulacao.sql passa a 'Concluída'.
--   • IDs 19 a 21 -> 'Agendada'  , datas 26-10-2026, 04-11-2026 e 19-11-2026 (futuro)
--
-- O campo diagnostico só está preenchido nas consultas 'Concluída'; fica NULL
-- nas 'Agendada' e na 'Cancelada'.
-- -------------------------------------------------------------------------
INSERT INTO CONSULTA (data_hora, motivo, diagnostico, estado, valor_consulta, id_animal, id_veterinario) VALUES
('2026-01-15 09:30:00', 'Reforço vacinal anual e avaliação geral de saúde',        'Animal saudável, condição corporal ideal e mucosas coradas.', 'Concluída', 800.00, 1, 1),
('2026-01-28 11:00:00', 'Esterilização eletiva previamente agendada',               'Ovariohisterectomia sem intercorrências; recuperação anestésica normal.', 'Concluída', 1000.00, 2, 2),
('2026-02-11 15:00:00', 'Prurido intenso nas orelhas e abanar constante da cabeça', 'Otite externa eritematosa bilateral associada a sobrecrescimento de Malassezia.', 'Concluída', 900.00, 3, 4),
('2026-02-25 10:15:00', 'Lacrimejo persistente no olho direito',                    'Úlcera corneana superficial sem perfuração, confirmada pelo teste de fluoresceína.', 'Concluída', 950.00, 4, 8),
('2026-03-12 16:30:00', 'Intolerância ao exercício e tosse seca noturna',           'Insuficiência mitral ligeira detetada em ecocardiograma; iniciada monitorização semestral.', 'Concluída', 1200.00, 5, 5),
('2026-03-26 14:00:00', 'Vermelhidão interdigital e queda de pelo localizada',      'Dermatite alérgica de contacto sem presença de ectoparasitas.', 'Concluída', 900.00, 6, 4),
('2026-04-09 09:45:00', 'Mau hálito acentuado e acumulação visível de tártaro',     'Doença periodontal de grau II; realizada destartarização completa.', 'Concluída', 850.00, 7, 9),
('2026-04-23 17:00:00', 'Crescimento excessivo das unhas e revisão dentária',       'Incisivos alinhados e unhas aparadas sem lesões podais.', 'Concluída', 700.00, 8, 7),
('2026-05-07 10:00:00', 'Claudicação do membro posterior direito após corrida',     'Entorse ligeira do joelho direito sem rutura do ligamento cruzado cranial.', 'Concluída', 1100.00, 9, 3),
('2026-05-21 11:30:00', 'Vómitos agudos e prostração há 24 horas',                  'Gastroenterite aguda ligeira com desidratação de 5%; estabilizada com fluidoterapia.', 'Concluída', 1500.00, 10, 15),
('2026-06-04 15:30:00', 'Castração eletiva e controlo pré-operatório',              'Análises pré-cirúrgicas normais e orquiectomia sem complicações.', 'Concluída', 1000.00, 11, 2),
('2026-06-18 16:00:00', 'Crescimento excessivo do bico e avaliação da plumagem',    'Plumagem íntegra; efetuado desgaste corretivo do bico.', 'Concluída', 800.00, 12, 7),
('2026-07-08 09:15:00', 'Primeira identificação eletrónica e vacinação antirrábica','Animal clinicamente são; microchip implantado na região cervical esquerda.', 'Concluída', 750.00, 13, 11),
('2026-08-05 14:45:00', 'Perda de peso progressiva no último mês',                  'Ligeira sobrecarga hepática na bioquímica; ajustada dieta hepatoprotetora.', 'Concluída', 950.00, 14, 12),
('2026-09-10 10:30:00', 'Vacinação anual felina e controlo de parasitas',           'Exame físico sem alterações; plano preventivo atualizado.', 'Concluída', 800.00, 15, 6),
('2026-10-06 11:15:00', 'Letargia sazonal e revisão nutricional da carapaça',       'Hipovitaminose A ligeira; prescrito ajuste da radiação UVB e suplementação.', 'Concluída', 900.00, 16, 7),
('2026-10-09 16:30:00', 'Radiografia torácica de controlo e revisão de peso',        NULL, 'Cancelada', 700.00, 17, 10),
('2026-10-21 15:30:00', 'Reavaliação ortopédica do joelho direito e controlo de peso', NULL, 'Agendada', 800.00, 9, 11),
('2026-10-26 10:00:00', 'Reavaliação cardíaca semestral de rotina',                  NULL, 'Agendada', 1200.00, 5, 5),
('2026-11-04 15:30:00', 'Consulta de rotina e ajuste do plano alimentar',            NULL, 'Agendada', 900.00, 17, 18),
('2026-11-19 11:00:00', 'Check-up geriátrico e rastreio oncológico',                 NULL, 'Agendada', 1100.00, 1, 14);

-- -------------------------------------------------------------------------
-- Inserção na tabela CONSULTA_TRATAMENTO (22 registos)
-- ENTIDADE ASSOCIATIVA: resolve a relação N:N entre CONSULTA e TRATAMENTO.
-- A chave primária composta (id_consulta, id_tratamento) garante que o mesmo
-- tratamento não pode ser registado duas vezes na mesma consulta.
-- O preco_aplicado fica congelado na data do ato: futuras alterações de
-- preco_base no catálogo NÃO alteram o histórico já faturado.
-- Nota: só são referenciados os tratamentos 1 a 20; os tratamentos 4, 16 e 21
--       ficam sem aplicação (o 21 é eliminado pelo DELETE do ficheiro 02).
-- -------------------------------------------------------------------------
INSERT INTO CONSULTA_TRATAMENTO (id_consulta, id_tratamento, quantidade, preco_aplicado, observacoes) VALUES
(1,  1,  1, 1200.00, 'Lote vacinal VC8-2026/014; sem reação local após 20 minutos de observação.'),
(1,  5,  1,  450.00, 'Comprimido mastigável ajustado à faixa de peso de 25 a 40 kg.'),
(2,  8,  1, 2500.00, 'Perfil pré-anestésico dentro dos valores de referência.'),
(2,  14, 1, 8500.00, 'Sutura intradérmica absorvível; colar isabelino durante 7 dias.'),
(3,  17, 1, 1300.00, 'Citologia auricular positiva para leveduras do género Malassezia.'),
(3,  18, 1, 1100.00, 'Aplicação em consultório; manter gotas uma vez por dia durante 10 dias.'),
(4,  12, 1,  900.00, 'Captação focal positiva na região paraxial direita; úlcera superficial.'),
(5,  10, 1, 2200.00, 'Índice cardiovertebral de 10,9; campos pulmonares limpos.'),
(5,  11, 1, 4500.00, 'Regurgitação mitral ligeira; reavaliação semestral programada.'),
(6,  6,  2,  600.00, 'Duas pipetas fornecidas para protocolo mensal contínuo.'),
(7,  13, 1, 5500.00, 'Polimento completo de ambas as arcadas sem necessidade de extrações.'),
(8,  19, 1,  700.00, 'Unhas aparadas acima do sabugo vascular; sem hemorragia.'),
(9,  10, 1, 2200.00, 'Sem sinais radiográficos de fratura ou de avulsão óssea.'),
(10, 9,  1, 3000.00, 'Espessamento difuso ligeiro da parede gástrica; sem corpo estranho.'),
(10, 20, 1, 1800.00, 'Perfusão de lactato de Ringer a 15 ml/h durante 90 minutos.'),
(11, 15, 1, 7500.00, 'Alta no próprio dia com prescrição anti-inflamatória oral por 5 dias.'),
(12, 19, 1,  700.00, 'Desgaste corretivo do bico realizado com lima rotativa.'),
(13, 7,  1, 1500.00, 'Leitura do transponder confirmada antes e após a implantação.'),
(13, 2,  1,  900.00, 'Dose antirrábica registada com validade de um ano; lote VA-2026/071.'),
(14, 8,  1, 2500.00, 'Aumento ligeiro de ALT/AST; repetir o perfil hepático em 60 dias.'),
(15, 3,  1, 1100.00, 'Reforço anual da vacina tríplice felina sem reações adversas.'),
(16, 5,  1,  450.00, 'Antiparasitário oral de largo espetro ajustado ao peso da carapaça.');

-- -------------------------------------------------------------------------
-- Inserção na tabela VACINACAO (35 registos)  ***  ENTIDADE FRACA  ***
--
-- Cada linha só existe por causa do animal a que pertence: se o animal for
-- apagado, ON DELETE CASCADE remove automaticamente todo o seu boletim vacinal.
--
-- Distribuição deliberada de doses por animal (para demonstrar a cardinalidade
-- 1:N entre ANIMAL e VACINACAO):
--   • 4 doses -> animal 1  (Max)
--   • 3 doses -> animais 3 (N'weti), 5 (Kanimambo), 10 (Nala), 17 (Duque)
--   • 2 doses -> animais 2, 6, 9, 11, 13, 14, 15 e 20
--   • 1 dose  -> animais 4 (Mia), 7 (Xiluva) e 19 (Nhlamvu)
--   • 0 doses -> animais 8, 12, 16 e 18 (coelho, ave, tartaruga e hamster:
--                exóticos que não seguem o plano vacinal de cães e gatos)
--
-- Coerência garantida nos dados:
--   • data_aplicacao é sempre posterior a data_nascimento do animal;
--   • data_aplicacao é sempre posterior a data_contratacao do veterinário;
--   • as doses administradas durante uma consulta coincidem com a data, o lote
--     e o veterinário dessa mesma consulta (consultas 1, 13 e 15).
-- -------------------------------------------------------------------------
INSERT INTO VACINACAO (id_animal, numero_dose, data_aplicacao, vacina, lote, id_veterinario) VALUES
(1,  1, '2020-07-20', 'Vacina Polivalente Canina (V8)', 'VC8-2020/114', 1),
(1,  2, '2020-08-17', 'Vacina Polivalente Canina (V8)', 'VC8-2020/114', 1),
(1,  3, '2020-09-14', 'Vacina Antirrábica',             'VA-2020/087',  1),
(1,  4, '2026-01-15', 'Vacina Polivalente Canina (V8)', 'VC8-2026/014', 1),
(2,  1, '2021-10-04', 'Vacina Tríplice Felina',         'VTF-2021/203', 6),
(2,  2, '2021-11-01', 'Vacina Tríplice Felina',         'VTF-2021/203', 6),
(3,  1, '2020-01-13', 'Vacina Polivalente Canina (V8)', 'VC8-2019/441', 1),
(3,  2, '2020-02-10', 'Vacina Polivalente Canina (V8)', 'VC8-2019/441', 1),
(3,  3, '2020-03-09', 'Vacina Antirrábica',             'VA-2020/012',  1),
(4,  1, '2022-04-11', 'Vacina Tríplice Felina',         'VTF-2022/088', 6),
(5,  1, '2018-09-03', 'Vacina Polivalente Canina (V8)', 'VC8-2018/220', 1),
(5,  2, '2018-10-01', 'Vacina Polivalente Canina (V8)', 'VC8-2018/220', 1),
(5,  3, '2018-11-05', 'Vacina Antirrábica',             'VA-2018/150',  5),
(6,  1, '2021-06-14', 'Vacina Polivalente Canina (V8)', 'VC8-2021/077', 4),
(6,  2, '2021-07-12', 'Vacina Antirrábica',             'VA-2021/064',  4),
(7,  1, '2020-11-19', 'Vacina Tríplice Felina',         'VTF-2020/311', 6),
(9,  1, '2019-06-05', 'Vacina Antirrábica',             'VA-2019/098',  1),
(9,  2, '2020-06-10', 'Vacina Antirrábica',             'VA-2020/045',  1),
(10, 1, '2022-02-08', 'Vacina Tríplice Felina',         'VTF-2022/019', 6),
(10, 2, '2022-03-08', 'Vacina Tríplice Felina',         'VTF-2022/019', 6),
(10, 3, '2023-02-14', 'Vacina Tríplice Felina',         'VTF-2023/006', 12),
(11, 1, '2020-03-16', 'Vacina Polivalente Canina (V8)', 'VC8-2020/032', 2),
(11, 2, '2020-04-13', 'Vacina Antirrábica',             'VA-2020/021',  2),
(13, 1, '2022-08-22', 'Vacina Polivalente Canina (V8)', 'VC8-2022/188', 1),
(13, 2, '2026-07-08', 'Vacina Antirrábica',             'VA-2026/071',  11),
(14, 1, '2021-03-11', 'Vacina Polivalente Canina (V8)', 'VC8-2021/040', 3),
(14, 2, '2021-04-08', 'Vacina Contra a Tosse do Canil', 'VTC-2021/055', 3),
(15, 1, '2023-07-05', 'Vacina Tríplice Felina',         'VTF-2023/141', 6),
(15, 2, '2026-09-10', 'Vacina Tríplice Felina',         'VTF-2026/119', 6),
(17, 1, '2019-08-19', 'Vacina Polivalente Canina (V8)', 'VC8-2019/266', 1),
(17, 2, '2019-09-16', 'Vacina Polivalente Canina (V8)', 'VC8-2019/266', 1),
(17, 3, '2019-10-14', 'Vacina Antirrábica',             'VA-2019/177',  1),
(19, 1, '2026-01-19', 'Vacina Tríplice Felina',         'VTF-2026/003', 6),
(20, 1, '2025-11-03', 'Vacina Polivalente Canina (V8)', 'VC8-2025/402', 11),
(20, 2, '2025-12-01', 'Vacina Polivalente Canina (V8)', 'VC8-2025/402', 11);

-- -------------------------------------------------------------------------
-- Inserção na tabela UTILIZADOR (22 registos: IDs 1 a 22)
--
-- Distribuição por perfil (respeita a restrição ck_utilizador_vinculo):
--   • IDs 1 a 3   -> 'Administrador' : id_dono e id_veterinario ambos NULOS
--   • IDs 4 a 15  -> 'Veterinario'   : id_veterinario preenchido (1 a 12),
--                                      id_dono NULO
--   • IDs 16 a 22 -> 'Dono'          : id_dono preenchido (1, 2, 3, 11, 12, 16
--                                      e 20), id_veterinario NULO
--
-- Contas desativadas (ativo = 0): IDs 3, 11 e 20.
-- Conta que nunca iniciou sessão (ultimo_login = NULL): ID 22.
--
-- SEGURANÇA: os valores de password_hash abaixo são FICTÍCIOS — texto inventado
-- com o formato visual de um hash bcrypt de 60 caracteres ($2b$12$ + salt de 22
-- + hash de 31). Não correspondem a nenhuma palavra-passe real e não devem ser
-- usados como exemplo de credencial.
-- -------------------------------------------------------------------------
INSERT INTO UTILIZADOR (email, password_hash, perfil, id_dono, id_veterinario, ativo, ultimo_login) VALUES
('admin.geral@clinicavet.co.mz',      '$2b$12$TKwgEDEaqhzyNnytoB5aoVsS8hhss6inCQmw31l26fqXAhjVmMyam', 'Administrador', NULL, NULL, 1, '2026-10-22 07:41:12'),
('rececao.maputo@clinicavet.co.mz',   '$2b$12$jXC.9jhUfWa9eEduMVfN7bpdLgfbXJ3c6RzO.JGOYTTwtt7L5tbe6', 'Administrador', NULL, NULL, 1, '2026-10-21 17:05:44'),
('tesouraria@clinicavet.co.mz',       '$2b$12$IDp.3st9Fc3VlxZRhOnzbITW6ictC.zZimA8EsZ2VxXQNggm6C8qh', 'Administrador', NULL, NULL, 0, '2026-09-30 11:22:03'),
('e.chissale@clinicavet.co.mz',       '$2b$12$Kw992UYPhCrCX6iZlxlj7fDNuRGwJSfhIENqKTTiqt2xN5OXzzezp', 'Veterinario',   NULL, 1,    1, '2026-10-22 07:55:30'),
('l.amaral@clinicavet.co.mz',         '$2b$12$SWT9SqRzG9lUp//cLLpQJa3WIeMosrsmhSJnHLwAXcUnTf6MvPTVg', 'Veterinario',   NULL, 2,    1, '2026-10-21 16:12:09'),
('h.bila@clinicavet.co.mz',           '$2b$12$QU9gnSsHUUFRleDJAlNhCYlhQupaD70ahgOQ0TvJDK50NvWG9fpau', 'Veterinario',   NULL, 3,    1, '2026-10-20 08:47:51'),
('m.guambe@clinicavet.co.mz',         '$2b$12$iPCpgf8dNKdzVHlw6s5wWOroxjtBhYeNvuvglFU9leuBZHYyEBrxK', 'Veterinario',   NULL, 4,    1, '2026-10-22 08:03:17'),
('r.machava@clinicavet.co.mz',        '$2b$12$bg2Ir6zOKRuhlXHz/6q9rMs.lP9U0OSDRlCCy2XaflpZPEIkEosNe', 'Veterinario',   NULL, 5,    1, '2026-10-19 14:26:38'),
('v.tembe@clinicavet.co.mz',          '$2b$12$LJvFZJX.ucvqIDITZFgE0.FbvIY3nXCZY72Co5fzjVj/zG5eISJVA', 'Veterinario',   NULL, 6,    1, '2026-10-21 09:14:02'),
('a.bacar@clinicavet.co.mz',          '$2b$12$G7.rr0xKBvwNsmJ8VpoAuXnm/sMkbiTANEBhAxQFknjLLlzjkXnHl', 'Veterinario',   NULL, 7,    1, '2026-10-18 15:39:26'),
('s.nhaca@clinicavet.co.mz',          '$2b$12$NfyeG6hf9qIJ8iDc574WpIHZcsDH6MkCySFwkeSLX1CEdf/8EELEy', 'Veterinario',   NULL, 8,    0, '2026-08-04 10:08:55'),
('b.mondlane@clinicavet.co.mz',       '$2b$12$xyArrv/.ve0rmYaREz/Gh6qcl/fKelylItZhljRxha7i50u6Ie0Ow', 'Veterinario',   NULL, 9,    1, '2026-10-22 07:36:41'),
('r.matsinhe@clinicavet.co.mz',       '$2b$12$sID5JvFN9sdwUAbwnierFWsA5agT/OlCIxr89LcspvfiHbtwjH.j3', 'Veterinario',   NULL, 10,   1, '2026-10-20 13:52:10'),
('n.chirindza@clinicavet.co.mz',      '$2b$12$Db0BtCH9sYFsvZc6Xjc3Gy4OrwdnaWW/iTRnXvaZtm9eaygGWI3r9', 'Veterinario',   NULL, 11,   1, '2026-10-21 18:04:33'),
('j.cumbana@clinicavet.co.mz',        '$2b$12$0T2kmsR95izWTG1E3s9nE.5jG.f34X5FPbxph9y5QC8WCHXrJaiDN', 'Veterinario',   NULL, 12,   1, '2026-10-16 09:41:27'),
('amelia.sitoe@gmail.com',            '$2b$12$dmTTTX2AZFY2jwikr3q8zkGJBJzcOwzZt/QD3zq8Fsyj8zR6gunG0', 'Dono',          1,    NULL, 1, '2026-10-21 20:11:05'),
('celso.nhaca@outlook.com',           '$2b$12$aJdekmrbrcs1./hQpt6EmcfxgsyREFg8f35Bvvh8wILzDHwB8Q7xg', 'Dono',          2,    NULL, 1, '2026-10-14 08:29:47'),
('dercio.tembe@gmail.com',            '$2b$12$fNzSgjQE5yxaFOBvk.tOVErK71hAMvRQzKCgQgHW.0vV14G59Au3v', 'Dono',          3,    NULL, 1, '2026-10-19 19:03:22'),
('marta.machava@gmail.com',           '$2b$12$eS5MPm5Tn.kW90AqULhGVOWR0tPVrJzNxtANz79hB79Wy28QYsIfk', 'Dono',          11,   NULL, 1, '2026-10-22 06:48:15'),
('nadia.macuacua@padariabeira.co.mz', '$2b$12$ZjaD2P9NBqgq9d1gRqAsdewy1qwtT9hAYsDpj.CYP2ExeE8elK0mW', 'Dono',          12,   NULL, 0, '2026-07-11 12:35:40'),
('rogerio.faquir@outlook.com',        '$2b$12$Bj1qz1lLToF7KTmotjE6qY3Tze.0MpQul9nhk.MeT1M.Uwk/x2xDj', 'Dono',          16,   NULL, 1, '2026-10-20 21:17:58'),
('yolanda.mabunda@outlook.com',         '$2b$12$PQNrFLbH5Ej2ldvLBlVLBHrDMNuq8tE3yebRs/yOItuVrOA7vJURj', 'Dono',          20,   NULL, 1, NULL);


-- =========================================================================
-- 3. VERIFICAÇÃO DOS MÍNIMOS (SECÇÃO OPCIONAL — pode ser ignorada/removida)
-- Confirma, logo após a criação, que cada uma das 8 tabelas tem 20 ou mais
-- registos e que as restrições CHECK e as chaves estrangeiras foram criadas.
-- Resultado esperado: DONO 21 | VETERINARIO 20 | TRATAMENTO 21 | ANIMAL 20 |
--                     CONSULTA 21 | CONSULTA_TRATAMENTO 22 | VACINACAO 35 |
--                     UTILIZADOR 22
-- =========================================================================
SELECT 'DONO'               AS tabela, COUNT(*) AS n_registos FROM DONO
UNION ALL SELECT 'VETERINARIO',         COUNT(*) FROM VETERINARIO
UNION ALL SELECT 'TRATAMENTO',          COUNT(*) FROM TRATAMENTO
UNION ALL SELECT 'ANIMAL',              COUNT(*) FROM ANIMAL
UNION ALL SELECT 'CONSULTA',            COUNT(*) FROM CONSULTA
UNION ALL SELECT 'CONSULTA_TRATAMENTO', COUNT(*) FROM CONSULTA_TRATAMENTO
UNION ALL SELECT 'VACINACAO',           COUNT(*) FROM VACINACAO
UNION ALL SELECT 'UTILIZADOR',          COUNT(*) FROM UTILIZADOR;

-- Confirma as 16 restrições CHECK criadas e nomeadas (MySQL 8.0.16+).
-- Resultado esperado: 16 linhas (uma por cada restrição CHECK nomeada).
SELECT tc.TABLE_NAME AS tabela, cc.CONSTRAINT_NAME AS restricao_check
FROM information_schema.CHECK_CONSTRAINTS cc
INNER JOIN information_schema.TABLE_CONSTRAINTS tc
        ON tc.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
       AND tc.CONSTRAINT_SCHEMA = cc.CONSTRAINT_SCHEMA
WHERE cc.CONSTRAINT_SCHEMA = 'clinica_vet'
  AND tc.CONSTRAINT_TYPE = 'CHECK'
ORDER BY tc.TABLE_NAME, cc.CONSTRAINT_NAME;

-- FIM DO FICHEIRO 01_criacao_e_insercao.sql
