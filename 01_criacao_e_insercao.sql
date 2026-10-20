-- =========================================================================
-- PROJETO DE TECNOLOGIAS DE BASE DE DADOS (2.º ANO — LICENCIATURA EM INFORMÁTICA)
-- TEMA: CLÍNICA VETERINÁRIA (clinica_vet)
-- FICHEIRO: 01_criacao_e_insercao.sql
-- SGBD: MySQL 8.0+
-- DESCRIÇÃO: Criação de raiz da base de dados, das 6 tabelas com restrições
--            de integridade e inserção de exatamente 20 registos por tabela.
-- =========================================================================

-- Remover a base de dados caso já exista, garantindo execução limpa de raiz
DROP DATABASE IF EXISTS clinica_vet;

-- Criar a base de dados com suporte completo a caracteres portugueses (UTF-8)
CREATE DATABASE clinica_vet
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Selecionar a base de dados criada
USE clinica_vet;

-- =========================================================================
-- 1. CRIAÇÃO DAS TABELAS (ORDEM RESPEITANDO AS CHAVES ESTRANGEIRAS)
-- Ordem: DONO -> VETERINARIO -> TRATAMENTO -> ANIMAL -> CONSULTA -> CONSULTA_TRATAMENTO
-- =========================================================================

-- -------------------------------------------------------------------------
-- Tabela 1: DONO
-- Armazena os dados pessoais e de contacto dos proprietários dos animais.
-- -------------------------------------------------------------------------
CREATE TABLE DONO (
    id_dono INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    nif VARCHAR(9) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    morada VARCHAR(150) NOT NULL,
    data_registo DATE NOT NULL,
    CONSTRAINT pk_dono PRIMARY KEY (id_dono),
    CONSTRAINT uq_dono_nif UNIQUE (nif),
    CONSTRAINT uq_dono_email UNIQUE (email)
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 2: VETERINARIO
-- Armazena os médicos veterinários da clínica, cédula da OMV e especialidade.
-- -------------------------------------------------------------------------
CREATE TABLE VETERINARIO (
    id_veterinario INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    nif VARCHAR(9) NOT NULL,
    cedula_profissional VARCHAR(15) NOT NULL,
    especialidade VARCHAR(60) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    data_contratacao DATE NOT NULL,
    CONSTRAINT pk_veterinario PRIMARY KEY (id_veterinario),
    CONSTRAINT uq_veterinario_nif UNIQUE (nif),
    CONSTRAINT uq_veterinario_cedula UNIQUE (cedula_profissional),
    CONSTRAINT uq_veterinario_email UNIQUE (email)
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 3: TRATAMENTO
-- Catálogo de atos médicos, vacinas, exames e cirurgias disponíveis.
-- -------------------------------------------------------------------------
CREATE TABLE TRATAMENTO (
    id_tratamento INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    preco_base DECIMAL(8,2) NOT NULL,
    duracao_minutos INT NOT NULL,
    CONSTRAINT pk_tratamento PRIMARY KEY (id_tratamento),
    CONSTRAINT uq_tratamento_nome UNIQUE (nome)
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 4: ANIMAL
-- Regista cada animal de companhia associado obrigatoriamente a um DONO.
-- ON DELETE RESTRICT impede eliminar um dono que ainda tenha animais registados.
-- -------------------------------------------------------------------------
CREATE TABLE ANIMAL (
    id_animal INT AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    especie VARCHAR(40) NOT NULL,
    raca VARCHAR(60) NOT NULL,
    sexo VARCHAR(10) NOT NULL,
    data_nascimento DATE NOT NULL,
    peso_kg DECIMAL(8,2) NOT NULL,
    microchip VARCHAR(15),
    id_dono INT NOT NULL,
    CONSTRAINT pk_animal PRIMARY KEY (id_animal),
    CONSTRAINT uq_animal_microchip UNIQUE (microchip),
    CONSTRAINT fk_animal_dono FOREIGN KEY (id_dono)
        REFERENCES DONO (id_dono)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------------------------------
-- Tabela 5: CONSULTA
-- Regista os atendimentos clínicos realizados por um VETERINARIO a um ANIMAL.
-- ON DELETE RESTRICT preserva o histórico clínico de animais e veterinários.
-- -------------------------------------------------------------------------
CREATE TABLE CONSULTA (
    id_consulta INT AUTO_INCREMENT,
    data_hora DATETIME NOT NULL,
    motivo VARCHAR(150) NOT NULL,
    diagnostico TEXT,
    estado VARCHAR(20) NOT NULL,
    valor_consulta DECIMAL(8,2) NOT NULL,
    id_animal INT NOT NULL,
    id_veterinario INT NOT NULL,
    CONSTRAINT pk_consulta PRIMARY KEY (id_consulta),
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
-- Tabela 6: CONSULTA_TRATAMENTO (Entidade Fraca / Associativa)
-- Decompõe a relação N:N entre CONSULTA e TRATAMENTO.
-- ON DELETE CASCADE em id_consulta: se a consulta for removida, os seus itens
-- deixam de existir; ON DELETE RESTRICT em id_tratamento: impede apagar do
-- catálogo um tratamento que já tenha sido aplicado em consultas.
-- -------------------------------------------------------------------------
CREATE TABLE CONSULTA_TRATAMENTO (
    id_consulta INT NOT NULL,
    id_tratamento INT NOT NULL,
    quantidade INT NOT NULL,
    preco_aplicado DECIMAL(8,2) NOT NULL,
    observacoes TEXT,
    CONSTRAINT pk_consulta_tratamento PRIMARY KEY (id_consulta, id_tratamento),
    CONSTRAINT fk_ct_consulta FOREIGN KEY (id_consulta)
        REFERENCES CONSULTA (id_consulta)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_ct_tratamento FOREIGN KEY (id_tratamento)
        REFERENCES TRATAMENTO (id_tratamento)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;


-- =========================================================================
-- 2. INSERÇÃO DE DADOS (EXATAMENTE 20 REGISTOS EM CADA TABELA)
-- Ordem das inserções: DONO -> VETERINARIO -> TRATAMENTO -> ANIMAL ->
--                      CONSULTA -> CONSULTA_TRATAMENTO
-- =========================================================================

-- -------------------------------------------------------------------------
-- Inserção na tabela DONO (20 registos: IDs 1 a 20)
-- Nota: Os donos 19 e 20 foram registados recentemente e ainda não têm animais,
--       ilustrando a participação parcial de DONO na relação com ANIMAL.
-- -------------------------------------------------------------------------
INSERT INTO DONO (nome, nif, telefone, email, morada, data_registo) VALUES
('António Manuel Ferreira', '214589632', '912345601', 'antonio.ferreira@email.pt', 'Rua de Santa Catarina, 145, 4000-450 Porto', '2023-02-14'),
('Maria João Albuquerque', '228945107', '963451202', 'maria.albuquerque@email.pt', 'Avenida da Liberdade, 88, 3.º Esq., 1250-145 Lisboa', '2023-03-21'),
('Carlos Eduardo Ribeiro', '231078459', '934567803', 'carlos.ribeiro@email.pt', 'Rua Ferreira Borges, 52, 3000-179 Coimbra', '2023-05-09'),
('Ana Sofia Carvalho', '245612389', '918765404', 'ana.carvalho@email.pt', 'Avenida Central, 110, 4710-229 Braga', '2023-06-18'),
('João Pedro Gonçalves', '253498712', '926543205', 'joao.goncalves@email.pt', 'Rua Direita, 34, 3800-149 Aveiro', '2023-08-03'),
('Inês Filipa Rodrigues', '261834590', '915432106', 'ines.rodrigues@email.pt', 'Rua de Santo António, 67, 8000-283 Faro', '2023-09-15'),
('Miguel Ângelo Martins', '219753486', '967890107', 'miguel.martins@email.pt', 'Avenida Luísa Todi, 212, 2900-452 Setúbal', '2023-11-02'),
('Beatriz Helena Sousa', '274169823', '938901208', 'beatriz.sousa@email.pt', 'Rua Formosa, 79, 3500-135 Viseu', '2024-01-12'),
('Rui Filipe Almeida', '238520147', '914321909', 'rui.almeida@email.pt', 'Praça do Giraldo, 19, 7000-508 Évora', '2024-02-25'),
('Catarina Isabel Mendes', '282641795', '929876510', 'catarina.mendes@email.pt', 'Avenida Heróis de Angola, 95, 2400-153 Leiria', '2024-04-08'),
('Tiago André Moreira', '247913680', '916789011', 'tiago.moreira@email.pt', 'Toural de São Pedro, 41, 4810-427 Guimarães', '2024-05-19'),
('Sofia Margarida Costa', '259307418', '964567812', 'sofia.costa@email.pt', 'Volta do Duche, 14, 2710-631 Sintra', '2024-07-04'),
('Diogo Nuno Pereira', '268452913', '931234513', 'diogo.pereira@email.pt', 'Avenida 25 de Abril, 53, 2750-515 Cascais', '2024-08-29'),
('Mariana Raquel Pinto', '213987654', '917654314', 'mariana.pinto@email.pt', 'Rua Brito Capelo, 302, 4450-073 Matosinhos', '2024-10-11'),
('Paulo Alexandre Teixeira', '276543219', '924321015', 'paulo.teixeira@email.pt', 'Avenida Dom Nuno Álvares Pereira, 76, 2800-178 Almada', '2025-01-17'),
('Cláudia Susana Lopes', '234876519', '919087616', 'claudia.lopes@email.pt', 'Rua Dr. Fernão de Ornelas, 28, 9050-021 Funchal', '2025-03-06'),
('Gonçalo Vasco Oliveira', '289123456', '962109817', 'goncalo.oliveira@email.pt', 'Rua Serpa Pinto, 84, 2000-046 Santarém', '2025-06-22'),
('Helena Teresa Nogueira', '241678905', '935678918', 'helena.nogueira@email.pt', 'Alameda da Liberdade, 37, 6000-073 Castelo Branco', '2025-09-30'),
('Vítor Hugo Henriques', '257890341', '913456719', 'vitor.henriques@email.pt', 'Avenida dos Combatentes, 129, 4900-563 Viana do Castelo', '2026-09-14'),
('Patrícia Alexandra Tavares', '264319875', '928765420', 'patricia.tavares@email.pt', 'Avenida Carvalho Araújo, 61, 5000-657 Vila Real', '2026-10-05');

-- -------------------------------------------------------------------------
-- Inserção na tabela VETERINARIO (20 registos: IDs 1 a 20)
-- Nota: Os veterinários 19 e 20 foram contratados recentemente e ainda não
--       realizaram consultas (participação parcial em CONSULTA).
-- -------------------------------------------------------------------------
INSERT INTO VETERINARIO (nome, nif, cedula_profissional, especialidade, telefone, email, data_contratacao) VALUES
('Dr. Fernando José Magalhães', '201345678', 'OMV-3104', 'Clínica Geral', '911223301', 'f.magalhaes@clinicavet.pt', '2020-03-02'),
('Dra. Lúcia Maria Azevedo', '202456789', 'OMV-3428', 'Cirurgia de Tecidos Moles', '911223302', 'l.azevedo@clinicavet.pt', '2020-07-15'),
('Dr. Henrique Duarte Barros', '203567891', 'OMV-3789', 'Ortopedia e Traumatologia', '911223303', 'h.barros@clinicavet.pt', '2021-01-11'),
('Dra. Marta Isabel Figueiredo', '204678912', 'OMV-4015', 'Dermatologia Veterinária', '911223304', 'm.figueiredo@clinicavet.pt', '2021-05-24'),
('Dr. Ricardo Jorge Monteiro', '205789123', 'OMV-4290', 'Cardiologia Veterinária', '911223305', 'r.monteiro@clinicavet.pt', '2021-09-06'),
('Dra. Vera Lúcia Antunes', '206891234', 'OMV-4512', 'Medicina Felina', '911223306', 'v.antunes@clinicavet.pt', '2022-02-14'),
('Dr. André Filipe Baptista', '207912345', 'OMV-4788', 'Animais Exóticos', '911223307', 'a.baptista@clinicavet.pt', '2022-06-01'),
('Dra. Sara Cristina Peixoto', '208123456', 'OMV-5021', 'Oftalmologia Veterinária', '911223308', 's.peixoto@clinicavet.pt', '2022-10-17'),
('Dr. Bruno Alexandre Cunha', '209234567', 'OMV-5314', 'Estomatologia Veterinária', '911223309', 'b.cunha@clinicavet.pt', '2023-01-09'),
('Dra. Rita Sofia Guerreiro', '210345679', 'OMV-5580', 'Imagiologia e Ecografia', '911223310', 'r.guerreiro@clinicavet.pt', '2023-04-03'),
('Dr. Nuno Miguel Valente', '211456780', 'OMV-5803', 'Clínica Geral', '911223311', 'n.valente@clinicavet.pt', '2023-09-11'),
('Dra. Joana Patrícia Correia', '212567892', 'OMV-6049', 'Medicina Interna', '911223312', 'j.correia@clinicavet.pt', '2024-01-15'),
('Dr. Pedro Afonso Lourenço', '215678903', 'OMV-6295', 'Neurologia Veterinária', '911223313', 'p.lourenco@clinicavet.pt', '2024-04-22'),
('Dra. Filipa Alexandra Simões', '216789014', 'OMV-6510', 'Oncologia Veterinária', '911223314', 'f.simoes@clinicavet.pt', '2024-08-05'),
('Dr. Tomás Guilherme Neves', '217890125', 'OMV-6742', 'Urgências e Cuidados Intensivos', '911223315', 't.neves@clinicavet.pt', '2025-01-06'),
('Dra. Carolina Beatriz Morais', '218901236', 'OMV-6988', 'Reabilitação e Fisioterapia', '911223316', 'c.morais@clinicavet.pt', '2025-05-12'),
('Dr. Vasco Manuel Pacheco', '220123457', 'OMV-7145', 'Anestesiologia Veterinária', '911223317', 'v.pacheco@clinicavet.pt', '2025-09-01'),
('Dra. Mafalda Inês Fonseca', '221234568', 'OMV-7390', 'Clínica Geral', '911223318', 'm.fonseca@clinicavet.pt', '2026-01-12'),
('Dr. Lourenço Dinis Raposo', '222345679', 'OMV-7612', 'Nutrição Clínica', '911223319', 'l.raposo@clinicavet.pt', '2026-09-21'),
('Dra. Matilde Leonor Amaral', '223456781', 'OMV-7854', 'Comportamento Animal', '911223320', 'm.amaral@clinicavet.pt', '2026-10-01');

-- -------------------------------------------------------------------------
-- Inserção na tabela TRATAMENTO (20 registos: IDs 1 a 20)
-- Nota: Os tratamentos 19 e 20 ainda não foram aplicados em nenhuma consulta,
--       permitindo testar a eliminação segura (DELETE) sem violar FKs.
-- -------------------------------------------------------------------------
INSERT INTO TRATAMENTO (nome, categoria, descricao, preco_base, duracao_minutos) VALUES
('Vacina Polivalente Canina', 'Vacinação', 'Imunização anual contra esgana, parvovirose, hepatite infeciosa, leptospirose e parainfluenza.', 38.00, 20),
('Vacina Antirrábica', 'Vacinação', 'Vacinação obrigatória contra o vírus da raiva com registo no boletim sanitário e SIAC.', 28.00, 15),
('Vacina Tríplice Felina', 'Vacinação', 'Proteção contra panleucopenia, rinotraqueíte viral felina e calicivirose.', 36.00, 20),
('Desparasitação Interna Completa', 'Preventivo', 'Administração oral de antiparasitário de largo espetro ajustado ao peso corporal.', 16.50, 15),
('Desparasitação Externa Spot-On', 'Preventivo', 'Aplicação tópica mensal contra pulgas, carraças, flebótomos e mosquitos.', 22.00, 15),
('Colocação de Microchip e Registo SIAC', 'Identificação', 'Implantação subcutânea de transponder ISO 11784/11785 e registo oficial no SIAC.', 35.00, 20),
('Hemograma e Bioquímica Sanguínea', 'Diagnóstico', 'Colheita de sangue venoso e análise laboratorial completa de função renal e hepática.', 65.00, 30),
('Ecografia Abdominal', 'Diagnóstico', 'Exame ecográfico detalhado aos órgãos abdominais com relatório imagiológico.', 75.00, 40),
('Radiografia Digital Torácica', 'Diagnóstico', 'Estudo radiográfico em duas projeções para avaliação pulmonar e silhueta cardíaca.', 58.00, 30),
('Ecocardiograma com Doppler', 'Diagnóstico', 'Avaliação morfológica e funcional das válvulas e câmaras cardíacas com Doppler a cores.', 95.00, 45),
('Destartarização e Polimento Dentário', 'Estomatologia', 'Remoção de tártaro por ultrassons e polimento dentário sob sedação monitorizada.', 120.00, 60),
('Esterilização Felina (Ovariohisterectomia)', 'Cirurgia', 'Intervenção cirúrgica eletiva em gata sob anestesia geral inalatória e analgesia multimodal.', 145.00, 75),
('Orquiectomia Canina', 'Cirurgia', 'Castração cirúrgica eletiva de cão macho com monitorização multiparamétrica.', 135.00, 60),
('Citologia Dermatológica e Raspagem', 'Dermatologia', 'Colheita e observação microscópica para pesquisa de ácaros, fungos, bactérias e leveduras.', 34.00, 25),
('Limpeza Auricular e Terapia Otite', 'Dermatologia', 'Lavagem vídeo-otoscópica do canal auditivo externo e aplicação tópica anti-inflamatória.', 29.00, 25),
('Teste de Fluoresceína Ocular', 'Oftalmologia', 'Avaliação da integridade corneana para deteção precoce de úlceras de córnea.', 26.00, 20),
('Fluidoterapia Endovenosa (Sessão)', 'Urgência', 'Reposição hidroeletrolítica endovenosa com bomba de infusão contínua.', 48.00, 90),
('Corte Técnico de Bico e Unhas (Exóticos)', 'Exóticos', 'Aparagem clínica segura de bico ou unhas em aves, coelhos e pequenos mamíferos.', 24.00, 20),
('Sessão de Acupuntura Veterinária', 'Reabilitação', 'Estimulação de pontos neuro-reativos para controlo de dor crónica osteoarticular.', 52.00, 45),
('Crioterapia Dermatológica Localizada', 'Dermatologia', 'Remoção criocirúrgica não invasiva de pequenas lesões cutâneas benignas.', 85.00, 35);

-- -------------------------------------------------------------------------
-- Inserção na tabela ANIMAL (20 registos: IDs 1 a 20)
-- Nota: Os donos 1 e 3 possuem 2 animais cada; os animais 19 e 20 foram
--       registados recentemente e ainda não realizaram consultas.
-- -------------------------------------------------------------------------
INSERT INTO ANIMAL (nome, especie, raca, sexo, data_nascimento, peso_kg, microchip, id_dono) VALUES
('Max', 'Cão', 'Labrador Retriever', 'Macho', '2020-05-14', 31.40, '620098100000001', 1),
('Luna', 'Gato', 'Europeu Comum', 'Fêmea', '2021-08-22', 4.20, '620098100000002', 2),
('Tejo', 'Cão', 'Cão de Água Português', 'Macho', '2019-11-03', 23.80, '620098100000003', 3),
('Mia', 'Gato', 'Persa', 'Fêmea', '2022-02-17', 3.90, '620098100000004', 4),
('Rocky', 'Cão', 'Pastor Alemão', 'Macho', '2018-07-09', 36.50, '620098100000005', 5),
('Kika', 'Cão', 'Bulldog Francês', 'Fêmea', '2021-04-30', 11.80, '620098100000006', 6),
('Simba', 'Gato', 'Siamês', 'Macho', '2020-09-12', 4.85, '620098100000007', 7),
('Pantufa', 'Coelho', 'Coelho Anão Holandês', 'Fêmea', '2023-03-19', 1.35, NULL, 8),
('Bobi', 'Cão', 'Rafeiro Alentejano', 'Macho', '2019-03-28', 41.20, '620098100000009', 9),
('Nala', 'Gato', 'Bosques da Noruega', 'Fêmea', '2021-12-05', 5.60, '620098100000010', 10),
('Thor', 'Cão', 'Golden Retriever', 'Macho', '2020-01-25', 33.10, '620098100000011', 11),
('Pipoca', 'Ave', 'Caturra', 'Fêmea', '2022-10-10', 0.10, NULL, 12),
('Zéus', 'Cão', 'Beagle', 'Macho', '2022-06-14', 13.70, '620098100000013', 13),
('Amora', 'Cão', 'Cocker Spaniel Inglês', 'Fêmea', '2021-01-18', 14.20, '620098100000014', 14),
('Óscar', 'Gato', 'British Shorthair', 'Macho', '2023-05-02', 5.10, '620098100000015', 15),
('Estrela', 'Tartaruga', 'Tartaruga Corcunda do Mississipi', 'Fêmea', '2017-08-01', 1.15, NULL, 16),
('Duque', 'Cão', 'Boxer', 'Macho', '2019-06-21', 29.90, '620098100000017', 17),
('Bolacha', 'Hamster', 'Hamster Sírio', 'Macho', '2025-04-11', 0.14, NULL, 18),
('Íris', 'Gato', 'Europeu Comum', 'Fêmea', '2025-11-20', 3.40, '620098100000019', 1),
('Faisca', 'Cão', 'Podengo Português', 'Macho', '2025-09-08', 9.60, '620098100000020', 3);

-- -------------------------------------------------------------------------
-- Inserção na tabela CONSULTA (20 registos: IDs 1 a 20)
-- Consultas 1 a 16: Concluídas | Consultas 17 a 19: Agendadas | Consulta 20: Cancelada
-- -------------------------------------------------------------------------
INSERT INTO CONSULTA (data_hora, motivo, diagnostico, estado, valor_consulta, id_animal, id_veterinario) VALUES
('2026-02-10 09:30:00', 'Reforço vacinal anual e check-up geral', 'Animal saudável, condição corporal ideal e mucosas coradas.', 'Concluída', 35.00, 1, 1),
('2026-02-18 11:00:00', 'Esterilização eletiva pré-agendada', 'Ovariohisterectomia decorreu sem intercorrências; recuperação anestésica normal.', 'Concluída', 40.00, 2, 2),
('2026-03-05 15:00:00', 'Prurido intenso nas orelhas e abanar constante da cabeça', 'Otite externa eritematosa bilateral associada a sobrecrescimento de Malassezia.', 'Concluída', 42.00, 3, 4),
('2026-03-19 10:15:00', 'Lacrimejo persistente no olho direito', 'Úlcera corneana superficial sem perfuração confirmada por teste de fluoresceína.', 'Concluída', 45.00, 4, 8),
('2026-04-08 16:30:00', 'Intolerância ao exercício e tosse seca noturna', 'Insuficiência mitral ligeira detetada em ecocardiograma; iniciada monitorização.', 'Concluída', 50.00, 5, 5),
('2026-04-22 14:00:00', 'Vermelhidão interdigital e queda de pelo localizada', 'Dermatite alérgica de contacto sem presença de ectoparasitas.', 'Concluída', 42.00, 6, 4),
('2026-05-06 09:45:00', 'Mau hálito acentuado e acumulação visível de tártaro', 'Doença periodontal grau II; realizada destartarização completa.', 'Concluída', 38.00, 7, 9),
('2026-05-20 17:00:00', 'Crescimento excessivo das unhas e revisão dentária', 'Incisivos alinhados e unhas aparadas sem lesões podais.', 'Concluída', 36.00, 8, 7),
('2026-06-03 10:00:00', 'Claudicação do membro posterior direito após corrida', 'Entorse ligeira do joelho direito sem rutura de ligamento cruzado.', 'Concluída', 48.00, 9, 3),
('2026-06-17 11:30:00', 'Vómitos agudos e prostração há 24 horas', 'Gastroenterite aguda ligeira com desidratação de 5%; estabilizada com fluidoterapia.', 'Concluída', 55.00, 10, 15),
('2026-07-02 15:30:00', 'Castração eletiva e controlo pré-operatório', 'Análises pré-cirúrgicas normais e orquiectomia sem complicações.', 'Concluída', 40.00, 11, 2),
('2026-07-16 16:00:00', 'Crescimento excessivo do bico e avaliação de plumagem', 'Plumagem íntegra; efetuado desgaste corretivo do bico.', 'Concluída', 36.00, 12, 7),
('2026-08-05 09:15:00', 'Primeira identificação eletrónica e vacinação antirrábica', 'Animal clinicamente são; microchip implantado na região cervical esquerda.', 'Concluída', 35.00, 13, 11),
('2026-08-24 14:45:00', 'Perda de peso progressiva no último mês', 'Ligeira sobrecarga hepática em bioquímica; ajustada dieta hepatoprotetora.', 'Concluída', 45.00, 14, 12),
('2026-09-09 10:30:00', 'Vacinação anual felina e controlo de parasitas', 'Exame físico sem alterações; plano preventivo atualizado.', 'Concluída', 35.00, 15, 6),
('2026-09-25 11:15:00', 'Letargia sazonal e revisão nutricional da carapaça', 'Hipovitaminose A ligeira; prescrito ajuste de radiação UVB e suplementação.', 'Concluída', 38.00, 16, 7),
('2026-10-24 10:00:00', 'Reavaliação cardíaca semestral de rotina', NULL, 'Agendada', 50.00, 5, 5),
('2026-10-27 15:30:00', 'Avaliação dermatológica de seguimento', NULL, 'Agendada', 42.00, 17, 18),
('2026-11-03 11:00:00', 'Check-up geriátrico e rastreio oncológico', NULL, 'Agendada', 48.00, 1, 14),
('2026-10-12 16:30:00', 'Revisão de peso e controlo alimentar', NULL, 'Cancelada', 35.00, 18, 10);

-- -------------------------------------------------------------------------
-- Inserção na tabela CONSULTA_TRATAMENTO (20 registos: pares únicos PK composta)
-- Nota: Apenas os tratamentos 1 a 18 são referenciados aqui; os tratamentos
--       19 e 20 permanecem sem consultas associadas.
-- -------------------------------------------------------------------------
INSERT INTO CONSULTA_TRATAMENTO (id_consulta, id_tratamento, quantidade, preco_aplicado, observacoes) VALUES
(1, 1, 1, 38.00, 'Lote vacinal Canigen L4; sem reação local após 20 minutos.'),
(1, 4, 1, 16.50, 'Administrado comprimido mastigável para faixa 25-40 kg.'),
(2, 7, 1, 65.00, 'Perfil pré-anestésico dentro dos valores de referência.'),
(2, 12, 1, 145.00, 'Sutura intradérmica absorvível; colar isabelino durante 7 dias.'),
(3, 14, 1, 34.00, 'Citologia auricular positiva para leveduras do género Malassezia.'),
(3, 15, 1, 29.00, 'Aplicação inicial em consultório; manter gotas 1x/dia por 10 dias.'),
(4, 16, 1, 26.00, 'Captação focal positiva na região paraxial direita.'),
(5, 9, 1, 58.00, 'Índice cardio-vertebral de 10.9; campos pulmonares limpos.'),
(5, 10, 1, 95.00, 'Regurgitação mitral ligeira; reavaliar em 6 meses.'),
(6, 5, 2, 22.00, 'Duas pipetas fornecidas para protocolo mensal contínuo.'),
(7, 11, 1, 120.00, 'Polimento completo de ambas as arcadas sem necessidade de extrações.'),
(8, 18, 1, 24.00, 'Unhas aparadas acima do sabugo vascular; sem hemorragia.'),
(9, 9, 1, 58.00, 'Sem sinais radiográficos de fratura ou avulsão óssea.'),
(10, 8, 1, 75.00, 'Espessamento difuso ligeiro da parede gástrica sem corpo estranho.'),
(10, 17, 1, 48.00, 'Perfusão de lactato de Ringer a 15 ml/h durante 90 minutos.'),
(11, 13, 1, 135.00, 'Alta no próprio dia com prescrição anti-inflamatória oral por 5 dias.'),
(13, 6, 1, 35.00, 'Leitura do transponder confirmada antes e após implantação.'),
(13, 2, 1, 28.00, 'Primeira dose antirrábica registada com validade de 1 ano.'),
(14, 7, 1, 65.00, 'Aumento ligeiro de ALT/AST; repetir perfil hepático em 60 dias.'),
(15, 3, 1, 36.00, 'Reforço anual de vacina tríplice felina sem reações adversas.');
