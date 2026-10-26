-- =============================================================================
-- RED SOCIAL ESTUDIANTIL PASCUALINA - TAREA 4 (PostgreSQL)
-- Autores: Deimar Copete Murillo e Iván Bolaños
-- =============================================================================

DROP TABLE IF EXISTS participa_en CASCADE;
DROP TABLE IF EXISTS reacciona_a CASCADE;
DROP TABLE IF EXISTS pertenece_grupo CASCADE;
DROP TABLE IF EXISTS conecta_con CASCADE;
DROP TABLE IF EXISTS tiene_interes CASCADE;
DROP TABLE IF EXISTS comentario CASCADE;
DROP TABLE IF EXISTS evento CASCADE;
DROP TABLE IF EXISTS grupo CASCADE;
DROP TABLE IF EXISTS publicacion CASCADE;
DROP TABLE IF EXISTS interes_habilidad CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;
DROP TABLE IF EXISTS area_estudio CASCADE;

CREATE TABLE area_estudio (
    id_area SERIAL CONSTRAINT pk_area_estudio PRIMARY KEY,
    nombre_area VARCHAR(100) NOT NULL CONSTRAINT uk_nombre_area UNIQUE,
    facultad VARCHAR(100) NOT NULL
);

CREATE TABLE usuario (
    id_usuario SERIAL CONSTRAINT pk_usuario PRIMARY KEY,
    id_area INTEGER NOT NULL CONSTRAINT fk_usuario_area REFERENCES area_estudio(id_area) ON DELETE RESTRICT ON UPDATE CASCADE,
    nombre_completo VARCHAR(150) NOT NULL,
    correo_institucional VARCHAR(150) NOT NULL CONSTRAINT uk_usuario_correo UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    foto_perfil VARCHAR(255),
    biografia TEXT,
    CONSTRAINT chk_correo_pascualino CHECK (correo_institucional LIKE '%@pascualbravo.edu.co')
);

CREATE TABLE interes_habilidad (
    id_interes SERIAL CONSTRAINT pk_interes_habilidad PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL CONSTRAINT uk_nombre_interes UNIQUE,
    categoria VARCHAR(50) NOT NULL
);

CREATE TABLE publicacion (
    id_publicacion SERIAL CONSTRAINT pk_publicacion PRIMARY KEY,
    id_usuario INTEGER NOT NULL CONSTRAINT fk_publicacion_usuario REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    tipo VARCHAR(50) DEFAULT 'Pregunta' NOT NULL,
    contenido TEXT NOT NULL,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata_iot JSONB,
    CONSTRAINT chk_tipo_publicacion CHECK (tipo IN ('Pregunta', 'Recurso', 'Noticia', 'Meme', 'General'))
);

CREATE TABLE comentario (
    id_comentario SERIAL CONSTRAINT pk_comentario PRIMARY KEY,
    id_publicacion INTEGER NOT NULL CONSTRAINT fk_comentario_publicacion REFERENCES publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    id_usuario INTEGER NOT NULL CONSTRAINT fk_comentario_usuario REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE grupo (
    id_grupo SERIAL CONSTRAINT pk_grupo PRIMARY KEY,
    id_creador INTEGER NOT NULL CONSTRAINT fk_grupo_creador REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    nombre_grupo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_grupo VARCHAR(50) DEFAULT 'Estudio' NOT NULL,
    fecha_creacion DATE DEFAULT CURRENT_DATE
);

CREATE TABLE evento (
    id_evento SERIAL CONSTRAINT pk_evento PRIMARY KEY,
    id_organizador INTEGER NOT NULL CONSTRAINT fk_evento_organizador REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_grupo INTEGER CONSTRAINT fk_evento_grupo REFERENCES grupo(id_grupo) ON DELETE SET NULL ON UPDATE CASCADE,
    nombre_evento VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_hora_inicio TIMESTAMP NOT NULL,
    fecha_hora_fin TIMESTAMP NOT NULL,
    ubicacion VARCHAR(255) NOT NULL,
    datos_geograficos_iot JSONB,
    CONSTRAINT chk_fechas_evento CHECK (fecha_hora_fin > fecha_hora_inicio)
);

CREATE TABLE tiene_interes (
    id_usuario INTEGER NOT NULL CONSTRAINT fk_ti_usuario REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_interes INTEGER NOT NULL CONSTRAINT fk_ti_interes REFERENCES interes_habilidad(id_interes) ON DELETE CASCADE ON UPDATE CASCADE,
    nivel VARCHAR(30) DEFAULT 'Principiante' NOT NULL,
    CONSTRAINT pk_tiene_interes PRIMARY KEY (id_usuario, id_interes)
);

CREATE TABLE conecta_con (
    id_origen INTEGER NOT NULL CONSTRAINT fk_cc_origen REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_destino INTEGER NOT NULL CONSTRAINT fk_cc_destino REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    estado VARCHAR(20) DEFAULT 'Pendiente' NOT NULL,
    fecha_conexion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_conecta_con PRIMARY KEY (id_origen, id_destino),
    CONSTRAINT chk_no_autoconexion CHECK (id_origen <> id_destino)
);

CREATE TABLE pertenece_grupo (
    id_usuario INTEGER NOT NULL CONSTRAINT fk_pg_usuario REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_grupo INTEGER NOT NULL CONSTRAINT fk_pg_grupo REFERENCES grupo(id_grupo) ON DELETE CASCADE ON UPDATE CASCADE,
    rol VARCHAR(30) DEFAULT 'Miembro' NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_pertenece_grupo PRIMARY KEY (id_usuario, id_grupo)
);

CREATE TABLE reacciona_a (
    id_usuario INTEGER NOT NULL CONSTRAINT fk_ra_usuario REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_publicacion INTEGER NOT NULL CONSTRAINT fk_ra_publicacion REFERENCES publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    tipo_reaccion VARCHAR(30) DEFAULT 'Me gusta' NOT NULL,
    fecha_reaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reacciona_a PRIMARY KEY (id_usuario, id_publicacion)
);

CREATE TABLE participa_en (
    id_usuario INTEGER NOT NULL CONSTRAINT fk_pe_usuario REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_evento INTEGER NOT NULL CONSTRAINT fk_pe_evento REFERENCES evento(id_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    estado_asistencia VARCHAR(30) DEFAULT 'Interesado' NOT NULL,
    CONSTRAINT pk_participa_en PRIMARY KEY (id_usuario, id_evento)
);
