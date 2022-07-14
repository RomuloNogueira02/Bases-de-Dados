--------------------------------------------------------------------------------------------
-- BD 2021/22 - etapa E2 - bd014 – TP12
-- João Ascenso 56939 (20%); Madalena Rodrigues 55853 (30%); 
-- Miguel Castro 56906 (20%); Rómulo Nogueira 56935 (30%)
--------------------------------------------------------------------------------------------

-- PERGUNTA 1
-- Nome e país de todos os jogadores que já marcaram pelo menos dois golos em algum jogo com
-- a França (FR). 

SELECT DISTINCT J.nome, J.pais, J.ano 
FROM jogador J 
INNER JOIN participa P ON (J.numero = P.jogador AND P.golos >= 2) 
INNER JOIN jogo JG ON (P.jogo_ano = JG.ano AND 
                       P.jogo_sigla = JG.sigla AND 
                       P.jogo_numero = JG.numero AND 
                       (JG.equipa1 = 'FR' OR JG.equipa2 = 'FR')) 
ORDER BY JG.ano DESC, J.nome ASC, J.pais ASC

--------------------------------------------------------------------------------------------

-- PERGUNTA 2
-- Número, nome, posição e país dos jogadores que são Top em pelo menos uma das posições: 
-- ponta de lança e avançado, ou que tenham ‘Ron’ no nome e tenham começado a jogar antes
-- do último Mundial no Brasil (2014). 

-- NOTA: "PL" refere-se a "ponta_lanca" e "A" a "avancado"

SELECT J.numero, J.nome, EB.posicao, J.pais 
FROM jogador J, e_bom EB 
WHERE J.numero = EB.jogador AND EB.tipo = 'top' AND (EB.posicao = 'PL' OR EB.posicao = 'A')
UNION 
SELECT J2.numero, J2.nome, EB2.posicao, J2.pais 
FROM jogador J2, e_bom EB2 
WHERE J2.numero = EB2.jogador AND J2.ano < 2014 AND J2.nome LIKE '%Ron%'

--------------------------------------------------------------------------------------------

-- PERGUNTA 3 (versão começar no ano do jogo) 
-- Identificação dos jogos de quartos de final realizados desde o Mundial Alemanha’2006 em 
-- que participou, pelo menos, um jogador que iniciou atividade nesse ano e tem na camisola
-- um nome com 7 letras, terminado por ‘o’.

-- Nesta versão considera-se que "iniciou atividade nesse ano" se refere ao ano do jogo de
-- quartos de final realizado após 2006

SELECT JG.ano, JG.sigla, JG.numero, J.nome
FROM jogo JG
INNER JOIN participa P ON (JG.ano = P.jogo_ano AND 
                            JG.ano >= 2006 AND P.jogo_ano >= 2006 AND 
                            JG.numero = P.Jogo_numero AND 
                            JG.sigla = 'QF' AND P.jogo_sigla = 'QF')
INNER JOIN jogador J ON (J.nome like '%o' AND LENGTH(J.nome) = 7 AND 
                          P.jogador = J.numero)

-- PERGUNTA 3 (versão começar em 2006)
-- Nesta versão considera-se que "iniciou atividade nesse ano" se refere ao ano de 2006

SELECT JG.numero, JG.ano, JG.sigla, J.nome
FROM jogo JG
INNER JOIN participa P ON (JG.ano = 2006 AND P.jogo_ano >= 2006 AND 
                            JG.numero = P.Jogo_numero AND 
                            JG.sigla = 'QF' AND P.jogo_sigla = 'QF')
INNER JOIN jogador J ON (J.nome like '%o' AND LENGTH(J.nome) = 7 AND 
                          P.jogador = J.numero)

--------------------------------------------------------------------------------------------

-- PERGUNTA 4
-- Nome, ano e país dos jogadores que nasceram antes do Mundial USA’1994 , e que nunca 
-- participaram à defesa, em oitavos de final com o Reino Unido (UK).

-- NOTA: "D" refere-se a "defesa"

SELECT DISTINCT J.nome, J.ano, J.pais
FROM jogador J, jogo JG, participa P 
WHERE J.nascimento < 1994 AND 
    (JG.equipa1 = 'UK' OR JG.equipa2 = 'UK') AND JG.sigla = 'OF' AND 
    (P.jogo_ano = JG.ano AND P.Jogo_sigla = JG.sigla AND P.Jogo_numero = JG.numero) AND 
    P.posicao != 'D'  
    AND J.numero = P.jogador

--------------------------------------------------------------------------------------------

-- PERGUNTA 5 
-- Identificação dos jogos em fases de grupo em que tenham participado jogadores italianos 
-- Top em todas as posições. 

-- Interpretámos que eram para ser mostrados apenas os jogos de fases de grupo em que tenham 
-- participado jogadores italianos TOP em todas as posições, ou seja caso houvesse um jogador
-- 'pro' numa das posições esse jogo não seria considerado

SELECT P.jogo_ano, P.Jogo_sigla, P.Jogo_numero
FROM participa P, jogador J, e_bom EB
WHERE P.jogador = EB.jogador 
	AND J.numero = EB.jogador 
  AND P.posicao = EB.posicao
  AND LENGTH(P.Jogo_sigla) = 1
  AND J.pais = "IT"  
  AND (P.jogo_ano, P.Jogo_sigla, P.Jogo_numero) NOT IN (
      SELECT P2.jogo_ano, P2.Jogo_sigla, P2.Jogo_numero
      FROM participa P2, jogador J2, e_bom EB2
      WHERE P2.jogador = EB2.jogador 
        AND J2.numero = EB2.jogador 
        AND P2.posicao = EB2.posicao
        AND LENGTH(P2.Jogo_sigla) = 1
        AND J2.pais = "IT"
        AND EB2.tipo = 'pro' 
      GROUP BY P2.jogo_ano, P2.Jogo_sigla, P2.Jogo_numero
  )
ORDER BY P.jogo_ano DESC, P.Jogo_sigla, P.Jogo_numero ASC

--------------------------------------------------------------------------------------------

-- PERGUNTA 6
-- Número de jogos em que participou cada jogador, em cada posição. 

SELECT COUNT(P.jogador) numero_jogos, J.nome, J.numero, P.posicao 
FROM jogador J
INNER JOIN participa P ON (P.jogador = J.numero)
GROUP BY P.jogador, P.posicao
ORDER BY J.nome, J.numero, P.posicao ASC

--------------------------------------------------------------------------------------------

-- PERGUNTA 7
-- Nome, número e nacionalidade dos jogadores que participaram em mais semifinais, em cada 
-- posição.

SELECT J.nome, P.jogador, J.pais, P.posicao, COUNT(P.posicao) AS 'numero_participacoes' 
FROM participa P 
JOIN jogador J ON P.jogador = J.numero
WHERE P.jogo_sigla = 'SF'
GROUP BY P.posicao, P.jogador
ORDER BY P.posicao, 'numero_participacoes' DESC

--------------------------------------------------------------------------------------------

-- PERGUNTA 8
-- Para cada ano de início de actividade, o número e nome na camisola do jogador que 
-- participou em mais jogos. Apresentar também o número total de jogos em que jogou, 
-- e o maior e menor número de golos que marcou nesses jogos.

SELECT J.ano, J.camisola, J.nome, COUNT(J.ano) AS 'numero_jogos',
                                  MAX(P.golos) AS 'maior_nr_golos', 
                                  MIN(P.golos) AS 'menor_nr_golos'
FROM jogador J
JOIN participa P ON J.numero = P.jogador
GROUP BY J.ano, P.jogador
ORDER BY J.ano, 'numero_jogos' DESC

--------------------------------------------------------------------------------------------

-- PERGUNTA 9
-- Nome, ano de nascimento e nacionalidade dos jogadores que nasceram depois do ano do 
-- Ronaldo (1985) e participaram em menos de 6 jogos em mundiais, mesmo que não tenham
-- participado em nenhum.

SELECT J.nome, J.nascimento, J.pais
  FROM participa P
  RIGHT OUTER JOIN jogador J ON J.numero = P.jogador
  LEFT OUTER JOIN jogo JG  ON (P.jogo_ano = JG.ano AND 
                               P.Jogo_sigla = JG.sigla AND 
                               P.Jogo_numero = JG.numero)
WHERE J.nascimento > 1985 
GROUP BY J.nome
HAVING COUNT(*) < 6

--------------------------------------------------------------------------------------------
