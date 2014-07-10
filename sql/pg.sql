CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);;

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    site    varchar(20) NOT NULL,
    site_id varchar(100) NOT NULL,
    user_name    varchar(100) NOT NULL
);;

DO $$
  BEGIN
    CREATE INDEX site_id_idx ON users (site,site_id); 
  EXCEPTION
    WHEN OTHERS THEN
      RETURN; 
  END; 
$$;;

CREATE TABLE IF NOT EXISTS tilemaps (
    map_id SERIAL PRIMARY KEY,
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
    min_zoom INTEGER NOT NULL,
    max_zoom INTEGER NOT NULL,
    zoom_index FLOAT NOT NULL,
    xml_url varchar(500),
    nontms_logic varchar(10000),
    mapbounds GEOMETRY(GEOMETRY,4326)
);;

DO $$
  BEGIN
    CREATE INDEX map_user_idx ON tilemaps (user_id); 
  EXCEPTION
    WHEN OTHERS THEN
      RETURN; 
  END; 
$$;;

DO $$
  BEGIN
    CREATE INDEX map_geo_idx ON tilemaps USING GIST (mapbounds); 
  EXCEPTION
    WHEN OTHERS THEN
      RETURN; 
  END; 
$$;;
