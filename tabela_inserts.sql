-- ATENÇÃO: Se for re-executar, pode ser necessário deletar as tabelas antes
-- (DROP TABLE IF EXISTS os_materiais, avaliacoes, historico_status_os, ordens_servico, chamados, ambientes, andares, edificios, materiais, categorias_servico, usuarios CASCADE;)

-- ===============================================
-- 1. INSERÇÕES BASE (Usando RETURNING para obter IDs)
-- ===============================================

-- Inserindo Usuários e armazenando os IDs temporariamente (usando RETURNING)
-- Você precisará de uma sessão interativa ou um bloco DO/função para armazenar esses valores
-- Se estiver usando um cliente SQL normal, anote os IDs retornados ou use SELECTs

-- Exemplo simplificado (você DEVE verificar os IDs retornados pelo seu cliente SQL):
INSERT INTO usuarios (nome_completo, email, senha_hash, telefone, tipo_usuario) VALUES
('Ana Silva', 'ana.silva@uni.br', 'hash123a', '84999001122', 'Solicitante') RETURNING id_usuario AS ana_id; -- id_usuario = 1
INSERT INTO usuarios (nome_completo, email, senha_hash, telefone, tipo_usuario) VALUES
('Bruno Costa', 'bruno.costa@uni.br', 'hash123b', '84988002233', 'Solicitante') RETURNING id_usuario AS bruno_id; -- id_usuario = 2
INSERT INTO usuarios (nome_completo, email, senha_hash, telefone, tipo_usuario) VALUES
('Carlos Melo', 'carlos.melo@uni.br', 'hash456c', '84977003344', 'Gestor') RETURNING id_usuario AS carlos_id; -- id_usuario = 3
INSERT INTO usuarios (nome_completo, email, senha_hash, telefone, tipo_usuario) VALUES
('Diana Souza', 'diana.souza@uni.br', 'hash456d', '84966004455', 'Técnico') RETURNING id_usuario AS diana_id; -- id_usuario = 4
INSERT INTO usuarios (nome_completo, email, senha_hash, telefone, tipo_usuario) VALUES
('Eduardo Reis', 'edu.reis@uni.br', 'hash789e', '84955005566', 'Técnico') RETURNING id_usuario AS eduardo_id; -- id_usuario = 5

-- Inserindo Categorias
INSERT INTO categorias_servico (nome_categoria) VALUES
('Elétrica') RETURNING id_categoria AS cat_eletrica_id; -- id_categoria = 1
INSERT INTO categorias_servico (nome_categoria) VALUES
('Hidráulica') RETURNING id_categoria AS cat_hidraulica_id; -- id_categoria = 2
INSERT INTO categorias_servico (nome_categoria) VALUES
('Estrutural');
INSERT INTO categorias_servico (nome_categoria) VALUES
('Climatização') RETURNING id_categoria AS cat_climatizacao_id; -- id_categoria = 4
INSERT INTO categorias_servico (nome_categoria) VALUES
('Mobiliário');

-- Inserindo Materiais
INSERT INTO materiais (nome_material, unidade_medida, quantidade_estoque, vlr_custo) VALUES
('Lâmpada LED 9W', 'UN', 150, 8.50) RETURNING id_material AS mat_lampada_id; -- id_material = 1
INSERT INTO materiais (nome_material, unidade_medida, quantidade_estoque, vlr_custo) VALUES
('Cano PVC 50mm', 'M', 80, 12.00) RETURNING id_material AS mat_cano_id; -- id_material = 2
INSERT INTO materiais (nome_material, unidade_medida, quantidade_estoque, vlr_custo) VALUES
('Fita Isolante', 'RL', 30, 4.90) RETURNING id_material AS mat_fita_id; -- id_material = 3
INSERT INTO materiais (nome_material, unidade_medida, quantidade_estoque, vlr_custo) VALUES
('Gás R-410A', 'KG', 5, 65.00);
INSERT INTO materiais (nome_material, unidade_medida, quantidade_estoque, vlr_custo) VALUES
('Parafuso Philips', 'PCT', 200, 2.50);


-- ===============================================
-- 2. INSERÇÕES DE LOCALIZAÇÃO (Encadeamento Lógico)
-- ===============================================

-- Inserindo Edifícios
INSERT INTO edificios (nome_edificio) VALUES
('Bloco A - Engenharia') RETURNING id_edificio AS bloco_a_id; -- id_edificio = 1
INSERT INTO edificios (nome_edificio) VALUES
('Biblioteca Central') RETURNING id_edificio AS biblioteca_id; -- id_edificio = 2
INSERT INTO edificios (nome_edificio) VALUES
('Reitoria');

-- Inserindo Andares (Usando Subconsultas para FKs)
INSERT INTO andares (id_edificio, nome_andar) VALUES
((SELECT id_edificio FROM edificios WHERE nome_edificio = 'Bloco A - Engenharia'), 'Térreo') RETURNING id_andar AS andar_a_terreo_id; -- id_andar = 1
INSERT INTO andares (id_edificio, nome_andar) VALUES
((SELECT id_edificio FROM edificios WHERE nome_edificio = 'Bloco A - Engenharia'), '1º Andar');
INSERT INTO andares (id_edificio, nome_andar) VALUES
((SELECT id_edificio FROM edificios WHERE nome_edificio = 'Biblioteca Central'), 'Subsolo');
INSERT INTO andares (id_edificio, nome_andar) VALUES
((SELECT id_edificio FROM edificios WHERE nome_edificio = 'Biblioteca Central'), '1º Andar') RETURNING id_andar AS andar_bib_1_id; -- id_andar = 4

-- Inserindo Ambientes (Usando Subconsultas para FKs)
INSERT INTO ambientes (id_edificio, id_andar, nome_ambiente) VALUES
((SELECT id_edificio FROM edificios WHERE nome_edificio = 'Bloco A - Engenharia'),
 (SELECT id_andar FROM andares WHERE id_edificio = (SELECT id_edificio FROM edificios WHERE nome_edificio = 'Bloco A - Engenharia') AND nome_andar = 'Térreo'),
 'Sala 101') RETURNING id_ambiente AS amb_sala101_id; -- id_ambiente = 1

INSERT INTO ambientes (id_edificio, id_andar, nome_ambiente) VALUES
((SELECT id_edificio FROM edificios WHERE nome_edificio = 'Bloco A - Engenharia'),
 (SELECT id_andar FROM andares WHERE id_edificio = (SELECT id_edificio FROM edificios WHERE nome_edificio = 'Bloco A - Engenharia') AND nome_andar = 'Térreo'),
 'Banheiro Masculino') RETURNING id_ambiente AS amb_banheiro_id; -- id_ambiente = 2
 
INSERT INTO ambientes (id_edificio, id_andar, nome_ambiente) VALUES
((SELECT id_edificio FROM edificios WHERE nome_edificio = 'Biblioteca Central'),
 (SELECT id_andar FROM andares WHERE id_edificio = (SELECT id_edificio FROM edificios WHERE nome_edificio = 'Biblioteca Central') AND nome_andar = '1º Andar'),
 'Área de Estudos') RETURNING id_ambiente AS amb_estudos_id; -- id_ambiente = 3


-- ===============================================
-- 3. INSERÇÕES DE FLUXO DE TRABALHO (Complexidade de FKs)
-- ===============================================

-- Inserindo Chamados (Usando Subconsultas para FKs)
INSERT INTO chamados (id_solicitante, descricao_problema, data_abertura, status_chamado) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@uni.br'), 'Lâmpada piscando na Sala 101.', CURRENT_DATE - INTERVAL '5 days', 'Concluído') RETURNING id_chamado AS chamado_1_id; -- id_chamado = 1

INSERT INTO chamados (id_solicitante, descricao_problema, data_abertura, status_chamado) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'bruno.costa@uni.br'), 'Vazamento no banheiro masculino, próximo ao bebedouro.', CURRENT_DATE - INTERVAL '3 days', 'Aberto') RETURNING id_chamado AS chamado_2_id; -- id_chamado = 2

INSERT INTO chamados (id_solicitante, descricao_problema, data_abertura, status_chamado) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@uni.br'), 'Ar condicionado da Área de Estudos está pingando.', CURRENT_DATE - INTERVAL '1 day', 'Em Análise') RETURNING id_chamado AS chamado_3_id; -- id_chamado = 3


-- Inserindo Ordens de Serviço (OS)
-- OS 1 (Concluída)
INSERT INTO ordens_servico (id_chamado, id_ambiente, id_tecnico, id_categoria, descricao_tecnica_servico, status_os, prioridade_os, procedimentos_necessarios, valor_estimado, data_atribuicao, data_conclusao) VALUES
((SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Lâmpada piscando%'),
 (SELECT id_ambiente FROM ambientes WHERE nome_ambiente = 'Sala 101'),
 (SELECT id_usuario FROM usuarios WHERE email = 'diana.souza@uni.br'), -- Diana
 (SELECT id_categoria FROM categorias_servico WHERE nome_categoria = 'Elétrica'),
 'Substituição de luminária LED. Problema na reatância.', 'Concluído', 2, 'Desligar disjuntor, trocar a lâmpada/reator, testar.', 15.00, CURRENT_DATE - INTERVAL '4 days', CURRENT_DATE - INTERVAL '3 days') RETURNING id_os AS os_1_id; -- id_os = 1

-- OS 2 (Aberta/Não atribuída)
INSERT INTO ordens_servico (id_chamado, id_ambiente, id_tecnico, id_categoria, descricao_tecnica_servico, status_os, prioridade_os, procedimentos_necessarios, valor_estimado, data_atribuicao, data_conclusao) VALUES
((SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Vazamento no banheiro%'),
 (SELECT id_ambiente FROM ambientes WHERE nome_ambiente = 'Banheiro Masculino'),
 NULL, -- Não atribuída
 (SELECT id_categoria FROM categorias_servico WHERE nome_categoria = 'Hidráulica'),
 'Vazamento aparente em junta de cano de esgoto 50mm.', 'Aberto', 1, 'Localizar vazamento, trocar seção do tubo, cimentar.', 150.00, NULL, NULL) RETURNING id_os AS os_2_id; -- id_os = 2

-- OS 3 (Em Execução)
INSERT INTO ordens_servico (id_chamado, id_ambiente, id_tecnico, id_categoria, descricao_tecnica_servico, status_os, prioridade_os, procedimentos_necessarios, valor_estimado, data_atribuicao, data_conclusao) VALUES
((SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Ar condicionado da Área de Estudos%'),
 (SELECT id_ambiente FROM ambientes WHERE nome_ambiente = 'Área de Estudos'),
 (SELECT id_usuario FROM usuarios WHERE email = 'edu.reis@uni.br'), -- Eduardo
 (SELECT id_categoria FROM categorias_servico WHERE nome_categoria = 'Climatização'),
 'Dreno do split entupido. Água condensada não escoando.', 'Em Execução', 3, 'Limpeza do dreno e verificação do nível de Gás R-410A.', 220.00, CURRENT_DATE - INTERVAL '10 hours', NULL) RETURNING id_os AS os_3_id; -- id_os = 3

-- ===============================================
-- 4. RASTREABILIDADE E CONSUMO (Utilizando os IDs das OS)
-- ===============================================

-- Inserindo Histórico de Status OS 1 (Concluída)
INSERT INTO historico_status_os (id_os, status_anterior, status_novo, data_mudanca) VALUES
((SELECT id_os FROM ordens_servico WHERE id_chamado = (SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Lâmpada piscando%')), 'Aberto', 'Atribuído', CURRENT_TIMESTAMP - INTERVAL '4 days 2 hours');
INSERT INTO historico_status_os (id_os, status_anterior, status_novo, data_mudanca) VALUES
((SELECT id_os FROM ordens_servico WHERE id_chamado = (SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Lâmpada piscando%')), 'Atribuído', 'Em Execução', CURRENT_TIMESTAMP - INTERVAL '3 days 10 hours');
INSERT INTO historico_status_os (id_os, status_anterior, status_novo, data_mudanca) VALUES
((SELECT id_os FROM ordens_servico WHERE id_chamado = (SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Lâmpada piscando%')), 'Em Execução', 'Concluído', CURRENT_TIMESTAMP - INTERVAL '3 days');

-- Inserindo Avaliação (para OS 1)
INSERT INTO avaliacoes (id_os, nota_satisfacao, comentario) VALUES
((SELECT id_os FROM ordens_servico WHERE id_chamado = (SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Lâmpada piscando%')),
 5, 'Serviço rápido e eficiente. A luz parou de piscar no mesmo dia.');

-- Inserindo Consumo de Materiais (OS_Materiais)
INSERT INTO os_materiais (id_os, id_material, quantidade_utilizada) VALUES
((SELECT id_os FROM ordens_servico WHERE id_chamado = (SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Lâmpada piscando%')),
 (SELECT id_material FROM materiais WHERE nome_material = 'Lâmpada LED 9W'), 1); -- OS 1 usou 1 lâmpada

INSERT INTO os_materiais (id_os, id_material, quantidade_utilizada) VALUES
((SELECT id_os FROM ordens_servico WHERE id_chamado = (SELECT id_chamado FROM chamados WHERE descricao_problema LIKE 'Lâmpada piscando%')),
 (SELECT id_material FROM materiais WHERE nome_material = 'Fita Isolante'), 0.5); -- OS 1 usou meia fita