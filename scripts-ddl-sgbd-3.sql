-- =============================================================================
-- RED SOCIAL ESTUDIANTIL PASCUALINA - TAREA 4 (Microsoft SQL Server)
-- Autores: Deimar Copete Murillo e Iván Bolaños
-- =============================================================================

IF OBJECT_ID('dbo.participa_en', 'U') IS NOT NULL DROP TABLE dbo.participa_en;
IF OBJECT_ID('dbo.reacciona_a', 'U') IS NOT NULL DROP TABLE dbo.reacciona_a;
IF OBJECT_ID('dbo.pertenece_grupo', 'U') IS NOT NULL DROP TABLE dbo.pertenece_grupo;
IF OBJECT_ID('dbo.conecta_con', 'U') IS NOT NULL DROP TABLE dbo.conecta_con;
IF OBJECT_ID('dbo.tiene_interes', 'U') IS NOT NULL DROP TABLE dbo.tiene_interes;
IF OBJECT_ID('dbo.comentario', 'U') IS NOT NULL DROP TABLE dbo.comentario;
IF OBJECT_ID('dbo.evento', 'U') IS NOT NULL DROP TABLE dbo.evento;
IF OBJECT_ID('dbo.grupo', 'U') IS NOT NULL DROP TABLE dbo.grupo;
IF OBJECT_ID('dbo.publicacion', 'U') IS NOT NULL DROP TABLE dbo.publicacion;
IF OBJECT_ID('dbo.interes_habilidad', 'U') IS NOT NULL DROP TABLE dbo.interes_habilidad;
IF OBJECT_ID('dbo.usuario', 'U') IS NOT NULL DROP TABLE dbo.usuario;
IF OBJECT_ID('dbo.area_estudio', 'U') IS NOT NULL DROP TABLE dbo.area_estudio;

CREATE TABLE dbo.area_estudio (
    id_area INT IDENTITY(1,1) CONSTRAINT pk_area_estudio PRIMARY KEY,
    nombre_area VARCHAR(100) NOT NULL CONSTRAINT uk_nombre_area UNIQUE,
    facultad VARCHAR(100) NOT NULL
);

CREATE TABLE dbo.usuario (
    id_usuario INT IDENTITY(1,1) CONSTRAINT pk_usuario PRIMARY KEY,
    id_area INT NOT NULL CONSTRAINT fk_usuario_area REFERENCES dbo.area_estudio(id_area) ON DELETE NO ACTION ON UPDATE CASCADE,
    nombre_completo VARCHAR(150) NOT NULL,
    correo_institucional VARCHAR(150) NOT NULL CONSTRAINT uk_usuario_correo UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    foto_perfil VARCHAR(255),
    biografia VARCHAR(MAX),
    CONSTRAINT chk_correo_pascualino CHECK (correo_institucional LIKE '%@pascualbravo.edu.co')
);

CREATE TABLE dbo.interes_habilidad (
    id_interes INT IDENTITY(1,1) CONSTRAINT pk_interes_habilidad PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL CONSTRAINT uk_nombre_interes UNIQUE,
    categoria VARCHAR(50) NOT NULL
);

CREATE TABLE dbo.publicacion (
    id_publicacion INT IDENTITY(1,1) CONSTRAINT pk_publicacion PRIMARY KEY,
    id_usuario INT NOT NULL CONSTRAINT fk_publicacion_usuario REFERENCES dbo.usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    tipo VARCHAR(50) DEFAULT 'Pregunta' NOT NULL,
    contenido VARCHAR(MAX) NOT NULL,
    fecha_publicacion DATETIME DEFAULT GETDATE(),
    metadata_iot NVARCHAR(MAX),
    CONSTRAINT chk_tipo_publicacion CHECK (tipo IN ('Pregunta', 'Recurso', 'Noticia', 'Meme', 'General')),
    CONSTRAINT chk_valid_json_pub CHECK (metadata_iot IS NULL OR ISJSON(metadata_iot) > 0)
);

CREATE TABLE dbo.comentario (
    id_comentario INT IDENTITY(1,1) CONSTRAINT pk_comentario PRIMARY KEY,
    id_publicacion INT NOT NULL CONSTRAINT fk_comentario_publicacion REFERENCES dbo.publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    id_usuario INT NOT NULL CONSTRAINT fk_comentario_usuario REFERENCES dbo.usuario(id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    contenido VARCHAR(MAX) NOT NULL,
    fecha_comentario DATETIME DEFAULT GETDATE()
);

CREATE TABLE dbo.grupo (
    id_grupo INT IDENTITY(1,1) CONSTRAINT pk_grupo PRIMARY KEY,
    id_creador INT NOT NULL CONSTRAINT fk_grupo_creador REFERENCES dbo.usuario(id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    nombre_grupo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(MAX),
    tipo_grupo VARCHAR(50) DEFAULT 'Estudio' NOT NULL,
    fecha_creacion DATE DEFAULT CAST(GETDATE() AS DATE)
);

CREATE TABLE dbo.evento (
    id_evento INT IDENTITY(1,1) CONSTRAINT pk_evento PRIMARY KEY,
    id_organizador INT NOT NULL CONSTRAINT fk_evento_organizador REFERENCES dbo.usuario(id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    id_grupo INT CONSTRAINT fk_evento_grupo REFERENCES dbo.grupo(id_grupo) ON DELETE SET NULL ON UPDATE CASCADE,
    nombre_evento VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_hora_inicio DATETIME NOT NULL,
    fecha_hora_fin DATETIME NOT NULL,
    ubicacion VARCHAR(255) NOT NULL,
    datos_geograficos_iot NVARCHAR(MAX),
    CONSTRAINT chk_fechas_evento CHECK (fecha_hora_fin > fecha_hora_inicio),
    CONSTRAINT chk_valid_json_evt CHECK (datos_geograficos_iot IS NULL OR ISJSON(datos_geograficos_iot) > 0)
);

CREATE TABLE dbo.tiene_interes (
    id_usuario INT NOT NULL CONSTRAINT fk_ti_usuario REFERENCES dbo.usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_interes INT NOT NULL CONSTRAINT fk_ti_interes REFERENCES dbo.interes_habilidad(id_interes) ON DELETE CASCADE ON UPDATE CASCADE,
    nivel VARCHAR(30) DEFAULT 'Principiante' NOT NULL,
    CONSTRAINT pk_tiene_interes PRIMARY KEY (id_usuario, id_interes)
);

CREATE TABLE dbo.conecta_con (
    id_origen INT NOT NULL CONSTRAINT fk_cc_origen REFERENCES dbo.usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_destino INT NOT NULL CONSTRAINT fk_cc_destino REFERENCES dbo.usuario(id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    estado VARCHAR(20) DEFAULT 'Pendiente' NOT NULL,
    fecha_conexion DATETIME DEFAULT GETDATE(),
    CONSTRAINT pk_conecta_con PRIMARY KEY (id_origen, id_destino),
    CONSTRAINT chk_no_autoconexion CHECK (id_origen <> id_destino)
);

CREATE TABLE dbo.pertenece_grupo (
    id_usuario INT NOT NULL CONSTRAINT fk_pg_usuario REFERENCES dbo.usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_grupo INT NOT NULL CONSTRAINT fk_pg_grupo REFERENCES dbo.grupo(id_grupo) ON DELETE CASCADE ON UPDATE CASCADE,
    rol VARCHAR(30) DEFAULT 'Miembro' NOT NULL,
    fecha_ingreso DATETIME DEFAULT GETDATE(),
    CONSTRAINT pk_pertenece_grupo PRIMARY KEY (id_usuario, id_grupo)
);

CREATE TABLE dbo.reacciona_a (
    id_usuario INT NOT NULL CONSTRAINT fk_ra_usuario REFERENCES dbo.usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_publicacion INT NOT NULL CONSTRAINT fk_ra_publicacion REFERENCES dbo.publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    tipo_reaccion VARCHAR(30) DEFAULT 'Me gusta' NOT NULL,
    fecha_reaccion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reacciona_a PRIMARY KEY (id_usuario, id_publicacion)
);

CREATE TABLE dbo.participa_en (
    id_usuario INT NOT NULL CONSTRAINT fk_pe_usuario REFERENCES dbo.usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    id_evento INT NOT NULL CONSTRAINT fk_pe_evento REFERENCES dbo.evento(id_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    estado_asistencia VARCHAR(30) DEFAULT 'Interesado' NOT NULL,
    CONSTRAINT pk_participa_en PRIMARY KEY (id_usuario, id_evento)
);
