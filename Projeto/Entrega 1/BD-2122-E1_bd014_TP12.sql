-- ----------------------------------------------------------------------------
-- BD 2021/22 - etapa E1 - bd014 – João Ascenso 56939; Madalena Rodrigues 55853; 
-- Miguel Castro 56906; Rómulo Nogueira 56935 TP12
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS comentarios;
DROP TABLE IF EXISTS preco_comprados;
DROP TABLE IF EXISTS desconto;
DROP TABLE IF EXISTS bilhete;
DROP TABLE IF EXISTS espetador;
DROP TABLE IF EXISTS regista;
DROP TABLE IF EXISTS jogado_por;
DROP TABLE IF EXISTS jogador;
DROP TABLE IF EXISTS treinador;
DROP TABLE IF EXISTS equipa;
DROP TABLE IF EXISTS jogo;
DROP TABLE IF EXISTS zona;
DROP TABLE IF EXISTS estadio;
DROP TABLE IF EXISTS fase;
DROP TABLE IF EXISTS edicao;

-- ----------------------------------------------------------------------------

CREATE TABLE edicao(

    ano NUMERIC(4),
    pais VARCHAR(40) NOT NULL,
    --
    CONSTRAINT pk_ano
        PRIMARY KEY (ano)
);

-- ----------------------------------------------------------------------------

CREATE TABLE fase(

    sigla     CHAR(2),
    periodo   NUMERIC(2), -- em dias
    inicio    DATE          NOT NULL,
    fim       DATE          NOT NULL,
    --
    CONSTRAINT pk_fase
        PRIMARY KEY (sigla, inicio, fim),
    --
    CONSTRAINT ck_sigla
        CHECK (sigla in ('A', 'B', 'C','D', 'E', 'F', 'G', 'H',  -- grupos
                         'OF', 'QF' , 'SF', 'TF', 'FF')), -- fase final - TF jogo do terceiro e quarto lugar
    --
    CONSTRAINT ck_inicio_fim
        CHECK (inicio < fim),
    --
    CONSTRAINT ck_periodo
        CHECK (periodo = fim-inicio)
);

-- ----------------------------------------------------------------------------

CREATE TABLE estadio(
    codigo        NUMERIC(3),
    nome          VARCHAR(50)     NOT NULL,
    localizacao   VARCHAR(30)     NOT NULL, -- Cidade + País
    lotacao       NUMERIC(6)      NOT NULL,
    website       VARCHAR(50)     NOT NULL,
    --
    CONSTRAINT pk_estadio
        PRIMARY KEY (codigo),
    --
    CONSTRAINT un_estadio_nome
        UNIQUE (nome),
    --
    CONSTRAINT ck_estadio_codigo
        CHECK (codigo BETWEEN 0 AND 999)
);

-- ----------------------------------------------------------------------------

CREATE TABLE zona(

    codigo      NUMERIC(3),
    letra       CHAR(1),
    --
    CONSTRAINT pk_zona
        PRIMARY KEY (codigo, letra),
    --
    CONSTRAINT fk_codigo
        FOREIGN KEY (codigo) REFERENCES estadio(codigo) ON DELETE CASCADE
    --
);

-- ----------------------------------------------------------------------------

CREATE TABLE jogo(

    nSequencial   NUMERIC(2), 
    data          DATE,
    horaInicio    TIME            NOT NULL, -- 00:00:00 
    duracao       NUMERIC(3)      NOT NULL, -- em minutos   
    fase          VARCHAR(2)      NOT NULL, 
    codEstadio    NUMERIC(3)      NOT NULL, 
    edicao        NUMERIC(4),
    --
    CONSTRAINT pk_jogo
        PRIMARY KEY (nSequencial, fase, edicao),
    --
    CONSTRAINT fk_fase_jogo
        FOREIGN KEY (fase) REFERENCES fase(sigla),
    --
    CONSTRAINT fk_codEstadio
        FOREIGN KEY (codEstadio) REFERENCES estadio (codigo),
    --
    CONSTRAINT fk_edicao
        FOREIGN KEY (edicao) REFERENCES edicao(ano),
    --
    CONSTRAINT ck_jogo_nSequencial
        CHECK (nSequencial BETWEEN 0 AND 99),
    --
    CONSTRAINT ck_jogo_duracao
        CHECK (duracao BETWEEN 0 AND 130)  -- 0 minutos no mínimo e 120 no máximo mais 10 de possivel compensação
    --
);

-- ----------------------------------------------------------------------------

CREATE TABLE equipa(

    pais    VARCHAR(20),
    pontos  NUMERIC(1),
    grupo   CHAR(1) NOT NULL,
    edicao  NUMERIC(4),
    --
    CONSTRAINT pk_equipa
        PRIMARY KEY (pais, edicao),
    --
    CONSTRAINT fk_equipa_grupo
        FOREIGN KEY (grupo) REFERENCES fase (sigla),
    --
    CONSTRAINT fk_equipa_edicao
        FOREIGN KEY (edicao) REFERENCES edicao (ano),
    --
    CONSTRAINT ck_pontos
        CHECK (pontos BETWEEN 0 AND 9)
);

-- ----------------------------------------------------------------------------

CREATE TABLE treinador(

    passaporte      NUMERIC(6),
    nacionalidade   VARCHAR(20) NOT NULL,
    genero          CHAR(1) NOT NULL,
    nome            VARCHAR(40) NOT NULL,
    nascimento      DATE NOT NULL,
    inicio          NUMERIC(4) NOT NULL, -- 4 pois é o ano de inicio 
    equipa          VARCHAR(20) NOT NULL,
    edicao          NUMERIC(4) NOT NULL,
    --
    CONSTRAINT pk_treinador
        PRIMARY KEY (passaporte),
    --
    CONSTRAINT fk_equipa_pertencente_treinador
        FOREIGN KEY (equipa, edicao) REFERENCES equipa (pais, edicao), -- TEM DE TER A CHAVE DA EQUIPA A QUE PERTENCE
    --
    CONSTRAINT ck_genero_membro
        CHECK (genero in ('M', 'F')),
    --
    CONSTRAINT ck_edicao_inicio
        CHECK (inicio <= edicao),
    --
    CONSTRAINT ck_edicao_nascimento
        CHECK (YEAR(nascimento) < edicao),
    --
    CONSTRAINT ck_inicio_nascimento
        CHECK (inicio > YEAR(nascimento)) 
);

-- ----------------------------------------------------------------------------

CREATE TABLE jogador(

    passaporte      NUMERIC(6),
    nacionalidade   VARCHAR(20) NOT NULL,
    genero          CHAR(1) NOT NULL,
    nome            VARCHAR(40) NOT NULL,
    nascimento      DATE NOT NULL,
    inicio          NUMERIC(4) NOT NULL, -- 4 pois é o ano de inicio 
    equipa          VARCHAR(20) NOT NULL,
    papeis          VARCHAR(40) NOT NULL,
    camisola        CHAR (2) NOT NULL,
    edicao          NUMERIC(4) NOT NULL,
    --
    CONSTRAINT pk_passaporte_jogador
        PRIMARY KEY(passaporte, papeis),
    --
    CONSTRAINT fk_equipa_pertencente_jogador
        FOREIGN KEY (equipa, edicao) REFERENCES equipa (pais, edicao),
    --
    CONSTRAINT ck_genero_membro
        CHECK (genero in ('M', 'F')),
    --
    CONSTRAINT ck_edicao_inicio
        CHECK (inicio <= edicao),
    --
    CONSTRAINT ck_edicao_nascimento
        CHECK (YEAR(nascimento) < edicao),
    --
    CONSTRAINT ck_inicio_nascimento
        CHECK (inicio > YEAR(nascimento)),
    --
    CONSTRAINT ck_camisola_jogador
        CHECK (camisola BETWEEN 1 AND 99),
    --
    CONSTRAINT ck_nacionalidade_equipa_jogador
        CHECK (equipa LIKE nacionalidade)
);

-- ----------------------------------------------------------------------------

CREATE TABLE jogado_por(
    jogo            NUMERIC(2),
    equipa1_pais    VARCHAR(50)     NOT NULL,
    equipa2_pais    VARCHAR(50)     NOT NULL,
    equipa1_golos   NUMERIC(2)      NOT NULL,
    equipa2_golos   NUMERIC(2)      NOT NULL,
    golos           NUMERIC(2)      NOT NULL,
    edicao_equipa1  NUMERIC(4)      NOT NULL,
    edicao_equipa2  NUMERIC(4)      NOT NULL,
    edicao_jogo     NUMERIC(4)      NOT NULL,
    fase            VARCHAR(2)      NOT NULL,
    --
    CONSTRAINT jogado_por
        PRIMARY KEY (jogo, equipa1_pais, equipa2_pais),
    --
    CONSTRAINT fk_equipa1_pais
        FOREIGN KEY (equipa1_pais, edicao_equipa1) REFERENCES equipa (pais, edicao),
    --
    CONSTRAINT fk_equipa2_pais
        FOREIGN KEY (equipa2_pais, edicao_equipa2) REFERENCES equipa (pais, edicao),
    --
    CONSTRAINT fk_jogo_jogador_por
        FOREIGN KEY (jogo, fase ,edicao_jogo) REFERENCES jogo (nSequencial, fase ,edicao),
    --
    CONSTRAINT ck_jogo_equipas
        CHECK (equipa1_pais != equipa2_pais),
    --
    CONSTRAINT ck_edicoes
        CHECK ( edicao_jogo = edicao_equipa1 AND edicao_equipa1 = edicao_equipa2 ),
    --
    CONSTRAINT ck_golos
        CHECK(golos = (equipa1_golos + equipa2_golos))
);

-- ----------------------------------------------------------------------------

CREATE TABLE regista(

    jogador     NUMERIC(6), -- passaporte do jogador
    jogo        NUMERIC(2),
    papel       VARCHAR(20), -- papel em que jogou
    minuto      NUMERIC(3), -- minuto do golo
    entrada     NUMERIC(3),
    saida       NUMERIC(3),
    auto_golo   NUMERIC(3), -- minuto de um possivel autogolo
    papeis_bons VARCHAR(40),
    --
    CONSTRAINT pk_regista
        PRIMARY KEY (jogador, jogo),
    --
    CONSTRAINT fk_jogador
        FOREIGN KEY (jogador, papeis_bons) REFERENCES jogador (passaporte, papeis),
    --
    CONSTRAINT fk_jogo_jogado
        FOREIGN KEY (jogo) REFERENCES jogo(nSequencial),
    --
    -- CONSTRAINT ck_papel_papeis_bons
        -- CHECK (papeis_bons LIKE '%' + papel + '%'),
    --
    CONSTRAINT ck_entrada_saida
        CHECK ( entrada < saida),
    --
    CONSTRAINT ck_minuto_entrada_saida
        CHECK ( minuto BETWEEN entrada AND saida),
    --
    CONSTRAINT  ck_auto_golo_entrada_saida
        CHECK ( auto_golo BETWEEN  entrada AND saida)

);

-- ----------------------------------------------------------------------------

CREATE TABLE espetador(

    bilhetes_comprados  NUMERIC(2),
    nome                VARCHAR(40) NOT NULL,
    email               VARCHAR(40) NOT NULL,
    fã                  VARCHAR(40),
    telefone            VARCHAR(15), -- varchar visto que dependendo dos prefixos podem ser menos de 15
    VAT                 NUMERIC(11),
    claque              VARCHAR(20),
    --
    CONSTRAINT un_email
        UNIQUE (email),
    --
    CONSTRAINT pk_telemovel
        PRIMARY KEY (telefone),
    --
    CONSTRAINT ck_bilhetes_comprados
        CHECK (bilhetes_comprados BETWEEN 0 AND 99)

);

-- ----------------------------------------------------------------------------

CREATE TABLE bilhete(

    lugar           VARCHAR(40),
    nome_comprador  VARCHAR(40) NOT NULL,
    recibo          BOOLEAN,
    telefone        VARCHAR(15), -- varchar visto que dependendo dos prefixos podem ser menos de 15
    preço           NUMERIC(3),
    jogo            NUMERIC(2),
    fase            VARCHAR(2),
    edicao          NUMERIC(4),

    CONSTRAINT pk_bilhete
        PRIMARY KEY (lugar, preço, jogo),
    --
    CONSTRAINT fk_telefone
        FOREIGN KEY (telefone) REFERENCES espetador(telefone),
    --
    CONSTRAINT fk_jogo_bilhete
        FOREIGN KEY (jogo, fase, edicao) REFERENCES jogo(nSequencial, fase, edicao),
    --
    CONSTRAINT ck_preco
        CHECK ( preço BETWEEN 0 AND 999)

);

-- ----------------------------------------------------------------------------

CREATE TABLE desconto(

    percentagem     NUMERIC(3),
    espetador       VARCHAR(15), -- varchar visto que dependendo dos prefixos podem ser menos de 15
    --
    CONSTRAINT pk_desconto
        PRIMARY KEY (percentagem, espetador),
    --
    CONSTRAINT fk_espetador
        FOREIGN KEY (espetador) REFERENCES espetador(telefone) ON DELETE CASCADE,
    --
    CONSTRAINT ck_percentagem
        CHECK (percentagem BETWEEN 0 AND 100)

);

-- ----------------------------------------------------------------------------

CREATE TABLE preco_comprados(
    valor           NUMERIC(4),
    zona            VARCHAR(1),
    desconto        NUMERIC(3),
    jogo            NUMERIC (2),
    bilhete         VARCHAR(40),
    cod             NUMERIC(3),
    bilhetes_sobram NUMERIC(6),
    --
    CONSTRAINT pk_preço
        PRIMARY KEY (bilhete, valor),
    --
    CONSTRAINT fk_bilhete_preço
        FOREIGN KEY (bilhete) REFERENCES bilhete(lugar) ON DELETE CASCADE ,
    --
    CONSTRAINT fk_desconto
        FOREIGN KEY (desconto) REFERENCES desconto(percentagem),
    --
    CONSTRAINT fk_jogo_preco
        FOREIGN KEY (jogo) REFERENCES jogo(nSequencial),
    --
    CONSTRAINT fk_zona_preço
        FOREIGN KEY (cod,zona) REFERENCES zona(codigo, letra) ,
    --
    CONSTRAINT ck_valor 
        CHECK (valor > 0.0),
    --
    CONSTRAINT ck_desconto
        CHECK (desconto BETWEEN 0 AND 100),
    --
    CONSTRAINT  ck_bilhetes_sobram
        CHECK ( bilhetes_sobram BETWEEN 0 AND 999999)
);




-- ----------------------------------------------------------------------------

CREATE TABLE comentarios (

    numero_sequencial   NUMERIC(6),
    tipo                CHAR(1) NOT NULL,
    data_comentario     DATE NOT NULL,
    hora                TIME NOT NULL,
    likes               NUMERIC(10) NOT NULL,
    dislikes            NUMERIC(10) NOT NULL,
    popularidade        NUMERIC(10) NOT NULL,
    jogo                NUMERIC(2),
    pessoa              VARCHAR(15), -- varchar visto que dependendo dos prefixos podem ser menos de 15
    --
    CONSTRAINT pk_comentarios
        PRIMARY KEY (numero_sequencial),
    --
    CONSTRAINT  fk_jogo_comentarios
        FOREIGN KEY (jogo) REFERENCES jogo(nSequencial),
    --
    CONSTRAINT fk_pessoa_comentario
        FOREIGN KEY (pessoa) REFERENCES espetador(telefone),
    --
    CONSTRAINT ck_comentario_tipo
        CHECK (tipo in ('P', 'R')), -- publicacao ou resposta
    --
    CONSTRAINT ck_comentario_likes
        CHECK (likes >= 0),
    --
    CONSTRAINT ck_comentario_dislikes
        CHECK (dislikes >= 0),
    --
    CONSTRAINT ck_numero_sequencia
        CHECK ( numero_sequencial BETWEEN  0 AND 999999),
    --
    CONSTRAINT ck_likes_dislikes_popularidade
        CHECK ( popularidade = likes - dislikes )
);

-- ----------------------------------------------------------------------------
--                                 RIAS:                                  --
-- ----------------------------------------------------------------------------

-- RIA 1: A localização do estadio  contém a cidade e o pais.
--  ex:   'Brasil-Salvador'

-- RIA 2: A nacionalidade do jogador tem de ser o nome do país.

-- RIA 3: Na fase de grupos as duas equipas que jogam entre sí têm de pertencer
--          ao mesmko grupo

-- RIA 4: Não podem estar mais de 11 jogadores de cada equipa em campo em simultaneo

-- ----------------------------------------------------------------------------
--                                 INSERTS:                                  --
-- ----------------------------------------------------------------------------

-- edicao

INSERT INTO edicao (ano, pais)
     VALUES (2022, 'Catar');

INSERT INTO edicao (ano, pais)
     VALUES (2018, 'Rússia');

INSERT INTO edicao (ano, pais)
     VALUES (2014, 'Brasil');

INSERT INTO edicao (ano, pais)
     VALUES (2012, 'Japão');

INSERT INTO edicao (ano, pais)
     VALUES (2024, 'Japão');

INSERT INTO edicao (ano, pais)
     VALUES (1998, 'França');


-- --------------------------------------------------------------------------

-- fase

INSERT INTO fase (sigla, periodo, inicio, fim)
     VALUES ('A', 14, '2018-06-14', '2018-06-28');

INSERT INTO fase (sigla, periodo, inicio, fim)
     VALUES ('A', 14, '2022-06-14', '2022-06-28');

INSERT INTO fase (sigla, periodo, inicio, fim)
     VALUES ('D', 14, '2016-06-14', '2016-06-28');

INSERT INTO fase (sigla, periodo, inicio, fim)
     VALUES ('H', 10, '2020-06-14', '2020-06-24');

INSERT INTO fase (sigla, periodo, inicio, fim)
     VALUES ('OF', 3, '2018-07-01', '2018-07-04');

INSERT INTO fase (sigla, periodo, inicio, fim)
     VALUES ('SF', 1, '2014-07-08', '2014-07-09');

INSERT INTO fase (sigla, periodo, inicio, fim)
     VALUES ('SF', 1, '2018-07-08', '2018-07-09');

-- --------------------------------------------------------------------------

-- estadio

INSERT INTO estadio (codigo, nome, localizacao, lotacao, website)
     VALUES (123,'Al Bayt', 'Catar-Al-Khor', 60000,'www.aspirezone.qa' );

INSERT INTO estadio (codigo, nome, localizacao, lotacao, website)
     VALUES (321,'Arena Fonte Nova', 'Brasil-Salvador', 50000,'www.itaipavaarenafontenova.com.br');

INSERT INTO estadio (codigo, nome, localizacao, lotacao, website)
     VALUES (111,'Estádio de Toyota', 'Japão-Toyota', 45000,'www.toyotacenter.com' );

INSERT INTO estadio (codigo, nome, localizacao, lotacao, website)
     VALUES (378,'Stade de France', 'França-Paris', 81338,'www.stadefrance.com');

INSERT INTO estadio (codigo, nome, localizacao, lotacao, website)
     VALUES (465,'Al Janoub', 'Catar-Al-Wakrah', 40000,'www.qatar2022.qa/en/stadiums/al-janoub-stadium');

-- --------------------------------------------------------------------------

-- zona
INSERT INTO zona(codigo, letra)
    VALUES (465, 'A');

INSERT INTO zona(codigo, letra)
    VALUES (465, 'D');

INSERT INTO zona(codigo, letra)
    VALUES (123, 'T');

INSERT INTO zona(codigo, letra)
    VALUES (123, 'A');

INSERT INTO zona(codigo, letra)
    VALUES (378, 'D');

INSERT INTO zona(codigo, letra)
    VALUES (111, 'Z');



-- --------------------------------------------------------------------------

-- jogo

INSERT INTO jogo (nSequencial, data, horaInicio, duracao, fase, codEstadio, edicao)
     VALUES (1, '2012-12-12', '20:00:00', 95, 'SF', 111, 2022);

INSERT INTO jogo (nSequencial, data, horaInicio, duracao, fase, codEstadio, edicao)
     VALUES (2, '2012-06-12', '17:00:00', 90, 'SF', 321, 2012);

INSERT INTO jogo (nSequencial, data, horaInicio, duracao, fase, codEstadio, edicao)
     VALUES (2, '2014-06-12', '20:00:00', 97, 'H', 111, 2018);

INSERT INTO jogo (nSequencial, data, horaInicio, duracao, fase, codEstadio, edicao)
     VALUES (5, '2022-06-12', '14:00:00', 90, 'A', 321, 2022);

INSERT INTO jogo (nSequencial, data, horaInicio, duracao, fase, codEstadio, edicao)
     VALUES (12, '2012-07-02', '17:00:00', 90, 'H', 378, 2012);

INSERT INTO jogo (nSequencial, data, horaInicio, duracao, fase, codEstadio, edicao)
     VALUES (22, '2022-07-22', '20:00:00', 90, 'SF', 465, 2022);

-- ----------------------------------------------------------------------------

-- equipa

INSERT INTO equipa (pais,pontos, grupo, edicao)
     VALUES ('Portugal', 7, 'A', 2022);

INSERT INTO equipa (pais,pontos, grupo, edicao)
     VALUES ('Portugal', 2, 'D', 2012);

INSERT INTO equipa (pais,pontos, grupo, edicao)
     VALUES ('França', 5, 'H', 2012);

INSERT INTO equipa (pais,pontos, grupo, edicao)
     VALUES ('Japão', 5, 'H', 2014);

INSERT INTO equipa (pais,pontos, grupo, edicao)
     VALUES ('Senegal', 6, 'H', 2018);

INSERT INTO equipa (pais,pontos, grupo, edicao)
     VALUES ('Brasil', 7, 'A', 2018);

INSERT INTO equipa (pais,pontos, grupo, edicao)
     VALUES ('Brasil', 7, 'A', 2022);

-- ----------------------------------------------------------------------------

-- treinador

INSERT INTO treinador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, edicao)
     VALUES (447951, 'Brasil', 'M', 'Fabricio Scolari', '1948-11-09','1966','Portugal', 2012);

INSERT INTO treinador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, edicao)
     VALUES (234669, 'Espanha', 'M', 'Vicente del Bosque', '1950-12-23','1966','Senegal', 2018);

INSERT INTO treinador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, edicao)
     VALUES (738927, 'Japão', 'M', 'Tetsuji Hashiratani', '1964-07-15','1984', 'Japão', 2014);

INSERT INTO treinador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, edicao)
     VALUES (395720, 'Portugal', 'M', 'Fernando Santos', '1954-10-10','1978', 'Portugal', 2022);

INSERT INTO treinador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, edicao)
     VALUES (657392, 'Brasil', 'M', 'Adenor Bachi (Tite)', '1961-05-25','1978', 'Brasil', 2022);

-- ----------------------------------------------------------------------------

-- jogador

INSERT INTO jogador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, papeis, camisola, edicao)
     VALUES (983510, 'Portugal', 'M', 'Cristiano Ronaldo', '1985-02-05','1993','Portugal','extremo esquerdo, ponta de lança','7', 2012);

INSERT INTO jogador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, papeis, camisola, edicao)
     VALUES (578893, 'Senegal', 'M', 'Leonel Messi', '1987-06-24','1995','Senegal','avançado','30', 2018);

INSERT INTO jogador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, papeis, camisola, edicao)
     VALUES (578893, 'Japão', 'M', 'Shogo Taniguchi', '1991-07-15','1995','Japão','defesa','5', 2014);

INSERT INTO jogador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, papeis, camisola, edicao)
     VALUES (256147, 'Portugal', 'M', 'Rui Costa', '1970-09-06','1985','Portugal','médio','10', 2012);

INSERT INTO jogador (passaporte, nacionalidade, genero, nome, nascimento, inicio, equipa, papeis, camisola, edicao)
     VALUES (862486, 'Brasil', 'M', 'Neymar Jr', '1987-02-24','2003','Brasil','médio, extremo direito','10', 2022);

-- ----------------------------------------------------------------------------

-- jogado_por

INSERT INTO jogado_por (jogo, equipa1_pais, equipa2_pais, equipa1_golos, equipa2_golos, golos, edicao_equipa1, edicao_equipa2,edicao_jogo ,fase)
     VALUES (1, 'Portugal', 'Brasil', 1, 0, 1, 2022, 2022, 2022, 'SF');

INSERT INTO jogado_por (jogo, equipa1_pais, equipa2_pais, equipa1_golos, equipa2_golos, golos, edicao_equipa1, edicao_equipa2,edicao_jogo ,fase)
     VALUES (2, 'Portugal', 'França', 1, 2, 3, 2012, 2012, 2012, 'SF');

INSERT INTO jogado_por (jogo, equipa1_pais, equipa2_pais, equipa1_golos, equipa2_golos, golos, edicao_equipa1, edicao_equipa2,edicao_jogo ,fase)
     VALUES (2, 'Senegal', 'Brasil', 2, 2, 4, 2018, 2018, 2018, 'H');

-- ----------------------------------------------------------------------------

-- regista

INSERT INTO regista (jogador, jogo, papel, minuto, entrada, saida, auto_golo, papeis_bons)
     VALUES (983510, 1, 'ponta de lança', 12, 00, 85, NULL, 'extremo esquerdo, ponta de lança');

INSERT INTO regista (jogador, jogo, papel, minuto, entrada, saida, auto_golo, papeis_bons)
     VALUES (578893, 12, 'avançado', 67, 45, NULL, NULL, 'avançado');

INSERT INTO regista (jogador, jogo, papel, minuto, entrada, saida, auto_golo, papeis_bons)
     VALUES (256147,5, 'médio', 32, 00, 65, NULL, 'médio');

-- ----------------------------------------------------------------------------

-- espetador

INSERT INTO espetador (bilhetes_comprados, nome, email, fã, telefone, VAT, claque)
     VALUES (2, 'Mário Sousa', 'mariosousa@gmail.com','Ronaldo, Neymar', '+3519127654', 12345678912, 'Portugal');

INSERT INTO espetador (bilhetes_comprados, nome, email, fã, telefone, VAT, claque)
     VALUES (5, 'Carla Maria', 'carlamaria@gmail.com','Messi', '0022934576072', 98765432198, 'Senegal');

INSERT INTO espetador (bilhetes_comprados, nome, email, fã, telefone, VAT, claque)
     VALUES (2, 'Maurilio Silvestre', 'maurivestre@outlook.com','Neymar, Gabriel Jesus', '+5598258746', NULL, 'Brasil');

INSERT INTO espetador (bilhetes_comprados, nome, email, fã, telefone, VAT, claque)
     VALUES (10, 'Naomi Ayumi', 'naomiayumi@gmail.jpn','Nakata', '+8112347684', NULL, NULL);

INSERT INTO espetador (bilhetes_comprados, nome, email, fã, telefone, VAT, claque)
     VALUES (15, 'Marta Fernandes', 'm_fernandes@outlook.com','Cristiano Ronaldo, Shogo Taniguchi', '+351934576072', 98765432198, 'Bélgica');

-- ----------------------------------------------------------------------------

-- desconto
INSERT INTO desconto (percentagem, espetador)
     VALUES (20, '+3519127654');

INSERT INTO desconto (percentagem, espetador)
     VALUES (0, '+5598258746');

INSERT INTO desconto (percentagem, espetador)
     VALUES (50, '+8112347684');

INSERT INTO desconto (percentagem, espetador)
     VALUES (100, '+351934576072');

-- ----------------------------------------------------------------------------

-- bilhete
INSERT INTO bilhete (lugar, nome_comprador, recibo, telefone, preço, jogo)
     VALUES ('A283', 'Mário Sousa', true, '+3519127654', 60, 1);

INSERT INTO bilhete (lugar, nome_comprador, recibo, telefone, preço, jogo)
     VALUES ('B234', 'Naomi Ayumi', false, '+8112347684', 30, 12);

INSERT INTO bilhete (lugar, nome_comprador, recibo, telefone, preço, jogo)
     VALUES ('B662', 'Naomi Ayumi', true, '+8112347684', 45, 12);

INSERT INTO bilhete (lugar, nome_comprador, recibo, telefone, preço, jogo)
     VALUES ('C341', 'Carla Maria', false, '0022934576072', 45, 2);

INSERT INTO bilhete (lugar, nome_comprador, recibo, telefone, preço, jogo)
     VALUES ('C341', 'Maurilio Silvestre', false, '+5598258746', 60, 12);

-- ----------------------------------------------------------------------------

-- preco_comprados

INSERT INTO preco_comprados (valor, zona, desconto, jogo, bilhete, bilhetes_sobram)
     VALUES (60, 'A', 0 , 12, 'A283', 65000);

INSERT INTO preco_comprados (valor, zona, desconto, jogo, bilhete, bilhetes_sobram)
     VALUES (45, 'T', 50 , 2, 'B662', 59760);

INSERT INTO preco_comprados (valor, zona, desconto, jogo, bilhete, bilhetes_sobram)
     VALUES (20, 'D', 50 , 1, 'B234', 20000);

INSERT INTO preco_comprados (valor, zona, desconto, jogo, bilhete, bilhetes_sobram)
     VALUES (60, 'Z', 20 , 12, 'C341', 64680);

-- ----------------------------------------------------------------------------

-- comentarios

INSERT INTO comentarios(numero_sequencial, tipo, data_comentario, hora, likes, dislikes, popularidade, jogo, pessoa)
    VALUES (12345, 'R', '2012-12-12', '20:00:00', 1200, 10, 1190, 1, '+3519127654');


INSERT INTO comentarios(numero_sequencial, tipo, data_comentario, hora, likes, dislikes, popularidade, jogo, pessoa)
    VALUES (85472, 'P', '2022-07-22', '20:00:00', 71, 1, 70, 12, '+5598258746');

INSERT INTO comentarios(numero_sequencial, tipo, data_comentario, hora, likes, dislikes, popularidade, jogo, pessoa)
    VALUES (14782, 'R', '2012-12-12', '20:00:00', 1200, 10, 1190, 1, '+5598258746');

INSERT INTO comentarios(numero_sequencial, tipo, data_comentario, hora, likes, dislikes, popularidade, jogo, pessoa)
    VALUES (14732, 'P', '2014-07-1', '20:32:00', 100, 8, 92, 2, '+8112347684');

-- ----------------------------------------------------------------------------

COMMIT;

-- ----------------------------------------------------------------------------
