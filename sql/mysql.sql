CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);;

CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    site    varchar(20) NOT NULL,
    site_id varchar(100) NOT NULL,
    user_name    varchar(100) NOT NULL,
    INDEX site_id_idx (site,site_id)
);;

CREATE TABLE IF NOT EXISTS tilemaps (
    map_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    map_name varchar(200) NOT NULL,
    map_url varchar(500) NOT NULL,
    description varchar(1000),
    attribution varchar(1000),
    is_tms boolean NOT NULL,
    min_lat DOUBLE NOT NULL,
    min_lng DOUBLE NOT NULL,
    max_lat DOUBLE NOT NULL,
    max_lng DOUBLE NOT NULL, 
    geom_name varchar(200),
    min_year INTEGER,
    max_year INTEGER,
    era_name varchar(200),
    min_zoom INTEGER NOT NULL,
    max_zoom INTEGER NOT NULL,
    zoom_index DOUBLE NOT NULL,
    xml_url varchar(500),
    nontms_logic varchar(10000),
    mapgeom_id INTEGER NOT NULL,
    mapera_id INTEGER,
    INDEX map_user_idx (user_id),
    INDEX map_geom_idx (mapgeom_id),
    INDEX map_era_idx (mapera_id)   
);;

CREATE TABLE IF NOT EXISTS mapgeoms (
    geom_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    geom_type varchar(50) NOT NULL,
    geom_name varchar(200) NOT NULL,
    geoms GEOMETRY NOT NULL,
    INDEX geom_type_idx (geom_type),
    SPATIAL INDEX idx_mapgeoms_geoms (geoms)
) ENGINE=MyISAM;;

CREATE TABLE IF NOT EXISTS maperas (
    era_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    era_type varchar(50) NOT NULL,
    era_name varchar(200) NOT NULL,
    eras GEOMETRY NOT NULL,
    INDEX era_type_idx (era_type),
    SPATIAL INDEX idx_maperas_eras (eras)
) ENGINE=MyISAM;;
