CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    tipo_usuario VARCHAR(20) CHECK (tipo_usuario IN ('Solicitante', 'Gestor', 'Técnico')) NOT NULL
);

CREATE TABLE categorias_servico (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE materiais (
    id_material SERIAL PRIMARY KEY,
    nome_material VARCHAR(100) UNIQUE NOT NULL,
    unidade_medida VARCHAR(20),
    quantidade_estoque INT DEFAULT 0 CHECK (quantidade_estoque >= 0),
    vlr_custo NUMERIC(10, 2) CHECK (vlr_custo >= 0)
);

CREATE TABLE edificios (
    id_edificio SERIAL PRIMARY KEY,
    nome_edificio VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE andares (
    id_andar SERIAL PRIMARY KEY,
    id_edificio INT NOT NULL REFERENCES edificios(id_edificio),
    nome_andar VARCHAR(50) NOT NULL,
    UNIQUE (id_edificio, nome_andar) 
);

CREATE TABLE ambientes (
    id_ambiente SERIAL PRIMARY KEY,
    id_edificio INT NOT NULL REFERENCES edificios(id_edificio),
    id_andar INT NOT NULL REFERENCES andares(id_andar),
    nome_ambiente VARCHAR(100) NOT NULL,
    UNIQUE (id_edificio, id_andar, nome_ambiente) 
);

CREATE TABLE chamados (
    id_chamado SERIAL PRIMARY KEY,
    id_solicitante INT NOT NULL REFERENCES usuarios(id_usuario),
    descricao_problema TEXT NOT NULL,
    foto_endereco BYTEA,
    data_abertura DATE NOT NULL DEFAULT CURRENT_DATE,
    status_chamado VARCHAR(20) CHECK (status_chamado IN ('Aberto', 'Em Análise', 'Rejeitado', 'Concluído')) NOT NULL
);

CREATE TABLE ordens_servico (
    id_os SERIAL PRIMARY KEY,
    id_chamado INT UNIQUE REFERENCES chamados(id_chamado), 
    id_ambiente INT NOT NULL REFERENCES ambientes(id_ambiente),
    id_tecnico INT REFERENCES usuarios(id_usuario), 
    id_categoria INT NOT NULL REFERENCES categorias_servico(id_categoria),
    descricao_tecnica_servico TEXT,
    status_os VARCHAR(20) CHECK (status_os IN ('Aberto', 'Atribuído', 'Em Execução', 'Concluído')) NOT NULL,
    prioridade_os INT CHECK (prioridade_os BETWEEN 1 AND 5),
    procedimentos_necessarios TEXT,
    valor_estimado NUMERIC(10, 2) CHECK (valor_estimado >= 0),
    data_atribuicao DATE,
    data_conclusao DATE
);

CREATE TABLE historico_status_os (
    id_historico SERIAL PRIMARY KEY,
    id_os INT NOT NULL REFERENCES ordens_servico(id_os),
    status_anterior VARCHAR(20),
    status_novo VARCHAR(20) NOT NULL,
    data_mudanca TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE avaliacoes (
    id_avaliacao SERIAL PRIMARY KEY,
    id_os INT UNIQUE REFERENCES ordens_servico(id_os), 
    nota_satisfacao INT CHECK (nota_satisfacao BETWEEN 1 AND 5),
    comentario TEXT
);

CREATE TABLE os_materiais (
    id_os INT NOT NULL REFERENCES ordens_servico(id_os),
    id_material INT NOT NULL REFERENCES materiais(id_material),
    quantidade_utilizada NUMERIC(10, 2) NOT NULL CHECK (quantidade_utilizada > 0),
    PRIMARY KEY (id_os, id_material)
);