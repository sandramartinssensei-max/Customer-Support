-- ============================================================================
-- PROJETO DE DATA ANALYTICS: OPERAÇÕES DE SUPORTE AO CLIENTE
-- Script SQL Definitivo (10 Consultas Estratégicas Perfeitamente Conciliadas)
-- Dataset: suporte_operacoes
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. VOLUME TOTAL DE CONTACTOS POR MÊS
-- Gráfico 1: Gráfico de Colunas (Ano-Mês vs Total de Contactos)
-- ----------------------------------------------------------------------------
SELECT 
    DATE_TRUNC('month', data_contacto) AS mes,
    COUNT(id_interacao) AS total_contactos
FROM suporte_operacoes
GROUP BY DATE_TRUNC('month', data_contacto)
ORDER BY mes ASC;

-- ----------------------------------------------------------------------------
-- 2. DISTRIBUIÇÃO DE CONTACTOS POR CANAL DE ATENDIMENTO
-- Gráfico 2: Gráfico Circular / Donut (Percentagem por Voz, Chat, Email)
-- ----------------------------------------------------------------------------
SELECT 
    canal,
    COUNT(id_interacao) AS total_contactos,
    ROUND(COUNT(id_interacao) * 100.0 / (SELECT COUNT(*) FROM suporte_operacoes), 2) AS percentagem_total
FROM suporte_operacoes
GROUP BY canal
ORDER BY total_contactos DESC;

-- ----------------------------------------------------------------------------
-- 3. VOLUME TOTAL DE CONTACTOS POR EQUIPA OPERACIONAL
-- Gráfico 3: Gráfico de Barras Horizontais (Equipa vs Total de Contactos)
-- ----------------------------------------------------------------------------
SELECT 
    equipa,
    COUNT(id_interacao) AS total_contactos
FROM suporte_operacoes
GROUP BY equipa
ORDER BY total_contactos DESC;

-- ----------------------------------------------------------------------------
-- 4. DISTRIBUIÇÃO DE CANAIS POR EQUIPA OPERACIONAL
-- Gráfico 4: Gráfico de Colunas Empilhadas (Equipa vs Canais)
-- ----------------------------------------------------------------------------
SELECT 
    equipa,
    canal,
    COUNT(id_interacao) AS total_contactos
FROM suporte_operacoes
GROUP BY equipa, canal
ORDER BY equipa, total_contactos DESC;

-- ----------------------------------------------------------------------------
-- 5. EVOLUÇÃO DIÁRIA DE RESOLUÇÕES (SPD - SOLVES PER DAY)
-- Gráfico 5: Gráfico de Linhas (Data de Contacto vs Total de Solves/Dia)
-- ----------------------------------------------------------------------------
SELECT 
    data_contacto,
    COUNT(id_interacao) AS total_solves_dia
FROM suporte_operacoes
GROUP BY data_contacto
ORDER BY data_contacto ASC;

-- ----------------------------------------------------------------------------
-- 6. TOP 10 AGENTES COM MAIOR VOLUME DE RESOLUÇÕES (SPD)
-- Gráfico 6: Gráfico de Barras Horizontais (Top 10 Agentes vs Resoluções)
-- ----------------------------------------------------------------------------
SELECT 
    id_agente,
    COUNT(id_interacao) AS total_casos_resolvidos
FROM suporte_operacoes
GROUP BY id_agente
ORDER BY total_casos_resolvidos DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- 7. TEMPO MÉDIO DE ATENDIMENTO (AHT) EM MINUTOS POR CANAL
-- Gráfico 7: Gráfico de Colunas (Canal vs AHT Médio em Minutos)
-- ----------------------------------------------------------------------------
SELECT 
    canal,
    ROUND(AVG(aht_segundos) / 60.0, 2) AS aht_medio_minutos
FROM suporte_operacoes
GROUP BY canal
ORDER BY aht_medio_minutos DESC;

-- ----------------------------------------------------------------------------
-- 8. COMPARATIVO AHT vs. THT EM MINUTOS POR EQUIPA
-- Gráfico 8: Gráfico de Colunas Agrupadas (Equipa vs AHT min e THT min)
-- ----------------------------------------------------------------------------
SELECT 
    equipa,
    ROUND(AVG(aht_segundos) / 60.0, 2) AS aht_medio_minutos,
    ROUND(AVG(tht_segundos) / 60.0, 2) AS tht_medio_minutos,
    ROUND(AVG(tht_segundos - aht_segundos) / 60.0, 2) AS tempo_pos_atendimento_minutos
FROM suporte_operacoes
GROUP BY equipa
ORDER BY tht_medio_minutos DESC;

-- ----------------------------------------------------------------------------
-- 9. SATISFAÇÃO DO CLIENTE (NPS MÉDIO) POR EQUIPA E CANAL
-- Gráfico 9: Gráfico de Colunas Agrupadas (Equipa vs NPS por Canal)
-- ----------------------------------------------------------------------------
SELECT 
    equipa,
    canal,
    COUNT(id_interacao) AS total_avaliacoes,
    ROUND(AVG(nps), 2) AS nps_medio
FROM suporte_operacoes
WHERE nps IS NOT NULL
GROUP BY equipa, canal
ORDER BY equipa, nps_medio DESC;

-- ----------------------------------------------------------------------------
-- 10. QUALIDADE OPERACIONAL (QA SCORE) vs. NPS POR EQUIPA
SELECT 
    equipa,
    -- Contagem ou percentagem de conformidade se for texto
    SUM(CASE WHEN qa_score = 'Sim' OR qa_score = 'Aprovado' THEN 1 ELSE 0 END) * 100.0 / COUNT(id_interacao) AS qa_score_percentagem_conformidade,
    ROUND(AVG(nps), 2) AS nps_medio
FROM suporte_operacoes
GROUP BY equipa
ORDER BY qa_score_percentagem_conformidade DESC;
ORDER BY qa_score_percentagem_conformidade DESC;
