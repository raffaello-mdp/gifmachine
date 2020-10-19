-- SCRIPT TO SETUP A POSTGRES INSTANCE WITH A SALSIFY DB AND A GIFS SCHEMA
-- TO RUN THIS USING TERRAFORM IT MUST NEED A VPN CONFIGURED AS THE RDS INSTANCE LIVE THE A PRIVATE SUBNET.
-- THIS SCRIPT HAS BEEN RUN MANUALLY IN AN EC2 INSTANCE IN THE SAME VPC AS THE RDS, WITH A PUBLIC IP AND ALLOWING
-- TRAFFIC ON PORT 22 FROM THE MY CURRENT IP.

REVOKE CREATE ON SCHEMA public FROM PUBLIC;

CREATE DATABASE salsify;
COMMENT ON DATABASE salsify IS 'Salsify Database';

REVOKE ALL ON DATABASE salsify FROM PUBLIC;

\c salsify

CREATE ROLE raffaellomesquita WITH LOGIN PASSWORD 'i97mJyv^6aNL';
GRANT CONNECT ON DATABASE salsify TO raffaellomesquita;

CREATE ROLE salsifyadmin;
GRANT salsifyadmin TO raffaellomesquita;

CREATE SCHEMA IF NOT EXISTS gifs;
COMMENT ON SCHEMA gifs IS 'Schema to group gifs related tables';

CREATE ROLE gifsadmin;
GRANT USAGE, CREATE ON SCHEMA gifs TO gifsadmin;

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON ALL TABLES IN SCHEMA gifs TO gifsadmin;
ALTER DEFAULT PRIVILEGES IN SCHEMA gifs GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON TABLES TO gifsadmin;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA gifs TO gifsadmin;
ALTER DEFAULT PRIVILEGES IN SCHEMA gifs GRANT USAGE ON SEQUENCES TO gifsadmin;

CREATE ROLE gifmachine WITH LOGIN PASSWORD 'KPAm$o$6*_obtm6k*';
GRANT CONNECT ON DATABASE salsify TO gifmachine;
GRANT gifsadmin TO gifmachine;
GRANT gifsadmin TO salsifyadmin;