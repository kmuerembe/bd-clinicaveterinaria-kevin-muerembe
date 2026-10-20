-- =========================================================================
-- PROJETO DE TECNOLOGIAS DE BASE DE DADOS (2.º ANO — LICENCIATURA EM INFORMÁTICA)
-- TEMA: CLÍNICA VETERINÁRIA (clinica_vet)
-- FICHEIRO: 02_manipulacao.sql
-- SGBD: MySQL 8.0+
-- DESCRIÇÃO: Script de manipulação de dados (SELECT simples, SELECT com JOIN,
--            UPDATE, DELETE e Teste de Integridade Referencial).
-- PRÉ-REQUISITO: Executar previamente o ficheiro 01_criacao_e_insercao.sql.
-- =========================================================================

USE clinica_vet;

-- =========================================================================
-- SECÇÃO 1 — CONSULTAS SIMPLES (3 COMANDOS SELECT COM WHERE E ORDER BY)
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 1: SELECT SIMPLES #1 — Cães com peso superior a 20 kg
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 6 registos da tabela ANIMAL correspondentes aos
-- cães com peso superior a 20.00 kg, ordenados do mais pesado para o mais leve:
-- Bobi (41.20 kg), Rocky (36.50 kg), Thor (33.10 kg), Max (31.40 kg),
-- Duque (29.90 kg) e Tejo (23.80 kg).
-- EXPLICAÇÃO: Filtra os registos da tabela ANIMAL pela espécie 'Cão' e por
-- peso superior a 20 kg através da cláusula WHERE, projetando apenas as colunas
-- relevantes e ordenando os resultados de forma decrescente por peso_kg.
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
-- COMANDO 2: SELECT SIMPLES #2 — Tratamentos com preço base igual ou superior a 50 €
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 9 registos da tabela TRATAMENTO cujo preço base
-- é igual ou superior a 50.00 €, ordenados do mais económico para o mais caro,
-- começando em 'Sessão de Acupuntura Veterinária' (52.00 €) até
-- 'Esterilização Felina (Ovariohisterectomia)' (145.00 €).
-- EXPLICAÇÃO: Seleciona os procedimentos clínicos de maior valor na tabela
-- TRATAMENTO recorrendo ao operador relacional >= na cláusula WHERE e ordena
-- o catálogo por ordem crescente de preco_base (ASC).
SELECT
    id_tratamento,
    nome,
    categoria,
    preco_base,
    duracao_minutos
FROM TRATAMENTO
WHERE preco_base >= 50.00
ORDER BY preco_base ASC;


-- -------------------------------------------------------------------------
-- COMANDO 3: SELECT SIMPLES #3 — Consultas futuras agendadas por ordem cronológica
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve 3 registos da tabela CONSULTA com estado igual a
-- 'Agendada' (IDs 17, 18 e 19), ordenados cronologicamente da data mais próxima
-- (2026-10-24 10:00:00) para a mais distante (2026-11-03 11:00:00).
-- EXPLICAÇÃO: Filtra a agenda clínica na tabela CONSULTA para obter apenas os
-- atendimentos pendentes ('Agendada') e apresenta-os por ordem cronológica
-- crescente através de ORDER BY data_hora ASC.
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
-- COMANDO 4: SELECT COM JOIN #1 — Histórico completo de consultas (4 tabelas)
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve todas as 20 consultas registadas, apresentando em
-- cada linha a data/hora, o estado, o nome e espécie do animal, o nome e telefone
-- do respetivo dono, e o nome e especialidade do médico veterinário responsável,
-- ordenadas da consulta mais recente para a mais antiga.
-- EXPLICAÇÃO: Utiliza INNER JOIN para cruzar quatro tabelas relacionadas pelas
-- suas chaves primárias e estrangeiras (CONSULTA -> ANIMAL -> DONO e
-- CONSULTA -> VETERINARIO), reunindo numa única vista toda a informação útil
-- para listagem no futuro sistema web da clínica.
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


-- -------------------------------------------------------------------------
-- COMANDO 5: SELECT COM JOIN #2 — Detalhe de tratamentos aplicados e faturação (4 tabelas)
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: Devolve os 20 registos da tabela associativa
-- CONSULTA_TRATAMENTO enriquecidos com a data da consulta, o nome do animal,
-- o nome e categoria do tratamento, a quantidade, o preço unitário aplicado e
-- o subtotal calculado (quantidade * preco_aplicado), ordenados do maior
-- subtotal (145.00 €) para o menor (16.50 €).
-- EXPLICAÇÃO: Combina CONSULTA_TRATAMENTO com CONSULTA, ANIMAL e TRATAMENTO
-- através de INNER JOIN e calcula dinamicamente o subtotal de cada linha de
-- tratamento com a expressão aritmética ROUND(ct.quantidade * ct.preco_aplicado, 2).
SELECT
    ct.id_consulta,
    c.data_hora,
    a.nome AS nome_animal,
    t.nome AS nome_tratamento,
    t.categoria,
    ct.quantidade,
    ct.preco_aplicado,
    ROUND(ct.quantidade * ct.preco_aplicado, 2) AS subtotal_tratamento
FROM CONSULTA_TRATAMENTO AS ct
INNER JOIN CONSULTA AS c
    ON ct.id_consulta = c.id_consulta
INNER JOIN ANIMAL AS a
    ON c.id_animal = a.id_animal
INNER JOIN TRATAMENTO AS t
    ON ct.id_tratamento = t.id_tratamento
ORDER BY subtotal_tratamento DESC, ct.id_consulta ASC;


-- =========================================================================
-- SECÇÃO 3 — ATUALIZAÇÃO DE DADOS (2 COMANDOS UPDATE)
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 6: UPDATE #1 — Registar conclusão e diagnóstico de uma consulta agendada
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: 1 linha afetada (1 row affected). A consulta com
-- id_consulta = 17 passa do estado 'Agendada' para 'Concluída' e fica com o
-- diagnóstico clínico preenchido, sem alterar nenhuma outra consulta.
-- EXPLICAÇÃO: Atualiza as colunas estado e diagnostico na tabela CONSULTA
-- filtrando pela chave primária (WHERE id_consulta = 17), simulando o fecho
-- clínico de um atendimento no sistema web após o exame do médico veterinário.
UPDATE CONSULTA
SET estado = 'Concluída',
    diagnostico = 'Estabilidade ecocardiográfica confirmada; mantida terapêutica atual.'
WHERE id_consulta = 17;


-- -------------------------------------------------------------------------
-- COMANDO 7: UPDATE #2 — Atualizar o preço de tabela de um tratamento
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: 1 linha afetada (1 row affected). O tratamento com
-- id_tratamento = 1 ('Vacina Polivalente Canina') passa de preco_base = 38.00 €
-- para preco_base = 41.50 €, mantendo intacto o histórico de preco_aplicado
-- (38.00 €) nas consultas já realizadas em CONSULTA_TRATAMENTO.
-- EXPLICAÇÃO: Altera o valor de catálogo na tabela TRATAMENTO usando a chave
-- primária (WHERE id_tratamento = 1), demonstrando também a vantagem de guardar
-- preco_aplicado na entidade associativa para preservar o histórico contabilístico.
UPDATE TRATAMENTO
SET preco_base = 41.50
WHERE id_tratamento = 1;


-- =========================================================================
-- SECÇÃO 4 — ELIMINAÇÃO DE DADOS (1 COMANDO DELETE RESPEITANDO AS FKs)
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 8: DELETE — Eliminar um tratamento sem consultas associadas
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: 1 linha afetada (1 row affected). O registo com
-- id_tratamento = 20 ('Crioterapia Dermatológica Localizada') é removido com
-- sucesso da tabela TRATAMENTO, passando esta a contar com 19 registos.
-- EXPLICAÇÃO: Elimina da tabela TRATAMENTO um procedimento que nunca foi
-- referenciado em CONSULTA_TRATAMENTO. Como não existem linhas filhas dependentes
-- deste id_tratamento, a restrição ON DELETE RESTRICT é integralmente respeitada.
DELETE FROM TRATAMENTO
WHERE id_tratamento = 20;


-- =========================================================================
-- SECÇÃO 5 — TESTE DE INTEGRIDADE REFERENCIAL (1 INSERT COM FK INEXISTENTE)
-- Nota: Este comando é colocado propositadamente no final do script porque o
--       seu objetivo é demonstrar o bloqueio automático de dados inválidos pelo
--       motor InnoDB do MySQL 8 (os comandos 1 a 8 acima executam sem erros).
-- =========================================================================

-- -------------------------------------------------------------------------
-- COMANDO 9: TESTE DE INTEGRIDADE — Tentar inserir consulta para animal inexistente
-- -------------------------------------------------------------------------
-- RESULTADO ESPERADO: A inserção falha e é rejeitada pelo MySQL 8 com o erro:
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint
-- fails (`clinica_vet`.`CONSULTA`, CONSTRAINT `fk_consulta_animal` FOREIGN KEY
-- (`id_animal`) REFERENCES `ANIMAL` (`id_animal`) ON DELETE RESTRICT ON UPDATE CASCADE).
-- EXPLICAÇÃO: O comando tenta registar uma nova linha na tabela filha CONSULTA
-- indicando id_animal = 999, valor que não existe na coluna id_animal da tabela
-- mãe ANIMAL (cujos IDs válidos vão apenas de 1 a 20). A chave estrangeira
-- fk_consulta_animal impede a criação de registos órfãos, garantindo a
-- integridade referencial da base de dados.
INSERT INTO CONSULTA (data_hora, motivo, diagnostico, estado, valor_consulta, id_animal, id_veterinario)
VALUES ('2026-11-10 10:00:00', 'Consulta de teste de integridade referencial', NULL, 'Agendada', 35.00, 999, 1);
