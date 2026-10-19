-- =====================================================================
-- PROJETO: Customer Support Operations Analytics
-- DESCRIÇÃO: 20 Consultas SQL Estratégicas para Análise Operacional (SPD, AHT, THT, NPS, QA)
-- =====================================================================


-- =====================================================================
-- BLOCO 1: EFICIÊNCIA OPERACIONAL E TEMPOS DE ATENDIMENTO
-- =====================================================================

-- 1. Qual é o tempo médio de atendimento (AHT) e de gestão (THT) por cada canal?
SELECT 
    canal,
    ROUND(AVG(aht_segundos), 2) AS media_aht,
    ROUND(AVG(tht_segundos), 2) AS media_tht
FROM dados_suporte_operacoes
GROUP BY canal;

-- 2. Qual é o tempo de espera (SPD) médio por cada equipa de suporte?
SELECT 
    equipa,
    ROUND(AVG(spd_segundos), 2) AS media_spd_segundos
FROM dados_suporte_operacoes
GROUP BY equipa
ORDER BY media_spd_segundos DESC;

-- 3. Qual é o tempo máximo de espera (SPD) registado por cada canal?
SELECT 
    canal,
    MAX(spd_segundos) AS max_spd_segundos
FROM dados_suporte_operacoes
GROUP BY canal;

-- 4. Qual é a média do THT (Total Handle Time) comparada com o AHT por equipa (para analisar o pós-atendimento)?
SELECT 
    equipa,
    ROUND(AVG(aht_segundos), 2) AS media_aht,
    ROUND(AVG(tht_segundos), 2) AS media_tht,
    ROUND(AVG(tht_segundos - aht_segundos), 2) AS media_tempo_wrapup
FROM dados_suporte_operacoes
GROUP BY equipa;

-- 5. Qual é a distribuição de volume de interações por cada equipa e por canal?
SELECT 
    equipa,
    canal,
    COUNT(id_interacao) AS total_interacoes
FROM dados_suporte_operacoes
GROUP BY equipa, canal
ORDER BY total_interacoes DESC;


-- =====================================================================
-- BLOCO 2: QUALIDADE E DESEMPENHO DOS AGENTES
-- =====================================================================

-- 6. Quais são os 5 agentes com melhor pontuação de qualidade (QA Score) média?
SELECT 
    id_agente,
    equipa,
    ROUND(AVG(qa_score), 2) AS media_qa
FROM dados_suporte_operacoes
GROUP BY id_agente, equipa
ORDER BY media_qa DESC
LIMIT 5;

-- 7. Quais são os agentes com maior volume de interações tratadas?
SELECT 
    id_agente,
    equipa,
    COUNT(id_interacao) AS total_atendimentos
FROM dados_suporte_operacoes
GROUP BY id_agente, equipa
ORDER BY total_atendimentos DESC
LIMIT 5;

-- 8. Qual é o AHT médio por agente, ordenado do mais rápido para o mais lento?
SELECT 
    id_agente,
    equipa,
    ROUND(AVG(aht_segundos), 2) AS media_aht
FROM dados_suporte_operacoes
GROUP BY id_agente, equipa
ORDER BY media_aht ASC;

-- 9. Quais são os agentes cuja pontuação média de QA é inferior a 70%?
SELECT 
    id_agente,
    equipa,
    ROUND(AVG(qa_score), 2) AS media_qa
FROM dados_suporte_operacoes
GROUP BY id_agente, equipa
HAVING AVG(qa_score) < 70
ORDER BY media_qa ASC;

-- 10. Qual é o ranking de produtividade (total de contactos) por agente dentro de cada equipa?
SELECT 
    equipa,
    id_agente,
    COUNT(id_interacao) AS total_contactos
FROM dados_suporte_operacoes
GROUP BY equipa, id_agente
ORDER BY equipa, total_contactos DESC;


-- =====================================================================
-- BLOCO 3: SATISFAÇÃO DO CLIENTE (NPS) E CORRELAÇÕES
-- =====================================================================

-- 11. Qual é a distribuição geral das respostas do NPS (Satisfação do Cliente)?
SELECT 
    nps,
    COUNT(id_interacao) AS total_respostas
FROM dados_suporte_operacoes
GROUP BY nps
ORDER BY nps DESC;

-- 12. Qual é o NPS médio cruzado por cada canal de atendimento?
SELECT 
    canal,
    ROUND(AVG(nps), 2) AS nps_medio,
    COUNT(id_interacao) AS total_respostas
FROM dados_suporte_operacoes
GROUP BY canal;

-- 13. Qual é o NPS médio cruzado por equipa de suporte?
SELECT 
    equipa,
    ROUND(AVG(nps), 2) AS nps_medio
FROM dados_suporte_operacoes
GROUP BY equipa
ORDER BY nps_medio DESC;

-- 14. Qual é o NPS médio por cada escalão de tempo de espera (SPD: Rápido <30s, Moderado 30-60s, Lento >60s)?
SELECT 
    CASE 
        WHEN spd_segundos < 30 THEN '1. Rápido (<30s)'
        WHEN spd_segundos BETWEEN 30 AND 60 THEN '2. Moderado (30-60s)'
        ELSE '3. Lento (>60s)'
    END AS escalao_espera,
    ROUND(AVG(nps), 2) AS nps_medio,
    COUNT(id_interacao) AS total_casos
FROM dados_suporte_operacoes
GROUP BY escalao_espera
ORDER BY escalao_espera;

-- 15. Identificar interações críticas onde o AHT foi superior a 10 minutos (600s) e o NPS foi baixo (< 6).
SELECT 
    id_interacao,
    id_agente,
    equipa,
    aht_segundos,
    nps
FROM dados_suporte_operacoes
WHERE aht_segundos > 600 AND nps < 6
ORDER BY aht_segundos DESC
LIMIT 10;


-- =====================================================================
-- BLOCO 4: TENDÊNCIAS TEMPORAIS E ANÁLISE EXECUTIVA GLOBAL
-- =====================================================================

-- 16. Qual é o volume total de contactos e o NPS médio agrupado por mês?
SELECT 
    SUBSTR(data_contacto, 1, 7) AS mes,
    COUNT(id_interacao) AS total_contactos,
    ROUND(AVG(nps), 2) AS nps_medio
FROM dados_suporte_operacoes
GROUP BY mes
ORDER BY mes ASC;

-- 17. Qual é a taxa de evolução do AHT médio por mês?
SELECT 
    SUBSTR(data_contacto, 1, 7) AS mes,
    ROUND(AVG(aht_segundos), 2) AS aht_medio
FROM dados_suporte_operacoes
GROUP BY mes
ORDER BY mes ASC;

-- 18. Quantas interações "perfeitas" (QA Score = 100 e NPS = 10) existem por equipa?
SELECT 
    equipa,
    COUNT(id_interacao) AS interacoes_perfeitas
FROM dados_suporte_operacoes
WHERE qa_score = 100 AND nps = 10
GROUP BY equipa
ORDER BY interacoes_perfeitas DESC;

-- 19. Qual é o dia do mês com maior volume registado de contactos de suporte?
SELECT 
    data_contacto,
    COUNT(id_interacao) AS total_contactos
FROM dados_suporte_operacoes
GROUP BY data_contacto
ORDER BY total_contactos DESC
LIMIT 5;

-- 20. Resumo Executivo Global da Operação: totais e médias gerais.
SELECT 
    COUNT(id_interacao) AS total_geral_interacoes,
    COUNT(DISTINCT id_agente) AS total_agentes_ativos,
    ROUND(AVG(spd_segundos), 2) AS spd_medio_global,
    ROUND(AVG(aht_segundos), 2) AS aht_medio_global,
    ROUND(AVG(qa_score), 2) AS qa_medio_global,
    ROUND(AVG(nps), 2) AS nps_medio_global
FROM dados_suporte_operacoes;
