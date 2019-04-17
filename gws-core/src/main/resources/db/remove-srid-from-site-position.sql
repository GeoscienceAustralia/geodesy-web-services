--liquibase formatted sql
--changeset lbodor:1555371779

DROP VIEW v_cors_site;

ALTER TABLE site ALTER COLUMN shape TYPE geometry;

CREATE VIEW v_cors_site AS
    SELECT
        s.id,
        s.date_installed,
        s.description,
        s.name,
        s.version,
        s.shape,
        cs.bedrock_condition,
        cs.bedrock_type,
        cs.domes_number,
        cs.four_character_id,
        cs.geologic_characteristic,
        cs.monument_id
    FROM site s,
        cors_site cs
    WHERE (s.id = cs.id);
