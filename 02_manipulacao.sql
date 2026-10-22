-- =========================================================================
-- PROJETO DE TECNOLOGIAS DE BASE DE DADOS (2.º ANO — LICENCIATURA EM INFORMÁTICA)
-- UNIVERSIDADE LICUNGO — MOÇAMBIQUE
-- ESTUDANTE: Kevin Muerembe
-- TEMA: CLÍNICA VETERINÁRIA (clinica_vet)
-- FICHEIRO: 02_manipulacao.sql
-- SGBD: MySQL 8.0.16 ou superior (motor InnoDB)
-- DESCRIÇÃO: Script de manipulação de dados (3 SELECT simples com WHERE e
--            ORDER BY, 2 SELECT com JOIN, 2 UPDATE, 1 DELETE e 1 Teste de
--            Integridade Referencial).
-- PRÉ-REQUISITO: Executar previamente o ficheiro 01_criacao_e_insercao.sql.
-- DATA DE REFERÊNCIA DO EXERCÍCIO: 22 de outubro de 2026.
-- =========================================================================

USE clinica_vet;


-- =========================================================================
-- SECÇÃO 1 — CONSULTAS SIMPLES (3 COMANDOS SELECT COM WHERE E ORDER BY)
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 1: SELECT SIMPLES #1 — Cães com peso superior a 20 kg
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 6 linhas da tabela ANIMAL, ordenadas do cão mais
-- pesado para o mais leve:
--   1. id_animal = 3  | N'weti    | Boerboel                          | 45.80 kg
--   2. id_animal = 5  | Kanimambo | Rottweiler                        | 38.60 kg
--   3. id_animal = 11 | Thor      | Golden Retriever                  | 33.10 kg
--   4. id_animal = 1  | Max       | Pastor Alemão                     | 31.40 kg
--   5. id_animal = 17 | Duque     | Labrador Retriever                | 29.90 kg
--   6. id_animal = 9  | Bobi      | Rafeiro Comum (Sem Raça Definida) | 22.40 kg
-- EXPLICAÇÃO: Procura na tabela ANIMAL apenas os animais da espécie 'Cão' que
-- pesam mais de 20 kg (os outros 4 cães da base têm entre 9.60 kg e 14.20 kg,
-- por isso ficam de fora) e ordena o resultado do maior para o menor peso.
SELECT
    id_animal,
    nome,
    raca,
    sexo,
    peso_kg,
    data_nascimento
FROM ANIMAL
WHERE especie = 'Cão'
  AND peso_kg > 20.00
ORDER BY peso_kg DESC;


-- -------------------------------------------------------------------------
-- COMANDO 2: SELECT SIMPLES #2 — Veterinários com conta de login ativa
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 11 linhas da tabela UTILIZADOR, ordenadas do
-- login mais recente para o mais antigo: começa em id_utilizador = 7
-- ('m.guambe@clinicavet.co.mz', id_veterinario = 4, '2026-10-22 08:03:17') e
-- termina em id_utilizador = 15 ('j.cumbana@clinicavet.co.mz',
-- id_veterinario = 12, '2026-10-16 09:41:27'). A conta id_utilizador = 11
-- ('s.nhaca@clinicavet.co.mz') não aparece porque está desativada (ativo = 0).
-- EXPLICAÇÃO: Consulta a nova tabela UTILIZADOR para listar os médicos
-- veterinários com acesso ativo ao sistema web, ordenados pelo último acesso.
-- Por segurança, não seleciono a coluna password_hash na listagem.
SELECT
    id_utilizador,
    email,
    perfil,
    id_veterinario,
    ultimo_login
FROM UTILIZADOR
WHERE perfil = 'Veterinario'
  AND ativo = 1
ORDER BY ultimo_login DESC;


-- -------------------------------------------------------------------------
-- COMANDO 3: SELECT SIMPLES #3 — Consultas agendadas por ordem cronológica
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 4 linhas da tabela CONSULTA com estado 'Agendada',
-- da data mais antiga para a mais distante:
--   1. id_consulta = 18 | 2026-10-21 15:30:00 | 800.00 MZN  | animal 9  | vet 11
--   2. id_consulta = 19 | 2026-10-26 10:00:00 | 1200.00 MZN | animal 5  | vet 5
--   3. id_consulta = 20 | 2026-11-04 15:30:00 | 900.00 MZN  | animal 17 | vet 18
--   4. id_consulta = 21 | 2026-11-19 11:00:00 | 1100.00 MZN | animal 1  | vet 14
-- EXPLICAÇÃO: Mostra todas as consultas ainda marcadas como 'Agendada' por
-- ordem de data e hora. Logo na primeira linha vê-se que a consulta 18 tem
-- data de ontem (21-10-2026), ou seja, já decorreu e falta apenas fechar no
-- sistema — o que vou fazer mais abaixo no UPDATE #1.
SELECT
    id_consulta,
    data_hora,
    motivo,
    valor_consulta,
    id_animal,
    id_veterinario
FROM CONSULTA
WHERE estado = 'Agendada'
ORDER BY data_hora ASC;


-- =========================================================================
-- SECÇÃO 2 — CONSULTAS COM JUNÇÃO DE TABELAS (2 COMANDOS SELECT COM JOIN)
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 4: SELECT COM JOIN #1 — Boletim vacinal com animal e dono (3 tabelas)
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 35 linhas (todas as 35 doses registadas na
-- entidade fraca VACINACAO, distribuídas por 16 animais). Ordenado por animal
-- e número de dose, começa nas 4 doses do cão Max (id_animal = 1, doses 1 a 4,
-- dona Amélia Chirinza Sitoe, '+258 84 217 5590') e termina na dose 2 do cão
-- Tintswalo (id_animal = 20, dose 2 em 2025-12-01, dono Dércio Loforte Tembe).
-- Os 4 animais exóticos sem vacinas (IDs 8, 12, 16 e 18) não aparecem.
-- EXPLICAÇÃO: Junta a entidade fraca VACINACAO com ANIMAL e DONO usando INNER
-- JOIN. Como VACINACAO depende de ANIMAL e a sua chave primária é composta por
-- (id_animal, numero_dose), este JOIN permite ver a quem pertence cada dose
-- (1, 2, 3...) e o contacto do dono, excluindo animais sem doses aplicadas.
SELECT
    v.id_animal,
    v.numero_dose,
    v.data_aplicacao,
    v.vacina,
    v.lote,
    a.nome AS nome_animal,
    a.especie,
    d.nome AS nome_dono,
    d.telefone AS telefone_dono
FROM VACINACAO AS v
INNER JOIN ANIMAL AS a
    ON v.id_animal = a.id_animal
INNER JOIN DONO AS d
    ON a.id_dono = d.id_dono
ORDER BY v.id_animal ASC, v.numero_dose ASC;


-- -------------------------------------------------------------------------
-- COMANDO 5: SELECT COM JOIN #2 — Histórico completo de consultas (4 tabelas)
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 21 linhas (todas as 21 consultas da base), da
-- data mais distante para a mais antiga: começa na consulta 21 ('2026-11-19
-- 11:00:00', 'Agendada', cão Max, dona Amélia Chirinza Sitoe, Dra. Filipa
-- Alexandra Zucula, 1100.00 MZN) e termina na consulta 1 ('2026-01-15
-- 09:30:00', 'Concluída', cão Max, Dr. Edson Macuácua Chissale, 800.00 MZN).
-- EXPLICAÇÃO: Liga 4 tabelas (CONSULTA, ANIMAL, DONO e VETERINARIO) pelas suas
-- chaves estrangeiras para juntar numa única listagem a data, o estado, o
-- animal, os dados de contacto do dono e o médico responsável pela consulta.
SELECT
    c.id_consulta,
    c.data_hora,
    c.estado,
    a.nome AS nome_animal,
    a.especie,
    d.nome AS nome_dono,
    d.telefone AS telefone_dono,
    v.nome AS nome_veterinario,
    v.especialidade,
    c.valor_consulta
FROM CONSULTA AS c
INNER JOIN ANIMAL AS a
    ON c.id_animal = a.id_animal
INNER JOIN DONO AS d
    ON a.id_dono = d.id_dono
INNER JOIN VETERINARIO AS v
    ON c.id_veterinario = v.id_veterinario
ORDER BY c.data_hora DESC;


-- =========================================================================
-- SECÇÃO 3 — ATUALIZAÇÃO DE DADOS (2 COMANDOS UPDATE)
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 6: UPDATE #1 — Concluir consulta cuja data já passou
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: 1 linha alterada (1 row affected). A consulta com
-- id_consulta = 18 (de ontem, 2026-10-21 15:30:00, do cão Bobi) muda do estado
-- 'Agendada' para 'Concluída' e fica com o diagnóstico registado. As outras 3
-- consultas futuras (IDs 19, 20 e 21) continuam 'Agendada'.
-- EXPLICAÇÃO: Como hoje é 22-10-2026, a consulta 18 de 21-10-2026 já aconteceu
-- e faltava apenas registar o fecho clínico. Uso WHERE pela chave primária
-- (id_consulta = 18) para alterar só essa linha e funcionar com o modo
-- "Safe Updates" ligado no MySQL Workbench.
UPDATE CONSULTA
SET estado = 'Concluída',
    diagnostico = 'Recuperação completa da entorse do joelho direito, sem dor nem claudicação; peso estável.'
WHERE id_consulta = 18;


-- -------------------------------------------------------------------------
-- COMANDO 7: UPDATE #2 — Atualizar preço base de um tratamento no catálogo
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: 1 linha alterada (1 row affected). Na tabela TRATAMENTO,
-- o registo com id_tratamento = 1 ('Vacina Polivalente Canina (V8)') passa de
-- preco_base = 1200.00 MZN para 1350.00 MZN. Na tabela CONSULTA_TRATAMENTO, a
-- consulta 1 mantém o preco_aplicado antigo de 1200.00 MZN sem alterações.
-- EXPLICAÇÃO: Atualiza apenas o preço de tabela atual de um tratamento usando
-- a chave primária (WHERE id_tratamento = 1). As consultas antigas não mudam
-- de valor porque o preço cobrado na altura ficou guardado em preco_aplicado
-- na tabela CONSULTA_TRATAMENTO, preservando o histórico de faturação.
UPDATE TRATAMENTO
SET preco_base = 1350.00
WHERE id_tratamento = 1;


-- =========================================================================
-- SECÇÃO 4 — ELIMINAÇÃO DE DADOS (1 COMANDO DELETE RESPEITANDO AS FKs)
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 8: DELETE — Eliminar um tratamento sem consultas associadas
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: 1 linha eliminada (1 row affected). O tratamento com
-- id_tratamento = 21 ('Sessão de Fisioterapia e Acupuntura Veterinária',
-- 2000.00 MZN) é removido da tabela TRATAMENTO, que passa de 21 para 20 linhas.
-- EXPLICAÇÃO: Apaga um tratamento pela sua chave primária (WHERE
-- id_tratamento = 21). Não viola nenhuma chave estrangeira porque a única FK
-- que aponta para TRATAMENTO é fk_ct_tratamento na tabela CONSULTA_TRATAMENTO
-- (com ON DELETE RESTRICT) e o tratamento 21 nunca foi usado em nenhuma
-- consulta, logo não existem linhas filhas dependentes dele.
DELETE FROM TRATAMENTO
WHERE id_tratamento = 21;


-- =========================================================================
-- SECÇÃO 5 — TESTE DE INTEGRIDADE REFERENCIAL (1 INSERT COM FK INEXISTENTE)
-- Nota: Este comando fica propositadamente no fim do ficheiro porque o seu
--       objetivo é mostrar o erro de chave estrangeira no MySQL (os comandos
--       1 a 8 acima executam todos sem erros).
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 9: TESTE DE INTEGRIDADE — Inserir consulta com id_animal = 999
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: 0 linhas inseridas. O MySQL rejeita o comando com o erro:
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint
-- fails (`clinica_vet`.`CONSULTA`, CONSTRAINT `fk_consulta_animal` FOREIGN KEY
-- (`id_animal`) REFERENCES `ANIMAL` (`id_animal`) ON DELETE RESTRICT ON UPDATE CASCADE).
-- EXPLICAÇÃO: Tento inserir uma consulta para o id_animal = 999, mas na tabela
-- ANIMAL só existem animais com IDs de 1 a 20. A chave estrangeira
-- fk_consulta_animal impede gravar uma consulta para um animal que não existe,
-- garantindo que nunca ficam consultas órfãs na base de dados.
INSERT INTO CONSULTA (data_hora, motivo, diagnostico, estado, valor_consulta, id_animal, id_veterinario)
VALUES ('2026-11-25 10:00:00', 'Consulta de teste de integridade referencial', NULL, 'Agendada', 800.00, 999, 1);
