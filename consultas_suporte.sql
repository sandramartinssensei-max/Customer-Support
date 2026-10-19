-- ============================================================================
-- PROJETO DE DATA ANALYTICS: OPERAÇÕES DE SUPORTE AO CLIENTE
-- Script SQL Completo (10 Consultas Estratégicas para PostgreSQL / MySQL)
-- Dataset: suporte_operacoes
-- ============================================================================

-- Tabela: suporte_operacoes
-- Colunas Reais:
--   - id_interacao (INT)
--   - data_contacto (DATE)
--   - canal (VARCHAR)
--   - equipa (VARCHAR)
--   - id_agente (VARCHAR)
--   - fcr (BOOLEAN)
--   - spd_segundos (INT)
--   - aht_segundos (INT)
--   - tht_segundos (INT)
--   - nps (INT)
--   - qa_score (DECIMAL)

-- ============================================================================
-- 1. VOLUME TOTAL DE CONTACTOS POR MÊS
-- Objetivo: Identificar sazonalidade e tendências de volume ao longo do ano.
-- ============================================================================
SELECT 
    DATE_TRUNC('month', data_contacto) AS mes,
    COUNT(id_interacao) AS total_contactos
FROM suporte_operacoes
GROUP BY DATE_TRUNC('month', data_contacto)
ORDER BY mes ASC;

-- ============================================================================
-- 2. DISTRIBUIÇÃO DE CONTACTOS POR CANAL DE ATENDIMENTO
-- Objetivo: Analisar a adesão dos clientes a cada canal (Voz, Chat, Email).
-- ============================================================================
SELECT 
    canal,
    COUNT(id_interacao) AS total_contactos,
    ROUND(COUNT(id_interacao) * 100.0 / (SELECT COUNT(*) FROM suporte_operacoes), 2) AS percentagem_total
FROM suporte_operacoes
GROUP BY canal
ORDER BY total_contactos DESC;

-- ============================================================================
-- 3. VOLUME DE CONTACTOS POR EQUIPA OPERACIONAL
-- Objetivo: Avaliar a distribuição de carga de trabalho entre as equipas.
-- ============================================================================
SELECT 
    equipa,
    COUNT(id_interacao) AS total_contactos
FROM suporte_operacoes
GROUP BY equipa
ORDER BY total_contactos DESC;

-- ============================================================================
-- 4. TAXA DE FCR (FIRST CONTACT RESOLUTION) POR CANAL
-- Objetivo: Medir a percentagem de problemas resolvidos logo no 1.º contacto.
-- ============================================================================
SELECT 
    canal,
    COUNT(id_interacao) AS total_contactos,
    SUM(CASE WHEN fcr = TRUE THEN 1 ELSE 0 END) AS contactos_resolvidos_fcr,
    ROUND(AVG(CASE WHEN fcr = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS taxa_fcr_percentagem
FROM suporte_operacoes
GROUP BY canal
ORDER BY taxa_fcr_percentagem DESC;

-- ============================================================================
-- 5. EVOLUÇÃO DIÁRIA DO SPD (SOLVES PER DAY)
-- Objetivo: Monitorizar a produtividade diária global (casos resolvidos/dia).
-- ============================================================================
SELECT 
    data_contacto,
    COUNT(id_interacao) AS total_solves_dia
FROM suporte_operacoes
GROUP BY data_contacto
ORDER BY data_contacto ASC;

-- ============================================================================
-- 6. MÉDIA DIÁRIA DE SPD (SOLVES PER DAY) POR EQUIPA
-- Objetivo: Comparar a capacidade diária de resolução de casos entre equipas.
-- ============================================================================
SELECT 
    equipa,
    COUNT(id_interacao) AS total_casos_resolvidos,
    COUNT(DISTINCT data_contacto) AS dias_operativos,
    ROUND(COUNT(id_interacao)::DECIMAL / COUNT(DISTINCT data_contacto), 1) AS media_spd_diario
FROM suporte_operacoes
GROUP BY equipa
ORDER BY media_spd_diario DESC;

-- ============================================================================
-- 7. TEMPO MÉDIO DE ATENDIMENTO (AHT) EM MINUTOS POR CANAL
-- Objetivo: Medir a duração média de conversação/atendimento em minutos.
-- ============================================================================
SELECT 
    canal,
    ROUND(AVG(aht_segundos) / 60.0, 2) AS aht_medio_minutos
FROM suporte_operacoes
GROUP BY canal
ORDER BY aht_medio_minutos DESC;

-- ============================================================================
-- 8. COMPARATIVO AHT vs. THT EM MINUTOS POR EQUIPA
-- Objetivo: Comparar o tempo de atendimento (AHT) com o tempo total de manipulação (THT).
-- ============================================================================
SELECT 
    equipa,
    ROUND(AVG(aht_segundos) / 60.0, 2) AS aht_medio_minutos,
    ROUND(AVG(tht_segundos) / 60.0, 2) AS tht_medio_minutos,
    ROUND(AVG(tht_segundos - aht_segundos) / 60.0, 2) AS tempo_pos_atendimento_minutos
FROM suporte_operacoes
GROUP BY equipa
ORDER BY tht_medio_minutos DESC;

-- ============================================================================
-- 9. SATISFAÇÃO DO CLIENTE (NPS MÉDIO) POR CANAL E EQUIPA
-- Objetivo: Identificar onde a satisfação do cliente é mais elevada ou crítica.
-- ============================================================================
SELECT 
    equipa,
    canal,
    COUNT(id_interacao) AS total_avaliacoes,
    ROUND(AVG(nps), 2) AS nps_medio
FROM suporte_operacoes
WHERE nps IS NOT NULL
GROUP BY equipa, canal
ORDER BY equipa, nps_medio DESC;

-- ============================================================================
-- 10. QUALIDADE OPERACIONAL (QA SCORE MÉDIO) vs. NPS POR EQUIPA
-- Objetivo: Relacionar a qualidade interna (auditorias QA) com a avaliação do cliente (NPS).
-- ============================================================================
SELECT 
    equipa,
    ROUND(AVG(qa_score), 2) AS
