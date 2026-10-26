-- =============================================================================
-- RED SOCIAL ESTUDIANTIL PASCUALINA - TAREA 4 (MySQL / MariaDB)
-- Autores: Deimar Copete Murillo e Iván Bolaños
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS participa_en;
DROP TABLE IF EXISTS reacciona_a;
DROP TABLE IF EXISTS pertenece_grupo;
DROP TABLE IF EXISTS conecta_con;
DROP TABLE IF EXISTS tiene_interes;
DROP TABLE IF EXISTS comentario;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS grupo;
DROP TABLE IF EXISTS publicacion;
DROP TABLE IF EXISTS interes_habilidad;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS area_estudio;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE area_estudio (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    nombre_area VARCHAR(100) NOT NULL UNIQUE,
    facultad VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_area INT NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    correo_institucional VARCHAR(150) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    foto_perfil VARCHAR(255),
    biografia TEXT,
    CONSTRAINT fk_usuario_area FOREIGN KEY (id_area) REFERENCES area_estudio(id_area) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_correo_pascualino CHECK (correo_institucional LIKE '%@pascualbravo.edu.co')
) ENGINE=InnoDB;

CREATE TABLE interes_habilidad (
    id_interes INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    categoria VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE publicacion (
    id_publicacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo VARCHAR(50) DEFAULT 'Pregunta' NOT NULL,
    contenido TEXT NOT NULL,
    fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    metadata_iot JSON,
    CONSTRAINT fk_publicacion_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_tipo_publicacion CHECK (tipo IN ('Pregunta', 'Recurso', 'Noticia', 'Meme', 'General'))
) ENGINE=InnoDB;

CREATE TABLE comentario (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_usuario INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE grupo (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_creador INT NOT NULL,
    nombre_grupo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_grupo VARCHAR(50) DEFAULT 'Estudio' NOT NULL,
    fecha_creacion DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_grupo_creador FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE evento (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    id_organizador INT NOT NULL,
    id_grupo INT,
    nombre_evento VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_hora_inicio DATETIME NOT NULL,
    fecha_hora_fin DATETIME NOT NULL,
    ubicacion VARCHAR(255) NOT NULL,
    datos_geograficos_iot JSON,
    CONSTRAINT fk_evento_organizador FOREIGN KEY (id_organizador) REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_fechas_evento CHECK (fecha_hora_fin > fecha_hora_inicio)
) ENGINE=InnoDB;

CREATE TABLE tiene_interes (
    id_usuario INT NOT NULL,
    id_interes INT NOT NULL,
    nivel VARCHAR(30) DEFAULT 'Principiante' NOT NULL,
    PRIMARY KEY (id_usuario, id_interes),
    CONSTRAINT fk_ti_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ti_interes FOREIGN KEY (id_interes) REFERENCES interes_habilidad(id_interes) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE conecta_con (
    id_origen INT NOT NULL,
    id_destino INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Pendiente' NOT NULL,
    fecha_conexion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_origen, id_destino),
    CONSTRAINT fk_cc_origen FOREIGN KEY (id_origen) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cc_destino FOREIGN KEY (id_destino) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_no_autoconexion CHECK (id_origen <> id_destino)
) ENGINE=InnoDB;

CREATE TABLE pertenece_grupo (
    id_usuario INT NOT NULL,
    id_grupo INT NOT NULL,
    rol VARCHAR(30) DEFAULT 'Miembro' NOT NULL,
    fecha_ingreso DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_pg_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pg_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reacciona_a (
    id_usuario INT NOT NULL,
    id_publicacion INT NOT NULL,
    tipo_reaccion VARCHAR(30) DEFAULT 'Me gusta' NOT NULL,
    fecha_reaccion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_publicacion),
    CONSTRAINT fk_ra_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ra_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE participa_en (
    id_usuario INT NOT NULL,
    id_evento INT NOT NULL,
    estado_asistencia VARCHAR(30) DEFAULT 'Interesado' NOT NULL,
    PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_pe_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pe_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
