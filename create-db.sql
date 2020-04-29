--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE geodesy;
ALTER ROLE geodesy WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5a49d6d1baa2f719f28e308e8a3c249fd';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md5e8a48653851e28c69d0506508fb27fc5';




--
-- PostgreSQL database cluster dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.16
-- Dumped by pg_dump version 11.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE geodesydb;
--
-- Name: geodesydb; Type: DATABASE; Schema: -; Owner: geodesy
--

CREATE DATABASE geodesydb WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE geodesydb OWNER TO geodesy;

\connect geodesydb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: geodesy; Type: SCHEMA; Schema: -; Owner: geodesy
--

CREATE SCHEMA geodesy;


ALTER SCHEMA geodesy OWNER TO geodesy;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: add_records_to_site_in_network(); Type: FUNCTION; Schema: geodesy; Owner: geodesy
--

CREATE FUNCTION geodesy.add_records_to_site_in_network() RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare
rsc record;
v_id cors_site_in_network.id%type;


BEGIN 
  RAISE NOTICE 'Start to update site_in_network and relation...';

  for rsc IN select b.id as "site_id", a.network_1, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_1 = c.name
union
select b.id as "site_id", a.network_2, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_2 = c.name
union
select b.id as "site_id", a.network_3, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_3 = c.name
union
select b.id as "site_id", a.network_4, c.id as "network_id"
from temp_site_network a, cors_site b, cors_site_network c
where a.four_character_id = b.four_character_id
and a.network_4 = c.name
order by 1 LOOP


      v_id  := nextVal('seq_surrogate_keys');
      insert into cors_site_in_network (id, cors_site_id, cors_site_network_id) values (v_id, rsc.site_id, rsc.network_id);       

  
END LOOP;
--commit;
RAISE NOTICE 'Done update site_in_network and relation.';

RETURN null;
END;
             $$;


ALTER FUNCTION geodesy.add_records_to_site_in_network() OWNER TO geodesy;

--
-- Name: add_records_to_site_network(); Type: FUNCTION; Schema: geodesy; Owner: geodesy
--

CREATE FUNCTION geodesy.add_records_to_site_network() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
declare
rsc record;
v_id cors_site_network.id%type;


BEGIN 
  RAISE NOTICE 'Start to update site_network and relation...';

  for rsc IN select distinct network_1 as "name" from temp_site_network where network_1 is not null
union
select distinct network_2 as "name" from temp_site_network where network_2 is not null
union
select distinct network_3 as "name" from temp_site_network where network_3 is not null
union
select distinct network_4 as "name" from temp_site_network where network_4 is not null
order by 1 LOOP

v_id := nextVal('seq_surrogate_keys');

insert into cors_site_network (id, name) values (v_id, rsc.name);
  
END LOOP;
--commit;
RAISE NOTICE 'Done update site_network and relation.';
   RETURN null;

END;
             $$;


ALTER FUNCTION geodesy.add_records_to_site_network() OWNER TO geodesy;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: clock_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.clock_configuration (
    id integer NOT NULL,
    input_frequency text
);


ALTER TABLE geodesy.clock_configuration OWNER TO geodesy;

--
-- Name: TABLE clock_configuration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.clock_configuration IS 'the table contains information of all clock configurations.';


--
-- Name: COLUMN clock_configuration.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.clock_configuration.id IS 'unique identifier of a clock configuration record, primary key and foreign key to id in cofiguration table';


--
-- Name: COLUMN clock_configuration.input_frequency; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.clock_configuration.input_frequency IS 'input frequency used in clock configuration';


--
-- Name: cors_site; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.cors_site (
    bedrock_condition text,
    bedrock_type text,
    domes_number text,
    four_character_id character varying(4) NOT NULL,
    geologic_characteristic text,
    id integer NOT NULL,
    monument_id integer,
    nine_character_id character varying(9) DEFAULT '_geodesy_'::character varying NOT NULL,
    site_status character varying(20) DEFAULT 'PRIVATE'::character varying NOT NULL
);


ALTER TABLE geodesy.cors_site OWNER TO geodesy;

--
-- Name: TABLE cors_site; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.cors_site IS 'table that contains information about all goedesy cors site';


--
-- Name: COLUMN cors_site.bedrock_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site.bedrock_type IS 'the type of bed rock of the site';


--
-- Name: COLUMN cors_site.domes_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site.domes_number IS 'domes number assigned by IERS ITRS Product center';


--
-- Name: COLUMN cors_site.four_character_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site.four_character_id IS '4-digit station identifier and the unique identifier of the site';


--
-- Name: COLUMN cors_site.geologic_characteristic; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site.geologic_characteristic IS 'features of the earth that were formed by geological processes';


--
-- Name: COLUMN cors_site.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site.id IS 'unique identifier, primary key';


--
-- Name: COLUMN cors_site.monument_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site.monument_id IS 'identifier of monument, the cors site is sitt on, foreign key to monument table';


--
-- Name: cors_site_added_to_network; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.cors_site_added_to_network (
    network_id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    site_id integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE geodesy.cors_site_added_to_network OWNER TO geodesy;

--
-- Name: cors_site_in_network; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.cors_site_in_network (
    id integer NOT NULL,
    cors_site_id integer,
    cors_site_network_id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone
);


ALTER TABLE geodesy.cors_site_in_network OWNER TO geodesy;

--
-- Name: TABLE cors_site_in_network; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.cors_site_in_network IS 'the table contains information of cors sites that are part of cors site networks';


--
-- Name: COLUMN cors_site_in_network.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_in_network.id IS 'unique identifier of record in the table, primary key';


--
-- Name: COLUMN cors_site_in_network.cors_site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_in_network.cors_site_id IS 'unique identifier of a cors site, foreign key to id in cors_site table';


--
-- Name: COLUMN cors_site_in_network.cors_site_network_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_in_network.cors_site_network_id IS 'unique identifier of a cors site network, foreigh key to id in cors_site_network table';


--
-- Name: COLUMN cors_site_in_network.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_in_network.effective_from IS 'time stamp(UTC) when current record starts to use';


--
-- Name: COLUMN cors_site_in_network.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_in_network.effective_to IS 'time stamp(UTC) when current record ceased to use';


--
-- Name: cors_site_network; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.cors_site_network (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    version integer
);


ALTER TABLE geodesy.cors_site_network OWNER TO geodesy;

--
-- Name: TABLE cors_site_network; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.cors_site_network IS 'the table contains information of cors site networks';


--
-- Name: COLUMN cors_site_network.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_network.id IS 'unique identifier of cors site network, primary key';


--
-- Name: COLUMN cors_site_network.name; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_network.name IS 'name of cors site network';


--
-- Name: COLUMN cors_site_network.description; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.cors_site_network.description IS 'description or notes of cors site network';


--
-- Name: cors_site_removed_from_network; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.cors_site_removed_from_network (
    network_id integer NOT NULL,
    effective_from timestamp without time zone,
    site_id integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE geodesy.cors_site_removed_from_network OWNER TO geodesy;

--
-- Name: databasechangelog; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE geodesy.databasechangelog OWNER TO geodesy;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE geodesy.databasechangeloglock OWNER TO geodesy;

--
-- Name: domain_event; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.domain_event (
    event_name text NOT NULL,
    id integer NOT NULL,
    error text,
    retries integer,
    subscriber text NOT NULL,
    time_handled timestamp without time zone,
    time_published timestamp without time zone,
    time_raised timestamp without time zone NOT NULL,
    username text
);


ALTER TABLE geodesy.domain_event OWNER TO geodesy;

--
-- Name: TABLE domain_event; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.domain_event IS 'the table contains information about all domain events';


--
-- Name: COLUMN domain_event.event_name; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.event_name IS 'the name of a sitelog event';


--
-- Name: COLUMN domain_event.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN domain_event.error; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.error IS 'error occurred in a domain event';


--
-- Name: COLUMN domain_event.retries; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.retries IS 'flag indicate whether retries had been done for a errored domain event';


--
-- Name: COLUMN domain_event.subscriber; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.subscriber IS 'the subscriber of a domain event';


--
-- Name: COLUMN domain_event.time_handled; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.time_handled IS 'time(UTC) when a domain event is handled';


--
-- Name: COLUMN domain_event.time_published; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.time_published IS 'time(UTC) when a domain event is published';


--
-- Name: COLUMN domain_event.time_raised; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.domain_event.time_raised IS 'time(UTC) when a domain event error is raised';


--
-- Name: equipment; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.equipment (
    equipment_type text NOT NULL,
    id integer NOT NULL,
    manufacturer text,
    serial_number text,
    type text,
    version integer
);


ALTER TABLE geodesy.equipment OWNER TO geodesy;

--
-- Name: TABLE equipment; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.equipment IS 'the table that contains information about all equipments';


--
-- Name: COLUMN equipment.equipment_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment.equipment_type IS 'type of equipment';


--
-- Name: COLUMN equipment.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment.id IS 'unique identifier of an equipment, primary key';


--
-- Name: COLUMN equipment.manufacturer; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment.manufacturer IS 'name of manufacturer of the equipment';


--
-- Name: COLUMN equipment.serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment.serial_number IS 'the serial number of the equipment';


--
-- Name: COLUMN equipment.type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment.type IS 'a specific product type of giving equipment type (such as gnss receiver or gnss antenna)';


--
-- Name: COLUMN equipment.version; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment.version IS 'version of the data when it is populated through application layer';


--
-- Name: equipment_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.equipment_configuration (
    equipment_configuration_id integer NOT NULL,
    equipment_id integer NOT NULL,
    configuration_time timestamp without time zone
);


ALTER TABLE geodesy.equipment_configuration OWNER TO geodesy;

--
-- Name: TABLE equipment_configuration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.equipment_configuration IS 'the table contains information of all equipment configurations, it is the parent table to all individual configuration tables';


--
-- Name: COLUMN equipment_configuration.equipment_configuration_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_configuration.equipment_configuration_id IS 'unique identifier of a equipment configuration, primary key';


--
-- Name: COLUMN equipment_configuration.equipment_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_configuration.equipment_id IS 'unique identifier of a equipment used in the configuration, foreign key to id of equipment table';


--
-- Name: COLUMN equipment_configuration.configuration_time; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_configuration.configuration_time IS 'time stamp(UTC) when the equipment configuration is made';


--
-- Name: equipment_in_use; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.equipment_in_use (
    id integer NOT NULL,
    equipment_configuration_id integer NOT NULL,
    equipment_id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    setup_id integer
);


ALTER TABLE geodesy.equipment_in_use OWNER TO geodesy;

--
-- Name: TABLE equipment_in_use; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.equipment_in_use IS 'the table contains information of all in_used equipments';


--
-- Name: COLUMN equipment_in_use.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_in_use.id IS 'unique identifier of a equipment-in-use record, primary key';


--
-- Name: COLUMN equipment_in_use.equipment_configuration_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_in_use.equipment_configuration_id IS 'unique identifier of a configuration record for the equipment in use, foreign key to id in equipment_configuration table';


--
-- Name: COLUMN equipment_in_use.equipment_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_in_use.equipment_id IS 'unique identifier of an equipment in use, foreign key to id in equipment table';


--
-- Name: COLUMN equipment_in_use.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_in_use.effective_from IS 'the time stamp(UTC) when the equipment starts to use';


--
-- Name: COLUMN equipment_in_use.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_in_use.effective_to IS 'the time stamp(UTC) when the equipment ends to use';


--
-- Name: COLUMN equipment_in_use.setup_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.equipment_in_use.setup_id IS 'unique identifier of a setup record used, foreign key to id in setup table';


--
-- Name: gnss_antenna_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.gnss_antenna_configuration (
    id integer NOT NULL,
    alignment_from_true_north text,
    antenna_cable_length text,
    antenna_cable_type text,
    antenna_reference_point text,
    marker_arp_east_eccentricity double precision,
    marker_arp_north_eccentricity double precision,
    marker_arp_up_eccentricity double precision,
    notes text,
    radome_serial_number text,
    radome_type text
);


ALTER TABLE geodesy.gnss_antenna_configuration OWNER TO geodesy;

--
-- Name: TABLE gnss_antenna_configuration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.gnss_antenna_configuration IS 'table contains configuration information of gnss antenna';


--
-- Name: COLUMN gnss_antenna_configuration.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.id IS 'unique identifier of gnss antenna configuration record, primary key and foreign key to id in configuration table';


--
-- Name: COLUMN gnss_antenna_configuration.alignment_from_true_north; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.alignment_from_true_north IS 'antenna alignment from true north (in degree)';


--
-- Name: COLUMN gnss_antenna_configuration.antenna_cable_length; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.antenna_cable_length IS 'the length of antenna cable';


--
-- Name: COLUMN gnss_antenna_configuration.antenna_cable_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.antenna_cable_type IS 'the type of antenna cable';


--
-- Name: COLUMN gnss_antenna_configuration.antenna_reference_point; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.antenna_reference_point IS 'the point where an antenna is reference to';


--
-- Name: COLUMN gnss_antenna_configuration.marker_arp_east_eccentricity; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.marker_arp_east_eccentricity IS 'the position of Antenna Reference Point (ARP) relative to the monument marker (MM) or the site eccentricity vector in east, measured by degree';


--
-- Name: COLUMN gnss_antenna_configuration.marker_arp_north_eccentricity; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.marker_arp_north_eccentricity IS 'the position of Antenna Reference Point (ARP) relative to the monument marker (MM) or the site eccentricity vector in north, measured by degree';


--
-- Name: COLUMN gnss_antenna_configuration.marker_arp_up_eccentricity; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.marker_arp_up_eccentricity IS 'the position of Antenna Reference Point (ARP) relative to the monument marker (MM) or the site eccentricity vector in up, measured by degree';


--
-- Name: COLUMN gnss_antenna_configuration.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.notes IS 'the notes or further information about this antenna';


--
-- Name: COLUMN gnss_antenna_configuration.radome_serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.radome_serial_number IS 'the factory serial number of the radome';


--
-- Name: COLUMN gnss_antenna_configuration.radome_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_antenna_configuration.radome_type IS 'the type of the radome';


--
-- Name: gnss_receiver_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.gnss_receiver_configuration (
    id integer NOT NULL,
    elevation_cutoff_setting text,
    firmware_version text,
    notes text,
    satellite_system text,
    temperature_stabilization text
);


ALTER TABLE geodesy.gnss_receiver_configuration OWNER TO geodesy;

--
-- Name: TABLE gnss_receiver_configuration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.gnss_receiver_configuration IS 'the table contains configuration information of gnss receiver configuration';


--
-- Name: COLUMN gnss_receiver_configuration.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_receiver_configuration.id IS 'unique identifier of a gnss receiver configuration record, primary key and foreign key to id in configuration table';


--
-- Name: COLUMN gnss_receiver_configuration.elevation_cutoff_setting; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_receiver_configuration.elevation_cutoff_setting IS 'elevation cutoff setting measured in degree';


--
-- Name: COLUMN gnss_receiver_configuration.firmware_version; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_receiver_configuration.firmware_version IS 'firmware for laser system version';


--
-- Name: COLUMN gnss_receiver_configuration.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_receiver_configuration.notes IS 'description or further note about the configuration';


--
-- Name: COLUMN gnss_receiver_configuration.satellite_system; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_receiver_configuration.satellite_system IS 'satelite system the receiver receives data from';


--
-- Name: COLUMN gnss_receiver_configuration.temperature_stabilization; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.gnss_receiver_configuration.temperature_stabilization IS 'indication whether the receiver is temperature stabilized';


--
-- Name: humidity_sensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.humidity_sensor (
    aspiration text,
    id integer NOT NULL
);


ALTER TABLE geodesy.humidity_sensor OWNER TO geodesy;

--
-- Name: TABLE humidity_sensor; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.humidity_sensor IS 'the table contains information of all humidity sensors, the table is a child table of equipment table';


--
-- Name: COLUMN humidity_sensor.aspiration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.humidity_sensor.aspiration IS 'aspiration of the humidity sensor';


--
-- Name: COLUMN humidity_sensor.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.humidity_sensor.id IS 'unique identifier of a humidity sensor, primary key and foreign key to id in equipment table';


--
-- Name: humidity_sensor_configuration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.humidity_sensor_configuration (
    id integer NOT NULL,
    height_diff_to_antenna text,
    notes text
);


ALTER TABLE geodesy.humidity_sensor_configuration OWNER TO geodesy;

--
-- Name: TABLE humidity_sensor_configuration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.humidity_sensor_configuration IS 'the table contains information of all humidity sensors, the table is a child table of equipment table';


--
-- Name: COLUMN humidity_sensor_configuration.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.humidity_sensor_configuration.id IS 'ununique identifier of a humidity sensor configuration, primary key and foreign key to id in configuration table';


--
-- Name: COLUMN humidity_sensor_configuration.height_diff_to_antenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.humidity_sensor_configuration.height_diff_to_antenna IS 'the height difference between antenna and humidity sensor';


--
-- Name: COLUMN humidity_sensor_configuration.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.humidity_sensor_configuration.notes IS 'the notes or further information about the configuration';


--
-- Name: invalid_site_log_received; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.invalid_site_log_received (
    site_log_text text NOT NULL,
    id integer NOT NULL
);


ALTER TABLE geodesy.invalid_site_log_received OWNER TO geodesy;

--
-- Name: TABLE invalid_site_log_received; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.invalid_site_log_received IS 'table contains information about invalid site log received';


--
-- Name: COLUMN invalid_site_log_received.site_log_text; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.invalid_site_log_received.site_log_text IS 'the log text of an invalid site log received';


--
-- Name: COLUMN invalid_site_log_received.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.invalid_site_log_received.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: monument; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.monument (
    id integer NOT NULL,
    description text,
    foundation text,
    height text,
    marker_description text
);


ALTER TABLE geodesy.monument OWNER TO geodesy;

--
-- Name: TABLE monument; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.monument IS 'the table contains information about the monuments';


--
-- Name: COLUMN monument.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.monument.id IS 'unique identifier of a monument, primary key';


--
-- Name: COLUMN monument.description; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.monument.description IS 'description of a monument';


--
-- Name: COLUMN monument.foundation; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.monument.foundation IS 'foundation of a monument';


--
-- Name: COLUMN monument.height; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.monument.height IS 'the height of a monument';


--
-- Name: COLUMN monument.marker_description; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.monument.marker_description IS 'marker description of a monument';


--
-- Name: new_cors_site_request; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.new_cors_site_request (
    id integer NOT NULL,
    email text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    organisation text NOT NULL,
    phone text NOT NULL,
    "position" text NOT NULL,
    sitelog_data text NOT NULL
);


ALTER TABLE geodesy.new_cors_site_request OWNER TO geodesy;

--
-- Name: new_cors_site_request_received; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.new_cors_site_request_received (
    new_cors_site_request_id integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE geodesy.new_cors_site_request_received OWNER TO geodesy;

--
-- Name: node; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.node (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    invalidated boolean NOT NULL,
    setup_id integer,
    site_id integer NOT NULL,
    version integer
);


ALTER TABLE geodesy.node OWNER TO geodesy;

--
-- Name: TABLE node; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.node IS 'the table contains information of nodes that associated with a site';


--
-- Name: COLUMN node.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.node.id IS 'unique identifier of a node, primary key';


--
-- Name: COLUMN node.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.node.effective_from IS 'the time stamp(UTC) when the node starts to use';


--
-- Name: COLUMN node.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.node.effective_to IS 'the time stamp(UTC) when the node ceased to use';


--
-- Name: COLUMN node.invalidated; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.node.invalidated IS 'a flag indicates whether the node is invalidated';


--
-- Name: COLUMN node.setup_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.node.setup_id IS 'unique identifier of a setup, foreign key to id in setup table';


--
-- Name: COLUMN node.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.node.site_id IS 'unique identifier of a site, foreign key to id in site table';


--
-- Name: COLUMN node.version; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.node.version IS 'version of the data when it is populated through application layer';


--
-- Name: position; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy."position" (
    id integer NOT NULL,
    as_at timestamp without time zone,
    datum_epsg_code integer,
    epoch timestamp without time zone,
    four_character_id character varying(255),
    node_id integer,
    position_source_id integer,
    x double precision,
    y double precision
);


ALTER TABLE geodesy."position" OWNER TO geodesy;

--
-- Name: TABLE "position"; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy."position" IS 'the table contains information of positions that associated with a node';


--
-- Name: COLUMN "position".id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".id IS 'unique identifier of record in the table, primary key';


--
-- Name: COLUMN "position".as_at; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".as_at IS 'the time stamp(UTC) when the positions are recorded';


--
-- Name: COLUMN "position".datum_epsg_code; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".datum_epsg_code IS 'datum EPSG code';


--
-- Name: COLUMN "position".epoch; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".epoch IS 'datum Epoch';


--
-- Name: COLUMN "position".four_character_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".four_character_id IS 'four character id of a site';


--
-- Name: COLUMN "position".node_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".node_id IS 'unique identifier of a node, foreign key to id in node table';


--
-- Name: COLUMN "position".position_source_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".position_source_id IS 'position source id';


--
-- Name: COLUMN "position".x; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".x IS 'x origin expressed for node position';


--
-- Name: COLUMN "position".y; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy."position".y IS 'y origin expressed for node position';


--
-- Name: seq_event; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_event
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_event OWNER TO geodesy;

--
-- Name: seq_sitelogantenna; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogantenna
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogantenna OWNER TO geodesy;

--
-- Name: seq_sitelogassociateddocument; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogassociateddocument
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogassociateddocument OWNER TO geodesy;

--
-- Name: seq_sitelogcollocationinfo; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogcollocationinfo
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogcollocationinfo OWNER TO geodesy;

--
-- Name: seq_sitelogfrequencystandard; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogfrequencystandard
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogfrequencystandard OWNER TO geodesy;

--
-- Name: seq_siteloghumiditysensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_siteloghumiditysensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_siteloghumiditysensor OWNER TO geodesy;

--
-- Name: seq_siteloglocalepisodiceffect; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_siteloglocalepisodiceffect
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_siteloglocalepisodiceffect OWNER TO geodesy;

--
-- Name: seq_siteloglocaltie; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_siteloglocaltie
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_siteloglocaltie OWNER TO geodesy;

--
-- Name: seq_sitelogmultipathsource; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogmultipathsource
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogmultipathsource OWNER TO geodesy;

--
-- Name: seq_sitelogotherinstrument; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogotherinstrument
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogotherinstrument OWNER TO geodesy;

--
-- Name: seq_sitelogpressuresensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogpressuresensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogpressuresensor OWNER TO geodesy;

--
-- Name: seq_sitelogradiointerference; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogradiointerference
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogradiointerference OWNER TO geodesy;

--
-- Name: seq_sitelogreceiver; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogreceiver
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogreceiver OWNER TO geodesy;

--
-- Name: seq_sitelogsignalobstruction; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogsignalobstruction
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogsignalobstruction OWNER TO geodesy;

--
-- Name: seq_sitelogsite; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogsite
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogsite OWNER TO geodesy;

--
-- Name: seq_sitelogtemperaturesensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogtemperaturesensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogtemperaturesensor OWNER TO geodesy;

--
-- Name: seq_sitelogwatervaporsensor; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_sitelogwatervaporsensor
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_sitelogwatervaporsensor OWNER TO geodesy;

--
-- Name: seq_surrogate_keys; Type: SEQUENCE; Schema: geodesy; Owner: geodesy
--

CREATE SEQUENCE geodesy.seq_surrogate_keys
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geodesy.seq_surrogate_keys OWNER TO geodesy;

--
-- Name: setup; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.setup (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    invalidated boolean NOT NULL,
    type text NOT NULL,
    site_id integer
);


ALTER TABLE geodesy.setup OWNER TO geodesy;

--
-- Name: TABLE setup; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.setup IS 'the table contains information of all setups for geodesy sites';


--
-- Name: COLUMN setup.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.setup.id IS 'unique identifier of a setup, primary key';


--
-- Name: COLUMN setup.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.setup.effective_from IS 'time stamp(UTC) when the setup starts to be used';


--
-- Name: COLUMN setup.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.setup.effective_to IS 'time stamp(UTC) when the setup ends to be used';


--
-- Name: COLUMN setup.invalidated; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.setup.invalidated IS 'the flag indicates whether the setup is still validate';


--
-- Name: COLUMN setup.type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.setup.type IS 'the name of a setup';


--
-- Name: COLUMN setup.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.setup.site_id IS 'the quique identifier of a site where the setup is used, foreign key to id of geodesy site table';


--
-- Name: site; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.site (
    id integer NOT NULL,
    date_installed timestamp without time zone,
    description text,
    name text,
    version integer,
    shape public.geometry
);


ALTER TABLE geodesy.site OWNER TO geodesy;

--
-- Name: TABLE site; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.site IS 'the table contains all information about geodesy sites';


--
-- Name: COLUMN site.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site.id IS 'unique identifier of a geodesy site, primary key';


--
-- Name: COLUMN site.date_installed; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site.date_installed IS 'time stamp(UTC) when the site is installed';


--
-- Name: COLUMN site.description; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site.description IS 'description about the site';


--
-- Name: COLUMN site.name; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site.name IS 'the name of the site';


--
-- Name: COLUMN site.version; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site.version IS 'version of the data when it is populated through application layer';


--
-- Name: COLUMN site.shape; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site.shape IS 'shape of a site';


--
-- Name: site_log_received; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.site_log_received (
    four_char_id text NOT NULL,
    id integer NOT NULL,
    site_log_text character varying(500000)
);


ALTER TABLE geodesy.site_log_received OWNER TO geodesy;

--
-- Name: TABLE site_log_received; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.site_log_received IS 'the table contains information that shows which site log are received.';


--
-- Name: COLUMN site_log_received.four_char_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site_log_received.four_char_id IS 'the four character id of the site';


--
-- Name: COLUMN site_log_received.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site_log_received.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: site_updated; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.site_updated (
    four_character_id character varying(255) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE geodesy.site_updated OWNER TO geodesy;

--
-- Name: TABLE site_updated; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.site_updated IS 'the table contains information about site updated';


--
-- Name: COLUMN site_updated.four_character_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site_updated.four_character_id IS 'the four character unique identifier of a site';


--
-- Name: COLUMN site_updated.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.site_updated.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: sitelog_associateddocument; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_associateddocument (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    file_reference character varying(256) NOT NULL,
    description character varying(256),
    type character varying(100),
    created_date timestamp without time zone,
    site_id integer
);


ALTER TABLE geodesy.sitelog_associateddocument OWNER TO geodesy;

--
-- Name: TABLE sitelog_associateddocument; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_associateddocument IS 'table contains associated documents (site map, site diagram, site images, etc.) in site log';


--
-- Name: sitelog_collocationinformation; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_collocationinformation (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    instrument_type text,
    notes text,
    status text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_collocationinformation OWNER TO geodesy;

--
-- Name: TABLE sitelog_collocationinformation; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_collocationinformation IS 'table contains about information about collocated instruments in site log';


--
-- Name: COLUMN sitelog_collocationinformation.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_collocationinformation.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.effective_from IS 'time stamp(UTC) when a collocated instrument starts to use';


--
-- Name: COLUMN sitelog_collocationinformation.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.effective_to IS 'time stamp(UTC) when a collocated instrument ceased to use';


--
-- Name: COLUMN sitelog_collocationinformation.instrument_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.instrument_type IS 'type of collocated instrument used';


--
-- Name: COLUMN sitelog_collocationinformation.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.notes IS 'description or notes about collocated instrument';


--
-- Name: COLUMN sitelog_collocationinformation.status; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.status IS 'status of collocated instrument';


--
-- Name: COLUMN sitelog_collocationinformation.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_collocationinformation.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_collocationinformation.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.date_deleted IS 'time stamp(UTC) when a sitelog_collocationinformation record is deleted';


--
-- Name: COLUMN sitelog_collocationinformation.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_collocationinformation.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_frequencystandard; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_frequencystandard (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    input_frequency text,
    notes text,
    type text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_frequencystandard OWNER TO geodesy;

--
-- Name: TABLE sitelog_frequencystandard; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_frequencystandard IS 'table contains information about frequency standards used in site log';


--
-- Name: COLUMN sitelog_frequencystandard.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_frequencystandard.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.effective_from IS 'time stamp(UTC) when a frequency standard starts to use';


--
-- Name: COLUMN sitelog_frequencystandard.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.effective_to IS 'time stamp(UTC) when a frequency standard ceased to use';


--
-- Name: COLUMN sitelog_frequencystandard.input_frequency; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.input_frequency IS 'input frequency used in site log';


--
-- Name: COLUMN sitelog_frequencystandard.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.notes IS 'description and notes about the frequency standard';


--
-- Name: COLUMN sitelog_frequencystandard.type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.type IS 'type of frequency standard';


--
-- Name: COLUMN sitelog_frequencystandard.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_frequencystandard.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_frequencystandard.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.date_deleted IS 'time stamp(UTC) when a sitelog_frequencystandard record is deleted';


--
-- Name: COLUMN sitelog_frequencystandard.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_frequencystandard.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_gnssantenna; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_gnssantenna (
    id integer NOT NULL,
    alignment_from_true_north text,
    antenna_cable_length text,
    antenna_cable_type text,
    antenna_radome_type text,
    antenna_reference_point text,
    date_installed timestamp without time zone,
    date_removed timestamp without time zone,
    marker_arp_east_ecc double precision,
    marker_arp_north_ecc double precision,
    marker_arp_up_ecc double precision,
    notes text,
    radome_serial_number text,
    serial_number text,
    antenna_type text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_gnssantenna OWNER TO geodesy;

--
-- Name: TABLE sitelog_gnssantenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_gnssantenna IS 'table contains information about gnss antenna in site log';


--
-- Name: COLUMN sitelog_gnssantenna.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.id IS 'the unique identifier of a gnss antenna, primary key';


--
-- Name: COLUMN sitelog_gnssantenna.alignment_from_true_north; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.alignment_from_true_north IS 'alignment of antenna from true north';


--
-- Name: COLUMN sitelog_gnssantenna.antenna_cable_length; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.antenna_cable_length IS 'the length of cable that connects to antenna';


--
-- Name: COLUMN sitelog_gnssantenna.antenna_cable_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.antenna_cable_type IS 'the type of cable that connects to antenna';


--
-- Name: COLUMN sitelog_gnssantenna.antenna_radome_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.antenna_radome_type IS 'the type of antenna radome';


--
-- Name: COLUMN sitelog_gnssantenna.antenna_reference_point; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.antenna_reference_point IS 'reference point used by the antenna';


--
-- Name: COLUMN sitelog_gnssantenna.date_installed; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.date_installed IS 'the date the anntenna was installed, timestamp without time zone';


--
-- Name: COLUMN sitelog_gnssantenna.date_removed; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.date_removed IS 'the date the anntenna was removed, timestamp without time zone';


--
-- Name: COLUMN sitelog_gnssantenna.marker_arp_east_ecc; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.marker_arp_east_ecc IS 'the position of Antenna Reference Point (ARP) relative to the monument marker (MM) or the site eccentricity vector in east, measured by degree';


--
-- Name: COLUMN sitelog_gnssantenna.marker_arp_north_ecc; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.marker_arp_north_ecc IS 'the position of Antenna Reference Point (ARP) relative to the monument marker (MM) or the site eccentricity vector in north, measured by degree';


--
-- Name: COLUMN sitelog_gnssantenna.marker_arp_up_ecc; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.marker_arp_up_ecc IS 'the position of Antenna Reference Point (ARP) relative to the monument marker (MM) or the site eccentricity vector in up, measured by degree';


--
-- Name: COLUMN sitelog_gnssantenna.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.notes IS 'description or notes about the gnss antenna';


--
-- Name: COLUMN sitelog_gnssantenna.radome_serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.radome_serial_number IS 'the factory serial number of the radome';


--
-- Name: COLUMN sitelog_gnssantenna.serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.serial_number IS 'the factory serial number of the antenna';


--
-- Name: COLUMN sitelog_gnssantenna.antenna_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.antenna_type IS 'the type of the gnss antenna';


--
-- Name: COLUMN sitelog_gnssantenna.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_gnssantenna.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_gnssantenna.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.date_deleted IS 'time stamp(UTC) when a sitelog_gnssantenna record is deleted';


--
-- Name: COLUMN sitelog_gnssantenna.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssantenna.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_gnssreceiver; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_gnssreceiver (
    id integer NOT NULL,
    date_installed timestamp without time zone,
    date_removed timestamp without time zone,
    elevation_cutoff_setting text,
    firmware_version text,
    notes text,
    satellite_system text,
    serial_number text,
    temperature_stabilization text,
    receiver_type text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_gnssreceiver OWNER TO geodesy;

--
-- Name: TABLE sitelog_gnssreceiver; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_gnssreceiver IS 'table contains information about gnss receiver in site log';


--
-- Name: COLUMN sitelog_gnssreceiver.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.id IS 'the unique identifier of a gnss receiver, primary key';


--
-- Name: COLUMN sitelog_gnssreceiver.date_installed; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.date_installed IS 'the date the receiver was installed, timestamp without time zone';


--
-- Name: COLUMN sitelog_gnssreceiver.date_removed; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.date_removed IS 'the date the receiver was removed, timestamp without time zone';


--
-- Name: COLUMN sitelog_gnssreceiver.elevation_cutoff_setting; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.elevation_cutoff_setting IS 'elevation cutoff setting measured in degree';


--
-- Name: COLUMN sitelog_gnssreceiver.firmware_version; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.firmware_version IS 'the version of firmware used by the receiver';


--
-- Name: COLUMN sitelog_gnssreceiver.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.notes IS 'description and notes about the gnss receiver';


--
-- Name: COLUMN sitelog_gnssreceiver.satellite_system; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.satellite_system IS 'satelite system the receiver receives data from';


--
-- Name: COLUMN sitelog_gnssreceiver.serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.serial_number IS 'the factory serial number of the gnss receiver';


--
-- Name: COLUMN sitelog_gnssreceiver.temperature_stabilization; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.temperature_stabilization IS 'indication whether the receiver is temperature stabilized';


--
-- Name: COLUMN sitelog_gnssreceiver.receiver_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.receiver_type IS 'the type of gnss receiver';


--
-- Name: COLUMN sitelog_gnssreceiver.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_gnssreceiver.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_gnssreceiver.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.date_deleted IS 'time stamp(UTC) when a sitelog_gnssreceiver record is deleted';


--
-- Name: COLUMN sitelog_gnssreceiver.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_gnssreceiver.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_humiditysensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_humiditysensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    accuracy_percent_rel_humidity text,
    aspiration text,
    data_sampling_interval text,
    notes text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_humiditysensor OWNER TO geodesy;

--
-- Name: TABLE sitelog_humiditysensor; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_humiditysensor IS 'table contains information about frequency standards of site log';


--
-- Name: COLUMN sitelog_humiditysensor.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_humiditysensor.callibration_date; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.callibration_date IS 'calibration date, timestamp without time zone';


--
-- Name: COLUMN sitelog_humiditysensor.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.effective_from IS 'time stamp(UTC) when a humidity sensor was used';


--
-- Name: COLUMN sitelog_humiditysensor.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.effective_to IS 'time stamp(UTC) when a humidity sensor ceased to use';


--
-- Name: COLUMN sitelog_humiditysensor.height_diff_to_antenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.height_diff_to_antenna IS 'hight difference between humidity sensor and antenna';


--
-- Name: COLUMN sitelog_humiditysensor.manufacturer; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.manufacturer IS 'manufacturer of a humidity sensor';


--
-- Name: COLUMN sitelog_humiditysensor.serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.serial_number IS 'serial number assigned to a humidity sensor';


--
-- Name: COLUMN sitelog_humiditysensor.type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.type IS 'type of a humidity sensor';


--
-- Name: COLUMN sitelog_humiditysensor.accuracy_percent_rel_humidity; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.accuracy_percent_rel_humidity IS 'accurate relative humidity (RH) in percentage';


--
-- Name: COLUMN sitelog_humiditysensor.aspiration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.aspiration IS 'aspiration used';


--
-- Name: COLUMN sitelog_humiditysensor.data_sampling_interval; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.data_sampling_interval IS 'the interval between data sampling collection';


--
-- Name: COLUMN sitelog_humiditysensor.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.notes IS 'further description of a humidity sensor record';


--
-- Name: COLUMN sitelog_humiditysensor.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.site_id IS 'unique identifier of a site, foreign key to id of sitelog_site table';


--
-- Name: COLUMN sitelog_humiditysensor.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_humiditysensor.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.date_deleted IS 'time stamp(UTC) when a sitelog_humiditysensor record is deleted';


--
-- Name: COLUMN sitelog_humiditysensor.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_humiditysensor.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_localepisodiceffect; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_localepisodiceffect (
    id integer NOT NULL,
    event text,
    site_id integer,
    effective_from timestamp(6) without time zone,
    effective_to timestamp(6) without time zone,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_localepisodiceffect OWNER TO geodesy;

--
-- Name: TABLE sitelog_localepisodiceffect; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_localepisodiceffect IS 'table contains information about episodic event in site log';


--
-- Name: COLUMN sitelog_localepisodiceffect.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_localepisodiceffect.event; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.event IS 'a episodic event in site log';


--
-- Name: COLUMN sitelog_localepisodiceffect.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.site_id IS 'unique identifier of site log site, foreign key to the id in sitelog_site table';


--
-- Name: COLUMN sitelog_localepisodiceffect.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.effective_from IS 'time stamp(UTC) when a episodic event measurement occur';


--
-- Name: COLUMN sitelog_localepisodiceffect.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.effective_to IS 'time stamp(UTC) when a episodic event ceased to be measured';


--
-- Name: COLUMN sitelog_localepisodiceffect.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_localepisodiceffect.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.date_deleted IS 'time stamp(UTC) when a sitelog_localepisodicevent record is deleted';


--
-- Name: COLUMN sitelog_localepisodiceffect.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_localepisodiceffect.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_mutlipathsource; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_mutlipathsource (
    id integer NOT NULL,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    possible_problem_source text,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    notes text,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_mutlipathsource OWNER TO geodesy;

--
-- Name: TABLE sitelog_mutlipathsource; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_mutlipathsource IS 'table contains information about multiple path sources in site log';


--
-- Name: COLUMN sitelog_mutlipathsource.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.id IS 'the unique identifier of a multiple path source, primary key';


--
-- Name: COLUMN sitelog_mutlipathsource.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_mutlipathsource.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_mutlipathsource.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.date_deleted IS 'time stamp(UTC) when a sitelog_mutlipathsource record is deleted';


--
-- Name: COLUMN sitelog_mutlipathsource.possible_problem_source; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.possible_problem_source IS 'the source of the problem';


--
-- Name: COLUMN sitelog_mutlipathsource.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.effective_from IS 'date when the problem first occurred';


--
-- Name: COLUMN sitelog_mutlipathsource.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.effective_to IS 'date when the problem was resolved';


--
-- Name: COLUMN sitelog_mutlipathsource.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.notes IS 'any extra comments about the problem';


--
-- Name: COLUMN sitelog_mutlipathsource.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_mutlipathsource.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_otherinstrumentation; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_otherinstrumentation (
    id integer NOT NULL,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    instrumentation text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_otherinstrumentation OWNER TO geodesy;

--
-- Name: TABLE sitelog_otherinstrumentation; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_otherinstrumentation IS 'table contains information about other instrumentation that is used in site log';


--
-- Name: COLUMN sitelog_otherinstrumentation.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_otherinstrumentation.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.effective_from IS 'time stamp(UTC) when an instrumentation starts to use';


--
-- Name: COLUMN sitelog_otherinstrumentation.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.effective_to IS 'time stamp(UTC) when an instrumentation ceased to use';


--
-- Name: COLUMN sitelog_otherinstrumentation.instrumentation; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.instrumentation IS 'time stamp(UTC) when an instrumentation ceased to use';


--
-- Name: COLUMN sitelog_otherinstrumentation.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_otherinstrumentation.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_otherinstrumentation.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.date_deleted IS 'time stamp(UTC) when a sitelog_otherinstrumentation record is deleted';


--
-- Name: COLUMN sitelog_otherinstrumentation.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_otherinstrumentation.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_pressuresensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_pressuresensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    accuracy_hpa text,
    data_sampling_interval text,
    notes text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_pressuresensor OWNER TO geodesy;

--
-- Name: TABLE sitelog_pressuresensor; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_pressuresensor IS 'table contains information about pressure sensors of site log';


--
-- Name: COLUMN sitelog_pressuresensor.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_pressuresensor.callibration_date; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.callibration_date IS 'the calibration date in pressure sensor, timestamp without time zone';


--
-- Name: COLUMN sitelog_pressuresensor.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.effective_from IS 'time stamp(UTC) when a pressure sensor starts to be used';


--
-- Name: COLUMN sitelog_pressuresensor.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.effective_to IS 'time stamp(UTC) when a pressure sensor ceased to use';


--
-- Name: COLUMN sitelog_pressuresensor.height_diff_to_antenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.height_diff_to_antenna IS 'the height difference between pressure sensor and antenna';


--
-- Name: COLUMN sitelog_pressuresensor.manufacturer; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.manufacturer IS 'the manufacturer of the pressure sensor';


--
-- Name: COLUMN sitelog_pressuresensor.serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.serial_number IS 'the serial number of the pressure sensor';


--
-- Name: COLUMN sitelog_pressuresensor.type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.type IS 'the type of the pressure sensor, such as MET4 or PTB202A';


--
-- Name: COLUMN sitelog_pressuresensor.accuracy_hpa; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.accuracy_hpa IS 'measurement accuracy of the pressure sensor in hpa';


--
-- Name: COLUMN sitelog_pressuresensor.data_sampling_interval; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.data_sampling_interval IS 'the time interval between data sampling in using pressure sensor';


--
-- Name: COLUMN sitelog_pressuresensor.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.notes IS 'description or notes about pressure sensor';


--
-- Name: COLUMN sitelog_pressuresensor.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_pressuresensor.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_pressuresensor.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.date_deleted IS 'time stamp(UTC) when a sitelog_pressuresensor record is deleted';


--
-- Name: COLUMN sitelog_pressuresensor.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_pressuresensor.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_radiointerference; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_radiointerference (
    id integer NOT NULL,
    observed_degradation text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    possible_problem_source text,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    notes text,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_radiointerference OWNER TO geodesy;

--
-- Name: TABLE sitelog_radiointerference; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_radiointerference IS 'table contains information about radio interference in site log';


--
-- Name: COLUMN sitelog_radiointerference.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_radiointerference.observed_degradation; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.observed_degradation IS 'observed degradtion due to radio interference in site log';


--
-- Name: COLUMN sitelog_radiointerference.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_radiointerference.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_radiointerference.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.date_deleted IS 'time stamp(UTC) when a sitelog_radiointerference record is deleted';


--
-- Name: COLUMN sitelog_radiointerference.possible_problem_source; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.possible_problem_source IS 'the source of the problem';


--
-- Name: COLUMN sitelog_radiointerference.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.effective_from IS 'date when the problem first occurred';


--
-- Name: COLUMN sitelog_radiointerference.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.effective_to IS 'date when the problem was resolved';


--
-- Name: COLUMN sitelog_radiointerference.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.notes IS 'any extra comments about the problem';


--
-- Name: COLUMN sitelog_radiointerference.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_radiointerference.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_responsible_party; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_responsible_party (
    id integer NOT NULL,
    site_id integer,
    responsible_party text NOT NULL,
    responsible_role_id integer NOT NULL,
    index integer
);


ALTER TABLE geodesy.sitelog_responsible_party OWNER TO geodesy;

--
-- Name: TABLE sitelog_responsible_party; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_responsible_party IS 'The table contains information of responsible party that associated with a sitelog site. Currently the responsible party information is stored as xml text, but in the future it should be coverted into columns in the table, such as name, organisation, address etc to facilitate serach.';


--
-- Name: COLUMN sitelog_responsible_party.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_responsible_party.id IS 'unique identifier of the record, primary key';


--
-- Name: COLUMN sitelog_responsible_party.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_responsible_party.site_id IS 'foreign key to pk of sitelog_site table';


--
-- Name: COLUMN sitelog_responsible_party.responsible_party; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_responsible_party.responsible_party IS 'information about the responsible party that associated with the responsible role. currently in xml text';


--
-- Name: COLUMN sitelog_responsible_party.responsible_role_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_responsible_party.responsible_role_id IS 'a responsible role that associated with the responsible party record, foreign key to pk of sitelog_responsible_party_role';


--
-- Name: sitelog_responsible_party_role; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_responsible_party_role (
    id integer NOT NULL,
    responsible_role_name text NOT NULL,
    responsible_role_xmltag text
);


ALTER TABLE geodesy.sitelog_responsible_party_role OWNER TO geodesy;

--
-- Name: TABLE sitelog_responsible_party_role; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_responsible_party_role IS 'The table contains information about all roles within the responsible party.';


--
-- Name: COLUMN sitelog_responsible_party_role.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_responsible_party_role.id IS 'unique identifier of the record, primary key.';


--
-- Name: COLUMN sitelog_responsible_party_role.responsible_role_name; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_responsible_party_role.responsible_role_name IS 'the name of a responsible role in responsible party defined by OGC/gml schemas.';


--
-- Name: COLUMN sitelog_responsible_party_role.responsible_role_xmltag; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_responsible_party_role.responsible_role_xmltag IS 'the tag name used by responsible role in responsible party defined by OGC/gml schemas.';


--
-- Name: sitelog_signalobstraction; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_signalobstraction (
    id integer NOT NULL,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    possible_problem_source text,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    notes text,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_signalobstraction OWNER TO geodesy;

--
-- Name: TABLE sitelog_signalobstraction; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_signalobstraction IS 'table contains information about signal obstraction in site log';


--
-- Name: COLUMN sitelog_signalobstraction.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_signalobstraction.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_signalobstraction.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_signalobstraction.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.date_deleted IS 'time stamp(UTC) when a sitelog_signalobstraction record is deleted';


--
-- Name: COLUMN sitelog_signalobstraction.possible_problem_source; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.possible_problem_source IS 'the source of the problem';


--
-- Name: COLUMN sitelog_signalobstraction.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.effective_from IS 'date when the problem first occurred';


--
-- Name: COLUMN sitelog_signalobstraction.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.effective_to IS 'date when the problem was resolved';


--
-- Name: COLUMN sitelog_signalobstraction.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.notes IS 'any extra comments about the problem';


--
-- Name: COLUMN sitelog_signalobstraction.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_signalobstraction.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_site; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_site (
    id integer NOT NULL,
    entrydate timestamp without time zone,
    form_date_prepared timestamp without time zone,
    form_prepared_by text,
    form_report_type text,
    mi_antenna_graphics text,
    mi_hard_copy_on_file text,
    mi_horizontal_mask text,
    mi_text_graphics_from_antenna text,
    mi_monument_description text,
    mi_notes text,
    mi_primary_data_center text,
    mi_secondary_data_center text,
    mi_site_diagram text,
    mi_site_map text,
    mi_site_pictires text,
    mi_url_for_more_information text,
    bedrock_condition text,
    bedrock_type text,
    cdp_number text,
    date_installed timestamp without time zone,
    distance_activity text,
    fault_zones_nearby text,
    foundation_depth text,
    four_character_id character varying(4),
    fracture_spacing text,
    geologic_characteristic text,
    height_of_monument text,
    iers_domes_number text,
    marker_description text,
    monument_description text,
    monument_foundation text,
    monument_inscription text,
    notes text,
    site_name text,
    elevation_grs80 text,
    itrf_x double precision,
    itrf_y double precision,
    itrf_z double precision,
    city text,
    country text,
    location_notes text,
    state text,
    tectonic_plate text,
    site_log_text text NOT NULL,
    mi_doi text,
    nine_character_id character varying(9),
    cartesian_position public.geometry,
    geodetic_position public.geometry,
    last_date_modified timestamp(6) without time zone
);


ALTER TABLE geodesy.sitelog_site OWNER TO geodesy;

--
-- Name: TABLE sitelog_site; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_site IS 'table contains information about sites that generate IGS site logs';


--
-- Name: COLUMN sitelog_site.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_site.entrydate; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.entrydate IS 'the date the site log was created, timestamp without time zone';


--
-- Name: COLUMN sitelog_site.form_date_prepared; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.form_date_prepared IS 'the data the site log form is prepared, timestamp without time zone';


--
-- Name: COLUMN sitelog_site.form_prepared_by; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.form_prepared_by IS 'the person who prepared the sitelog form';


--
-- Name: COLUMN sitelog_site.form_report_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.form_report_type IS 'site log report type';


--
-- Name: COLUMN sitelog_site.mi_antenna_graphics; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_antenna_graphics IS 'graphics of mi antenna';


--
-- Name: COLUMN sitelog_site.mi_hard_copy_on_file; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_hard_copy_on_file IS 'indication whether a hard copy is kept in file';


--
-- Name: COLUMN sitelog_site.mi_horizontal_mask; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_horizontal_mask IS 'the mask for mi horizontal';


--
-- Name: COLUMN sitelog_site.mi_text_graphics_from_antenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_text_graphics_from_antenna IS 'text graphics from antenna';


--
-- Name: COLUMN sitelog_site.mi_monument_description; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_monument_description IS 'description of mi monument';


--
-- Name: COLUMN sitelog_site.mi_notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_notes IS 'description or notes about mi';


--
-- Name: COLUMN sitelog_site.mi_primary_data_center; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_primary_data_center IS 'mi primary data center';


--
-- Name: COLUMN sitelog_site.mi_secondary_data_center; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_secondary_data_center IS 'mi second data center';


--
-- Name: COLUMN sitelog_site.mi_site_diagram; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_site_diagram IS 'mi site diagram';


--
-- Name: COLUMN sitelog_site.mi_site_map; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_site_map IS 'mi site map';


--
-- Name: COLUMN sitelog_site.mi_site_pictires; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_site_pictires IS 'mi site pictires';


--
-- Name: COLUMN sitelog_site.mi_url_for_more_information; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_url_for_more_information IS 'mi url for query more information';


--
-- Name: COLUMN sitelog_site.bedrock_condition; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.bedrock_condition IS 'bedrock condition';


--
-- Name: COLUMN sitelog_site.bedrock_type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.bedrock_type IS 'the type of bedrock';


--
-- Name: COLUMN sitelog_site.cdp_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.cdp_number IS 'cdp number';


--
-- Name: COLUMN sitelog_site.date_installed; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.date_installed IS 'the date the site was installed, timestamp without time zone';


--
-- Name: COLUMN sitelog_site.distance_activity; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.distance_activity IS 'distance activity';


--
-- Name: COLUMN sitelog_site.fault_zones_nearby; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.fault_zones_nearby IS 'fault zone nearby (YES or NO)';


--
-- Name: COLUMN sitelog_site.foundation_depth; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.foundation_depth IS 'depth of foundation';


--
-- Name: COLUMN sitelog_site.four_character_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.four_character_id IS 'four character unique identifier of a gnss site';


--
-- Name: COLUMN sitelog_site.fracture_spacing; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.fracture_spacing IS 'the spacing of opening -mode fractures in layered materials';


--
-- Name: COLUMN sitelog_site.geologic_characteristic; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.geologic_characteristic IS 'features of the earth that were formed by goelogical processes';


--
-- Name: COLUMN sitelog_site.height_of_monument; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.height_of_monument IS 'the height of mounument';


--
-- Name: COLUMN sitelog_site.iers_domes_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.iers_domes_number IS 'IERS DOMES number';


--
-- Name: COLUMN sitelog_site.marker_description; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.marker_description IS 'Definition of marker';


--
-- Name: COLUMN sitelog_site.monument_description; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.monument_description IS 'description of monument';


--
-- Name: COLUMN sitelog_site.monument_foundation; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.monument_foundation IS 'foundataion of mounment';


--
-- Name: COLUMN sitelog_site.monument_inscription; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.monument_inscription IS 'inscription of monument';


--
-- Name: COLUMN sitelog_site.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.notes IS 'description or notes about site';


--
-- Name: COLUMN sitelog_site.site_name; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.site_name IS 'the name of the site';


--
-- Name: COLUMN sitelog_site.elevation_grs80; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.elevation_grs80 IS 'elevation data in Geodetic Reference System of 1980';


--
-- Name: COLUMN sitelog_site.itrf_x; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.itrf_x IS 'x origin expressed in the ITRF frame';


--
-- Name: COLUMN sitelog_site.itrf_y; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.itrf_y IS 'y origin expressed in the ITRF frame';


--
-- Name: COLUMN sitelog_site.itrf_z; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.itrf_z IS 'z origin expressed in the ITRF frame';


--
-- Name: COLUMN sitelog_site.city; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.city IS 'site city location';


--
-- Name: COLUMN sitelog_site.location_notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.location_notes IS 'description or notes on location';


--
-- Name: COLUMN sitelog_site.state; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.state IS 'site state location';


--
-- Name: COLUMN sitelog_site.tectonic_plate; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.tectonic_plate IS 'tectonic plate the site is sitting on';


--
-- Name: COLUMN sitelog_site.site_log_text; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.site_log_text IS 'the contents of the site log';


--
-- Name: COLUMN sitelog_site.mi_doi; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.mi_doi IS 'doi of mi';


--
-- Name: COLUMN sitelog_site.nine_character_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.nine_character_id IS 'the nine character unique identifier of a site';


--
-- Name: COLUMN sitelog_site.cartesian_position; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.cartesian_position IS 'Position in EPSG:7789 reference system - x,y,z';


--
-- Name: COLUMN sitelog_site.geodetic_position; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_site.geodetic_position IS 'Position in EPSG:7912 reference system - lat,long,elevation';


--
-- Name: sitelog_surveyedlocaltie; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_surveyedlocaltie (
    id integer NOT NULL,
    date_measured timestamp without time zone,
    dx double precision,
    dy double precision,
    dz double precision,
    local_site_tie_accuracy text,
    notes text,
    survey_method text,
    tied_marker_cdp_number text,
    tied_marker_domes_number text,
    tied_marker_name text,
    tied_marker_usage text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_surveyedlocaltie OWNER TO geodesy;

--
-- Name: TABLE sitelog_surveyedlocaltie; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_surveyedlocaltie IS 'table contains information about surveyed local ties in site log';


--
-- Name: COLUMN sitelog_surveyedlocaltie.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_surveyedlocaltie.date_measured; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.date_measured IS 'the date when a survey is made in the local ties, timestamp without time zone';


--
-- Name: COLUMN sitelog_surveyedlocaltie.dx; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.dx IS 'x origin expressed in the local ties surveyed';


--
-- Name: COLUMN sitelog_surveyedlocaltie.dy; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.dy IS 'y origin expressed in the local ties surveyed';


--
-- Name: COLUMN sitelog_surveyedlocaltie.dz; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.dz IS 'z origin expressed in the local ties surveyed';


--
-- Name: COLUMN sitelog_surveyedlocaltie.local_site_tie_accuracy; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.local_site_tie_accuracy IS 'accuracy for surveyed local ties in site log';


--
-- Name: COLUMN sitelog_surveyedlocaltie.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.notes IS 'description or notes about local ties surveyed';


--
-- Name: COLUMN sitelog_surveyedlocaltie.survey_method; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.survey_method IS 'method used to survey local ties';


--
-- Name: COLUMN sitelog_surveyedlocaltie.tied_marker_cdp_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.tied_marker_cdp_number IS 'CDP number of tied marker for surveyed local ties';


--
-- Name: COLUMN sitelog_surveyedlocaltie.tied_marker_domes_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.tied_marker_domes_number IS 'DOMES number of tied marker for surveyed local ties';


--
-- Name: COLUMN sitelog_surveyedlocaltie.tied_marker_name; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.tied_marker_name IS 'the name of tied marker for surveyed local ties';


--
-- Name: COLUMN sitelog_surveyedlocaltie.tied_marker_usage; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.tied_marker_usage IS 'usage of tied marker for surveyed local ties';


--
-- Name: COLUMN sitelog_surveyedlocaltie.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.site_id IS 'unique identifier of a site in site log, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_surveyedlocaltie.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_surveyedlocaltie.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.date_deleted IS 'time stamp(UTC) when a sitelog_surveyedlocaltie record is deleted';


--
-- Name: COLUMN sitelog_surveyedlocaltie.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_surveyedlocaltie.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_temperaturesensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_temperaturesensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    accurace_degree_celcius text,
    aspiration text,
    data_sampling_interval text,
    notes text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_temperaturesensor OWNER TO geodesy;

--
-- Name: TABLE sitelog_temperaturesensor; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_temperaturesensor IS 'table contains information about temperature sensor used in site log';


--
-- Name: COLUMN sitelog_temperaturesensor.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_temperaturesensor.callibration_date; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.callibration_date IS 'the calibration date in temperature sensor, timestamp without time zone';


--
-- Name: COLUMN sitelog_temperaturesensor.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.effective_from IS 'time stamp(UTC) when a temperature sensor starts to use';


--
-- Name: COLUMN sitelog_temperaturesensor.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.effective_to IS 'time stamp(UTC) when a temperature sensor ceased to use';


--
-- Name: COLUMN sitelog_temperaturesensor.height_diff_to_antenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.height_diff_to_antenna IS 'height difference between temperature sensor and antenna';


--
-- Name: COLUMN sitelog_temperaturesensor.manufacturer; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.manufacturer IS 'the manufacturer of the temperature sensor';


--
-- Name: COLUMN sitelog_temperaturesensor.serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.serial_number IS 'the serial number of the temperature sensor';


--
-- Name: COLUMN sitelog_temperaturesensor.type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.type IS 'the type of the temperature sensor';


--
-- Name: COLUMN sitelog_temperaturesensor.accurace_degree_celcius; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.accurace_degree_celcius IS 'measurement accuracy in celcius degree';


--
-- Name: COLUMN sitelog_temperaturesensor.aspiration; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.aspiration IS 'aspiration of temperature sensor';


--
-- Name: COLUMN sitelog_temperaturesensor.data_sampling_interval; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.data_sampling_interval IS 'the time interval between data sampling in using temperature sensor';


--
-- Name: COLUMN sitelog_temperaturesensor.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.notes IS 'description or notes about temperature sensor';


--
-- Name: COLUMN sitelog_temperaturesensor.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_temperaturesensor.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_temperaturesensor.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.date_deleted IS 'time stamp(UTC) when a sitelog_temperaturesensor record is deleted';


--
-- Name: COLUMN sitelog_temperaturesensor.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_temperaturesensor.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: sitelog_watervaporsensor; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.sitelog_watervaporsensor (
    id integer NOT NULL,
    callibration_date timestamp without time zone,
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    height_diff_to_antenna text,
    manufacturer text,
    serial_number text,
    type text,
    distance_to_antenna double precision,
    notes text,
    site_id integer,
    deleted_reason text,
    date_deleted timestamp(6) without time zone,
    date_inserted timestamp without time zone
);


ALTER TABLE geodesy.sitelog_watervaporsensor OWNER TO geodesy;

--
-- Name: TABLE sitelog_watervaporsensor; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.sitelog_watervaporsensor IS 'table contains information about water vaport sensor used in site log';


--
-- Name: COLUMN sitelog_watervaporsensor.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.id IS 'the unique identifier of a record in the table, primary key';


--
-- Name: COLUMN sitelog_watervaporsensor.callibration_date; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.callibration_date IS 'the calibration date in water vaport sensor, timestamp without time zone';


--
-- Name: COLUMN sitelog_watervaporsensor.effective_from; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.effective_from IS 'time stamp(UTC) when a water vapor sensor starts to use';


--
-- Name: COLUMN sitelog_watervaporsensor.effective_to; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.effective_to IS 'time stamp(UTC) when a water vapor sensor ceased to use';


--
-- Name: COLUMN sitelog_watervaporsensor.height_diff_to_antenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.height_diff_to_antenna IS 'the height difference between water vapor sensor and antenna';


--
-- Name: COLUMN sitelog_watervaporsensor.manufacturer; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.manufacturer IS 'the manufacturer of the water vapor sensor';


--
-- Name: COLUMN sitelog_watervaporsensor.serial_number; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.serial_number IS 'the serial number of the water vapor sensor';


--
-- Name: COLUMN sitelog_watervaporsensor.type; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.type IS 'the type of the water vapor sensor';


--
-- Name: COLUMN sitelog_watervaporsensor.distance_to_antenna; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.distance_to_antenna IS 'the distance between water vapor sensor and antenna';


--
-- Name: COLUMN sitelog_watervaporsensor.notes; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.notes IS 'description or notes about water vapor sensor';


--
-- Name: COLUMN sitelog_watervaporsensor.site_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.site_id IS 'unique identifier of a site, foreign key to id in sitelog_site table';


--
-- Name: COLUMN sitelog_watervaporsensor.deleted_reason; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.deleted_reason IS 'a short statement why the record is deleted';


--
-- Name: COLUMN sitelog_watervaporsensor.date_deleted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.date_deleted IS 'time stamp(UTC) when a sitelog_watervaporsensor record is deleted';


--
-- Name: COLUMN sitelog_watervaporsensor.date_inserted; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.sitelog_watervaporsensor.date_inserted IS 'datetime the record was inserted into the log';


--
-- Name: user_registration; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.user_registration (
    id integer NOT NULL,
    email text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    organisation text NOT NULL,
    phone text NOT NULL,
    "position" text NOT NULL,
    remarks text NOT NULL
);


ALTER TABLE geodesy.user_registration OWNER TO geodesy;

--
-- Name: user_registration_received; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.user_registration_received (
    user_registration_id integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE geodesy.user_registration_received OWNER TO geodesy;

--
-- Name: v_cors_site; Type: VIEW; Schema: geodesy; Owner: geodesy
--

CREATE VIEW geodesy.v_cors_site AS
 SELECT s.id,
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
   FROM geodesy.site s,
    geodesy.cors_site cs
  WHERE (s.id = cs.id);


ALTER TABLE geodesy.v_cors_site OWNER TO geodesy;

--
-- Name: weekly_solution; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.weekly_solution (
    id integer NOT NULL,
    as_at timestamp without time zone,
    epoch timestamp without time zone,
    sinex_file_name text
);


ALTER TABLE geodesy.weekly_solution OWNER TO geodesy;

--
-- Name: TABLE weekly_solution; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.weekly_solution IS 'table contains information about weekly solutions';


--
-- Name: weekly_solution_available; Type: TABLE; Schema: geodesy; Owner: geodesy
--

CREATE TABLE geodesy.weekly_solution_available (
    weekly_solution_id integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE geodesy.weekly_solution_available OWNER TO geodesy;

--
-- Name: TABLE weekly_solution_available; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON TABLE geodesy.weekly_solution_available IS 'the table contains information about available solution to a domain event';


--
-- Name: COLUMN weekly_solution_available.weekly_solution_id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.weekly_solution_available.weekly_solution_id IS 'foreign key to id in domain event table';


--
-- Name: COLUMN weekly_solution_available.id; Type: COMMENT; Schema: geodesy; Owner: geodesy
--

COMMENT ON COLUMN geodesy.weekly_solution_available.id IS 'the unique identifier of a record in the table, primary key';


--
-- Data for Name: clock_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.clock_configuration (id, input_frequency) FROM stdin;
\.


--
-- Data for Name: cors_site; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.cors_site (bedrock_condition, bedrock_type, domes_number, four_character_id, geologic_characteristic, id, monument_id, nine_character_id, site_status) FROM stdin;
\.


--
-- Data for Name: cors_site_added_to_network; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.cors_site_added_to_network (network_id, effective_from, effective_to, site_id, id) FROM stdin;
\.


--
-- Data for Name: cors_site_in_network; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.cors_site_in_network (id, cors_site_id, cors_site_network_id, effective_from, effective_to) FROM stdin;
\.


--
-- Data for Name: cors_site_network; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.cors_site_network (id, name, description, version) FROM stdin;
1	APREF	\N	1
51	ARGN	\N	1
101	AUSCOPE	\N	1
151	CAMPAIGN	\N	1
201	CORSNET-NSW	\N	1
251	GEONET	\N	1
301	GPSNET	\N	1
351	IGS	\N	1
401	POSITIONZ	\N	1
451	RTKNETWEST	\N	1
501	SPRGN	\N	1
551	SUNPOZ	\N	1
\.


--
-- Data for Name: cors_site_removed_from_network; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.cors_site_removed_from_network (network_id, effective_from, site_id, id) FROM stdin;
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
1464742487660-1	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:03.860524	1	EXECUTED	7:2a4dd6b2a7fb54bad8e62d1e94c47c28	createSequence sequenceName=seq_event		\N	3.5.3	\N	\N	8147623451
1464742487660-2	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:03.896787	2	EXECUTED	7:b0ea6bcffbbea9bf625b0f499912e255	createSequence sequenceName=seq_sitelogantenna		\N	3.5.3	\N	\N	8147623451
1464742487660-3	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:03.916035	3	EXECUTED	7:72f5bd12ed54d1fbe2d3eba5fe5aec87	createSequence sequenceName=seq_sitelogcollocationinfo		\N	3.5.3	\N	\N	8147623451
1464742487660-4	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:03.945533	4	EXECUTED	7:396ff91a03798752c5fd4d59b50d1a28	createSequence sequenceName=seq_sitelogfrequencystandard		\N	3.5.3	\N	\N	8147623451
1464742487660-5	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:03.971728	5	EXECUTED	7:1b34ad155c8978443fe109fef291ec02	createSequence sequenceName=seq_siteloghumiditysensor		\N	3.5.3	\N	\N	8147623451
1464742487660-6	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:03.981102	6	EXECUTED	7:dd4e906c1b7e92c7bbd9394e09bf7e87	createSequence sequenceName=seq_siteloglocalepisodicevent		\N	3.5.3	\N	\N	8147623451
1464742487660-7	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.011575	7	EXECUTED	7:5c7b0c0a24b56208b06655b28ae9d442	createSequence sequenceName=seq_siteloglocaltie		\N	3.5.3	\N	\N	8147623451
1464742487660-8	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.027061	8	EXECUTED	7:152e9ca6dfa32f7a02fe928fbf9cd4ae	createSequence sequenceName=seq_sitelogmultipathsource		\N	3.5.3	\N	\N	8147623451
1464742487660-9	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.040231	9	EXECUTED	7:9cca0c65fafb6e6d0f34e8e759cf5c7d	createSequence sequenceName=seq_sitelogotherinstrument		\N	3.5.3	\N	\N	8147623451
1464742487660-10	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.058955	10	EXECUTED	7:3b5e26e4921f6ab7ec2540c6f3051a5b	createSequence sequenceName=seq_sitelogpressuresensor		\N	3.5.3	\N	\N	8147623451
1464742487660-11	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.07328	11	EXECUTED	7:b874fe45a2549bb588479b6749e905a4	createSequence sequenceName=seq_sitelogradiointerference		\N	3.5.3	\N	\N	8147623451
1464742487660-12	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.091901	12	EXECUTED	7:20997afc8e96bf3c3b08b108dd09317c	createSequence sequenceName=seq_sitelogreceiver		\N	3.5.3	\N	\N	8147623451
1464742487660-13	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.104232	13	EXECUTED	7:b2b2016e465b3731ed41e5d7d43c42d8	createSequence sequenceName=seq_sitelogsignalobstruction		\N	3.5.3	\N	\N	8147623451
1464742487660-14	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.113469	14	EXECUTED	7:387448feb47c7742e918e9e035274297	createSequence sequenceName=seq_sitelogsite		\N	3.5.3	\N	\N	8147623451
1464742487660-15	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.131775	15	EXECUTED	7:7148aca958f1b2545bf88b06e22bfb92	createSequence sequenceName=seq_sitelogtemperaturesensor		\N	3.5.3	\N	\N	8147623451
1464742487660-16	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.141324	16	EXECUTED	7:6feb5a726a22905249d8550baf9ff0e6	createSequence sequenceName=seq_sitelogwatervaporsensor		\N	3.5.3	\N	\N	8147623451
1464742487660-17	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.177682	17	EXECUTED	7:8ffe0ddda63385420d097e3a2509724c	createSequence sequenceName=seq_surrogate_keys		\N	3.5.3	\N	\N	8147623451
1464742487660-18	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.185932	18	EXECUTED	7:ebc6c0045986823adcb06ad59bbdcfc8	createTable tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-19	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.199406	19	EXECUTED	7:0eeee521a1a7a70d4c912060720b56dd	createTable tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1464742487660-20	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.215051	20	EXECUTED	7:2e7fbbcaf355b21e9868f4ea569e8e77	createTable tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1464742487660-21	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.231031	21	EXECUTED	7:e5b30d93e010a715aa7ccb7316b8d5f0	createTable tableName=equipment		\N	3.5.3	\N	\N	8147623451
1464742487660-22	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.246377	22	EXECUTED	7:35e7847eec3c275f511ef3d9ffb4e74d	createTable tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1464742487660-23	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.259948	23	EXECUTED	7:d3a55d70973289fffbd1ed2d5b68100f	createTable tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-24	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.273076	24	EXECUTED	7:f7e3538378a7125e288f60b5a7e03d42	createTable tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-25	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.283777	25	EXECUTED	7:1b2feb62573bdb2a53ca2d5d4fdf8a28	createTable tableName=humidity_sensor		\N	3.5.3	\N	\N	8147623451
1464742487660-26	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.303979	26	EXECUTED	7:3bd269014eafc98c54651829e994c552	createTable tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-27	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.316527	27	EXECUTED	7:7db50529fd12f857883d5311e5ac59b5	createTable tableName=invalid_site_log_received		\N	3.5.3	\N	\N	8147623451
1464742487660-28	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.333734	28	EXECUTED	7:6b4df0c48a48f4897636fc7414fb2f5c	createTable tableName=monument		\N	3.5.3	\N	\N	8147623451
1464742487660-29	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.344012	29	EXECUTED	7:241ffba958accea8c6641e57ddacce5e	createTable tableName=node		\N	3.5.3	\N	\N	8147623451
1464742487660-30	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.355962	30	EXECUTED	7:6100a1d72706417e4b10fe38333ced2e	createTable tableName=position		\N	3.5.3	\N	\N	8147623451
1464742487660-31	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.369342	31	EXECUTED	7:2773d96b3417ce619959cff54e0c7af3	createTable tableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1464742487660-32	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.381095	32	EXECUTED	7:e765d26e935353cd831b96766a60a011	createTable tableName=setup		\N	3.5.3	\N	\N	8147623451
1464742487660-33	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.395101	33	EXECUTED	7:185fd1d5119a097cefbc22cffbeca270	createTable tableName=site		\N	3.5.3	\N	\N	8147623451
1464742487660-34	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.406968	34	EXECUTED	7:1e3cb4e53f6becb91b0020088246079f	createTable tableName=site_log_received		\N	3.5.3	\N	\N	8147623451
1464742487660-35	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.416465	35	EXECUTED	7:ae8efc9850d88ea55ea24f948e06c72a	createTable tableName=site_updated		\N	3.5.3	\N	\N	8147623451
1464742487660-36	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.43164	36	EXECUTED	7:75dea22fc34bf0fe2b62a39bba18d4e7	createTable tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1464742487660-37	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.444032	37	EXECUTED	7:cce7ac7f2704d46a07346e749cd7f1f0	createTable tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1464742487660-38	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.458152	38	EXECUTED	7:ef60fc43b388af31cf04721229fa0d37	createTable tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1464742487660-39	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.47348	39	EXECUTED	7:7da264dfb246573e3cf6d9fea9d61b46	createTable tableName=sitelog_gnssgreceiver		\N	3.5.3	\N	\N	8147623451
1464742487660-40	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.486675	40	EXECUTED	7:b1e37f1a8b2175ef20dba51cfdfc41ae	createTable tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1464742487660-41	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.49821	41	EXECUTED	7:dec2ffe3029d4f1fd8c9e8e84f7bf09b	createTable tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1464742487660-42	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.507012	42	EXECUTED	7:c3f691297907948621ed890b8172a1a0	createTable tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1464742487660-43	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.519679	43	EXECUTED	7:5c73df66532d44045d966ff2a4072e66	createTable tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1464742487660-44	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.535016	44	EXECUTED	7:f79450124910cebd6df61a13a59b4214	createTable tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1464742487660-45	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.542181	45	EXECUTED	7:e4e44b113681ec1b880277187dc138f1	createTable tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1464742487660-46	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.551973	46	EXECUTED	7:a4f55bf1c827c526294865643e29a16a	createTable tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1464742487660-47	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.575068	47	EXECUTED	7:ce3e61a73134ad24ff13f628654b04a7	createTable tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-48	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.587937	48	EXECUTED	7:a5e7fda6e4448d93f514f837317af628	createTable tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1464742487660-49	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.612318	49	EXECUTED	7:5dbaef061683670db540c47dfecb85ef	createTable tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1464742487660-50	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.632425	50	EXECUTED	7:e3870722fb48e6ed9f64218e288847ba	createTable tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1464742487660-51	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.647763	51	EXECUTED	7:d932f717541f4569c55caa44bda8df3e	createTable tableName=weekly_solution		\N	3.5.3	\N	\N	8147623451
1464742487660-52	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.665866	52	EXECUTED	7:845a006d5a17f43f207d8daec6f26a5b	createTable tableName=weekly_solution_available		\N	3.5.3	\N	\N	8147623451
1464742487660-54	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.68463	53	EXECUTED	7:385d20c42154aa7fb3a07e4798c8da46	addPrimaryKey constraintName=clock_configuration_pkey, tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-55	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.695769	54	EXECUTED	7:9933ed5009080f6ade54d9ed66acf18a	addPrimaryKey constraintName=cors_site_pkey, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1464742487660-56	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.710138	55	EXECUTED	7:baf9f75edfd130ad7c84e601325e65de	addPrimaryKey constraintName=domain_event_pkey, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1464742487660-57	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.722508	56	EXECUTED	7:b48cbb1555008354d21c51d32e93cd22	addPrimaryKey constraintName=equipment_in_use_pkey, tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1464742487660-58	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.736133	57	EXECUTED	7:4b6b911c4909d6693c5ccb34a0e8d179	addPrimaryKey constraintName=equipment_pkey, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1464742487660-59	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.754523	58	EXECUTED	7:e2c36bbb3512978f81b7f1a9f9c25643	addPrimaryKey constraintName=gnss_antenna_configuration_pkey, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-60	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.764148	59	EXECUTED	7:4f50a082bee6d19d8c262c3f91017a72	addPrimaryKey constraintName=gnss_receiver_configuration_pkey, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-61	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.774669	60	EXECUTED	7:e65bfac7c40f6c8906f831bb9d8ee0a0	addPrimaryKey constraintName=humidity_sensor_configuration_pkey, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1464742487660-62	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.790508	61	EXECUTED	7:6bde33c68827285599c8232b9d649ace	addPrimaryKey constraintName=humidity_sensor_pkey, tableName=humidity_sensor		\N	3.5.3	\N	\N	8147623451
1464742487660-63	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.799243	62	EXECUTED	7:45af95d7d39bc2badee2d843989b8ce3	addPrimaryKey constraintName=invalid_site_log_received_pkey, tableName=invalid_site_log_received		\N	3.5.3	\N	\N	8147623451
1464742487660-64	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.814601	63	EXECUTED	7:4d6f113562d6a69ca42e48e04c21ff51	addPrimaryKey constraintName=monument_pkey, tableName=monument		\N	3.5.3	\N	\N	8147623451
1464742487660-65	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.823308	64	EXECUTED	7:02696cfeda038626b787993af761b8c1	addPrimaryKey constraintName=node_pkey, tableName=node		\N	3.5.3	\N	\N	8147623451
1464742487660-66	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.834223	65	EXECUTED	7:0380327c68cd5a6a54addc8cd5e72b18	addPrimaryKey constraintName=position_pkey, tableName=position		\N	3.5.3	\N	\N	8147623451
1464742487660-67	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.844754	66	EXECUTED	7:05891fa768f34399f0ad6dc4523c8cf2	addPrimaryKey constraintName=responsible_party_pkey, tableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1464742487660-68	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.85171	67	EXECUTED	7:88f6fd670cd11c32911657cf0386e98a	addPrimaryKey constraintName=setup_pkey, tableName=setup		\N	3.5.3	\N	\N	8147623451
1473286366418-5	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.507086	147	EXECUTED	7:f5dbb2468d80488a0e7763ce6f136dc5	modifyDataType columnName=alignment_from_true_north, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1464742487660-69	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.859969	68	EXECUTED	7:21d03fc6d3063bd735ac9952ef671efb	addPrimaryKey constraintName=site_log_received_pkey, tableName=site_log_received		\N	3.5.3	\N	\N	8147623451
1464742487660-70	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.873957	69	EXECUTED	7:880ee6601ce7db71c6d440a0eca68541	addPrimaryKey constraintName=site_pkey, tableName=site		\N	3.5.3	\N	\N	8147623451
1464742487660-71	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.884147	70	EXECUTED	7:35f83f0a8a482cd4c7ad23fcaa80766c	addPrimaryKey constraintName=site_updated_pkey, tableName=site_updated		\N	3.5.3	\N	\N	8147623451
1464742487660-72	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.891545	71	EXECUTED	7:8d4e7b39207bd8d087107c4e1470bc22	addPrimaryKey constraintName=sitelog_collocationinformation_pkey, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1464742487660-73	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.901041	72	EXECUTED	7:f24d3e2093d4a5e10d54aaafcec6c43f	addPrimaryKey constraintName=sitelog_frequencystandard_pkey, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1464742487660-74	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.908393	73	EXECUTED	7:3ab4648373f63660cfdb49a36e258637	addPrimaryKey constraintName=sitelog_gnssantenna_pkey, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1464742487660-75	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.91644	74	EXECUTED	7:f791db1c7e3d0d15e3c81205bd760925	addPrimaryKey constraintName=sitelog_gnssgreceiver_pkey, tableName=sitelog_gnssgreceiver		\N	3.5.3	\N	\N	8147623451
1464742487660-76	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.932697	75	EXECUTED	7:711c53bc8ebb42fd1382fd892dbbdac6	addPrimaryKey constraintName=sitelog_humiditysensor_pkey, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1464742487660-77	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.941615	76	EXECUTED	7:ff57c0435506639047c5a20061cbb63c	addPrimaryKey constraintName=sitelog_localepisodicevent_pkey, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1464742487660-78	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.951731	77	EXECUTED	7:849f26cfb8aeff96c4187609d232000a	addPrimaryKey constraintName=sitelog_mutlipathsource_pkey, tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1464742487660-79	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.959327	78	EXECUTED	7:13c3c5309eb148066b77a1fb76ef5a55	addPrimaryKey constraintName=sitelog_otherinstrumentation_pkey, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1464742487660-80	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.967031	79	EXECUTED	7:f7828a7a676aa372445bc4b142f60620	addPrimaryKey constraintName=sitelog_pressuresensor_pkey, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1464742487660-81	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.974399	80	EXECUTED	7:b09783a7d2dc15e32022b299550aeea9	addPrimaryKey constraintName=sitelog_radiointerference_pkey, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1464742487660-82	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.981763	81	EXECUTED	7:360ff3ff2c790c6e79a0b1a7d4d6af2d	addPrimaryKey constraintName=sitelog_signalobstraction_pkey, tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1464742487660-83	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.988676	82	EXECUTED	7:a567e35511d5977b4286c33c0200ca18	addPrimaryKey constraintName=sitelog_site_pkey, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-84	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:04.996195	83	EXECUTED	7:9775d5687a4ea2f42125b71d02babc3a	addPrimaryKey constraintName=sitelog_surveyedlocaltie_pkey, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1464742487660-85	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.003698	84	EXECUTED	7:514045c1ed51a0fcbae9ea6bb64b8a98	addPrimaryKey constraintName=sitelog_temperaturesensor_pkey, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1464742487660-86	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.011013	85	EXECUTED	7:f5e9d2ce7f2371a6fafd3a8965db899a	addPrimaryKey constraintName=sitelog_watervaporsensor_pkey, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1464742487660-87	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.018257	86	EXECUTED	7:5d6b9866e9f065305aa4f99a98e408f8	addPrimaryKey constraintName=weekly_solution_available_pkey, tableName=weekly_solution_available		\N	3.5.3	\N	\N	8147623451
1464742487660-88	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.025751	87	EXECUTED	7:d7e157e23a4d12c1d54c7e0de1cafd3f	addPrimaryKey constraintName=weekly_solution_pkey, tableName=weekly_solution		\N	3.5.3	\N	\N	8147623451
1464742487660-89	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.034248	88	EXECUTED	7:da0d597c13fded412ee2280e69cad2d7	addUniqueConstraint constraintName=uk_fg9w6m54cvx6bhnjag7t1i4a8, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1464742487660-90	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.041355	89	EXECUTED	7:49d9c59be21df83b333c1f58b7293eb1	addForeignKeyConstraint baseTableName=sitelog_signalobstraction, constraintName=fk1cs9mfi9h443h8b8fwp2g8o2j, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-91	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.047169	90	EXECUTED	7:bd677c3de84909dd2c4055977da2f913	addForeignKeyConstraint baseTableName=cors_site, constraintName=fk25mip9h81ast4isagcbn5nnsk, referencedTableName=monument		\N	3.5.3	\N	\N	8147623451
1464742487660-92	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.053024	91	EXECUTED	7:b4569a06600eed01370a634a78fb0985	addForeignKeyConstraint baseTableName=sitelog_gnssantenna, constraintName=fk2kaqvog12n3c227vv9wmka8sk, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-93	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.058557	92	EXECUTED	7:90b7a42deddb7f76537d250e6d04c319	addForeignKeyConstraint baseTableName=humidity_sensor, constraintName=fk3v3u8pev0722n8fjgvx596fsg, referencedTableName=equipment		\N	3.5.3	\N	\N	8147623451
1464742487660-94	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.064225	93	EXECUTED	7:7293a0e9ca4e5145d365f17c06a7d900	addForeignKeyConstraint baseTableName=site_updated, constraintName=fk4k5lbyl5p83qh9dikhri2m5v3, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1464742487660-95	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.06981	94	EXECUTED	7:71fcced1d396fcc21860ac19b1250d59	addForeignKeyConstraint baseTableName=site_log_received, constraintName=fk66u1s5twhejx5r71kce1xbndo, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1464742487660-96	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.075543	95	EXECUTED	7:4ce70e5ddaf0b478d894808fd059e34a	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk6j824swpk9wrunv18oltj7r4h, referencedTableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1464742487660-97	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.082219	96	EXECUTED	7:f87ca48a3c5f4d3b2587fd408baf9778	addForeignKeyConstraint baseTableName=equipment_in_use, constraintName=fk6l38ggororukg4q0921somuq2, referencedTableName=setup		\N	3.5.3	\N	\N	8147623451
1464742487660-98	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.087921	97	EXECUTED	7:0dc1da316946fbd00f11b02510a19dab	addForeignKeyConstraint baseTableName=sitelog_collocationinformation, constraintName=fk7dvx9fjqujrwswcq5ai8yrbgd, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-99	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.094526	98	EXECUTED	7:237c33fc64f28c7caa662f3e9108a10d	addForeignKeyConstraint baseTableName=sitelog_gnssgreceiver, constraintName=fk9pk6uvtcik5nbfnxqbj57sl7a, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-100	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.100233	99	EXECUTED	7:cb9185929be191f9d853d9fe0498fc38	addForeignKeyConstraint baseTableName=sitelog_pressuresensor, constraintName=fkac6h7fcxwqdb02wmd9ioa9qxy, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-101	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.11057	100	EXECUTED	7:866ce473d93a8cc157011461959de876	addForeignKeyConstraint baseTableName=sitelog_frequencystandard, constraintName=fkdbdv2fxny6htdef63toxeouo4, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-102	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.118703	101	EXECUTED	7:4b3538a963763c3641cf17058617f6d2	addForeignKeyConstraint baseTableName=sitelog_otherinstrumentation, constraintName=fkeuy2r6xamax3cuji4c48scctu, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-103	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.132204	102	EXECUTED	7:920fac2bc1b9ed95e71512c3200c85f6	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fkfhimbva6rwtmx2jwvtimp1iau, referencedTableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1464742487660-104	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.148953	103	EXECUTED	7:3b74b3d985555f8dc54dd3c92393ae35	addForeignKeyConstraint baseTableName=sitelog_watervaporsensor, constraintName=fkgu7ol5xrkfrdcx68jg7y3yfnx, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-105	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.156575	104	EXECUTED	7:a162adf81baf0fc078c72291d4072de3	addForeignKeyConstraint baseTableName=cors_site, constraintName=fkhsotbco85rmtycrk2fydldkv5, referencedTableName=site		\N	3.5.3	\N	\N	8147623451
1464742487660-106	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.164728	105	EXECUTED	7:059049cc8953de8cf3580c31dde417e0	addForeignKeyConstraint baseTableName=sitelog_radiointerference, constraintName=fkketnpsi74n9jy8h4ivigf0rm5, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-107	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.174355	106	EXECUTED	7:6f210c37e32c7284c2564b7e52c75a8b	addForeignKeyConstraint baseTableName=sitelog_mutlipathsource, constraintName=fkkria59xm558w92kh5lqpd1f3x, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-108	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.183574	107	EXECUTED	7:268d5db86999c6b7657f570c615cccee	addForeignKeyConstraint baseTableName=sitelog_humiditysensor, constraintName=fkmlt0smj74de6jldjl24s27vj8, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-109	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.195322	108	EXECUTED	7:7eb3f4736e810a5e3c3d0f0e41f35895	addForeignKeyConstraint baseTableName=sitelog_localepisodicevent, constraintName=fkmx1d8uddptk7ey2qqemjblaqh, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-110	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.210858	109	EXECUTED	7:1bdfce992e3c77a27ef9016d532460e9	addForeignKeyConstraint baseTableName=sitelog_temperaturesensor, constraintName=fkqi6nwchgfbv76i7lbyommqfb5, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-111	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.226121	110	EXECUTED	7:188e95c9d80a127147b946687ffacf40	addForeignKeyConstraint baseTableName=sitelog_surveyedlocaltie, constraintName=fksve549v5ist4ri18uvf8sxjn3, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1464742487660-112	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.234471	111	EXECUTED	7:8dc1eb19a98a3c0389e9cef54d4a9997	addForeignKeyConstraint baseTableName=invalid_site_log_received, constraintName=fkt0wcgi5uifpvl1m5vbxtbql2d, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1464742487660-113	simon (generated)	db/geodesy-db-schema-baseline.xml	2020-04-29 08:07:05.241013	112	EXECUTED	7:ec69a902fb46a78acc713b7eb1320150	addForeignKeyConstraint baseTableName=weekly_solution_available, constraintName=fktiaeyjhtj7j08vvfdab8ft66y, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1465197179687-1	lazar (generated)	db/rename-site-name-column.xml	2020-04-29 08:07:05.24912	113	EXECUTED	7:30176eccb1c353c08f0d1e5d0ffbd669	renameColumn newColumnName=name, oldColumnName=site_name, tableName=site		\N	3.5.3	\N	\N	8147623451
1465281587609-1	lazar (generated)	db/add-site-log-text-column.xml	2020-04-29 08:07:05.2628	114	EXECUTED	7:d34ec880ecf16b3af5cb0e496eb26980	addColumn tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
renameTable sitelog_gnssgreceiver to sitelog_gnssreceiver -1	simon	db/rename-sitelog_gnssgantenna-table-to-sitelog_gnssantenna.xml	2020-04-29 08:07:05.271866	115	EXECUTED	7:38cd051bf0abe331df1d1fa32aded0b3	renameTable newTableName=sitelog_gnssreceiver, oldTableName=sitelog_gnssgreceiver		\N	3.5.3	\N	\N	8147623451
renameTable sitelog_gnssgreceiver to sitelog_gnssreceiver -2	simon	db/rename-sitelog_gnssgantenna-table-to-sitelog_gnssantenna.xml	2020-04-29 08:07:05.279656	116	EXECUTED	7:010e839a366777cbbf0e3ad0aac260b1	dropPrimaryKey constraintName=sitelog_gnssgreceiver_pkey, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
renameTable sitelog_gnssgreceiver to sitelog_gnssreceiver -3	simon	db/rename-sitelog_gnssgantenna-table-to-sitelog_gnssantenna.xml	2020-04-29 08:07:05.289101	117	EXECUTED	7:86c2d2f53c81f86d6dcd5b0b5d9e1b45	addPrimaryKey constraintName=sitelog_gnssreceiver_pkey, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1465522320786-1	brookes (generated)	db/geodesy-add-sitelog_site_midoi.xml	2020-04-29 08:07:05.295735	118	EXECUTED	7:9f3e8d11cc1299d3efe75138289ac4dc	addColumn tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1466471561618-1	heya (custom)	db/remove-event-date-and-add-effective-dates.xml	2020-04-29 08:07:05.304934	119	EXECUTED	7:b9b466b606ada9a3a70139f15f43002d	dropColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1466471561618-2	heya (generated)	db/remove-event-date-and-add-effective-dates.xml	2020-04-29 08:07:05.310657	120	EXECUTED	7:7a39e7c9631382d4edb1e68d415ba11c	addColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1466471561618-3	heya (generated)	db/remove-event-date-and-add-effective-dates.xml	2020-04-29 08:07:05.317978	121	EXECUTED	7:e88f63953bec09ee4459c46ae343bc99	addColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1467790767-1	lbodor (custom)	db/add-equipment-configuration-fks.xml	2020-04-29 08:07:05.329488	122	EXECUTED	7:b22597da8e3bb04b9a3456d0d22a51b9	addForeignKeyConstraint baseTableName=gnss_receiver_configuration, constraintName=fk_equipmentconfiguration_equipment, referencedTableName=equipment; addForeignKeyConstraint baseTableName=gnss_antenna_configuration, constraintName=fk_equipmentconf...		\N	3.5.3	\N	\N	8147623451
rename equipment foreign keys	simon	db/geodesy-rename-equipment-fks.xml	2020-04-29 08:07:05.338264	123	EXECUTED	7:4e4b798984f4881008f917b73f2ca367	sql		\N	3.5.3	\N	\N	8147623451
drop generically named foreign keys	simon	db/geodesy-drop-generically-named-fks.xml	2020-04-29 08:07:05.36338	124	EXECUTED	7:f6098a0c34313a9cba3281ee6316e065	sql		\N	3.5.3	\N	\N	8147623451
1469510134849-1	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.368817	125	EXECUTED	7:98c25aebe6e16dd4cc1e9cb8f972c61e	addForeignKeyConstraint baseTableName=cors_site, constraintName=fk_cors_site_monument, referencedTableName=monument		\N	3.5.3	\N	\N	8147623451
1469510134849-2	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.374183	126	EXECUTED	7:e552f823e6c3b4ea4315a7abd7067cc6	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_responsible_party_contact, referencedTableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1469510134849-3	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.382191	127	EXECUTED	7:abfb804a456a4bd7318633e88af58cc3	addForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_responsible_party_custodian, referencedTableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1469510134849-4	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.389364	128	EXECUTED	7:bd2ce4e0a3e2e2151e160702255a6a79	addForeignKeyConstraint baseTableName=sitelog_collocationinformation, constraintName=fk_sitelog_site_sitelog_collocationinformation, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-5	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.396417	129	EXECUTED	7:cab35a37da7dfa174127efc560946a93	addForeignKeyConstraint baseTableName=sitelog_gnssantenna, constraintName=fk_sitelog_site_sitelog_gnss_antenna, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-6	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.402842	130	EXECUTED	7:835c1bfbd6583bf1a7d1947a99e04f5d	addForeignKeyConstraint baseTableName=sitelog_gnssreceiver, constraintName=fk_sitelog_site_sitelog_gnss_receiver, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-7	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.409245	131	EXECUTED	7:ae5e9385ccc2ae732be2085389c5378f	addForeignKeyConstraint baseTableName=sitelog_humiditysensor, constraintName=fk_sitelog_site_sitelog_humiditysensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-8	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.415281	132	EXECUTED	7:6ec8ee8c41b1d62149d7591a6934e97c	addForeignKeyConstraint baseTableName=sitelog_localepisodicevent, constraintName=fk_sitelog_site_sitelog_localepisodicevent, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-9	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.42255	133	EXECUTED	7:81766d9f8b3d9e4d1719ee710e97db31	addForeignKeyConstraint baseTableName=sitelog_mutlipathsource, constraintName=fk_sitelog_site_sitelog_mutlipathsource, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-10	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.429548	134	EXECUTED	7:518dce5da95ac8b16296ca161a4d4faa	addForeignKeyConstraint baseTableName=sitelog_otherinstrumentation, constraintName=fk_sitelog_site_sitelog_otherinstrumentation, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-11	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.436073	135	EXECUTED	7:6a79935ca90ba52c6f4b99e9784d946d	addForeignKeyConstraint baseTableName=sitelog_pressuresensor, constraintName=fk_sitelog_site_sitelog_pressuresensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-12	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.443558	136	EXECUTED	7:e8f5f21fdeee8f8a549ce9cbf2015ed8	addForeignKeyConstraint baseTableName=sitelog_radiointerference, constraintName=fk_sitelog_site_sitelog_radiointerference, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-13	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.449427	137	EXECUTED	7:7631467723b12d7b4c7b6c75646e88cb	addForeignKeyConstraint baseTableName=sitelog_signalobstraction, constraintName=fk_sitelog_site_sitelog_signalobstraction, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-14	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.457224	138	EXECUTED	7:85099192f85d2cd087b54df8b9eabaa0	addForeignKeyConstraint baseTableName=sitelog_surveyedlocaltie, constraintName=fk_sitelog_site_sitelog_surveyedlocaltie, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-15	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.464453	139	EXECUTED	7:6af060e5cfce7dba23108d2dd19e2dc5	addForeignKeyConstraint baseTableName=sitelog_temperaturesensor, constraintName=fk_sitelog_site_sitelog_temperaturesensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-16	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.472098	140	EXECUTED	7:df9c8a495661d89da59c8a20af412db5	addForeignKeyConstraint baseTableName=sitelog_watervaporsensor, constraintName=fk_sitelog_site_sitelog_watervaporsensor, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1469510134849-17	simon (generated)	db/geodesy-create-named-foreign-keys.xml	2020-04-29 08:07:05.478624	141	EXECUTED	7:37a6c2fe9d084fcd0233e1cd928a0610	addForeignKeyConstraint baseTableName=sitelog_frequencystandard, constraintName=fk_sitelog_site_sitelogfrequencystandard, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1472444888001-1	ted (generated)	db/add-site-log-nine-character-id-column.xml	2020-04-29 08:07:05.482944	142	EXECUTED	7:01cab3f46d7bdf69e55306889f2a9b9b	addColumn tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-1	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.487496	143	EXECUTED	7:92e7ca1c1cad84b10b9174280d2433ba	modifyDataType columnName=accurace_degree_celcius, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-2	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.492064	144	EXECUTED	7:f8c7a552888d14eb6fcc5a042818f022	modifyDataType columnName=accuracy_hpa, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1473286366418-3	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.49614	145	EXECUTED	7:23e42b3b1894b40ef6756787631d64c4	modifyDataType columnName=accuracy_percent_rel_humidity, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-4	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.500224	146	EXECUTED	7:9109609cf7a72198f098342df8e7f2fc	modifyDataType columnName=alignment_from_true_north, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-6	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.511499	148	EXECUTED	7:0ee8e4a912123120e72a00a7918387ac	modifyDataType columnName=antenna_cable_length, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-7	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.520067	149	EXECUTED	7:f76ff4ceebf0dd2d9ff56940b69aa9b0	modifyDataType columnName=antenna_cable_length, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-8	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.524367	150	EXECUTED	7:e04689cf3399422d3779bb4199802652	modifyDataType columnName=antenna_cable_type, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-9	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.528635	151	EXECUTED	7:29cd1aa58e698edbfe4cc658a7471cce	modifyDataType columnName=antenna_cable_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-10	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.532649	152	EXECUTED	7:f48db6f23384e1ad29f2238610abf626	modifyDataType columnName=antenna_radome_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-11	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.536537	153	EXECUTED	7:8829fe584a9c1d95d26a162e0638b7f6	modifyDataType columnName=antenna_reference_point, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-12	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.541389	154	EXECUTED	7:722d7e94f2ab7cb54abd6d1d4a6ee3fd	modifyDataType columnName=antenna_reference_point, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-13	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.547257	155	EXECUTED	7:bd55296b1a46cedd2a93c07a747d17df	modifyDataType columnName=antenna_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-14	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.5545	156	EXECUTED	7:3fe0af6fc724100b7a6aa07dcb3e5442	modifyDataType columnName=aspiration, tableName=humidity_sensor		\N	3.5.3	\N	\N	8147623451
1473286366418-15	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.558841	157	EXECUTED	7:b24005f9d425c38b065ae57d2a67f63c	modifyDataType columnName=aspiration, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-16	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.565247	158	EXECUTED	7:0f4b908e5f69d55e44cedf771efea850	modifyDataType columnName=aspiration, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-17	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.572131	159	EXECUTED	7:23621128b058da0233bf85508ad39967	modifyDataType columnName=bedrock_condition, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1473286366418-18	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.577861	160	EXECUTED	7:4ce4ce0d8a4b812bfabd4410f66404e6	modifyDataType columnName=bedrock_condition, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-19	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.5832	161	EXECUTED	7:99ae714f1659a3c3dff2e07bc88abd37	modifyDataType columnName=bedrock_type, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1473286366418-20	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.587858	162	EXECUTED	7:e2e8b81b57dc77e2e20aadb38292ff14	modifyDataType columnName=bedrock_type, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-21	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.593156	163	EXECUTED	7:ff7e5151aa2a8c8a476f7c86e295149f	modifyDataType columnName=cdp_number, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-22	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.597864	164	EXECUTED	7:53b69025d0f11dbb46d491c5caece569	modifyDataType columnName=city, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-23	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.60246	165	EXECUTED	7:d9af7f31f2d94048b16718165e8a839f	modifyDataType columnName=country, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-24	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.607398	166	EXECUTED	7:dc1ec015f2cfa4fe3a949a2f41415f91	modifyDataType columnName=data_sampling_interval, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-25	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.612105	167	EXECUTED	7:070b9d5fb1a398778788ac6b400f166b	modifyDataType columnName=data_sampling_interval, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1473286366418-26	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.618162	168	EXECUTED	7:298e337b32c10e77b0d3a85001b01f31	modifyDataType columnName=data_sampling_interval, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-27	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.623152	169	EXECUTED	7:e8f63fd58497d85bb3ecd7b625f84e39	modifyDataType columnName=description, tableName=monument		\N	3.5.3	\N	\N	8147623451
1473286366418-28	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.627348	170	EXECUTED	7:e1497cb4d6bfa2d0b035c197e02079a0	modifyDataType columnName=description, tableName=site		\N	3.5.3	\N	\N	8147623451
1473286366418-29	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.631886	171	EXECUTED	7:216acc7b35909bee195c81a80a48bc49	modifyDataType columnName=distance_activity, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-30	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.636266	172	EXECUTED	7:7a73fc3416f424291f030ae0b4fac557	modifyDataType columnName=domes_number, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1473286366418-31	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.640503	173	EXECUTED	7:d5248dc95c2e33beaa4339746cd4f335	modifyDataType columnName=elevation_cutoff_setting, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-32	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.644703	174	EXECUTED	7:6b0d7d9db71db8c0dd4a652c44de4372	modifyDataType columnName=elevation_cutoff_setting, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1473286366418-33	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.64884	175	EXECUTED	7:cbb7ab89935ad9a15e4e5966fec8aaaf	modifyDataType columnName=elevation_grs80, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-34	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.65317	176	EXECUTED	7:0cc29f1a4fba14e5c2371155d30e6283	modifyDataType columnName=equipment_type, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1473286366418-35	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.657471	177	EXECUTED	7:68c34141044533a8dd2948d89c564400	modifyDataType columnName=error, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1473286366418-36	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.662882	178	EXECUTED	7:3617291f868f28905a25f8f18fdb2287	modifyDataType columnName=event, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1473286366418-37	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.667104	179	EXECUTED	7:d1edaf0db57f584e9696a6d128cdf6e6	modifyDataType columnName=event_name, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1473286366418-38	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.671261	180	EXECUTED	7:366366d0edd58673d5babb138d1b3d9e	modifyDataType columnName=fault_zones_nearby, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-39	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.675516	181	EXECUTED	7:0ee4b04c9a6465c12860d67d6716cc53	modifyDataType columnName=firmware_version, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-40	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.679621	182	EXECUTED	7:0b695a192930dd286ac3037b50ec88fa	modifyDataType columnName=firmware_version, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1473286366418-41	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.68397	183	EXECUTED	7:9062e36e16308aee0a23aae9ffce202d	modifyDataType columnName=form_prepared_by, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-42	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.688371	184	EXECUTED	7:017becf0fdaaa71f17def0cfecc2d212	modifyDataType columnName=form_report_type, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-43	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.692456	185	EXECUTED	7:66a43f5e52c293f3989516b15ef7a83e	modifyDataType columnName=foundation, tableName=monument		\N	3.5.3	\N	\N	8147623451
1473286366418-44	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.696434	186	EXECUTED	7:76b5328ed3dd88766c11da6f63a7a659	modifyDataType columnName=foundation_depth, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-45	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.703651	187	EXECUTED	7:a6607551df3ac02de5897c3e876ef0e3	modifyDataType columnName=four_char_id, tableName=site_log_received		\N	3.5.3	\N	\N	8147623451
1473286366418-46	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.709013	188	EXECUTED	7:ccb26a0d59502a8d6d198701c4f4b7cb	modifyDataType columnName=fracture_spacing, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-47	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.716892	189	EXECUTED	7:3e517c92d51ee71ba530e2c2766fc9de	modifyDataType columnName=geologic_characteristic, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1473286366418-48	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.722387	190	EXECUTED	7:8e4e1078c3702c80fb1043d260d655db	modifyDataType columnName=geologic_characteristic, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-49	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.726518	191	EXECUTED	7:29e54ff57c679cc897d9d0ca9e99ab03	modifyDataType columnName=height, tableName=monument		\N	3.5.3	\N	\N	8147623451
1473286366418-50	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.731793	192	EXECUTED	7:8037ba98f5693f8fdc79d91c6f4cb865	modifyDataType columnName=height_diff_to_antenna, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-51	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.73781	193	EXECUTED	7:6e791b3cd7871e217050f02bf31a7218	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-52	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.742144	194	EXECUTED	7:21a5638407967bf6a9eb24da170bd968	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1473286366418-53	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.957596	195	EXECUTED	7:895acdee719ba5b57d475c41956e5452	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-54	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.964532	196	EXECUTED	7:ddd820a90cf1028efb07ebf47ed3a1ef	modifyDataType columnName=height_diff_to_antenna, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1473286366418-55	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.970241	197	EXECUTED	7:7cc433fc6ff054d793b0417b517c1eb4	modifyDataType columnName=height_of_monument, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-56	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.976116	198	EXECUTED	7:9f120764a7202cbe5152b67c1570644e	modifyDataType columnName=iers_domes_number, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-57	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:05.999017	199	EXECUTED	7:d35cb2617214ca1d791800e7c55783d5	modifyDataType columnName=input_frequency, tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-58	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.01122	200	EXECUTED	7:1fc617c598b542b6a5b67f924dc06208	modifyDataType columnName=input_frequency, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1473286366418-59	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.025626	201	EXECUTED	7:334c6d75a267553c4532e205393cdebd	modifyDataType columnName=instrument_type, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1473286366418-60	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.045846	202	EXECUTED	7:7763ed17364f1fa3b9ba3990a31a95ba	modifyDataType columnName=instrumentation, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1473286366418-61	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.061903	203	EXECUTED	7:55e23eece2b5e5736b8e758c3ff1481a	modifyDataType columnName=iso_19115, tableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1473286366418-62	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.069638	204	EXECUTED	7:6e1011722804bae6171e863da9bfe609	modifyDataType columnName=local_site_tie_accuracy, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1473286366418-63	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.079739	205	EXECUTED	7:a8975aef55b466014c9508f514917925	modifyDataType columnName=location_notes, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-64	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.08644	206	EXECUTED	7:e802aea1ba8fe3c8d4f10dc8daa7e294	modifyDataType columnName=manufacturer, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1473286366418-65	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.091481	207	EXECUTED	7:3372f798afb6d96a0f40e41587f87089	modifyDataType columnName=manufacturer, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-66	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.096397	208	EXECUTED	7:7e4c8bf7e183672b355685e0cf9b3a6c	modifyDataType columnName=manufacturer, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1473286366418-67	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.105127	209	EXECUTED	7:b7f24d991355a06e9fa8ee7804c9319a	modifyDataType columnName=manufacturer, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-68	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.123077	210	EXECUTED	7:cff446e9690dd0e8051ef2f96a1c0be0	modifyDataType columnName=manufacturer, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1473286366418-69	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.128604	211	EXECUTED	7:12c917be0918e11d8d813fcb199d54ea	modifyDataType columnName=marker_description, tableName=monument		\N	3.5.3	\N	\N	8147623451
1473286366418-70	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.134618	212	EXECUTED	7:096b417860141f21b2064148a3a9fac9	modifyDataType columnName=marker_description, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-71	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.211685	213	EXECUTED	7:d22d0fa30faeec447454137ca0af651e	modifyDataType columnName=mi_antenna_graphics, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-72	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.217754	214	EXECUTED	7:3655eb55154264abe582266519c32ea9	modifyDataType columnName=mi_doi, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-73	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.222867	215	EXECUTED	7:f095ddec827b6b94b25351aa0187907a	modifyDataType columnName=mi_hard_copy_on_file, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-74	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.228009	216	EXECUTED	7:da41585880c2eb3812b532cd62a26a18	modifyDataType columnName=mi_horizontal_mask, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-75	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.234799	217	EXECUTED	7:1ce2f22e9e5c5502c87fa954cfe51036	modifyDataType columnName=mi_monument_description, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-76	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.250879	218	EXECUTED	7:7729c50b2c47e1b4bf7af3723740c559	modifyDataType columnName=mi_notes, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-77	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.261775	219	EXECUTED	7:ab4b566fe292bcd4b99f83107e27fc4e	modifyDataType columnName=mi_primary_data_center, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-78	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.267801	220	EXECUTED	7:3db03922bd8dafa3c3bf841870f681bf	modifyDataType columnName=mi_secondary_data_center, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-79	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.273188	221	EXECUTED	7:55572fc1ce09796d559822a1ab16d6c0	modifyDataType columnName=mi_site_diagram, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-80	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.278984	222	EXECUTED	7:8e9795b80058bfb76e46f708705e5e0a	modifyDataType columnName=mi_site_map, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-81	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.284813	223	EXECUTED	7:ccb89e0c4b803e16cf34d2da369095f5	modifyDataType columnName=mi_site_pictires, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-82	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.289663	224	EXECUTED	7:4194be60af747139aae14111f4aa1f39	modifyDataType columnName=mi_text_graphics_from_antenna, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-83	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.295091	225	EXECUTED	7:89b6d58bdf95df7432fea8239057d934	modifyDataType columnName=mi_url_for_more_information, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-84	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.300347	226	EXECUTED	7:019db638e2576d29eb13affd82ead7e2	modifyDataType columnName=monument_description, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-85	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.306053	227	EXECUTED	7:3d7824c6c297f595b40f92ef75021bc9	modifyDataType columnName=monument_foundation, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-86	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.310551	228	EXECUTED	7:e35c2e4f12a4d5d0c1885c203e1e298c	modifyDataType columnName=monument_inscription, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-87	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.317704	229	EXECUTED	7:c5b8c87dcfb47453948653c8c9eaeb8c	modifyDataType columnName=name, tableName=setup		\N	3.5.3	\N	\N	8147623451
1473286366418-88	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.322078	230	EXECUTED	7:af89c081a1467ae46f72e673e72688d4	modifyDataType columnName=name, tableName=site		\N	3.5.3	\N	\N	8147623451
1473286366418-89	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.537632	231	EXECUTED	7:b67245dec0ebdcb71cbae939fc82d30d	modifyDataType columnName=notes, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-90	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.543213	232	EXECUTED	7:90cab3c99f1e121c11c00259692cfdb6	modifyDataType columnName=notes, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-91	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.548319	233	EXECUTED	7:4195bb205ccd1eca27835b6a7cc9db50	modifyDataType columnName=notes, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-92	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.556176	234	EXECUTED	7:ce55160fd597f291ff0201ba3e172a55	modifyDataType columnName=notes, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1473286366418-93	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.561054	235	EXECUTED	7:cf0f6e6d91d175181580accdc13057d7	modifyDataType columnName=notes, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1473286366418-94	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.568726	236	EXECUTED	7:67c4108c0b3c3bb9291502b21f4c7888	modifyDataType columnName=notes, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-95	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.584524	237	EXECUTED	7:c5066ef89dcc9af66cef2a2a4de09320	modifyDataType columnName=notes, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1473286366418-96	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.595896	238	EXECUTED	7:7b9a74b0c3fff234ab3dde3c58db115e	modifyDataType columnName=notes, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-97	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.601066	239	EXECUTED	7:315aee88eaaed0279baf1ad6892e9b59	modifyDataType columnName=notes, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1473286366418-98	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.617122	240	EXECUTED	7:3606dada87e6935eb8050014b1031678	modifyDataType columnName=notes, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-99	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.623215	241	EXECUTED	7:312ce26aeb9d49ce7537221a17b0fe33	modifyDataType columnName=notes, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1473286366418-100	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.639109	242	EXECUTED	7:21039fe683b8e98764e3f4da62fdba5e	modifyDataType columnName=notes, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-101	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.648738	243	EXECUTED	7:d01ff68675329c55d7fc3141bddd135b	modifyDataType columnName=notes, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1473286366418-102	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.655782	244	EXECUTED	7:12a07dcbbf2638d0a187bd22a06ca87a	modifyDataType columnName=observed_degradation, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1473286366418-103	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.659989	245	EXECUTED	7:92eb2759078652b366180895e607c360	modifyDataType columnName=radome_serial_number, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-104	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.676172	246	EXECUTED	7:5910fdaabacaa896b61f732e68bdd2be	modifyDataType columnName=radome_serial_number, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-105	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.687004	247	EXECUTED	7:a5a2973a91f54b3dba12c6d6eef45c4c	modifyDataType columnName=radome_type, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-106	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.841765	248	EXECUTED	7:893957b059ec2f9429660932f49e431a	modifyDataType columnName=receiver_type, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1473286366418-107	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.84728	249	EXECUTED	7:c56310dbd8b5bad3689fc52e45a24a5f	modifyDataType columnName=satellite_system, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-108	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.851841	250	EXECUTED	7:5cf90c470db95c609a29f599658e155b	modifyDataType columnName=satellite_system, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1473286366418-109	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.856056	251	EXECUTED	7:542ff5084fe6ac56df07b94590841f88	modifyDataType columnName=serial_number, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1473286366418-110	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.86251	252	EXECUTED	7:6ac8a8ac1595b43bf2ec47e1253af51e	modifyDataType columnName=serial_number, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1473286366418-111	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.868981	253	EXECUTED	7:73d01d74b43146823be52d6ee160e14b	modifyDataType columnName=serial_number, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1473286366418-112	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.873292	254	EXECUTED	7:55df725e9829b7edcd2abf1e3a76ad4e	modifyDataType columnName=serial_number, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-113	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.877584	255	EXECUTED	7:5abaa3966d94f27f702c58c7c8d6a100	modifyDataType columnName=serial_number, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1473286366418-114	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.890166	256	EXECUTED	7:21be4a8dd9d19a4ffbb3b2fedaa32898	modifyDataType columnName=serial_number, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-115	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.895161	257	EXECUTED	7:0aa47cc9a70a7c0f590ed53797ec5a4c	modifyDataType columnName=serial_number, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1473286366418-116	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.912598	258	EXECUTED	7:4ed51303a22da91d839f2573856ebd61	modifyDataType columnName=sinex_file_name, tableName=weekly_solution		\N	3.5.3	\N	\N	8147623451
1473286366418-117	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.917356	259	EXECUTED	7:379ad151180be24488c773a5b869526b	modifyDataType columnName=site_log_text, tableName=invalid_site_log_received		\N	3.5.3	\N	\N	8147623451
1473286366418-118	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.922186	260	EXECUTED	7:9c0d84f42aad093c88731106461d01ed	modifyDataType columnName=site_log_text, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-119	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.935021	261	EXECUTED	7:204256a2569caaedd9b5e8e670453fcd	modifyDataType columnName=site_name, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-120	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.939889	262	EXECUTED	7:d51770cff75d5adaa5cb7af36f1cb9a4	modifyDataType columnName=state, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-121	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.953203	263	EXECUTED	7:9bd75b36ebf4a304fac92156bd81adf6	modifyDataType columnName=status, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1473286366418-122	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.968198	264	EXECUTED	7:d46164f310eaeb26888edd313b6a92b5	modifyDataType columnName=subscriber, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1473286366418-123	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:06.973248	265	EXECUTED	7:79ee84d20c5841bddfb3ce5e6ab3de98	modifyDataType columnName=survey_method, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1473286366418-124	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.140823	266	EXECUTED	7:b84a1bb8242840b3433996dbcdda0926	modifyDataType columnName=tectonic_plate, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1473286366418-125	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.146874	267	EXECUTED	7:5cdeffb3022d8291c76cfca0082d733a	modifyDataType columnName=temperature_stabilization, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1473286366418-126	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.152365	268	EXECUTED	7:e84ae239c25ddfc72e44fedd2077cddb	modifyDataType columnName=temperature_stabilization, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1473286366418-127	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.157651	269	EXECUTED	7:483d2c2397da2fff882b5712b2bfe98c	modifyDataType columnName=tied_marker_cdp_number, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1473286366418-128	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.165928	270	EXECUTED	7:da6fe2c8a3585f972aae5f3a6d7ece7a	modifyDataType columnName=tied_marker_domes_number, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1473286366418-129	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.175349	271	EXECUTED	7:ee62d453d2623d7c6892aa72978ce8d3	modifyDataType columnName=tied_marker_name, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1473286366418-130	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.184326	272	EXECUTED	7:1624669cac317d1a526c37904743d22b	modifyDataType columnName=tied_marker_usage, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1473286366418-131	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.198907	273	EXECUTED	7:15ca6ad873b575b1bad013a2c88f9ff7	modifyDataType columnName=type, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1473286366418-132	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.211326	274	EXECUTED	7:5a5e5579045004fdd3a9e49d605699d2	modifyDataType columnName=type, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1473286366418-133	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.22118	275	EXECUTED	7:9b5b3e6603d5c247b017404c39620be9	modifyDataType columnName=type, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1473286366418-134	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.232441	276	EXECUTED	7:ae2bc29d5a2238cbe2612c1b3c14e328	modifyDataType columnName=type, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1473286366418-135	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.242841	277	EXECUTED	7:026fcde64700a65734370102a46086e4	modifyDataType columnName=type, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1473286366418-136	lbodor (generated)	db/use-text-data-type.xml	2020-04-29 08:07:07.251923	278	EXECUTED	7:3f1d51b9ade48b4b58ccb828a0a6e671	modifyDataType columnName=type, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1473637019131-1	hong (generated)	db/add_missing_fk.xml	2020-04-29 08:07:07.27233	279	EXECUTED	7:ef9a9ccf38c87d85475c7b7ae8f7d416	addForeignKeyConstraint baseTableName=equipment_in_use, constraintName=fk_equipment_in_use_equipmentid, referencedTableName=equipment		\N	3.5.3	\N	\N	8147623451
1473637019131-2	hong (generated)	db/add_missing_fk.xml	2020-04-29 08:07:07.284341	280	EXECUTED	7:8ab18b53c9fe136bd7cb495cbc1584d5	addForeignKeyConstraint baseTableName=setup, constraintName=fk_setup_siteid, referencedTableName=site		\N	3.5.3	\N	\N	8147623451
1473998705916-1	asedgmen (generated)	db/prepare-view-for-site-wfs.xml	2020-04-29 08:07:07.347991	281	EXECUTED	7:2a66b32757b8c3dd877d3a6bd370af7e	addColumn tableName=site		\N	3.5.3	\N	\N	8147623451
1473998705916-2	asedgmen (generated)	db/prepare-view-for-site-wfs.xml	2020-04-29 08:07:07.356659	282	EXECUTED	7:a4d3132975624d5752d9d521f2279881	createView viewName=v_cors_site		\N	3.5.3	\N	\N	8147623451
1474431967	asedgment	db/add-comment-to-cors-site-view.sql	2020-04-29 08:07:07.362003	283	EXECUTED	7:e7173f7586756a383e80a078693ee637	sql		\N	3.5.3	\N	\N	8147623451
1474419465891-1	hong (generated)	db/create_equipment_configuration_table.xml	2020-04-29 08:07:07.367759	284	EXECUTED	7:6c7ab0aad5834ee4471e38f52cf801b8	createTable tableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1474419465891-2	hong (generated)	db/create_equipment_configuration_table.xml	2020-04-29 08:07:07.37487	285	EXECUTED	7:0f2259effae1616adb83dd6c602ada58	addPrimaryKey constraintName=equjipment_configuration_pkey, tableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1474424364	HongJin	db/add_records_to_equipment_configuration.sql	2020-04-29 08:07:07.381779	286	EXECUTED	7:27c581adb9942c587999c863c3fcd7d2	sql		\N	3.5.3	\N	\N	8147623451
1474431280707-1	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.386974	287	EXECUTED	7:89d348ea863b0c5583073e357c00e8b5	addForeignKeyConstraint baseTableName=clock_configuration, constraintName=fk_clock_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1474431280707-2	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.392355	288	EXECUTED	7:faaea3e30aeb67869ed51c570974327f	addForeignKeyConstraint baseTableName=equipment_configuration, constraintName=fk_equipment_configuration_equipment_id, referencedTableName=equipment		\N	3.5.3	\N	\N	8147623451
1474431280707-3	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.39771	289	EXECUTED	7:44d9184533a0d986254d61f014043b4d	addForeignKeyConstraint baseTableName=equipment_in_use, constraintName=fk_equipment_in_use_equipment_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1474431280707-4	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.402979	290	EXECUTED	7:86fa637e9ef717bd9b068587f44c2d8d	addForeignKeyConstraint baseTableName=gnss_antenna_configuration, constraintName=fk_gnss_antenna_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1474431280707-5	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.410627	291	EXECUTED	7:90f9b05c0dc59e82c4fcc00843d45ec3	addForeignKeyConstraint baseTableName=gnss_receiver_configuration, constraintName=fk_gnss_receiver_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1474431280707-6	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.416107	292	EXECUTED	7:db3e198044b01a9224ded75b9ceba35f	addForeignKeyConstraint baseTableName=humidity_sensor_configuration, constraintName=fk_humidity_sensor_configuration_id, referencedTableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1474431280707-7	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.42109	293	EXECUTED	7:2619a097fd843d65f10b4bfd7c3e900f	dropForeignKeyConstraint baseTableName=clock_configuration, constraintName=fk_clock_configuration_equipment		\N	3.5.3	\N	\N	8147623451
1474431280707-8	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.425638	294	EXECUTED	7:575f24993c1f38adf20b713755da4212	dropForeignKeyConstraint baseTableName=gnss_antenna_configuration, constraintName=fk_gnss_antenna_configuration_equipment		\N	3.5.3	\N	\N	8147623451
1474431280707-9	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.430048	295	EXECUTED	7:bc76711ccaffad526b7f01cbb29fe575	dropForeignKeyConstraint baseTableName=gnss_receiver_configuration, constraintName=fk_gnss_receiver_configuration_equipment		\N	3.5.3	\N	\N	8147623451
1474431280707-10	hong (generated)	db/redo_fk_link.xml	2020-04-29 08:07:07.434324	296	EXECUTED	7:00c3a739e50e105ad72e5262b37a2158	dropForeignKeyConstraint baseTableName=humidity_sensor_configuration, constraintName=fk_humidity_sensor_configuration_equipment		\N	3.5.3	\N	\N	8147623451
1474524159272-1	hong (generated)	db/drop_configuration_time_columns.xml	2020-04-29 08:07:07.438593	297	EXECUTED	7:f0c7a58af1d6ab11182b6f1baec70586	dropColumn columnName=configuration_time, tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1474524159272-2	hong (generated)	db/drop_configuration_time_columns.xml	2020-04-29 08:07:07.44297	298	EXECUTED	7:f4f839a2b6c4429f31dfb2912e48d342	dropColumn columnName=configuration_time, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1474524159272-3	hong (generated)	db/drop_configuration_time_columns.xml	2020-04-29 08:07:07.447146	299	EXECUTED	7:1ff98d87494bce1acb6adcd58ce2c5e9	dropColumn columnName=configuration_time, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1474524159272-4	hong (generated)	db/drop_configuration_time_columns.xml	2020-04-29 08:07:07.451584	300	EXECUTED	7:e31504f32f8b8fed9b7e5e314f84e97a	dropColumn columnName=configuration_time, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1474595198431-1	hong (generated)	db/drop_equipment_id.xml	2020-04-29 08:07:07.599695	301	EXECUTED	7:be194533910984b77021d443f6081923	dropColumn columnName=equipment_id, tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1474595198431-2	hong (generated)	db/drop_equipment_id.xml	2020-04-29 08:07:07.604686	302	EXECUTED	7:768b1692673544f655772cc28346af75	dropColumn columnName=equipment_id, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1474595198431-3	hong (generated)	db/drop_equipment_id.xml	2020-04-29 08:07:07.608924	303	EXECUTED	7:355583a97dc88106dd82a0341a0c1db6	dropColumn columnName=equipment_id, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1474595198431-4	hong (generated)	db/drop_equipment_id.xml	2020-04-29 08:07:07.613174	304	EXECUTED	7:75198f98d6b607c0a59b3322b17ae179	dropColumn columnName=equipment_id, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1475206562	HongJin	db/rename_all_constraints.sql	2020-04-29 08:07:07.678286	305	EXECUTED	7:abc7b96e0e506b08b33ee5ef61ce705e	sql		\N	3.5.3	\N	\N	8147623451
1475639382613-1	hong (generated)	db/create-temp-tab-for-9-digit-character.xml	2020-04-29 08:07:07.686294	306	EXECUTED	7:5abc7e428171f6251290b715646b50c4	createTable tableName=temp_9_character_data		\N	3.5.3	\N	\N	8147623451
1476162775	HongJin	db/add-9-character-id-to-cors-site.sql	2020-04-29 08:07:08.292111	307	EXECUTED	7:1663481dd8fa405a27807dcc1a92aff2	sql		\N	3.5.3	\N	\N	8147623451
1485225822117-25	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.18982	683	EXECUTED	7:afe4d60fb4c8abdde58799f03f72134f	addColumn tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1476314353412-1	hong (generated)	db/create-temp-tab-for-site-status-updating.xml	2020-04-29 08:07:08.300069	308	EXECUTED	7:f38e17eb271fd4c8574dc52b93ac2456	createTable tableName=temp_site_network		\N	3.5.3	\N	\N	8147623451
1476314353412-2	hong (generated)	db/create-temp-tab-for-site-status-updating.xml	2020-04-29 08:07:08.307567	309	EXECUTED	7:d9994e4b7721086960209351b27606e9	addPrimaryKey constraintName=temp_site_network_pkey, tableName=temp_site_network		\N	3.5.3	\N	\N	8147623451
1476314284	HongJin	db/update-site-status.sql	2020-04-29 08:07:09.439614	310	EXECUTED	7:f570c5f2d0243479ef6c2d9ab641ddf6	sql		\N	3.5.3	\N	\N	8147623451
1476851963015-1	hong (generated)	db/add-site-network.xml	2020-04-29 08:07:09.452317	311	EXECUTED	7:34234d20f60ad8f78cd263e42cda449e	createTable tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1476851963015-2	hong (generated)	db/add-site-network.xml	2020-04-29 08:07:09.461218	312	EXECUTED	7:cd24dd7e48638b9d3ff8572a02b1c614	createTable tableName=cors_site_network_relation		\N	3.5.3	\N	\N	8147623451
1476851963015-3	hong (generated)	db/add-site-network.xml	2020-04-29 08:07:09.471154	313	EXECUTED	7:10968f4a0390fa75c5cde342ac550e4a	addPrimaryKey constraintName=pk_cors_site_network_relation_id, tableName=cors_site_network_relation		\N	3.5.3	\N	\N	8147623451
1476851963015-4	hong (generated)	db/add-site-network.xml	2020-04-29 08:07:09.480321	314	EXECUTED	7:7bcee42f0c1850f4281786d1b689c8ec	addPrimaryKey constraintName=pk_cors_site_networkid, tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1476851963015-5	hong (generated)	db/add-site-network.xml	2020-04-29 08:07:09.488649	315	EXECUTED	7:11261a0769e2265ac32a6b09cfdcb00d	addForeignKeyConstraint baseTableName=cors_site_network_relation, constraintName=fk_cors_site_network_relation_networkid, referencedTableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1476851963015-6	hong (generated)	db/add-site-network.xml	2020-04-29 08:07:09.498905	316	EXECUTED	7:afad96950627d89f1b1f24eb19a89953	addForeignKeyConstraint baseTableName=cors_site_network_relation, constraintName=fk_cors_site_network_relation_siteid, referencedTableName=cors_site		\N	3.5.3	\N	\N	8147623451
1476923463	HongJin	db/recreate-site-network-table.sql	2020-04-29 08:07:09.530134	317	EXECUTED	7:7a2986f49da3687b6485f10ad1dc0d3b	sql		\N	3.5.3	\N	\N	8147623451
1477355459	hongjin	db/add-records-to-site-network.xml	2020-04-29 08:07:09.537457	318	EXECUTED	7:294053b690b9c04887bfba7ea3540479	createProcedure		\N	3.5.3	\N	\N	8147623451
1477355830	hongjin	db/add-records-to-site-network.xml	2020-04-29 08:07:09.556045	319	EXECUTED	7:add0e41eece52c50727bc38ae14c441f	createProcedure		\N	3.5.3	\N	\N	8147623451
1477364071	HongJin	db/call-function-to-add-records-to-site-in-network.sql	2020-04-29 08:07:09.573955	320	EXECUTED	7:4cf0495cb6a006916683ae640b5df9b2	sql		\N	3.5.3	\N	\N	8147623451
1477527412	HongJin	db/add-missing-9-character.sql	2020-04-29 08:07:10.178517	321	EXECUTED	7:30ae826facdb006178584bf561500b5c	sql		\N	3.5.3	\N	\N	8147623451
1477623351128-1	hong (generated)	db/drop-temp-tables.xml	2020-04-29 08:07:10.184826	322	EXECUTED	7:8152bc20fa6f180e1fb73f69a8fa5310	dropTable tableName=temp_9_character_data		\N	3.5.3	\N	\N	8147623451
1477623351128-2	hong (generated)	db/drop-temp-tables.xml	2020-04-29 08:07:10.1916	323	EXECUTED	7:f4714d4137afa18dbfc011595c6e91e0	dropTable tableName=temp_site_network		\N	3.5.3	\N	\N	8147623451
1478057658650-1	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.200614	324	EXECUTED	7:9ea2605e38c351c3f5c767d8883acbb2	createTable tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1478057658650-2	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.208555	325	EXECUTED	7:870bd3d11339c3733a0bafe940228cce	createTable tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	8147623451
1478057658650-3	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.215323	326	EXECUTED	7:d2645f6e73949842c498a0a5e166f8a6	addPrimaryKey constraintName=pk_sitelog_responsible_party_id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1478057658650-4	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.225556	327	EXECUTED	7:14b1c2c08501df5134cfc67c8535b294	addPrimaryKey constraintName=pk_sitelog_responsible_party_role_id, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	8147623451
1478057658650-5	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.231229	328	EXECUTED	7:788dce1ba968eddacf480c64426788a5	addForeignKeyConstraint baseTableName=sitelog_responsible_party, constraintName=fk_sitelog_responsible_party_responsiblerole, referencedTableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	8147623451
1478057658650-6	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.237154	329	EXECUTED	7:ac347936b316c1cdb5121bfb36c95b60	addForeignKeyConstraint baseTableName=sitelog_responsible_party, constraintName=fk_sitelog_responsible_party_siteid, referencedTableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1478057658650-7	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.242602	330	EXECUTED	7:7776a172d57528ec1be76b6478f0f8a2	dropForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_site_contactid		\N	3.5.3	\N	\N	8147623451
1478057658650-8	hong (generated)	db/creante-new-responsible-party-tables.xml	2020-04-29 08:07:10.24813	331	EXECUTED	7:d006da88c37134f39dd92d0b6f678899	dropForeignKeyConstraint baseTableName=sitelog_site, constraintName=fk_sitelog_site_site_metadata_custodianid		\N	3.5.3	\N	\N	8147623451
1478058091	HongJin	db/migrate-site-responsible-party-data-to-new-table.sql	2020-04-29 08:07:10.261158	332	EXECUTED	7:b369f32e0400780c9ead61bed64a6726	sql		\N	3.5.3	\N	\N	8147623451
1478060335489-1	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.267344	333	EXECUTED	7:e54f5406e0963b70dead24dc47aa0037	setTableRemarks tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1478060335489-2	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.273374	334	EXECUTED	7:82e2bc89e51283b80cd066e2306e23a7	setTableRemarks tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	8147623451
1478060335489-3	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.279806	335	EXECUTED	7:69590dce648a42c70ddc3573e97b31c5	setColumnRemarks columnName=id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1478060335489-4	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.286026	336	EXECUTED	7:e3c0c354cab77fbfc964930ab080c570	setColumnRemarks columnName=id, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	8147623451
1478060335489-5	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.29237	337	EXECUTED	7:db9779ff8a8d8b41ba33d66227336193	setColumnRemarks columnName=responsible_party, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1478060335489-6	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.298009	338	EXECUTED	7:a69fe92c55ec19683055ca65539e44f5	setColumnRemarks columnName=responsible_role, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1483935176618-87	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.649593	433	EXECUTED	7:752992689554c3a386025bdc56f516b8	setColumnRemarks columnName=id, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1478060335489-7	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.30361	339	EXECUTED	7:266deafcfff442e98f4a05d851599636	setColumnRemarks columnName=responsible_role_name, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	8147623451
1478060335489-8	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.309494	340	EXECUTED	7:4b3ed381fc1170086ad5db3fb35f786e	setColumnRemarks columnName=responsible_role_xmltag, tableName=sitelog_responsible_party_role		\N	3.5.3	\N	\N	8147623451
1478060335489-9	hong (generated)	db/add-comments-to-new-responsible-party-tables.xml	2020-04-29 08:07:10.314895	341	EXECUTED	7:b5c4b782426c52ad1c3cdc39acb3b5be	setColumnRemarks columnName=site_id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1478571328	HongJin	db/rename-responsible-party-column-name.sql	2020-04-29 08:07:10.321559	342	EXECUTED	7:92e3581d0f6464ae5f435e7402b5e50b	sql		\N	3.5.3	\N	\N	8147623451
1479093882	lbodor	db/drop-non-null-constraint.xml	2020-04-29 08:07:10.327527	343	EXECUTED	7:78da8e8451a1c34d46e074abbb6357b4	dropNotNullConstraint columnName=site_id, tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1482119825334-1	hong (generated)	db/drop-old-responsible-party-table.xml	2020-04-29 08:07:10.334272	344	EXECUTED	7:19390ff62c90dd5e09654b7e661c4649	dropTable tableName=responsible_party		\N	3.5.3	\N	\N	8147623451
1482119825334-2	hong (generated)	db/drop-old-responsible-party-table.xml	2020-04-29 08:07:10.34012	345	EXECUTED	7:648b479d6fb7a40819c261ef41d6e230	dropColumn columnName=site_contact_id, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1482119825334-3	hong (generated)	db/drop-old-responsible-party-table.xml	2020-04-29 08:07:10.346124	346	EXECUTED	7:cd5aba67a3f2a6915ba4c1740b6ff3fa	dropColumn columnName=site_metadata_custodian_id, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-1	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.351759	347	EXECUTED	7:dcf76148cbf3179b950347a16931c79c	setTableRemarks tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-2	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.357418	348	EXECUTED	7:6fb6c1575e0afca3a1bed86fb1a9dc0d	setTableRemarks tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1483935176618-3	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.362895	349	EXECUTED	7:d9b399eb016ab54f3e9b1eb9b2c8bd6c	setTableRemarks tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-4	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.369022	350	EXECUTED	7:60adca50f46a717defe48b1b773ff694	setTableRemarks tableName=equipment		\N	3.5.3	\N	\N	8147623451
1483935176618-5	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.374203	351	EXECUTED	7:38ccdd11a5b07bc00428255499c8ea76	setTableRemarks tableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-6	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.380731	352	EXECUTED	7:e666ee2a52dcb3544b18910062294f95	setTableRemarks tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-7	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.387055	353	EXECUTED	7:bb15b8450c974219b86a7371d7702b1d	setTableRemarks tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-8	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.393141	354	EXECUTED	7:891f7f135008a0a67bd697dff117b8c2	setTableRemarks tableName=humidity_sensor		\N	3.5.3	\N	\N	8147623451
1483935176618-9	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.399288	355	EXECUTED	7:48fe1c7e136a33f04f803286da03e7a9	setTableRemarks tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-10	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.405573	356	EXECUTED	7:e124ba22ff8c489ef9cd139523c33376	setTableRemarks tableName=monument		\N	3.5.3	\N	\N	8147623451
1483935176618-11	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.411187	357	EXECUTED	7:d6bc07113a0af6513fdfa47c39cfc705	setTableRemarks tableName=setup		\N	3.5.3	\N	\N	8147623451
1483935176618-12	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.417607	358	EXECUTED	7:99a4bc3282932022eb39cf396a053bc6	setTableRemarks tableName=site		\N	3.5.3	\N	\N	8147623451
1483935176618-13	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.422982	359	EXECUTED	7:e12040e3e4b79f4f71b1fdda780d1264	setTableRemarks tableName=site_log_received		\N	3.5.3	\N	\N	8147623451
1483935176618-14	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.428456	360	EXECUTED	7:bc1868bc7df869ae5f3263faa87a31c1	setTableRemarks tableName=site_updated		\N	3.5.3	\N	\N	8147623451
1483935176618-15	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.434636	361	EXECUTED	7:1bb567a8966c1dd4694779cd8552fcf6	setTableRemarks tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-16	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.44063	362	EXECUTED	7:597634145242cf0540c1a08c6eff061a	setTableRemarks tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-17	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.447193	363	EXECUTED	7:a445a3f2339fd59a15a6b200b0c6b820	setTableRemarks tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-18	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.453508	364	EXECUTED	7:bb2186f978df6195f29e8bddcb1ce148	setTableRemarks tableName=weekly_solution_available		\N	3.5.3	\N	\N	8147623451
1483935176618-19	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.458769	365	EXECUTED	7:eefe9694e8181f4a8ab2d4de72101964	setColumnRemarks columnName=accuracy_percent_rel_humidity, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-20	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.465039	366	EXECUTED	7:59254a8c00aaf81a27c85d00eb51a714	setColumnRemarks columnName=alignment_from_true_north, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-21	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.471142	367	EXECUTED	7:9963326468ada0c59da77bd2a56072ec	setColumnRemarks columnName=antenna_cable_length, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-22	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.476728	368	EXECUTED	7:04a789a477a77cb70f7e263555604715	setColumnRemarks columnName=antenna_cable_type, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-23	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.48276	369	EXECUTED	7:6700999e1cbb19bfa780cfc782dcf38e	setColumnRemarks columnName=antenna_reference_point, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-24	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.488391	370	EXECUTED	7:85d0b9a584e07f84b75092e6eb7df43a	setColumnRemarks columnName=aspiration, tableName=humidity_sensor		\N	3.5.3	\N	\N	8147623451
1483935176618-88	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.662645	434	EXECUTED	7:a347f8520f8f7993c956d8fd7be36005	setColumnRemarks columnName=id, tableName=weekly_solution_available		\N	3.5.3	\N	\N	8147623451
1483935176618-25	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.494282	371	EXECUTED	7:ede734f2858639974cec23a7b3054167	setColumnRemarks columnName=aspiration, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-26	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.499756	372	EXECUTED	7:07831c76dd9b06c9ced76d43fbd62636	setColumnRemarks columnName=bedrock_condition, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-27	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.505645	373	EXECUTED	7:4934e373a765ee2d604f00c31336e231	setColumnRemarks columnName=bedrock_type, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1483935176618-28	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.510939	374	EXECUTED	7:ec9162666e8e3973910dc42973b60535	setColumnRemarks columnName=bedrock_type, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-29	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.516832	375	EXECUTED	7:cde0a16a48e23366d1233d39c3afa2bb	setColumnRemarks columnName=callibration_date, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-30	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.522371	376	EXECUTED	7:a54f6c8f666721860d58eea1fc5b018f	setColumnRemarks columnName=cdp_number, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-31	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.528411	377	EXECUTED	7:7941a0cb6c633d06b5507ef800dccbf8	setColumnRemarks columnName=city, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-32	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.53465	378	EXECUTED	7:4744f8d4c2de67a6e2011dc8f37a0878	setColumnRemarks columnName=configuration_time, tableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-33	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.541361	379	EXECUTED	7:64c41b97afa4cb42e1dea2120cebdeae	setColumnRemarks columnName=data_sampling_interval, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-34	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.547634	380	EXECUTED	7:fa17ac0e80dc6f132a041f218bdc9c1e	setColumnRemarks columnName=date_installed, tableName=site		\N	3.5.3	\N	\N	8147623451
1483935176618-35	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.555381	381	EXECUTED	7:6c80232c8f9396b9df07b06820344905	setColumnRemarks columnName=date_installed, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-36	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.561118	382	EXECUTED	7:1b3df8772b7840dcad966be1f9b9c2c7	setColumnRemarks columnName=description, tableName=monument		\N	3.5.3	\N	\N	8147623451
1483935176618-37	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.567558	383	EXECUTED	7:a127f65a6dbd4dc2e17eaa1549eec399	setColumnRemarks columnName=description, tableName=site		\N	3.5.3	\N	\N	8147623451
1483935176618-38	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.573279	384	EXECUTED	7:412e273e05a8178a9fe4ca7ea524037f	setColumnRemarks columnName=distance_activity, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-39	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.58057	385	EXECUTED	7:745f35d2111cfe5980f4fe83c833bf9a	setColumnRemarks columnName=domes_number, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1483935176618-40	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.585306	386	EXECUTED	7:379032042baabc4ca4a3bc8bd382f152	setColumnRemarks columnName=effective_from, tableName=setup		\N	3.5.3	\N	\N	8147623451
1483935176618-41	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.590366	387	EXECUTED	7:0488da365a43345f8cbf37314c6f982d	setColumnRemarks columnName=effective_from, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-42	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.595912	388	EXECUTED	7:74bbacf1eb95d5986360730ef94d43b2	setColumnRemarks columnName=effective_from, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-43	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.601523	389	EXECUTED	7:997787759bf88061986397c907a25dc8	setColumnRemarks columnName=effective_to, tableName=setup		\N	3.5.3	\N	\N	8147623451
1483935176618-44	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.607322	390	EXECUTED	7:45df4e412e35c242617ac1f59b1dbb59	setColumnRemarks columnName=effective_to, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-45	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.613481	391	EXECUTED	7:72ddb958a1cfc944b87afeb6185d3eed	setColumnRemarks columnName=effective_to, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-46	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.620492	392	EXECUTED	7:14c7a84e5ebd9f85843da17b8e6bf333	setColumnRemarks columnName=elevation_cutoff_setting, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-47	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.626442	393	EXECUTED	7:54091b88450d1d3069d3f97f54fb24f4	setColumnRemarks columnName=elevation_grs80, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-48	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.632959	394	EXECUTED	7:6879bc52c6697722304e9e401036bd74	setColumnRemarks columnName=entrydate, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-49	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.638669	395	EXECUTED	7:2ed882da29207c0900c536e324f07ab0	setColumnRemarks columnName=equipment_configuration_id, tableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-50	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.644328	396	EXECUTED	7:088122cd4bb8802d416fedd015826210	setColumnRemarks columnName=equipment_id, tableName=equipment_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-51	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.651135	397	EXECUTED	7:1ab76146d950979a23b52589b2e14a5e	setColumnRemarks columnName=equipment_type, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1483935176618-52	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.658127	398	EXECUTED	7:ef9bb1890d0274820d8119cd266105fb	setColumnRemarks columnName=error, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-53	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.664299	399	EXECUTED	7:9abef18a121d5759accaf35987fecbcf	setColumnRemarks columnName=event_name, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-54	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.671077	400	EXECUTED	7:90a181ab6f858493b0266bc05d0854df	setColumnRemarks columnName=fault_zones_nearby, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-55	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.676955	401	EXECUTED	7:c18d0e03665c87490f5e249e1355cda1	setColumnRemarks columnName=firmware_version, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-56	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.682787	402	EXECUTED	7:bcef6fbc6abb1025f54edcc5d99ca8ed	setColumnRemarks columnName=form_date_prepared, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-57	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.688926	403	EXECUTED	7:8d15c70fc01c3c57c8260c024f820463	setColumnRemarks columnName=form_prepared_by, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-58	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:10.695342	404	EXECUTED	7:b141daf408f94e30ae17947203c5eeec	setColumnRemarks columnName=form_report_type, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-59	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.105777	405	EXECUTED	7:07a33cc3d024acdfc1d86b634bcc1c51	setColumnRemarks columnName=foundation, tableName=monument		\N	3.5.3	\N	\N	8147623451
1483935176618-60	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.111656	406	EXECUTED	7:eba2c03876d75ec3c953cf61203d60f7	setColumnRemarks columnName=foundation_depth, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-61	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.117006	407	EXECUTED	7:7bba89d17e605db317757d48f3056124	setColumnRemarks columnName=four_char_id, tableName=site_log_received		\N	3.5.3	\N	\N	8147623451
1483935176618-62	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.122268	408	EXECUTED	7:4b33e5ddb29a32bc82f00b79094066db	setColumnRemarks columnName=four_character_id, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1483935176618-63	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.127783	409	EXECUTED	7:f1fc1b4cf6842e2ccf6fc2d86ea89eab	setColumnRemarks columnName=four_character_id, tableName=site_updated		\N	3.5.3	\N	\N	8147623451
1483935176618-64	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.134612	410	EXECUTED	7:589421f3cd0611f7a94b8ad06cad49a1	setColumnRemarks columnName=four_character_id, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-65	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.141601	411	EXECUTED	7:c041c76e196ce4b14f2b3bbd69f4dc53	setColumnRemarks columnName=fracture_spacing, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-66	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.148112	412	EXECUTED	7:a3dd3c81c0d22a52e71e31a74304063b	setColumnRemarks columnName=geologic_characteristic, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1483935176618-67	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.155446	413	EXECUTED	7:2aeaf025335d5cc7096368626ec1b936	setColumnRemarks columnName=geologic_characteristic, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-68	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.162003	414	EXECUTED	7:fa3d253b60429ce304a5050ccb9d6d68	setColumnRemarks columnName=height, tableName=monument		\N	3.5.3	\N	\N	8147623451
1483935176618-69	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.168476	415	EXECUTED	7:c52913f7c8ef66f2b7a5a6111be37854	setColumnRemarks columnName=height_diff_to_antenna, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-70	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.175257	416	EXECUTED	7:72571c1a0cda107ba8b18c3e04eede5d	setColumnRemarks columnName=height_diff_to_antenna, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-71	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.183338	417	EXECUTED	7:2ddc059845404bb83d51d9ee83a4cc9b	setColumnRemarks columnName=height_of_monument, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-72	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.189373	418	EXECUTED	7:b45b3d8747bd59726d2d7c20720176da	setColumnRemarks columnName=id, tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-73	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.194872	419	EXECUTED	7:7838f26729ac7a8ca94089f7a42e1682	setColumnRemarks columnName=id, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1483935176618-74	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.230362	420	EXECUTED	7:859339e53b89af29e60bd1cec4548937	setColumnRemarks columnName=id, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-75	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.235514	421	EXECUTED	7:0c9a10ab83870ae13cd5e28d27706876	setColumnRemarks columnName=id, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1483935176618-76	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.52049	422	EXECUTED	7:2906e1c69c473936ac209d7d3801864e	setColumnRemarks columnName=id, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-77	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.529022	423	EXECUTED	7:708987fb317a8213e0241c3ba75b31f4	setColumnRemarks columnName=id, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-78	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.537051	424	EXECUTED	7:54b551dba2c31bd9c9aa4085a4717012	setColumnRemarks columnName=id, tableName=humidity_sensor		\N	3.5.3	\N	\N	8147623451
1483935176618-79	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.544795	425	EXECUTED	7:4cc24c97e4564de88ba6d663da1deec5	setColumnRemarks columnName=id, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-80	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.556974	426	EXECUTED	7:4390f7e8601ada784a5731d967c0ba63	setColumnRemarks columnName=id, tableName=monument		\N	3.5.3	\N	\N	8147623451
1483935176618-81	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.567367	427	EXECUTED	7:5cbbf57c124d67e5589ebc52f3b2e172	setColumnRemarks columnName=id, tableName=setup		\N	3.5.3	\N	\N	8147623451
1483935176618-82	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.579314	428	EXECUTED	7:45b506236de269da64b0b768cbae5080	setColumnRemarks columnName=id, tableName=site		\N	3.5.3	\N	\N	8147623451
1483935176618-83	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.592524	429	EXECUTED	7:644e8ca9c44a57ead668d8ad1f065a7e	setColumnRemarks columnName=id, tableName=site_log_received		\N	3.5.3	\N	\N	8147623451
1483935176618-84	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.606199	430	EXECUTED	7:6f97f89b7512b6016639ef8ee1307c34	setColumnRemarks columnName=id, tableName=site_updated		\N	3.5.3	\N	\N	8147623451
1483935176618-85	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.621269	431	EXECUTED	7:b702cb20a24183ceab501e6986edb0db	setColumnRemarks columnName=id, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-86	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.635493	432	EXECUTED	7:8bd01c62b24f891b308b5f2d583778cc	setColumnRemarks columnName=id, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-89	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.67588	435	EXECUTED	7:972e803159c2557c816535fc1d314024	setColumnRemarks columnName=iers_domes_number, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-90	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.690051	436	EXECUTED	7:67b3fb17226afaf1d7566ba50224c891	setColumnRemarks columnName=input_frequency, tableName=clock_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-91	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.700171	437	EXECUTED	7:9c8cbd7b31d5f6c59ae5213c5d646718	setColumnRemarks columnName=input_frequency, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-92	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.705788	438	EXECUTED	7:bbf1d0c5fa8132ddabcf0142b0b0a9bb	setColumnRemarks columnName=invalidated, tableName=setup		\N	3.5.3	\N	\N	8147623451
1483935176618-93	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.718904	439	EXECUTED	7:a750d5ce77d5d29728bed52015a6eaad	setColumnRemarks columnName=itrf_x, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-94	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.737137	440	EXECUTED	7:b93797ebaa0d3014b6425b20898b0fdd	setColumnRemarks columnName=itrf_y, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-95	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.743024	441	EXECUTED	7:e714f3aa0599c6468ffaff95358d90cd	setColumnRemarks columnName=itrf_z, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-96	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.75499	442	EXECUTED	7:420347a16732ea90fd0d3b8c7add84cc	setColumnRemarks columnName=location_notes, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-97	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.761981	443	EXECUTED	7:df2a27135a1999210f20693770af60e8	setColumnRemarks columnName=manufacturer, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1483935176618-98	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.766816	444	EXECUTED	7:82999cf9e3a5e77adc2ee8e955f7d67e	setColumnRemarks columnName=manufacturer, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-99	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.771361	445	EXECUTED	7:be3908287ad382bad78ae109f4846477	setColumnRemarks columnName=marker_arp_east_eccentricity, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-100	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.775947	446	EXECUTED	7:42d3b4c2de2535bc910c32f61b6a6bea	setColumnRemarks columnName=marker_arp_north_eccentricity, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-101	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.780432	447	EXECUTED	7:edd2092d9859e22c204596169340748d	setColumnRemarks columnName=marker_arp_up_eccentricity, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-102	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.784938	448	EXECUTED	7:4c42252eebcec84ef8e3931658e399f0	setColumnRemarks columnName=marker_description, tableName=monument		\N	3.5.3	\N	\N	8147623451
1483935176618-103	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.789473	449	EXECUTED	7:3a559d1f39d804d3c81547f42da63ab3	setColumnRemarks columnName=marker_description, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-104	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.794049	450	EXECUTED	7:501545da3c0bf76e3a23d91e13921231	setColumnRemarks columnName=mi_antenna_graphics, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-105	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.798767	451	EXECUTED	7:40e8cc490454e372115d42b32a68a574	setColumnRemarks columnName=mi_doi, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-106	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.803516	452	EXECUTED	7:214f2a8d1499c22b8784e22f1c3d2bcb	setColumnRemarks columnName=mi_hard_copy_on_file, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-107	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.808069	453	EXECUTED	7:d662b303a4572322888f55b473332e58	setColumnRemarks columnName=mi_horizontal_mask, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-108	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.812487	454	EXECUTED	7:a553be66ab74165ea21b9697e96faa34	setColumnRemarks columnName=mi_monument_description, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-109	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.81692	455	EXECUTED	7:d8f4fb60f894e4cb9dcc1f5a9e3e8f91	setColumnRemarks columnName=mi_notes, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-110	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:11.821685	456	EXECUTED	7:a3f75f914e28aeaccb90af936ee121dc	setColumnRemarks columnName=mi_primary_data_center, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-111	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.327619	457	EXECUTED	7:b4d827518efdec9ad271d1e8a07dc4e4	setColumnRemarks columnName=mi_secondary_data_center, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-112	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.332399	458	EXECUTED	7:107a29ee3df86042ace49297d96b79f8	setColumnRemarks columnName=mi_site_diagram, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-113	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.336902	459	EXECUTED	7:ae1b7fd0729459dc946d8c8e36900602	setColumnRemarks columnName=mi_site_map, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-114	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.341287	460	EXECUTED	7:bad49bc78375acb5a9b25637e326c130	setColumnRemarks columnName=mi_site_pictires, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-115	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.347981	461	EXECUTED	7:799452c48e3a836f6eb36448a7480810	setColumnRemarks columnName=mi_text_graphics_from_antenna, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-116	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.35807	462	EXECUTED	7:666b2417dfae5dd2ae54315c0d6597d8	setColumnRemarks columnName=mi_url_for_more_information, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-117	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.369098	463	EXECUTED	7:26333debd165efe85c9c6ebac1ab21bf	setColumnRemarks columnName=monument_description, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-118	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.379399	464	EXECUTED	7:c161e55668bb7bb6a80a668ee4951bd2	setColumnRemarks columnName=monument_foundation, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-119	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.389722	465	EXECUTED	7:64e5c68d26f0573152aa97a65776c64c	setColumnRemarks columnName=monument_id, tableName=cors_site		\N	3.5.3	\N	\N	8147623451
1483935176618-120	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.401204	466	EXECUTED	7:969465e84ac4fd16ebd08ca2c665575b	setColumnRemarks columnName=monument_inscription, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-121	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.412109	467	EXECUTED	7:73d115b61b11a31d55c436af76d74b30	setColumnRemarks columnName=name, tableName=setup		\N	3.5.3	\N	\N	8147623451
1483935176618-122	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.423377	468	EXECUTED	7:8c5cba927c839bde20a62ec0036ef314	setColumnRemarks columnName=name, tableName=site		\N	3.5.3	\N	\N	8147623451
1483935176618-123	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.43412	469	EXECUTED	7:8e8653e00a958bee2781638c75d85d82	setColumnRemarks columnName=nine_character_id, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-124	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.44702	470	EXECUTED	7:97b8070ad1056a762ea0ecc02cda0ab3	setColumnRemarks columnName=notes, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-125	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.465265	471	EXECUTED	7:55d4773a485842b6fc351812225acd9a	setColumnRemarks columnName=notes, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-126	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.475477	472	EXECUTED	7:b294d5879325f860f31c9ed1da763fb9	setColumnRemarks columnName=notes, tableName=humidity_sensor_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-127	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.487046	473	EXECUTED	7:7857c1ee8f05ac1a2b801fd618b2c919	setColumnRemarks columnName=notes, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-128	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.698466	474	EXECUTED	7:197a5822ef29c8292a255d9fca745c2f	setColumnRemarks columnName=notes, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-129	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.702973	475	EXECUTED	7:c86fcde63f048f1e2e4e6abd3a3c5d08	setColumnRemarks columnName=notes, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-130	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.707109	476	EXECUTED	7:d35c5af1666aefb14d6dda10339223f1	setColumnRemarks columnName=radome_serial_number, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-131	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.711153	477	EXECUTED	7:111519b510fd1bdf3cb32a153b5fac4f	setColumnRemarks columnName=radome_type, tableName=gnss_antenna_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-132	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.71482	478	EXECUTED	7:53d40f132e529cb7d4b1138ad106c459	setColumnRemarks columnName=retries, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-133	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.718579	479	EXECUTED	7:dfb9e54d427977eb218408fe996cc9c6	setColumnRemarks columnName=satellite_system, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-134	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.722422	480	EXECUTED	7:571404cb90d129fa1c1c162a7083569c	setColumnRemarks columnName=serial_number, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1483935176618-135	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.726026	481	EXECUTED	7:2589e6590b1575fa1169e290a8751849	setColumnRemarks columnName=serial_number, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-136	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.729591	482	EXECUTED	7:9064db15d5a5a57988806c881d608034	setColumnRemarks columnName=shape, tableName=site		\N	3.5.3	\N	\N	8147623451
1483935176618-137	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.733442	483	EXECUTED	7:d5782962b56a744595f450db158672eb	setColumnRemarks columnName=site_id, tableName=setup		\N	3.5.3	\N	\N	8147623451
1483935176618-138	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.737201	484	EXECUTED	7:71d52a0ecf975f7a8ca6e05462fffd43	setColumnRemarks columnName=site_id, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-139	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.741057	485	EXECUTED	7:4c3bb7c904f3c6c3f803d29db265577f	setColumnRemarks columnName=site_id, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-140	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.745036	486	EXECUTED	7:c08d3ce4af9303dd7e90326f87affb67	setColumnRemarks columnName=site_log_text, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-141	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.748646	487	EXECUTED	7:ea6d09803b9860ebd0909733e9e58b85	setColumnRemarks columnName=site_name, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-142	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.752371	488	EXECUTED	7:e1a26c1d4c26dd34b1dbfa1a4216662c	setColumnRemarks columnName=state, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-143	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.755782	489	EXECUTED	7:2c7fa7d4d2e746dedd5e9a1631607e0a	setColumnRemarks columnName=subscriber, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-144	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.75937	490	EXECUTED	7:bdd4a27c907837eb3e4a7a8103dbaf13	setColumnRemarks columnName=tectonic_plate, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1483935176618-145	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.871142	491	EXECUTED	7:df9425e77a0ae573c89ef7746688ef35	setColumnRemarks columnName=temperature_stabilization, tableName=gnss_receiver_configuration		\N	3.5.3	\N	\N	8147623451
1483935176618-146	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.876148	492	EXECUTED	7:719860f7a46281b9e805e3820c50c376	setColumnRemarks columnName=time_handled, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-147	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.88046	493	EXECUTED	7:901bd93681022b73f1a84cc07cd3fa99	setColumnRemarks columnName=time_published, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-148	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.884609	494	EXECUTED	7:605fe08175ca13eacdb5a4acbefa771c	setColumnRemarks columnName=time_raised, tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1483935176618-149	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.888604	495	EXECUTED	7:3819320b9120282c6c6c1836d3e11fc4	setColumnRemarks columnName=type, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1483935176618-150	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.892575	496	EXECUTED	7:ecb79f36c9e6d113176d44720566fe50	setColumnRemarks columnName=type, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1483935176618-151	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.896653	497	EXECUTED	7:d77c05e7c1ad0686a6fe025834446339	setColumnRemarks columnName=type, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1483935176618-152	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.900707	498	EXECUTED	7:2fe8dce8f13fa2506ca424ea030e66cf	setColumnRemarks columnName=version, tableName=equipment		\N	3.5.3	\N	\N	8147623451
1483935176618-153	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.904626	499	EXECUTED	7:4d0222039a32bb229587ab25e0ba0260	setColumnRemarks columnName=version, tableName=site		\N	3.5.3	\N	\N	8147623451
1483935176618-154	hong (generated)	db/add-table-column-comments-part1.xml	2020-04-29 08:07:12.908474	500	EXECUTED	7:3eb6bbde580183f89e5539d052dac8b2	setColumnRemarks columnName=weekly_solution_id, tableName=weekly_solution_available		\N	3.5.3	\N	\N	8147623451
1484110610909-1	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:12.912532	501	EXECUTED	7:4ad6eef64d070ac9177126a5b4836de7	setTableRemarks tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1484110610909-2	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:12.916563	502	EXECUTED	7:285ce8c25142820daacdb37913437020	setTableRemarks tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1484110610909-3	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:12.920774	503	EXECUTED	7:52ddb479db48c6180b2b31cf138d5c70	setTableRemarks tableName=invalid_site_log_received		\N	3.5.3	\N	\N	8147623451
1484110610909-4	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:12.924872	504	EXECUTED	7:008b98b86d1d4f33bedbe39de2b8fd5e	setTableRemarks tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-5	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:12.929057	505	EXECUTED	7:17737af1c846ecacc88f245405f89644	setTableRemarks tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1484110610909-6	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:12.933317	506	EXECUTED	7:3679e3446deb6cc7a2e6b506d10dd069	setTableRemarks tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-7	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:12.93759	507	EXECUTED	7:b9326c0cfeb3510143af73b5f388f230	setTableRemarks tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-8	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.228329	508	EXECUTED	7:6d32fafac4929c8bc1910b393ae00064	setTableRemarks tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1484110610909-9	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.234738	509	EXECUTED	7:7b44fa1ebebe1721edc7e2bc1174b4cf	setTableRemarks tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1484110610909-10	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.240507	510	EXECUTED	7:b0e652b834119e989d2c5ec470acc076	setTableRemarks tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1484110610909-11	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.245541	511	EXECUTED	7:72be1f737f2af9e994e4cfae08560cea	setTableRemarks tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-12	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.250921	512	EXECUTED	7:23eeb827544719465ed5c06c40d46545	setTableRemarks tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1484110610909-13	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.255847	513	EXECUTED	7:afb18356396c9327568b5aff0c20623d	setTableRemarks tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1484110610909-14	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.278294	514	EXECUTED	7:aad1dcfdad142abb3d5066cb60c6faa1	setTableRemarks tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-15	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.291667	515	EXECUTED	7:8043fc2cae143dffbf063860579b05bb	setTableRemarks tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-16	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.316724	516	EXECUTED	7:8a01527b430dbe2fda53b696ac67de7a	setTableRemarks tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-17	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.322833	517	EXECUTED	7:fa5074e36ffba6c59ab77431e7192065	setTableRemarks tableName=weekly_solution		\N	3.5.3	\N	\N	8147623451
1484110610909-18	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.328776	518	EXECUTED	7:b2e1c5c7a3b22f548fc645338f7c0412	setColumnRemarks columnName=accurace_degree_celcius, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-19	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.334279	519	EXECUTED	7:2b4996180b2fee757f48ac2f35464876	setColumnRemarks columnName=accuracy_hpa, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-20	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.339982	520	EXECUTED	7:4c2c56a9cf7f0acd32b1722b599bde8d	setColumnRemarks columnName=alignment_from_true_north, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-21	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.345322	521	EXECUTED	7:8281fc6b662ba077247ca6b9cda6d942	setColumnRemarks columnName=antenna_cable_length, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-22	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.350437	522	EXECUTED	7:22ad3c638e9b79fb646b24c236144816	setColumnRemarks columnName=antenna_cable_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-23	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.355697	523	EXECUTED	7:78e04e67c6c8ac8ec3ac51f72c9bcf61	setColumnRemarks columnName=antenna_radome_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-24	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.360931	524	EXECUTED	7:9d9c2ca25f21d2b935938f3815d75d91	setColumnRemarks columnName=antenna_reference_point, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-25	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.431372	525	EXECUTED	7:3d5560e76016282855f43693aa6d5edf	setColumnRemarks columnName=antenna_type, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-26	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.436792	526	EXECUTED	7:df301b647b406871a3e83dabd96019e7	setColumnRemarks columnName=aspiration, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-27	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.441749	527	EXECUTED	7:2a15288eabcee04026738adb7dcd8e79	setColumnRemarks columnName=callibration_date, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-28	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.446792	528	EXECUTED	7:0ac61aead30e0bee81e7262dfcd21a74	setColumnRemarks columnName=callibration_date, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-29	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.452063	529	EXECUTED	7:23c76b31a44affbb4b5759258015150b	setColumnRemarks columnName=callibration_date, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-30	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.457308	530	EXECUTED	7:e3ce3bc4f41176a3fe4b3d64646d2c36	setColumnRemarks columnName=cors_site_id, tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1484110610909-31	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.461902	531	EXECUTED	7:697643fa8d895568fff4e5aaca57ff2f	setColumnRemarks columnName=cors_site_network_id, tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1484110610909-32	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.466654	532	EXECUTED	7:9268486c252dff8e638c280fff7df544	setColumnRemarks columnName=data_sampling_interval, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-33	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.471314	533	EXECUTED	7:2b8c8d141ad64ad0eb7f9a47752d66c2	setColumnRemarks columnName=data_sampling_interval, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-34	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.475662	534	EXECUTED	7:8a2f977ac280b19f273ef9244a659c71	setColumnRemarks columnName=date_installed, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-35	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.480151	535	EXECUTED	7:35fbf197eda600b4890686ff49dfb3e7	setColumnRemarks columnName=date_installed, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-36	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.484548	536	EXECUTED	7:0eaff8432a4da3e460ec4b261ce5954e	setColumnRemarks columnName=date_measured, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-37	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.489182	537	EXECUTED	7:ecc9be3075be8f8614ebfb14a23823b3	setColumnRemarks columnName=date_removed, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-38	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.49345	538	EXECUTED	7:70151130bc117ffa6b92c13ffd103bfa	setColumnRemarks columnName=date_removed, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-39	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.497872	539	EXECUTED	7:e91bd03139bae603072e12b155e9d3c1	setColumnRemarks columnName=distance_to_antenna, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-40	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.502103	540	EXECUTED	7:c00cb86eede58a4c3404615d01f2b8d2	setColumnRemarks columnName=dx, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-41	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.506573	541	EXECUTED	7:e029d999fe414391d1e42de3f44ce82a	setColumnRemarks columnName=dy, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-42	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.671524	542	EXECUTED	7:fc301a66178160007bbaadd58215ca66	setColumnRemarks columnName=dz, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-43	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.680769	543	EXECUTED	7:3b8fb77a4f33f771e40e7a3cd883b6fd	setColumnRemarks columnName=effective_from, tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1484110610909-44	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.686393	544	EXECUTED	7:7de5f8c3f35dd26b0a9ef78529ac7af5	setColumnRemarks columnName=effective_from, tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1484110610909-45	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.696477	545	EXECUTED	7:7eb67b14521278fda1800744d1bd73d6	setColumnRemarks columnName=effective_from, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-46	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.70246	546	EXECUTED	7:cf5dd6418988e9661f8fb2cf0ca77102	setColumnRemarks columnName=effective_from, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1484110610909-47	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.725587	547	EXECUTED	7:aa57139fe8fd9f5a4a95a956e2fd438c	setColumnRemarks columnName=effective_from, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1484110610909-48	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.738624	548	EXECUTED	7:b51c4d3f1ae793246321837036d13589	setColumnRemarks columnName=effective_from, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1484110610909-49	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.750421	549	EXECUTED	7:757487e98434a954a50b388518161976	setColumnRemarks columnName=effective_from, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-50	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.762525	550	EXECUTED	7:c635691013aec8e517c128ca443c7fa0	setColumnRemarks columnName=effective_from, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-51	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.773304	551	EXECUTED	7:d9021e480da2b45991f4aef7ee819c1b	setColumnRemarks columnName=effective_from, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-52	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.779732	552	EXECUTED	7:b7a9b2ff7739ce574db8c71cffc8cf9c	setColumnRemarks columnName=effective_to, tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1484110610909-53	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.805022	553	EXECUTED	7:fbf1adaf73b3d355d8dd43af47573a88	setColumnRemarks columnName=effective_to, tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1484110610909-54	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.811214	554	EXECUTED	7:70d44fcc682c351c03112a7b02135ab5	setColumnRemarks columnName=effective_to, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-55	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.827001	555	EXECUTED	7:2546c910a22a4c362338fa748cc069d8	setColumnRemarks columnName=effective_to, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1484110610909-56	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.840394	556	EXECUTED	7:8bb019cdc5373f9d3daa1c2fefba7d1e	setColumnRemarks columnName=effective_to, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1484110610909-57	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.854111	557	EXECUTED	7:71e65cec3ee5f7155d9a57579bafa932	setColumnRemarks columnName=effective_to, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1484110610909-58	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.866975	558	EXECUTED	7:575976ec953f308a6d69e83587d39e6f	setColumnRemarks columnName=effective_to, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-59	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.881088	559	EXECUTED	7:9fe4e0de4e0605996915d6131bfd9805	setColumnRemarks columnName=effective_to, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-60	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.895289	560	EXECUTED	7:ef4d53c90a35ff3e7d25a3c85f8ad528	setColumnRemarks columnName=effective_to, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-61	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.909766	561	EXECUTED	7:56a8af3b78bd9933d7c179bb46cc8ac2	setColumnRemarks columnName=elevation_cutoff_setting, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-62	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.927212	562	EXECUTED	7:bc4482bda68f6645fb75ba53050efc4f	setColumnRemarks columnName=equipment_configuration_id, tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1484110610909-63	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.949815	563	EXECUTED	7:26accca2ac00ffb243ee303465b4995b	setColumnRemarks columnName=equipment_id, tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1484110610909-64	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.967571	564	EXECUTED	7:74f01d339d9b81099ee3287b0efcf561	setColumnRemarks columnName=event, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1484110610909-65	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.974845	565	EXECUTED	7:24c2a607597edf4c300edd4d315755e2	setColumnRemarks columnName=firmware_version, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-66	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.981241	566	EXECUTED	7:75ffb2459bd9a77a6402cfbd14ae8a45	setColumnRemarks columnName=height_diff_to_antenna, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-67	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.986339	567	EXECUTED	7:5c6f839a2a8003700cd412d2172d216f	setColumnRemarks columnName=height_diff_to_antenna, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-68	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.991785	568	EXECUTED	7:c450977ddc2b582bb666fbfe8e2c839d	setColumnRemarks columnName=height_diff_to_antenna, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-69	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:13.997042	569	EXECUTED	7:f927573e504496a49462bb55a596c040	setColumnRemarks columnName=id, tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1484110610909-70	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.002065	570	EXECUTED	7:a68af30fa9720e9cda5244173ed2ac39	setColumnRemarks columnName=id, tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1484110610909-71	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.007708	571	EXECUTED	7:354e39e1eecc19f02538a863a904ad90	setColumnRemarks columnName=id, tableName=invalid_site_log_received		\N	3.5.3	\N	\N	8147623451
1484110610909-72	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.013213	572	EXECUTED	7:828dc5dcf429ed3d2695de81f5226a78	setColumnRemarks columnName=id, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-73	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.018135	573	EXECUTED	7:4498921f0ffa6766add7270f4db330ca	setColumnRemarks columnName=id, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-74	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.023977	574	EXECUTED	7:55887e09e4b5493da35a66d6cb686b8f	setColumnRemarks columnName=id, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-75	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.029437	575	EXECUTED	7:b86f3066290eb4b124059871bad71f52	setColumnRemarks columnName=id, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1484110610909-76	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.034456	576	EXECUTED	7:897b9fc5b491a73dafc33d9d3a9d3741	setColumnRemarks columnName=id, tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1484110610909-77	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.038877	577	EXECUTED	7:2397f5f8249a15ba3cdf40acff67a7c8	setColumnRemarks columnName=id, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1484110610909-78	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.043571	578	EXECUTED	7:0ae2b1fbf396834ded89f4c0ca81235d	setColumnRemarks columnName=id, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-79	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.050353	579	EXECUTED	7:7a7cd3170fe12d7e1bb1495393b742f0	setColumnRemarks columnName=id, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1484110610909-80	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.055758	580	EXECUTED	7:9bf12ca01b6d7d5be1fe5d910b572d3d	setColumnRemarks columnName=id, tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1484110610909-81	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.061011	581	EXECUTED	7:6ccc127c5b152cb8954c6704c3c943b3	setColumnRemarks columnName=id, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-82	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.06573	582	EXECUTED	7:db100daab898ec5ae8808ba8948fe820	setColumnRemarks columnName=id, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-83	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.071563	583	EXECUTED	7:3ad5e73698bba52852313b3fa4847230	setColumnRemarks columnName=id, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-84	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.078993	584	EXECUTED	7:b0f66f7488024fe0f9b00c4c4342e8e4	setColumnRemarks columnName=input_frequency, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1484110610909-85	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.085342	585	EXECUTED	7:4f1091e84e7cbd84d36c5f2d706e5237	setColumnRemarks columnName=instrument_type, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-86	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.092649	586	EXECUTED	7:ea88846c354a2a3a3146dffd26ccb1e0	setColumnRemarks columnName=instrumentation, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1484110610909-87	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.101357	587	EXECUTED	7:4f7f79e3ad44c1cae25729b3a22b8de7	setColumnRemarks columnName=local_site_tie_accuracy, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-88	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.110067	588	EXECUTED	7:5dd1b7801676b1a1696ccc77e7e870b0	setColumnRemarks columnName=manufacturer, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-89	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.117765	589	EXECUTED	7:216614ed71fa6d9b296a9205b2bca5e6	setColumnRemarks columnName=manufacturer, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-90	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.125767	590	EXECUTED	7:d5b312a0a714d50fcaec779f7f12c4d7	setColumnRemarks columnName=manufacturer, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-91	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.133671	591	EXECUTED	7:7dca321d88e1685e7d55e971e0b05942	setColumnRemarks columnName=marker_arp_east_ecc, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-92	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.517064	592	EXECUTED	7:7cfc60812483cb01fc30c0223e45ac0d	setColumnRemarks columnName=marker_arp_north_ecc, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-93	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.533513	593	EXECUTED	7:96266af9109629ee25b593ad179f36a6	setColumnRemarks columnName=marker_arp_up_ecc, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-94	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.54336	594	EXECUTED	7:cf09650c17e4692464453e4b92d486da	setColumnRemarks columnName=notes, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-95	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.564791	595	EXECUTED	7:515310c9fdfbb76fc9421b79c5f1fc03	setColumnRemarks columnName=notes, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1484110610909-96	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.578487	596	EXECUTED	7:2d69e971e78f7c848fa06149c138841e	setColumnRemarks columnName=notes, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-97	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.59058	597	EXECUTED	7:368a5a20e9c7c4482b01b4d6a8320f7c	setColumnRemarks columnName=notes, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-98	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.606239	598	EXECUTED	7:1a5517968e5ba858a54e707da0a2548a	setColumnRemarks columnName=notes, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-99	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.621532	599	EXECUTED	7:838538157e91b628720fba550089630f	setColumnRemarks columnName=notes, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-100	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.637729	600	EXECUTED	7:f8ac1b5446589d265eefce60ff996f13	setColumnRemarks columnName=notes, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-101	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.652177	601	EXECUTED	7:df41c176b9e7f2d4df239f003045b4dc	setColumnRemarks columnName=notes, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-102	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.668252	602	EXECUTED	7:3413fed22b982e4f5bda2b35d677a4dc	setColumnRemarks columnName=observed_degradation, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1484110610909-103	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.690668	603	EXECUTED	7:378dca60162e51473f4db1e04ddee4d7	setColumnRemarks columnName=radome_serial_number, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-104	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.70358	604	EXECUTED	7:43da3120ce24d9bc0531577502b56e66	setColumnRemarks columnName=receiver_type, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-105	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.715734	605	EXECUTED	7:e74e97ce08fd7e69fa506da62e0a10c7	setColumnRemarks columnName=satellite_system, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-106	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.72988	606	EXECUTED	7:aadc21b19ba7471a084bedbbcefdf99f	setColumnRemarks columnName=serial_number, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-107	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.736882	607	EXECUTED	7:74975b7c23f30200fc8e887c234a7058	setColumnRemarks columnName=serial_number, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-108	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:14.743133	608	EXECUTED	7:2a47fb115ee1ae0ad0fa0d380a291342	setColumnRemarks columnName=serial_number, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-109	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.002221	609	EXECUTED	7:cec42ec925f32b1afbd1802d3ccb7a22	setColumnRemarks columnName=serial_number, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-110	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.006828	610	EXECUTED	7:c383639936387018161c6ba13431d1ad	setColumnRemarks columnName=serial_number, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-111	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.010817	611	EXECUTED	7:22040a56f1c287a1234ab89f86e8525e	setColumnRemarks columnName=setup_id, tableName=equipment_in_use		\N	3.5.3	\N	\N	8147623451
1484110610909-112	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.014965	612	EXECUTED	7:6f819a1aace47e94973ee79ac08eb3d2	setColumnRemarks columnName=site_id, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-113	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.018891	613	EXECUTED	7:b9920ea0ebb221f5dd83f524757906e4	setColumnRemarks columnName=site_id, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1484110610909-114	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.022932	614	EXECUTED	7:388c8504a18e6b288e4c6c57943048f0	setColumnRemarks columnName=site_id, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-115	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.032568	615	EXECUTED	7:7249fceaabe33ed9cc7c38103e455d96	setColumnRemarks columnName=site_id, tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1484110610909-116	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.038278	616	EXECUTED	7:d8b0e60dc50acaef5662f7635fb29f40	setColumnRemarks columnName=site_id, tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1484110610909-117	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.043888	617	EXECUTED	7:73e3aa31e10daefe808f7ec74f11883f	setColumnRemarks columnName=site_id, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1484110610909-118	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.050638	618	EXECUTED	7:2d1107f942f0656285d1d4f74f36e0e9	setColumnRemarks columnName=site_id, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-119	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.056384	619	EXECUTED	7:9ff3c4a9f87482f972cf54243d97d9c2	setColumnRemarks columnName=site_id, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1484110610909-120	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.062289	620	EXECUTED	7:6845d6a1e74d5c20b6d6b29272297c65	setColumnRemarks columnName=site_id, tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1484110610909-121	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.070259	621	EXECUTED	7:ba8b4993bda2becd82a2525a5368ec5f	setColumnRemarks columnName=site_id, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-122	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.077309	622	EXECUTED	7:2e5429c8b66bbb5e11e36495067c8b04	setColumnRemarks columnName=site_id, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-123	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.092812	623	EXECUTED	7:05db89a1931eeead8dad92c46430307d	setColumnRemarks columnName=site_id, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484110610909-124	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.105051	624	EXECUTED	7:dabf4c05ca6072ad05429e0708aa5b35	setColumnRemarks columnName=site_log_text, tableName=invalid_site_log_received		\N	3.5.3	\N	\N	8147623451
1484110610909-125	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.114927	625	EXECUTED	7:a66c8ced0c51ddabff48ed557bdc2eac	setColumnRemarks columnName=status, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1484110610909-126	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.330296	626	EXECUTED	7:f5e2060db0a5957056679079c10735c7	setColumnRemarks columnName=survey_method, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-127	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.335678	627	EXECUTED	7:0cfbd8eb5e5cea7a0da788b82e52f81b	setColumnRemarks columnName=temperature_stabilization, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1484110610909-128	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.341081	628	EXECUTED	7:68747e0e65b3285ecffd9bd2fa649268	setColumnRemarks columnName=tied_marker_cdp_number, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-129	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.346903	629	EXECUTED	7:07cc095e7182a3fc71dfa0cd07b4af11	setColumnRemarks columnName=tied_marker_domes_number, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-130	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.352802	630	EXECUTED	7:dddd8cafeb570b263ef272542a890360	setColumnRemarks columnName=tied_marker_name, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-131	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.370654	631	EXECUTED	7:b52e2f93057f2637a9d28a07a9d09153	setColumnRemarks columnName=tied_marker_usage, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1484110610909-132	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.380847	632	EXECUTED	7:a6de2f46884fd4c05e0793dd06cacf5b	setColumnRemarks columnName=type, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1484110610909-133	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.391562	633	EXECUTED	7:b59ca69f8817c39a80eda8ff42583975	setColumnRemarks columnName=type, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1484110610909-134	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.402243	634	EXECUTED	7:c3c4934461868f585c99237938c347c4	setColumnRemarks columnName=type, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1484110610909-135	hong (generated)	db/add-table-column-comments-part2.xml	2020-04-29 08:07:15.412458	635	EXECUTED	7:b5d065cb7780c3aead0562502569e04e	setColumnRemarks columnName=type, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1484527847082-1	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.42376	636	EXECUTED	7:b93fb6bed62f12d02a25bcb2b5a7498b	setTableRemarks tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1484527847082-2	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.434283	637	EXECUTED	7:9bfcda938d0025c73b221622231cb19f	setTableRemarks tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-3	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.445037	638	EXECUTED	7:544c66979de519ea39d4cbfec2c83c3a	setTableRemarks tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-4	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.455283	639	EXECUTED	7:0bc331ecfec860590b534c85945d2465	setColumnRemarks columnName=as_at, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-5	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.474672	640	EXECUTED	7:35b0106192613e69aec8715064d65154	setColumnRemarks columnName=cors_site_network_id, tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1484527847082-6	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.483925	641	EXECUTED	7:1824b1f42305633df5c84465ff68075c	setColumnRemarks columnName=datum_epsg_code, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-7	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.493417	642	EXECUTED	7:1567dee823835d5804161f96a17d6507	setColumnRemarks columnName=description, tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1484527847082-8	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.588693	643	EXECUTED	7:0e6d4d303bd71efb88734c6514891272	setColumnRemarks columnName=effective_from, tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-9	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.596347	644	EXECUTED	7:a9201f814c9d3d3e9acb661cf8b98b0d	setColumnRemarks columnName=effective_to, tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-10	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.604751	645	EXECUTED	7:85c3bdf52597d0e39b095800b17f83fa	setColumnRemarks columnName=epoch, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-11	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.614312	646	EXECUTED	7:5e8a030e319690da153955ea6e628a67	setColumnRemarks columnName=four_character_id, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-12	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.626912	647	EXECUTED	7:d5cffcfd844b6aa11a5ea508aa3ebd58	setColumnRemarks columnName=id, tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1484527847082-13	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.64044	648	EXECUTED	7:e9873be419be6f67cc959d7eefc8c404	setColumnRemarks columnName=id, tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-14	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.653107	649	EXECUTED	7:c47c544f61ca1f12f5a0064cf8ac0b06	setColumnRemarks columnName=id, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-15	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.661083	650	EXECUTED	7:12350eb7182ccdbb749425b3e4047a31	setColumnRemarks columnName=invalidated, tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-16	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.668518	651	EXECUTED	7:892fbc5b2f0c183ec8e97597a0f1f87f	setColumnRemarks columnName=name, tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1484527847082-17	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.675336	652	EXECUTED	7:dfa77bbccf3ea8546203bb704f920ff5	setColumnRemarks columnName=node_id, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-18	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.681925	653	EXECUTED	7:7559985f43b02a0f960b756033c0bc4b	setColumnRemarks columnName=position_source_id, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-19	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.688612	654	EXECUTED	7:a9224ce2902d297adff2bd4d724b7b15	setColumnRemarks columnName=setup_id, tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-20	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.695716	655	EXECUTED	7:f900b38fc66fbd12091dcd961b97938a	setColumnRemarks columnName=site_id, tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-21	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.702825	656	EXECUTED	7:e4fd32a535b5fa0f41536d20fea03b58	setColumnRemarks columnName=version, tableName=node		\N	3.5.3	\N	\N	8147623451
1484527847082-22	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.709686	657	EXECUTED	7:52dfaa2bc9707f487ebe1658d7cca484	setColumnRemarks columnName=x, tableName=position		\N	3.5.3	\N	\N	8147623451
1484527847082-23	hong (generated)	db/add-table-column-comments-part3.xml	2020-04-29 08:07:15.716646	658	EXECUTED	7:55c6702b85a02ce1f073e11638886b0c	setColumnRemarks columnName=y, tableName=position		\N	3.5.3	\N	\N	8147623451
1485225822117-1	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:15.726417	659	EXECUTED	7:bd8ff58ce58336a7bbefccbf248da366	addColumn tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1485225822117-2	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:15.942829	660	EXECUTED	7:4d3de725be16657640eeb8b59452c266	addColumn tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1485225822117-3	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:15.949006	661	EXECUTED	7:737177e453712021557f299eb9a660d2	addColumn tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1485225822117-4	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:15.96017	662	EXECUTED	7:f1950364e2c6455d6ea7b49d74f6f90f	addColumn tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1485225822117-5	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:15.972451	663	EXECUTED	7:68ba4897b04a1b8b614222ab3ae55e87	addColumn tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1485225822117-6	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:15.984535	664	EXECUTED	7:0e580f03eb22600454f16a5b91f99b17	addColumn tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1485225822117-7	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:15.998694	665	EXECUTED	7:91fd397c159ac1269ce23c4618312c66	addColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1485225822117-8	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.010598	666	EXECUTED	7:0493d65c2a59c5150718ebce28d97185	addColumn tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1485225822117-9	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.024325	667	EXECUTED	7:6f45f449925f1fda22ca7b6694f37ffe	addColumn tableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
1485225822117-10	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.037238	668	EXECUTED	7:0bb7b64abb17cc175271373b9bf0eb51	addColumn tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1485225822117-11	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.048889	669	EXECUTED	7:33fb2371585ff9be3337cddd4e789a03	addColumn tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1485225822117-12	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.062623	670	EXECUTED	7:168957c4fb9eba3479b2adcb3a8c2c11	addColumn tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1485225822117-13	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.074446	671	EXECUTED	7:eb0334118a4fd72b9444186824faa909	addColumn tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1485225822117-14	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.080657	672	EXECUTED	7:b19d9938f3c8c916e6ba056c2c6bb8c0	addColumn tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1485225822117-15	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.086502	673	EXECUTED	7:818a48d0bc786e641ed711d89942e2e0	addColumn tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1485225822117-16	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.091406	674	EXECUTED	7:3f9bc50929d87c18bfd94c78bc8a7464	addColumn tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1485225822117-17	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.096558	675	EXECUTED	7:6067f57823e38cb1d6a2f210527c26e2	addColumn tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1485225822117-18	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.108403	676	EXECUTED	7:914521ab13a9fe3bde2ac19dd89bcdfd	addColumn tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1485225822117-19	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.158512	677	EXECUTED	7:57c24a1055b49c36a90b62f1637bc211	addColumn tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1485225822117-20	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.164508	678	EXECUTED	7:e5cc22610d9ab0150f330a53019efd4f	addColumn tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1485225822117-21	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.169464	679	EXECUTED	7:3cdacaff5693bc3132ec097d5df62f23	addColumn tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1485225822117-22	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.174434	680	EXECUTED	7:bc394d81119c415496513800afc8bfbd	addColumn tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1485225822117-23	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.179712	681	EXECUTED	7:4361954d2e1183c1d16b8ab2a6747a4f	addColumn tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1485225822117-24	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.185279	682	EXECUTED	7:a049205f2fec5c73b01acc02740e66b4	addColumn tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1485225822117-26	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.194478	684	EXECUTED	7:c737115e24fa56f74db4df24ee9f21d3	addColumn tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1485225822117-27	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.199322	685	EXECUTED	7:026eaa4979f5f3fe150271bdc922c206	addColumn tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1485225822117-28	hong (generated)	db/add-delete-column-in-sitelog.xml	2020-04-29 08:07:16.204448	686	EXECUTED	7:82ab464b3d2d4ca9a737ba0ca4999ed3	addColumn tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1490566826524-1	lbodor (generated)	db/add-user-registration.xml	2020-04-29 08:07:16.213162	687	EXECUTED	7:63c817e6ff479786fc05ab40ebcb6ca6	createTable tableName=user_registration		\N	3.5.3	\N	\N	8147623451
1490566826524-2	lbodor (generated)	db/add-user-registration.xml	2020-04-29 08:07:16.219738	688	EXECUTED	7:6a7aa393e1f11ae5814f8f8f6fb37ff4	createTable tableName=user_registration_received		\N	3.5.3	\N	\N	8147623451
1490566826524-3	lbodor (generated)	db/add-user-registration.xml	2020-04-29 08:07:16.229263	689	EXECUTED	7:f59848fc2555ecb42fa5036b8431dfd5	addPrimaryKey constraintName=user_registration_pkey, tableName=user_registration		\N	3.5.3	\N	\N	8147623451
1490566826524-4	lbodor (generated)	db/add-user-registration.xml	2020-04-29 08:07:16.241211	690	EXECUTED	7:9583c7fa9c64c655d484fc60ead180ae	addPrimaryKey constraintName=user_registration_received_pkey, tableName=user_registration_received		\N	3.5.3	\N	\N	8147623451
1490566826524-5	lbodor (generated)	db/add-user-registration.xml	2020-04-29 08:07:16.255966	691	EXECUTED	7:ba7cf174091821b082c0ad6bb15aba75	addForeignKeyConstraint baseTableName=user_registration_received, constraintName=fk_user_registration_received_id, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1490566826524-6	lbodor (generated)	db/add-user-registration.xml	2020-04-29 08:07:16.270482	692	EXECUTED	7:71abfde4111b6c3718b74418891cf9a0	addForeignKeyConstraint baseTableName=user_registration_received, constraintName=fk_user_registration_id, referencedTableName=user_registration		\N	3.5.3	\N	\N	8147623451
1490677327962-1	lbodor (generated)	db/add-user-registration-remarks.xml	2020-04-29 08:07:16.285119	693	EXECUTED	7:0b639e15b3a11d1f701dba03abfa4b8c	addColumn tableName=user_registration		\N	3.5.3	\N	\N	8147623451
renameTable sitelog_localepisodicevent to sitelog_localepisodiceffect -1	heya	db/rename-local-episodic-event-table.xml	2020-04-29 08:07:16.326158	694	EXECUTED	7:e9c0e3b437a2e8780977892b260b8446	renameTable newTableName=sitelog_localepisodiceffect, oldTableName=sitelog_localepisodicevent		\N	3.5.3	\N	\N	8147623451
renameTable sitelog_localepisodicevent to sitelog_localepisodiceffect -2	heya	db/rename-local-episodic-event-table.xml	2020-04-29 08:07:16.339063	695	EXECUTED	7:07c6bb6fa7238bcd9d7abc6f37ccf653	dropPrimaryKey constraintName=pk_sitelog_localepisodicevent_id, tableName=sitelog_localepisodiceffect; dropForeignKeyConstraint baseTableName=sitelog_localepisodiceffect, constraintName=fk_sitelog_localepisodicevent_siteid; dropSequence sequenceNa...		\N	3.5.3	\N	\N	8147623451
renameTable sitelog_localepisodicevent to sitelog_localepisodiceffect -3	heya	db/rename-local-episodic-event-table.xml	2020-04-29 08:07:16.354519	696	EXECUTED	7:49bc802717b0e84baab37b057a603ac7	addPrimaryKey constraintName=pk_sitelog_localepisodiceffect_id, tableName=sitelog_localepisodiceffect; addForeignKeyConstraint baseTableName=sitelog_localepisodiceffect, constraintName=fk_sitelog_site_sitelog_localepisodiceffect, referencedTableNa...		\N	3.5.3	\N	\N	8147623451
1488326723446-1	heya	db/add-sitelog_site_position_points.xml	2020-04-29 08:07:16.360183	697	MARK_RAN	7:43fc3de74e0808d60bf98baa0347361f	dropColumn columnName=itrf_x, tableName=sitelog_site; dropColumn columnName=itrf_y, tableName=sitelog_site; dropColumn columnName=itrf_z, tableName=sitelog_site; dropColumn columnName=elevation_grs80, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1488326723446-2	heya	db/add-sitelog_site_position_points.xml	2020-04-29 08:07:16.375017	698	EXECUTED	7:31b9b7a6d74f486e90d15035909b3eb3	addColumn tableName=sitelog_site; setColumnRemarks columnName=cartesian_position, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1488326723446-3	heya	db/add-sitelog_site_position_points.xml	2020-04-29 08:07:16.388938	699	EXECUTED	7:a3616b4d0918a7ba6cd03a2df9d5ddee	addColumn tableName=sitelog_site; setColumnRemarks columnName=geodetic_position, tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1490933518333-1	heya	db/add-missing-columns-to-problem-source-tables.xml	2020-04-29 08:07:16.422976	700	EXECUTED	7:2ca6f85a7b047fba92c5a4c7cea7e5d0	addColumn tableName=sitelog_mutlipathsource; addColumn tableName=sitelog_mutlipathsource; addColumn tableName=sitelog_mutlipathsource; addColumn tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1490933518333-2	heya	db/add-missing-columns-to-problem-source-tables.xml	2020-04-29 08:07:16.440471	701	EXECUTED	7:017b317399ee031722d3d0f213a591df	addColumn tableName=sitelog_signalobstraction; addColumn tableName=sitelog_signalobstraction; addColumn tableName=sitelog_signalobstraction; addColumn tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1490933518333-3	heya	db/add-missing-columns-to-problem-source-tables.xml	2020-04-29 08:07:16.475392	702	EXECUTED	7:4d38a0267b88ebf256f132e3b09d869e	addColumn tableName=sitelog_radiointerference; addColumn tableName=sitelog_radiointerference; addColumn tableName=sitelog_radiointerference; addColumn tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1492474214992-1	lbodor (generated)	db/add-version-to-cors-network.xml	2020-04-29 08:07:16.50511	703	EXECUTED	7:441a7e6e210f8bbd33251f82e7fc8461	addColumn tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1492478430133-1	lbodor (generated)	db/add-cors-network-name-constraints.xml	2020-04-29 08:07:16.513589	704	EXECUTED	7:14fc5dfd4ab24ba8f29e5aacb1e3b27b	addUniqueConstraint constraintName=uc_cors_network_name, tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1492478430133-2	lbodor (generated)	db/add-cors-network-name-constraints.xml	2020-04-29 08:07:16.519527	705	EXECUTED	7:65c38a09728d56fb02daa10f88976523	addNotNullConstraint columnName=name, tableName=cors_site_network		\N	3.5.3	\N	\N	8147623451
1494977112808-1	lbodor (generated)	db/add-index-column-to-responsible-parties.xml	2020-04-29 08:07:16.524873	706	EXECUTED	7:07416cc4da1399d874ff10e1f566734a	addColumn tableName=sitelog_responsible_party		\N	3.5.3	\N	\N	8147623451
1496184059218-1	heya	db/add-new-cors-site-request.xml	2020-04-29 08:07:16.534048	707	EXECUTED	7:76efa1ebe206e3491810c2f9804c57e4	createTable tableName=new_cors_site_request		\N	3.5.3	\N	\N	8147623451
1496184059218-2	heya	db/add-new-cors-site-request.xml	2020-04-29 08:07:16.545807	708	EXECUTED	7:cad43e0e05e34f3ecd1f26a4274db917	createTable tableName=new_cors_site_request_received		\N	3.5.3	\N	\N	8147623451
1496184059218-3	heya	db/add-new-cors-site-request.xml	2020-04-29 08:07:16.555731	709	EXECUTED	7:68fb65c421d8ab745375c23e792ddd9f	addPrimaryKey constraintName=new_cors_site_request_pkey, tableName=new_cors_site_request		\N	3.5.3	\N	\N	8147623451
1496184059218-4	heya	db/add-new-cors-site-request.xml	2020-04-29 08:07:16.566716	710	EXECUTED	7:f0887741b04ea429142e61e78573b21d	addPrimaryKey constraintName=new_cors_site_request_received_pkey, tableName=new_cors_site_request_received		\N	3.5.3	\N	\N	8147623451
1496184059218-5	heya	db/add-new-cors-site-request.xml	2020-04-29 08:07:16.581682	711	EXECUTED	7:8405c4cf971f26a2173d8ccd51bc508a	addForeignKeyConstraint baseTableName=new_cors_site_request_received, constraintName=fk_new_cors_site_request_received_id, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1496184059218-6	heya	db/add-new-cors-site-request.xml	2020-04-29 08:07:16.590106	712	EXECUTED	7:a348975d756ec0ca74b1b7254c9306b8	addForeignKeyConstraint baseTableName=new_cors_site_request_received, constraintName=fk_new_cors_site_request_id, referencedTableName=new_cors_site_request		\N	3.5.3	\N	\N	8147623451
1498217709-1	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.617084	713	EXECUTED	7:a1bc3d5d56d41cf5d8fa340f93a67632	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1498217709-2	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.63588	714	EXECUTED	7:803f890b36d04955e1cd400cf4945708	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1498217709-3	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.647948	715	EXECUTED	7:6da1eb08e9c5865425a61b4e895a6078	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1498217709-4	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.656748	716	EXECUTED	7:b9e0e808f09390ae142851f469214904	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1498217709-5	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.665176	717	EXECUTED	7:ab83e13c6121e085bd6e113fa663d7c7	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1498217709-6	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.674625	718	EXECUTED	7:791db5f16853f812cf138a94a80c1c8a	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1498217709-7	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.690312	719	EXECUTED	7:8fa37f9bed22387a5635f4eb62ad3500	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_localepisodiceffect		\N	3.5.3	\N	\N	8147623451
1498217709-8	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.698086	720	EXECUTED	7:8c4ea0c2d07cdbb79c8fed9b54e6b60c	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_localepisodiceffect		\N	3.5.3	\N	\N	8147623451
1498217709-9	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.706141	721	EXECUTED	7:1dd93ef364eaf127a0a85e9a61148bc4	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1498217709-10	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.723963	722	EXECUTED	7:33a7e7d19dbafde8bab7d14b98ac2e53	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1498217709-11	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.730073	723	EXECUTED	7:208b3efbe0a046bbcf13134d313409c7	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1498217709-12	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.735918	724	EXECUTED	7:cd6fd2af1ff4cc27b2348fb82ea739ab	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1498217709-13	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.74136	725	EXECUTED	7:e7fad7acc8076a871bca0eabf2f12b14	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1498217709-14	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.746082	726	EXECUTED	7:88c97af13b636ba9a495df9e96b99333	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1498217709-15	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.750734	727	EXECUTED	7:145368bc283dad29d0f33fb65e50a1e3	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1498217709-16	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.755475	728	EXECUTED	7:ec62aa114ee68f579ed4eaf5f2668305	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1498217709-17	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.760491	729	EXECUTED	7:d5dedf4772fd2dbb6a75d49df8e053fd	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1498217709-18	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.765389	730	EXECUTED	7:cf01f5af1de1b7179a50c81335a2529d	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1498217709-19	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.770844	731	EXECUTED	7:75f79144864769f498dc71e0ce7fb930	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1498217709-20	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.776529	732	EXECUTED	7:c31c61a471aa121b35138c6f7f37fc63	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1498217709-21	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.781945	733	EXECUTED	7:1e617455fdbdc3e0820c2a82bb9c9fe8	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1498217709-22	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.787386	734	EXECUTED	7:afbc8f1910f329817aa890b989672d4d	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1498217709-23	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.792901	735	EXECUTED	7:44655e7fe017a2ce55c26a87ed168bd8	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1498217709-24	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.798371	736	EXECUTED	7:4831e2eb8c420cb6e1289c4ca6ed7520	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1498217709-25	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:16.804315	737	EXECUTED	7:1eb7613aa8b1b69090108b8bc81d8b8a	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1498217709-26	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:17.017684	738	EXECUTED	7:40af03646f36dadad1379081f37174a6	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1498217709-27	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:17.0263	739	EXECUTED	7:3f5c778fd488bf9e35a4c6e0f5b3d9ad	renameColumn newColumnName=deleted_reason, oldColumnName=delete_reason, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1498217709-28	lbodor	db/rename-change-tracking-columns.xml	2020-04-29 08:07:17.031851	740	EXECUTED	7:68322aac34229e76091d84e14f808acd	renameColumn newColumnName=date_deleted, oldColumnName=delete_time, tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1498218194-1	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.037742	741	EXECUTED	7:80768474508c038d72a0e0471b27526b	addColumn tableName=sitelog_mutlipathsource		\N	3.5.3	\N	\N	8147623451
1498218194-2	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.044594	742	EXECUTED	7:73f6d2fd721d62b4f4a80a179c65c2c8	addColumn tableName=sitelog_signalobstraction		\N	3.5.3	\N	\N	8147623451
1498218194-3	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.059016	743	EXECUTED	7:a159a59ba279ac9798d826bf9e00b51d	addColumn tableName=sitelog_radiointerference		\N	3.5.3	\N	\N	8147623451
1498218194-4	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.069824	744	EXECUTED	7:a9bb9aaeb9c767d459a3c5d3823734c5	addColumn tableName=sitelog_localepisodiceffect		\N	3.5.3	\N	\N	8147623451
1498218194-5	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.077094	745	EXECUTED	7:a08ddcf8c04c5be384ac7203d2735454	addColumn tableName=sitelog_otherinstrumentation		\N	3.5.3	\N	\N	8147623451
1498218194-6	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.08258	746	EXECUTED	7:864dc37e073771642423b28035e1ab78	addColumn tableName=sitelog_collocationinformation		\N	3.5.3	\N	\N	8147623451
1498218194-7	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.087687	747	EXECUTED	7:db89895e3aecc32932da1b2827c151ca	addColumn tableName=sitelog_frequencystandard		\N	3.5.3	\N	\N	8147623451
1498218194-8	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.092963	748	EXECUTED	7:862da85fbb7f9a042f6997c340599105	addColumn tableName=sitelog_gnssreceiver		\N	3.5.3	\N	\N	8147623451
1498218194-9	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.098427	749	EXECUTED	7:8b6a8a1218d3910b84188e57b40e2243	addColumn tableName=sitelog_watervaporsensor		\N	3.5.3	\N	\N	8147623451
1498218194-10	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.106149	750	EXECUTED	7:b1fb98e84ea8aec0ed2545f6ecf38cfc	addColumn tableName=sitelog_pressuresensor		\N	3.5.3	\N	\N	8147623451
1498218194-11	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.117031	751	EXECUTED	7:5326835c6c677bdd2b81e31ce403ec2d	addColumn tableName=sitelog_humiditysensor		\N	3.5.3	\N	\N	8147623451
1498218194-12	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.128807	752	EXECUTED	7:195a94e1da8ce882ecb1e3a706e46211	addColumn tableName=sitelog_surveyedlocaltie		\N	3.5.3	\N	\N	8147623451
1498218194-13	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.141123	753	EXECUTED	7:7c4eb08af3386728803b61379a6a07f3	addColumn tableName=sitelog_temperaturesensor		\N	3.5.3	\N	\N	8147623451
1498218194-14	lbodor	db/add-date-inserted-change-tracking-columns.xml	2020-04-29 08:07:17.14847	754	EXECUTED	7:ccff41d600ecb9e201c9cc82e250bd9b	addColumn tableName=sitelog_gnssantenna		\N	3.5.3	\N	\N	8147623451
1498879698295-1	lbodor (generated)	db/add-site-log-text-to-event.xml	2020-04-29 08:07:17.241238	755	EXECUTED	7:985f1c9a1e514c5c75e8a92ba80e5e3b	addColumn tableName=site_log_received		\N	3.5.3	\N	\N	8147623451
1499209951-0	lbodor	db/drop-not-null-constraint-from-site-in-network.xml	2020-04-29 08:07:17.247119	756	EXECUTED	7:fe1e840c0492dabac81db9ed1f3dbaa0	dropNotNullConstraint columnName=cors_site_id, tableName=cors_site_in_network		\N	3.5.3	\N	\N	8147623451
1499220892902-1	lbodor (generated)	db/cors-site-added-to-network.xml	2020-04-29 08:07:17.253674	757	EXECUTED	7:cc0940a52a5616a3e76c9894a03dc324	createTable tableName=cors_site_added_to_network		\N	3.5.3	\N	\N	8147623451
1499220892902-2	lbodor (generated)	db/cors-site-added-to-network.xml	2020-04-29 08:07:17.263404	758	EXECUTED	7:90472d30a5e8b21892467d67b7a7a88f	addPrimaryKey constraintName=cors_site_added_to_network_pkey, tableName=cors_site_added_to_network		\N	3.5.3	\N	\N	8147623451
1499220892902-3	lbodor (generated)	db/cors-site-added-to-network.xml	2020-04-29 08:07:17.278804	759	EXECUTED	7:d35830fe757c84225168e54bcda34534	addForeignKeyConstraint baseTableName=cors_site_added_to_network, constraintName=fk222urqk2qjbhph3rrxbtc7hsn, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1499925754606-1	lbodor (generated)	db/add-username-to-event.xml	2020-04-29 08:07:17.291428	760	EXECUTED	7:e59d2e02fddc368ae684e3884d2340db	addColumn tableName=domain_event		\N	3.5.3	\N	\N	8147623451
1507665831656-1	lbodor (generated)	db/add-sitelog-last-modified-date.xml	2020-04-29 08:07:17.302469	761	EXECUTED	7:d6cbcb8d3649eed86021cfd172961804	addColumn tableName=sitelog_site		\N	3.5.3	\N	\N	8147623451
1533698532	lbodor	db/init-cors-networks-versions.sql	2020-04-29 08:07:17.314584	762	EXECUTED	7:09696da3b3f52f488d38f6ec9e2c44de	sql		\N	3.5.3	\N	\N	8147623451
af2deba9-1226-47c4-a1e6-ddf7ada0dc28	lazar (generated)	db/rename-setup-name-column.xml	2020-04-29 08:07:17.327453	763	EXECUTED	7:4559862b5c8cdd48eb46ed14de5aae6a	renameColumn newColumnName=type, oldColumnName=name, tableName=setup		\N	3.5.3	\N	\N	8147623451
ed28f1be-2624-4a80-8407-3875eb79e44b	lbodor	db/rename-cors-setup-type.sql	2020-04-29 08:07:17.337391	764	EXECUTED	7:c94f36a7986b71c3f0551cf085076699	sql		\N	3.5.3	\N	\N	8147623451
1553667158-1	frankfu	db/add-cors-site-removed-from-network.xml	2020-04-29 08:07:17.34892	765	EXECUTED	7:7ff3110b691fe2fd735ac9465f46d9b3	createTable tableName=cors_site_removed_from_network		\N	3.5.3	\N	\N	8147623451
1553667158--2	frankfu	db/add-cors-site-removed-from-network.xml	2020-04-29 08:07:17.364166	766	EXECUTED	7:cab2f9cb1f0d341fe19128271833cd98	addPrimaryKey constraintName=cors_site_removed_from_network_pkey, tableName=cors_site_removed_from_network		\N	3.5.3	\N	\N	8147623451
1553667158-3	frankfu	db/add-cors-site-removed-from-network.xml	2020-04-29 08:07:17.375507	767	EXECUTED	7:7255166e1dc0c1e71034d4ade8a5e314	addForeignKeyConstraint baseTableName=cors_site_removed_from_network, constraintName=fk_domain_event_cors_site_removed_from_network, referencedTableName=domain_event		\N	3.5.3	\N	\N	8147623451
1555371779	lbodor	db/remove-srid-from-site-position.sql	2020-04-29 08:07:17.390844	768	EXECUTED	7:491d0bd2ea4f8e94fc9e92d15233c75b	sql		\N	3.5.3	\N	\N	8147623451
1574826014-1	frankfu	db/add-associated-document-table.xml	2020-04-29 08:07:17.422161	769	EXECUTED	7:2cff0fadc8baf35edf850b569fa5b260	createTable tableName=sitelog_associateddocument		\N	3.5.3	\N	\N	8147623451
1574826014-2	frankfu	db/add-associated-document-table.xml	2020-04-29 08:07:17.505991	770	EXECUTED	7:9fd2b73e0b9e20d6ce362af02cb00853	addPrimaryKey constraintName=pk_sitelog_associateddocument_id, tableName=sitelog_associateddocument; addForeignKeyConstraint baseTableName=sitelog_associateddocument, constraintName=fk_sitelog_site_sitelog_associateddocument, referencedTableName=s...		\N	3.5.3	\N	\N	8147623451
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
\.


--
-- Data for Name: domain_event; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.domain_event (event_name, id, error, retries, subscriber, time_handled, time_published, time_raised, username) FROM stdin;
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.equipment (equipment_type, id, manufacturer, serial_number, type, version) FROM stdin;
\.


--
-- Data for Name: equipment_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.equipment_configuration (equipment_configuration_id, equipment_id, configuration_time) FROM stdin;
\.


--
-- Data for Name: equipment_in_use; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.equipment_in_use (id, equipment_configuration_id, equipment_id, effective_from, effective_to, setup_id) FROM stdin;
\.


--
-- Data for Name: gnss_antenna_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.gnss_antenna_configuration (id, alignment_from_true_north, antenna_cable_length, antenna_cable_type, antenna_reference_point, marker_arp_east_eccentricity, marker_arp_north_eccentricity, marker_arp_up_eccentricity, notes, radome_serial_number, radome_type) FROM stdin;
\.


--
-- Data for Name: gnss_receiver_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.gnss_receiver_configuration (id, elevation_cutoff_setting, firmware_version, notes, satellite_system, temperature_stabilization) FROM stdin;
\.


--
-- Data for Name: humidity_sensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.humidity_sensor (aspiration, id) FROM stdin;
\.


--
-- Data for Name: humidity_sensor_configuration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.humidity_sensor_configuration (id, height_diff_to_antenna, notes) FROM stdin;
\.


--
-- Data for Name: invalid_site_log_received; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.invalid_site_log_received (site_log_text, id) FROM stdin;
\.


--
-- Data for Name: monument; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.monument (id, description, foundation, height, marker_description) FROM stdin;
\.


--
-- Data for Name: new_cors_site_request; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.new_cors_site_request (id, email, first_name, last_name, organisation, phone, "position", sitelog_data) FROM stdin;
\.


--
-- Data for Name: new_cors_site_request_received; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.new_cors_site_request_received (new_cors_site_request_id, id) FROM stdin;
\.


--
-- Data for Name: node; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.node (id, effective_from, effective_to, invalidated, setup_id, site_id, version) FROM stdin;
\.


--
-- Data for Name: position; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy."position" (id, as_at, datum_epsg_code, epoch, four_character_id, node_id, position_source_id, x, y) FROM stdin;
\.


--
-- Data for Name: setup; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.setup (id, effective_from, effective_to, invalidated, type, site_id) FROM stdin;
\.


--
-- Data for Name: site; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.site (id, date_installed, description, name, version, shape) FROM stdin;
\.


--
-- Data for Name: site_log_received; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.site_log_received (four_char_id, id, site_log_text) FROM stdin;
\.


--
-- Data for Name: site_updated; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.site_updated (four_character_id, id) FROM stdin;
\.


--
-- Data for Name: sitelog_associateddocument; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_associateddocument (id, name, file_reference, description, type, created_date, site_id) FROM stdin;
\.


--
-- Data for Name: sitelog_collocationinformation; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_collocationinformation (id, effective_from, effective_to, instrument_type, notes, status, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_frequencystandard; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_frequencystandard (id, effective_from, effective_to, input_frequency, notes, type, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_gnssantenna; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_gnssantenna (id, alignment_from_true_north, antenna_cable_length, antenna_cable_type, antenna_radome_type, antenna_reference_point, date_installed, date_removed, marker_arp_east_ecc, marker_arp_north_ecc, marker_arp_up_ecc, notes, radome_serial_number, serial_number, antenna_type, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_gnssreceiver; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_gnssreceiver (id, date_installed, date_removed, elevation_cutoff_setting, firmware_version, notes, satellite_system, serial_number, temperature_stabilization, receiver_type, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_humiditysensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_humiditysensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, accuracy_percent_rel_humidity, aspiration, data_sampling_interval, notes, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_localepisodiceffect; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_localepisodiceffect (id, event, site_id, effective_from, effective_to, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_mutlipathsource; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_mutlipathsource (id, site_id, deleted_reason, date_deleted, possible_problem_source, effective_from, effective_to, notes, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_otherinstrumentation; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_otherinstrumentation (id, effective_from, effective_to, instrumentation, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_pressuresensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_pressuresensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, accuracy_hpa, data_sampling_interval, notes, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_radiointerference; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_radiointerference (id, observed_degradation, site_id, deleted_reason, date_deleted, possible_problem_source, effective_from, effective_to, notes, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_responsible_party; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_responsible_party (id, site_id, responsible_party, responsible_role_id, index) FROM stdin;
\.


--
-- Data for Name: sitelog_responsible_party_role; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_responsible_party_role (id, responsible_role_name, responsible_role_xmltag) FROM stdin;
601	Site Owner	SiteOwner
651	Site Contact	SiteContact
701	Site Metadata Custodian	SiteMetadataCustodian
751	Site Data Center	SiteDataCenter
801	Site Data Source	SiteDataSource
\.


--
-- Data for Name: sitelog_signalobstraction; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_signalobstraction (id, site_id, deleted_reason, date_deleted, possible_problem_source, effective_from, effective_to, notes, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_site; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_site (id, entrydate, form_date_prepared, form_prepared_by, form_report_type, mi_antenna_graphics, mi_hard_copy_on_file, mi_horizontal_mask, mi_text_graphics_from_antenna, mi_monument_description, mi_notes, mi_primary_data_center, mi_secondary_data_center, mi_site_diagram, mi_site_map, mi_site_pictires, mi_url_for_more_information, bedrock_condition, bedrock_type, cdp_number, date_installed, distance_activity, fault_zones_nearby, foundation_depth, four_character_id, fracture_spacing, geologic_characteristic, height_of_monument, iers_domes_number, marker_description, monument_description, monument_foundation, monument_inscription, notes, site_name, elevation_grs80, itrf_x, itrf_y, itrf_z, city, country, location_notes, state, tectonic_plate, site_log_text, mi_doi, nine_character_id, cartesian_position, geodetic_position, last_date_modified) FROM stdin;
\.


--
-- Data for Name: sitelog_surveyedlocaltie; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_surveyedlocaltie (id, date_measured, dx, dy, dz, local_site_tie_accuracy, notes, survey_method, tied_marker_cdp_number, tied_marker_domes_number, tied_marker_name, tied_marker_usage, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_temperaturesensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_temperaturesensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, accurace_degree_celcius, aspiration, data_sampling_interval, notes, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: sitelog_watervaporsensor; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.sitelog_watervaporsensor (id, callibration_date, effective_from, effective_to, height_diff_to_antenna, manufacturer, serial_number, type, distance_to_antenna, notes, site_id, deleted_reason, date_deleted, date_inserted) FROM stdin;
\.


--
-- Data for Name: user_registration; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.user_registration (id, email, first_name, last_name, organisation, phone, "position", remarks) FROM stdin;
\.


--
-- Data for Name: user_registration_received; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.user_registration_received (user_registration_id, id) FROM stdin;
\.


--
-- Data for Name: weekly_solution; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.weekly_solution (id, as_at, epoch, sinex_file_name) FROM stdin;
\.


--
-- Data for Name: weekly_solution_available; Type: TABLE DATA; Schema: geodesy; Owner: geodesy
--

COPY geodesy.weekly_solution_available (weekly_solution_id, id) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys  FROM stdin;
\.


--
-- Name: seq_event; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_event', 1, false);


--
-- Name: seq_sitelogantenna; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogantenna', 1, false);


--
-- Name: seq_sitelogassociateddocument; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogassociateddocument', 1, false);


--
-- Name: seq_sitelogcollocationinfo; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogcollocationinfo', 1, false);


--
-- Name: seq_sitelogfrequencystandard; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogfrequencystandard', 1, false);


--
-- Name: seq_siteloghumiditysensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_siteloghumiditysensor', 1, false);


--
-- Name: seq_siteloglocalepisodiceffect; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_siteloglocalepisodiceffect', 1, false);


--
-- Name: seq_siteloglocaltie; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_siteloglocaltie', 1, false);


--
-- Name: seq_sitelogmultipathsource; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogmultipathsource', 1, false);


--
-- Name: seq_sitelogotherinstrument; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogotherinstrument', 1, false);


--
-- Name: seq_sitelogpressuresensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogpressuresensor', 1, false);


--
-- Name: seq_sitelogradiointerference; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogradiointerference', 1, false);


--
-- Name: seq_sitelogreceiver; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogreceiver', 1, false);


--
-- Name: seq_sitelogsignalobstruction; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogsignalobstruction', 1, false);


--
-- Name: seq_sitelogsite; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogsite', 1, false);


--
-- Name: seq_sitelogtemperaturesensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogtemperaturesensor', 1, false);


--
-- Name: seq_sitelogwatervaporsensor; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_sitelogwatervaporsensor', 1, false);


--
-- Name: seq_surrogate_keys; Type: SEQUENCE SET; Schema: geodesy; Owner: geodesy
--

SELECT pg_catalog.setval('geodesy.seq_surrogate_keys', 801, true);


--
-- Name: cors_site_added_to_network cors_site_added_to_network_pkey; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_added_to_network
    ADD CONSTRAINT cors_site_added_to_network_pkey PRIMARY KEY (id);


--
-- Name: cors_site_removed_from_network cors_site_removed_from_network_pkey; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_removed_from_network
    ADD CONSTRAINT cors_site_removed_from_network_pkey PRIMARY KEY (id);


--
-- Name: new_cors_site_request new_cors_site_request_pkey; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.new_cors_site_request
    ADD CONSTRAINT new_cors_site_request_pkey PRIMARY KEY (id);


--
-- Name: new_cors_site_request_received new_cors_site_request_received_pkey; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.new_cors_site_request_received
    ADD CONSTRAINT new_cors_site_request_received_pkey PRIMARY KEY (id);


--
-- Name: clock_configuration pk_clock_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.clock_configuration
    ADD CONSTRAINT pk_clock_configuration_id PRIMARY KEY (id);


--
-- Name: cors_site pk_cors_site_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site
    ADD CONSTRAINT pk_cors_site_id PRIMARY KEY (id);


--
-- Name: cors_site_in_network pk_cors_site_in_network_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_in_network
    ADD CONSTRAINT pk_cors_site_in_network_id PRIMARY KEY (id);


--
-- Name: cors_site_network pk_cors_site_network_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_network
    ADD CONSTRAINT pk_cors_site_network_id PRIMARY KEY (id);


--
-- Name: databasechangeloglock pk_databasechangeloglock_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.databasechangeloglock
    ADD CONSTRAINT pk_databasechangeloglock_id PRIMARY KEY (id);


--
-- Name: domain_event pk_domain_event_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.domain_event
    ADD CONSTRAINT pk_domain_event_id PRIMARY KEY (id);


--
-- Name: equipment_configuration pk_equipment_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.equipment_configuration
    ADD CONSTRAINT pk_equipment_configuration_id PRIMARY KEY (equipment_configuration_id);


--
-- Name: equipment pk_equipment_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.equipment
    ADD CONSTRAINT pk_equipment_id PRIMARY KEY (id);


--
-- Name: equipment_in_use pk_equipment_in_use_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.equipment_in_use
    ADD CONSTRAINT pk_equipment_in_use_id PRIMARY KEY (id);


--
-- Name: gnss_antenna_configuration pk_gnss_antenna_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.gnss_antenna_configuration
    ADD CONSTRAINT pk_gnss_antenna_configuration_id PRIMARY KEY (id);


--
-- Name: gnss_receiver_configuration pk_gnss_receiver_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.gnss_receiver_configuration
    ADD CONSTRAINT pk_gnss_receiver_configuration_id PRIMARY KEY (id);


--
-- Name: humidity_sensor_configuration pk_humidity_sensor_configuration_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.humidity_sensor_configuration
    ADD CONSTRAINT pk_humidity_sensor_configuration_id PRIMARY KEY (id);


--
-- Name: humidity_sensor pk_humidity_sensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.humidity_sensor
    ADD CONSTRAINT pk_humidity_sensor_id PRIMARY KEY (id);


--
-- Name: invalid_site_log_received pk_invalid_site_log_received_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.invalid_site_log_received
    ADD CONSTRAINT pk_invalid_site_log_received_id PRIMARY KEY (id);


--
-- Name: monument pk_monument_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.monument
    ADD CONSTRAINT pk_monument_id PRIMARY KEY (id);


--
-- Name: node pk_node_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.node
    ADD CONSTRAINT pk_node_id PRIMARY KEY (id);


--
-- Name: position pk_position_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy."position"
    ADD CONSTRAINT pk_position_id PRIMARY KEY (id);


--
-- Name: setup pk_setup_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.setup
    ADD CONSTRAINT pk_setup_id PRIMARY KEY (id);


--
-- Name: site pk_site_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.site
    ADD CONSTRAINT pk_site_id PRIMARY KEY (id);


--
-- Name: site_log_received pk_site_log_received_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.site_log_received
    ADD CONSTRAINT pk_site_log_received_id PRIMARY KEY (id);


--
-- Name: site_updated pk_site_updated_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.site_updated
    ADD CONSTRAINT pk_site_updated_id PRIMARY KEY (id);


--
-- Name: sitelog_associateddocument pk_sitelog_associateddocument_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_associateddocument
    ADD CONSTRAINT pk_sitelog_associateddocument_id PRIMARY KEY (id);


--
-- Name: sitelog_collocationinformation pk_sitelog_collocationinformation_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_collocationinformation
    ADD CONSTRAINT pk_sitelog_collocationinformation_id PRIMARY KEY (id);


--
-- Name: sitelog_frequencystandard pk_sitelog_frequencystandard_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_frequencystandard
    ADD CONSTRAINT pk_sitelog_frequencystandard_id PRIMARY KEY (id);


--
-- Name: sitelog_gnssantenna pk_sitelog_gnssantenna_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_gnssantenna
    ADD CONSTRAINT pk_sitelog_gnssantenna_id PRIMARY KEY (id);


--
-- Name: sitelog_gnssreceiver pk_sitelog_gnssreceiver_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_gnssreceiver
    ADD CONSTRAINT pk_sitelog_gnssreceiver_id PRIMARY KEY (id);


--
-- Name: sitelog_humiditysensor pk_sitelog_humiditysensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_humiditysensor
    ADD CONSTRAINT pk_sitelog_humiditysensor_id PRIMARY KEY (id);


--
-- Name: sitelog_localepisodiceffect pk_sitelog_localepisodiceffect_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_localepisodiceffect
    ADD CONSTRAINT pk_sitelog_localepisodiceffect_id PRIMARY KEY (id);


--
-- Name: sitelog_mutlipathsource pk_sitelog_mutlipathsource_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_mutlipathsource
    ADD CONSTRAINT pk_sitelog_mutlipathsource_id PRIMARY KEY (id);


--
-- Name: sitelog_otherinstrumentation pk_sitelog_otherinstrumentation_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_otherinstrumentation
    ADD CONSTRAINT pk_sitelog_otherinstrumentation_id PRIMARY KEY (id);


--
-- Name: sitelog_pressuresensor pk_sitelog_pressuresensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_pressuresensor
    ADD CONSTRAINT pk_sitelog_pressuresensor_id PRIMARY KEY (id);


--
-- Name: sitelog_radiointerference pk_sitelog_radiointerference_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_radiointerference
    ADD CONSTRAINT pk_sitelog_radiointerference_id PRIMARY KEY (id);


--
-- Name: sitelog_responsible_party pk_sitelog_responsible_party_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_responsible_party
    ADD CONSTRAINT pk_sitelog_responsible_party_id PRIMARY KEY (id);


--
-- Name: sitelog_responsible_party_role pk_sitelog_responsible_party_role_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_responsible_party_role
    ADD CONSTRAINT pk_sitelog_responsible_party_role_id PRIMARY KEY (id);


--
-- Name: sitelog_signalobstraction pk_sitelog_signalobstraction_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_signalobstraction
    ADD CONSTRAINT pk_sitelog_signalobstraction_id PRIMARY KEY (id);


--
-- Name: sitelog_site pk_sitelog_site_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_site
    ADD CONSTRAINT pk_sitelog_site_id PRIMARY KEY (id);


--
-- Name: sitelog_surveyedlocaltie pk_sitelog_surveyedlocaltie_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_surveyedlocaltie
    ADD CONSTRAINT pk_sitelog_surveyedlocaltie_id PRIMARY KEY (id);


--
-- Name: sitelog_temperaturesensor pk_sitelog_temperaturesensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_temperaturesensor
    ADD CONSTRAINT pk_sitelog_temperaturesensor_id PRIMARY KEY (id);


--
-- Name: sitelog_watervaporsensor pk_sitelog_watervaporsensor_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_watervaporsensor
    ADD CONSTRAINT pk_sitelog_watervaporsensor_id PRIMARY KEY (id);


--
-- Name: weekly_solution_available pk_weekly_solution_available_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.weekly_solution_available
    ADD CONSTRAINT pk_weekly_solution_available_id PRIMARY KEY (id);


--
-- Name: weekly_solution pk_weekly_solution_id; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.weekly_solution
    ADD CONSTRAINT pk_weekly_solution_id PRIMARY KEY (id);


--
-- Name: cors_site_network uc_cors_network_name; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_network
    ADD CONSTRAINT uc_cors_network_name UNIQUE (name);


--
-- Name: cors_site uk_cors_site_four_characterid; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site
    ADD CONSTRAINT uk_cors_site_four_characterid UNIQUE (four_character_id);


--
-- Name: sitelog_associateddocument uk_sitelog_associateddocument_filereference; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_associateddocument
    ADD CONSTRAINT uk_sitelog_associateddocument_filereference UNIQUE (file_reference) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sitelog_associateddocument uk_sitelog_associateddocument_name; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_associateddocument
    ADD CONSTRAINT uk_sitelog_associateddocument_name UNIQUE (name) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_registration user_registration_pkey; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.user_registration
    ADD CONSTRAINT user_registration_pkey PRIMARY KEY (id);


--
-- Name: user_registration_received user_registration_received_pkey; Type: CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.user_registration_received
    ADD CONSTRAINT user_registration_received_pkey PRIMARY KEY (id);


--
-- Name: cors_site_added_to_network fk222urqk2qjbhph3rrxbtc7hsn; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_added_to_network
    ADD CONSTRAINT fk222urqk2qjbhph3rrxbtc7hsn FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: clock_configuration fk_clock_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.clock_configuration
    ADD CONSTRAINT fk_clock_configuration_id FOREIGN KEY (id) REFERENCES geodesy.equipment_configuration(equipment_configuration_id);


--
-- Name: cors_site fk_cors_site_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site
    ADD CONSTRAINT fk_cors_site_id FOREIGN KEY (id) REFERENCES geodesy.site(id);


--
-- Name: cors_site_in_network fk_cors_site_in_network_networkid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_in_network
    ADD CONSTRAINT fk_cors_site_in_network_networkid FOREIGN KEY (cors_site_network_id) REFERENCES geodesy.cors_site_network(id);


--
-- Name: cors_site_in_network fk_cors_site_in_network_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_in_network
    ADD CONSTRAINT fk_cors_site_in_network_siteid FOREIGN KEY (cors_site_id) REFERENCES geodesy.cors_site(id);


--
-- Name: cors_site fk_cors_site_monument; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site
    ADD CONSTRAINT fk_cors_site_monument FOREIGN KEY (monument_id) REFERENCES geodesy.monument(id);


--
-- Name: cors_site_removed_from_network fk_domain_event_cors_site_removed_from_network; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.cors_site_removed_from_network
    ADD CONSTRAINT fk_domain_event_cors_site_removed_from_network FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: equipment_configuration fk_equipment_configuration_equipment_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.equipment_configuration
    ADD CONSTRAINT fk_equipment_configuration_equipment_id FOREIGN KEY (equipment_id) REFERENCES geodesy.equipment(id);


--
-- Name: equipment_in_use fk_equipment_in_use_equipment_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.equipment_in_use
    ADD CONSTRAINT fk_equipment_in_use_equipment_configuration_id FOREIGN KEY (equipment_configuration_id) REFERENCES geodesy.equipment_configuration(equipment_configuration_id);


--
-- Name: equipment_in_use fk_equipment_in_use_equipmentid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.equipment_in_use
    ADD CONSTRAINT fk_equipment_in_use_equipmentid FOREIGN KEY (equipment_id) REFERENCES geodesy.equipment(id);


--
-- Name: equipment_in_use fk_equipment_in_use_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.equipment_in_use
    ADD CONSTRAINT fk_equipment_in_use_id FOREIGN KEY (setup_id) REFERENCES geodesy.setup(id);


--
-- Name: gnss_antenna_configuration fk_gnss_antenna_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.gnss_antenna_configuration
    ADD CONSTRAINT fk_gnss_antenna_configuration_id FOREIGN KEY (id) REFERENCES geodesy.equipment_configuration(equipment_configuration_id);


--
-- Name: gnss_receiver_configuration fk_gnss_receiver_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.gnss_receiver_configuration
    ADD CONSTRAINT fk_gnss_receiver_configuration_id FOREIGN KEY (id) REFERENCES geodesy.equipment_configuration(equipment_configuration_id);


--
-- Name: humidity_sensor_configuration fk_humidity_sensor_configuration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.humidity_sensor_configuration
    ADD CONSTRAINT fk_humidity_sensor_configuration_id FOREIGN KEY (id) REFERENCES geodesy.equipment_configuration(equipment_configuration_id);


--
-- Name: humidity_sensor fk_humidity_sensor_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.humidity_sensor
    ADD CONSTRAINT fk_humidity_sensor_id FOREIGN KEY (id) REFERENCES geodesy.equipment(id);


--
-- Name: invalid_site_log_received fk_invalid_site_log_received_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.invalid_site_log_received
    ADD CONSTRAINT fk_invalid_site_log_received_id FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: new_cors_site_request_received fk_new_cors_site_request_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.new_cors_site_request_received
    ADD CONSTRAINT fk_new_cors_site_request_id FOREIGN KEY (new_cors_site_request_id) REFERENCES geodesy.new_cors_site_request(id);


--
-- Name: new_cors_site_request_received fk_new_cors_site_request_received_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.new_cors_site_request_received
    ADD CONSTRAINT fk_new_cors_site_request_received_id FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: setup fk_setup_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.setup
    ADD CONSTRAINT fk_setup_siteid FOREIGN KEY (site_id) REFERENCES geodesy.site(id);


--
-- Name: site_log_received fk_site_log_received_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.site_log_received
    ADD CONSTRAINT fk_site_log_received_id FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: site_updated fk_site_updated_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.site_updated
    ADD CONSTRAINT fk_site_updated_id FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: sitelog_collocationinformation fk_sitelog_collocationinformation_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_collocationinformation
    ADD CONSTRAINT fk_sitelog_collocationinformation_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_frequencystandard fk_sitelog_frequencystandard_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_frequencystandard
    ADD CONSTRAINT fk_sitelog_frequencystandard_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_gnssantenna fk_sitelog_gnssantenna_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_gnssantenna
    ADD CONSTRAINT fk_sitelog_gnssantenna_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_gnssreceiver fk_sitelog_gnssreceiver_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_gnssreceiver
    ADD CONSTRAINT fk_sitelog_gnssreceiver_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_humiditysensor fk_sitelog_humiditysensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_humiditysensor
    ADD CONSTRAINT fk_sitelog_humiditysensor_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_mutlipathsource fk_sitelog_mutlipathsource_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_mutlipathsource
    ADD CONSTRAINT fk_sitelog_mutlipathsource_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_otherinstrumentation fk_sitelog_otherinstrumentation_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_otherinstrumentation
    ADD CONSTRAINT fk_sitelog_otherinstrumentation_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_pressuresensor fk_sitelog_pressuresensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_pressuresensor
    ADD CONSTRAINT fk_sitelog_pressuresensor_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_radiointerference fk_sitelog_radiointerference_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_radiointerference
    ADD CONSTRAINT fk_sitelog_radiointerference_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_responsible_party fk_sitelog_responsible_party_responsible_roleid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_responsible_party
    ADD CONSTRAINT fk_sitelog_responsible_party_responsible_roleid FOREIGN KEY (responsible_role_id) REFERENCES geodesy.sitelog_responsible_party_role(id);


--
-- Name: sitelog_responsible_party fk_sitelog_responsible_party_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_responsible_party
    ADD CONSTRAINT fk_sitelog_responsible_party_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_signalobstraction fk_sitelog_signalobstraction_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_signalobstraction
    ADD CONSTRAINT fk_sitelog_signalobstraction_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_associateddocument fk_sitelog_site_sitelog_associateddocument; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_associateddocument
    ADD CONSTRAINT fk_sitelog_site_sitelog_associateddocument FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_localepisodiceffect fk_sitelog_site_sitelog_localepisodiceffect; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_localepisodiceffect
    ADD CONSTRAINT fk_sitelog_site_sitelog_localepisodiceffect FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_surveyedlocaltie fk_sitelog_surveyedlocaltie_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_surveyedlocaltie
    ADD CONSTRAINT fk_sitelog_surveyedlocaltie_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_temperaturesensor fk_sitelog_temperaturesensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_temperaturesensor
    ADD CONSTRAINT fk_sitelog_temperaturesensor_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: sitelog_watervaporsensor fk_sitelog_watervaporsensor_siteid; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.sitelog_watervaporsensor
    ADD CONSTRAINT fk_sitelog_watervaporsensor_siteid FOREIGN KEY (site_id) REFERENCES geodesy.sitelog_site(id);


--
-- Name: user_registration_received fk_user_registration_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.user_registration_received
    ADD CONSTRAINT fk_user_registration_id FOREIGN KEY (user_registration_id) REFERENCES geodesy.user_registration(id);


--
-- Name: user_registration_received fk_user_registration_received_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.user_registration_received
    ADD CONSTRAINT fk_user_registration_received_id FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: weekly_solution_available fk_weekly_solution_avaliable_id; Type: FK CONSTRAINT; Schema: geodesy; Owner: geodesy
--

ALTER TABLE ONLY geodesy.weekly_solution_available
    ADD CONSTRAINT fk_weekly_solution_avaliable_id FOREIGN KEY (id) REFERENCES geodesy.domain_event(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

