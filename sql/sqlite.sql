CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);;

CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    site    varchar(20) NOT NULL,
    site_id varchar(100) NOT NULL,
    user_name    varchar(100) NOT NULL
);;

CREATE INDEX IF NOT EXISTS site_id_idx ON users(site,site_id);;

SELECT CASE (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='spatial_ref_sys')
    WHEN 1 THEN (SELECT 1) 
    ELSE (SELECT InitSpatialMetaData())
END;;

REPLACE INTO spatial_ref_sys (srid, auth_name, auth_srid, ref_sys_name, proj4text) VALUES (4326, 'epsg', 4326, 'WGS 84', '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs');;
REPLACE INTO spatial_ref_sys (srid, auth_name, auth_srid, ref_sys_name, proj4text) VALUES (3857, 'epsg', 3857, 'WGS 84 / Simple Mercator', '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs');;

CREATE TABLE IF NOT EXISTS tilemaps (
    map_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    map_name varchar(200) NOT NULL,
    map_url varchar(500) NOT NULL,
    description varchar(1000),
    attribution varchar(1000),
    is_tms boolean NOT NULL,
    min_lat FLOAT NOT NULL,
    min_lng FLOAT NOT NULL,
    max_lat FLOAT NOT NULL,
    max_lng FLOAT NOT NULL,
    geom_name varchar(200),
    min_year INTEGER,
    max_year INTEGER,
    era_name varchar(200),
    min_zoom INTEGER NOT NULL,
    max_zoom INTEGER NOT NULL,
    zoom_index FLOAT NOT NULL,
    xml_url varchar(500),
    nontms_logic varchar(10000),
    mapgeom_id INTEGER NOT NULL,
    mapera_id INTEGER
);;

--SELECT CASE (SELECT count(*) FROM sqlite_master WHERE type='trigger' AND name='ggi_tilemaps_mapbounds')
--    WHEN 1 THEN (SELECT 1)
--    ELSE (SELECT AddGeometryColumn('tilemaps', 'mapbounds', 4326, 'GEOMETRY', 'XY', 1))
--END;;

CREATE INDEX IF NOT EXISTS map_user_idx ON tilemaps(user_id);;
CREATE INDEX IF NOT EXISTS map_geom_idx ON tilemaps(mapgeom_id);;
CREATE INDEX IF NOT EXISTS map_era_idx ON tilemaps(mapera_id);;

--SELECT CASE (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='idx_tilemaps_mapbounds')
--    WHEN 1 THEN (SELECT 1)
--    ELSE (SELECT CreateSpatialIndex('tilemaps','mapbounds'))
--END;;

CREATE TABLE IF NOT EXISTS mapgeoms (
    geom_id INTEGER PRIMARY KEY AUTOINCREMENT,
    geom_type varchar(50) NOT NULL,
    geom_name varchar(200) NOT NULL
);;

SELECT CASE (SELECT count(*) FROM sqlite_master WHERE type='trigger' AND name='ggi_mapgeoms_geoms')
    WHEN 1 THEN (SELECT 1)
    ELSE (SELECT AddGeometryColumn('mapgeoms', 'geoms', 4326, 'GEOMETRY', 'XY', 1))
END;;

CREATE INDEX IF NOT EXISTS geom_type_idx ON mapgeoms(geom_type);;

SELECT CASE (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='idx_mapgeoms_geoms')
    WHEN 1 THEN (SELECT 1)
    ELSE (SELECT CreateSpatialIndex('mapgeoms','geoms'))
END;;

CREATE TABLE IF NOT EXISTS maperas (
    era_id INTEGER PRIMARY KEY AUTOINCREMENT,
    era_type varchar(50) NOT NULL,
    era_name varchar(200) NOT NULL
);;

SELECT CASE (SELECT count(*) FROM sqlite_master WHERE type='trigger' AND name='ggi_maperas_eras')
    WHEN 1 THEN (SELECT 1)
    ELSE (SELECT AddGeometryColumn('maperas', 'eras', -1, 'GEOMETRY', 'XY', 1))
END;;

CREATE INDEX IF NOT EXISTS era_type_idx ON maperas(era_type);;

SELECT CASE (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='idx_maperas_eras')
    WHEN 1 THEN (SELECT 1)
    ELSE (SELECT CreateSpatialIndex('maperas','eras'))
END;;






