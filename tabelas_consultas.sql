\\fazer isso aqui abaixo antes de criar a primeira view 
UPDATE chamados SET id_ambiente = 1 WHERE id_ambiente IS NULL;

CREATE VIEW vw_painel_gestao AS
SELECT 
    c.id_chamado,
    u.nome_completo AS solicitante,
    e.nome_edificio || ' - ' || amb.nome_ambiente AS localizacao,
    c.descricao_problema,
    c.data_abertura,
    COALESCE(os.status_os, 'Aguardando OS') AS status_atual,
    cat.nome_categoria
FROM chamados c
JOIN usuarios u ON c.id_solicitante = u.id_usuario
JOIN ambientes amb ON c.id_ambiente = amb.id_ambiente
JOIN andares an ON amb.id_andar = an.id_andar
JOIN edificios e ON an.id_edificio = e.id_edificio
LEFT JOIN ordens_servico os ON c.id_chamado = os.id_chamado
LEFT JOIN categorias_servico cat ON os.id_categoria = cat.id_categoria;

CREATE VIEW custo_total_manutencao AS
SELECT 
    cat.nome_categoria,
    COUNT(os.id_os) AS total_ordens,
    SUM(os.valor_estimado) AS custo_total_estimado
FROM ordens_servico os
JOIN categorias_servico cat ON os.id_categoria = cat.id_categoria
GROUP BY cat.nome_categoria
ORDER BY custo_total_estimado DESC;

CREATE VIEW ranking_produtividade AS
SELECT 
    u.nome_completo AS tecnico,
    COUNT(os.id_os) AS os_concluidas
FROM ordens_servico os
JOIN usuarios u ON os.id_tecnico = u.id_usuario
WHERE os.status_os = 'Concluído'
GROUP BY u.nome_completo
ORDER BY os_concluidas DESC;

CREATE VIEW vw_detalhe_materiais_os AS
SELECT 
    os.id_os,
    m.nome_material,
    osm.quantidade_utilizada,
    m.vlr_custo AS custo_unitario,
    (osm.quantidade_utilizada * m.vlr_custo) AS custo_final_material
FROM os_materiais osm
JOIN materiais m ON osm.id_material = m.id_material
JOIN ordens_servico os ON osm.id_os = os.id_os;

CREATE VIEW concorrencia_ambientes AS
SELECT 
    e.nome_edificio,
    amb.nome_ambiente,
    COUNT(c.id_chamado) AS total_ocorrencias
FROM chamados c
JOIN ambientes amb ON c.id_ambiente = amb.id_ambiente
JOIN andares an ON amb.id_andar = an.id_andar
JOIN edificios e ON an.id_edificio = e.id_edificio
GROUP BY e.nome_edificio, amb.nome_ambiente
ORDER BY total_ocorrencias DESC
LIMIT 5;

CREATE VIEW tempo_medio_atendimento AS
SELECT 
    AVG(os.data_conclusao - os.data_atribuicao) AS media_dias_para_solucao
FROM ordens_servico os
WHERE os.status_os = 'Concluído' 
AND os.data_conclusao IS NOT NULL;

//fazer isso aqui abaixo antes do chamados_criticos_pendentes
UPDATE ordens_servico 
SET prioridade_os = 5 
WHERE id_os = 3;


CREATE VIEW chamados_criticos_pendentes AS
SELECT 
    os.id_os,
    os.descricao_tecnica_servico,
    os.prioridade_os,
    os.status_os,
    os.data_atribuicao
FROM ordens_servico os
WHERE os.prioridade_os >= 4 
AND os.status_os IN ('Aberto', 'Atribuído', 'Em Execução')
ORDER BY os.prioridade_os DESC;

CREATE VIEW vw_feedback_usuario AS
SELECT 
    av.nota_satisfacao,
    av.comentario,
    u_tec.nome_completo AS tecnico_responsavel,
    cat.nome_categoria
FROM avaliacoes av
JOIN ordens_servico os ON av.id_os = os.id_os
JOIN usuarios u_tec ON os.id_tecnico = u_tec.id_usuario
JOIN categorias_servico cat ON os.id_categoria = cat.id_categoria;

    CREATE VIEW estoque_critico AS
    SELECT 
        nome_material,
        quantidade_estoque,
        vlr_custo
    FROM materiais
    WHERE quantidade_estoque < 10
    ORDER BY quantidade_estoque ASC;

CREATE VIEW historico_completo_os AS
SELECT 
    h.id_os,
    h.status_anterior,
    h.status_novo,
    h.data_mudanca
FROM historico_status_os h
ORDER BY h.data_mudanca ASC;