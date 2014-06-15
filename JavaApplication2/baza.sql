--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.4
-- Dumped by pg_dump version 9.3.1
-- Started on 2014-06-15 23:23:18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 193 (class 3079 OID 11755)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2100 (class 0 OID 0)
-- Dependencies: 193
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 194 (class 3079 OID 16385)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 2101 (class 0 OID 0)
-- Dependencies: 194
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- TOC entry 593 (class 1247 OID 16855)
-- Name: active_prescription; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE active_prescription AS (
	prescription_id integer,
	doctor_id integer,
	doctor_name character varying(255),
	doctor_address character varying(255),
	doctor_license_number integer,
	prescription_owner_id integer,
	drug_id integer,
	dosage integer,
	max_dosage integer,
	unit integer,
	quantity integer,
	execution integer,
	time_of_execution date
);


ALTER TYPE public.active_prescription OWNER TO postgres;

--
-- TOC entry 596 (class 1247 OID 16858)
-- Name: active_prescriptions; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE active_prescriptions AS (
	prescription_id integer,
	doctor_id integer,
	doctor_name character varying(255),
	doctor_address character varying(255),
	doctor_license_number integer,
	prescription_owner_id integer,
	drug_id integer,
	dosage integer,
	max_dosage integer,
	unit character varying(255),
	quantity integer
);


ALTER TYPE public.active_prescriptions OWNER TO postgres;

--
-- TOC entry 599 (class 1247 OID 16861)
-- Name: holder; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE holder AS (
	medicineid integer,
	name text,
	prescription_requirement boolean,
	medicine_type text,
	maximum_dosage integer,
	unit text
);


ALTER TYPE public.holder OWNER TO postgres;

--
-- TOC entry 602 (class 1247 OID 16864)
-- Name: medicine_holder; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE medicine_holder AS (
	medicineid integer,
	name character varying(255),
	prescription_requirement boolean,
	medicine_type character varying(255),
	maximum_dosage integer,
	unit character varying(255)
);


ALTER TYPE public.medicine_holder OWNER TO postgres;

--
-- TOC entry 605 (class 1247 OID 16867)
-- Name: prescription_history; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE prescription_history AS (
	prescription_id integer,
	doctor_id integer,
	doctor_name character varying(255),
	doctor_address character varying(255),
	doctor_license_number integer,
	prescription_owner_id integer,
	drug_id integer,
	dosage integer,
	max_dosage integer,
	unit character varying(255),
	quantity integer,
	execution boolean,
	time_of_execution date,
	pharmacy_id integer,
	pharmacy_name character varying(255),
	pharmacy_adress character varying(255)
);


ALTER TYPE public.prescription_history OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 16945)
-- Name: browse_active_prescriptions(integer, integer, bytea, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION browse_active_prescriptions(integer, integer, bytea, bytea) RETURNS SETOF active_prescriptions
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		lv_to_hash bytea;
		lv_hash text;
		lv_nonce bigint;
		lv_public_key text;
		lv_signed_hash text;
	BEGIN
	lv_nonce := nonce FROM "Pharmacist" WHERE id = $1;

	lv_to_hash := 'browse_active_prescrptions' ||  $1 || $2 || lv_nonce;
	
	lv_hash := sha1(lv_to_hash);

	--PERFORM dump_hash(lv_hash);

	--lv_temp_signature := (SELECT system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig'));

	PERFORM dump_sig($3);
	lv_public_key := public_key FROM "Pharmacist" WHERE id = $1;
	PERFORM dump_key(lv_public_key);
	PERFORM system('bash /fixkey.sh');
	lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
	
	IF lv_signed_hash != lv_hash THEN
		RETURN;
	END IF;

	PERFORM dump_sig($4);
	lv_public_key := public_key FROM "Patient" WHERE id = $2;
	PERFORM dump_key(public_key);
	PERFORM system('bash /fixkey.sh');
	lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
	IF lv_signed_hash != lv_hash THEN
		RETURN;
	END IF;

		RETURN QUERY 
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				(p.quantity - GREATEST(0, (SELECT SUM(pe1.quantity) from "Prescription_execution" pe1 where pe1.prescription_id = p.id)::integer)) as "quan"
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p
				LEFT JOIN "Prescription_execution" pe on pe.prescription_id=p.id
				WHERE p.doctor_id = dc.id 
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND p.owner_id = $2
				GROUP BY p.id, dc.name, dc.address, dc.license_number, d.max_dosage, u.unit_name, "quan"
				) as pres_history
				WHERE pres_history.quan > 0
				;

	END;
$_$;


ALTER FUNCTION public.browse_active_prescriptions(integer, integer, bytea, bytea) OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 16868)
-- Name: Doctor_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Doctor_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Doctor_ID_seq" OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 184 (class 1259 OID 16886)
-- Name: Doctor; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Doctor" (
    id integer DEFAULT nextval('"Doctor_ID_seq"'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    license_number integer NOT NULL,
    nonce bigint NOT NULL,
    certificate bytea NOT NULL,
    private_key text,
    public_key text
);


ALTER TABLE public."Doctor" OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16946)
-- Name: browse_doctors(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION browse_doctors(text DEFAULT ''::text, text DEFAULT ''::text, integer DEFAULT NULL::integer) RETURNS SETOF "Doctor"
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		license text;
	BEGIN
		IF $3 is not null
		THEN
			license:= CAST($3 as TEXT);
		ELSE
			license := '';
		END IF;
		RETURN QUERY SELECT * FROM "Doctor" d
			WHERE d.name like '%' || $1 || '%'
			AND d.address like '%' || $2 || '%'
			AND CAST(d.license_number AS TEXT) like '%' || '' || '%';
	END;
$_$;


ALTER FUNCTION public.browse_doctors(text, text, integer) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16947)
-- Name: browse_medicines(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION browse_medicines(text DEFAULT ''::text, text DEFAULT ''::text) RETURNS SETOF medicine_holder
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN QUERY SELECT d.id, d.name, d.prescription_requirement, dt.type, d.max_dosage, du.unit_name FROM "Drug" d, "Drug_type" dt, "Drug_unit" du
			WHERE d.name like '%' || $1 || '%' and
			dt.type like '%' || $2 || '%' and
			d.type = dt.id and d.unit = du.id;
	END;
$_$;


ALTER FUNCTION public.browse_medicines(text, text) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16948)
-- Name: browse_my_prescriptions_history(integer, boolean, date, date, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION browse_my_prescriptions_history(integer, boolean DEFAULT NULL::boolean, date DEFAULT NULL::date, date DEFAULT NULL::date, bytea DEFAULT NULL::bytea) RETURNS SETOF prescription_history
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		execution boolean;
		start_date date;
		end_date date;
		lv_to_hash bytea;
		lv_hash text;
		lv_nonce bigint;
		lv_public_key text;
		lv_signed_hash text;
	BEGIN
		lv_nonce := nonce FROM "Patient" WHERE id = $1;

	lv_to_hash := 'browse_my_prescriptions_history' ||  $1 || $2 || $3 || $4 || lv_nonce;
	
	lv_hash := sha1(lv_to_hash);

	PERFORM dump_hash(lv_hash);

	--lv_temp_signature := (SELECT system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig'));

	PERFORM dump_sig($5);
	lv_public_key := public_key FROM "Patient" WHERE id = $1;
	PERFORM dump_key(lv_public_key);
	PERFORM system('bash /fixkey.sh');
	--lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
	lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig -pubin'));
	IF lv_signed_hash != lv_hash THEN
		RETURN;
	ELSE
	
		IF $3 is not null
		THEN
			start_date:= $3;
		ELSE
			start_date := DATE '1970-10-05';
		END IF;
		IF $4 is not null
		THEN
			end_date:= $4;
		ELSE
			end_date := now();
		END IF;

		IF $2 is true
		THEN
				
			RETURN QUERY 
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				pe.quantity as "quan", 
				true, pe.time, pe.pharmacist_id, ph.name, ph.address
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p, "Prescription_execution" pe, "Pharmacist" ph
				WHERE p.doctor_id = dc.id 
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND (p.patient_id = $1 OR p.owner_id = $1)
				AND pe.prescription_id=p.id
				AND pe.pharmacist_id = ph.id
				) as pres_history
				WHERE pres_history.quan > 0
				
			UNION
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				(p.quantity - GREATEST(0, (SELECT SUM(pe1.quantity) from "Prescription_execution" pe1 where pe1.prescription_id = p.id)::integer)) as "quan", 
				false, null::DATE, null::integer, null::varchar(255), null::varchar(255)
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p
				LEFT JOIN "Prescription_execution" pe on pe.id=p.id
				WHERE p.doctor_id = dc.id 
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND (p.patient_id = $1 OR p.owner_id = $1)
				GROUP BY p.id, dc.name, dc.address, dc.license_number, d.max_dosage, u.unit_name, "quan"
				) as pres_history
				WHERE pres_history.quan > 0
				;

		ELSE

			RETURN QUERY 
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				(p.quantity - GREATEST(0, (SELECT SUM(pe1.quantity) from "Prescription_execution" pe1 where pe1.prescription_id = p.id)::integer)) as "quan", 
				false, null::DATE, null::integer, null::varchar(255), null::varchar(255)
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p
				LEFT JOIN "Prescription_execution" pe on pe.prescription_id=p.id
				WHERE p.doctor_id = dc.id 
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND (p.patient_id = $1 OR p.owner_id = $1)
				GROUP BY p.id, dc.name, dc.address, dc.license_number, d.max_dosage, u.unit_name, "quan"
				) as pres_history
				WHERE pres_history.quan > 0
				;
		END IF;
	END IF;
	END;
$_$;


ALTER FUNCTION public.browse_my_prescriptions_history(integer, boolean, date, date, bytea) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16949)
-- Name: browse_patient_prescription_history(integer, integer, date, date, boolean, bytea, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION browse_patient_prescription_history(integer, integer, date DEFAULT NULL::date, date DEFAULT NULL::date, boolean DEFAULT NULL::boolean, bytea DEFAULT NULL::bytea, bytea DEFAULT NULL::bytea) RETURNS SETOF prescription_history
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		execution boolean;
		start_date date;
		end_date date;
		lv_to_hash bytea;
		lv_hash text;
		lv_nonce bigint;
		lv_public_key text;
		lv_signed_hash text;
	BEGIN
		lv_nonce := nonce FROM "Doctor" WHERE id = $1;

	lv_to_hash := 'browse_my_prescrptions_history' ||  $1 || $2 || $3 || $4 || $5 || lv_nonce;
	
	lv_hash := sha1(lv_to_hash);
	

	--lv_temp_signature := (SELECT system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig'));

	PERFORM dump_sig($6);
	lv_public_key := public_key FROM "Patient" WHERE id = $1;
	PERFORM dump_key(lv_public_key);
	PERFORM system('bash /fixkey.sh');
	lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
	
	IF lv_signed_hash != lv_hash THEN
		RETURN;
	END IF;

	
	PERFORM dump_sig($7);
	lv_public_key := public_key FROM "Doctor" WHERE id = $2;
	PERFORM dump_key(lv_public_key);
	PERFORM system('bash /fixkey.sh');
	lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
	
	IF lv_signed_hash != lv_hash THEN
		RETURN;
	END IF;

		IF $3 is not null
		THEN
			start_date:= $3;
		ELSE
			start_date := DATE '1970-10-05';
		END IF;
		IF $4 is not null
		THEN
			end_date:= $4;
		ELSE
			end_date := now();
		END IF;

		IF $5 is true
		THEN
				
			RETURN QUERY 
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				pe.quantity as "quan", 
				true, pe.time, pe.pharmacist_id, ph.name, ph.address
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p, "Prescription_execution" pe, "Pharmacist" ph
				WHERE p.doctor_id = dc.id 
				AND p.doctor_id = $1
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND p.patient_id = $2
				AND pe.prescription_id=p.id
				AND pe.pharmacist_id = ph.id
				) as pres_history
				WHERE pres_history.quan > 0
				
			UNION
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				(p.quantity - GREATEST(0, (SELECT SUM(pe1.quantity) from "Prescription_execution" pe1 where pe1.prescription_id = p.id)::integer)) as "quan", 
				false, null::DATE, null::integer, null::varchar(255), null::varchar(255)
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p
				LEFT JOIN "Prescription_execution" pe on pe.id=p.id
				WHERE p.doctor_id = dc.id 
				AND p.doctor_id = $1
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND p.patient_id = $2
				GROUP BY p.id, dc.name, dc.address, dc.license_number, d.max_dosage, u.unit_name, "quan"
				) as pres_history
				WHERE pres_history.quan > 0
				;

		ELSE

			RETURN QUERY 
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				(p.quantity - GREATEST(0, (SELECT SUM(pe1.quantity) from "Prescription_execution" pe1 where pe1.prescription_id = p.id)::integer)) as "quan", 
				false, null::DATE, null::integer, null::varchar(255), null::varchar(255)
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p
				LEFT JOIN "Prescription_execution" pe on pe.prescription_id=p.id
				WHERE p.doctor_id = dc.id 
				AND p.doctor_id = $1
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND p.patient_id = $2
				GROUP BY p.id, dc.name, dc.address, dc.license_number, d.max_dosage, u.unit_name, "quan"
				) as pres_history
				WHERE pres_history.quan > 0
				;
		END IF;

	END;
$_$;


ALTER FUNCTION public.browse_patient_prescription_history(integer, integer, date, date, boolean, bytea, bytea) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 16968)
-- Name: browse_patient_prescription_history2(integer, integer, date, date, boolean, bytea, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION browse_patient_prescription_history2(integer, integer, date DEFAULT NULL::date, date DEFAULT NULL::date, boolean DEFAULT NULL::boolean, bytea DEFAULT NULL::bytea, bytea DEFAULT NULL::bytea) RETURNS SETOF prescription_history
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		execution boolean;
		start_date date;
		end_date date;
		lv_to_hash bytea;
		lv_hash text;
		lv_nonce bigint;
		lv_public_key text;
		lv_signed_hash text;
	BEGIN
		

		IF $3 is not null
		THEN
			start_date:= $3;
		ELSE
			start_date := DATE '1970-10-05';
		END IF;
		IF $4 is not null
		THEN
			end_date:= $4;
		ELSE
			end_date := now();
		END IF;

		IF $5 is true
		THEN
				
			RETURN QUERY 
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				pe.quantity as "quan", 
				true, pe.time, pe.pharmacist_id, ph.name, ph.address
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p, "Prescription_execution" pe, "Pharmacist" ph
				WHERE p.doctor_id = dc.id 
				AND p.doctor_id = $1
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND p.patient_id = $2
				AND pe.prescription_id=p.id
				AND pe.pharmacist_id = ph.id
				) as pres_history
				WHERE pres_history.quan > 0
				
			UNION
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				(p.quantity - GREATEST(0, (SELECT SUM(pe1.quantity) from "Prescription_execution" pe1 where pe1.prescription_id = p.id)::integer)) as "quan", 
				false, null::DATE, null::integer, null::varchar(255), null::varchar(255)
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p
				LEFT JOIN "Prescription_execution" pe on pe.id=p.id
				WHERE p.doctor_id = dc.id 
				AND p.doctor_id = $1
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND p.patient_id = $2
				--GROUP BY p.id, dc.name, dc.address, dc.license_number, d.max_dosage, u.unit_name, "quan", p.doctor_id,p.owner_id
				) as pres_history
				WHERE pres_history.quan > 0
				;

		ELSE

			RETURN QUERY 
			SELECT * FROM
				(
				SELECT p.id, p.doctor_id, dc.name, dc.address, dc.license_number, p.owner_id, p.drug_id, p.dosage, d.max_dosage, u.unit_name,
				(p.quantity - GREATEST(0, (SELECT SUM(pe1.quantity) from "Prescription_execution" pe1 where pe1.prescription_id = p.id)::integer)) as "quan", 
				false, null::DATE, null::integer, null::varchar(255), null::varchar(255)
				FROM "Doctor" dc, "Drug_unit" u, "Drug" d, "Prescription" p
				LEFT JOIN "Prescription_execution" pe on pe.prescription_id=p.id
				WHERE p.doctor_id = dc.id 
				AND p.doctor_id = $1
				AND p.drug_id = d.id 
				AND p.unit = u.id
				AND p.patient_id = $2
				--GROUP BY p.id, dc.name, dc.address, dc.license_number, d.max_dosage, u.unit_name, "quan", p.doctor_id,p.owner_id
				) as pres_history
				WHERE pres_history.quan > 0
				;
		END IF;

	END;
$_$;


ALTER FUNCTION public.browse_patient_prescription_history2(integer, integer, date, date, boolean, bytea, bytea) OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 16880)
-- Name: Pharmacist_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Pharmacist_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Pharmacist_ID_seq" OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 16923)
-- Name: Pharmacist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pharmacist" (
    id integer DEFAULT nextval('"Pharmacist_ID_seq"'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    license_number integer NOT NULL,
    nonce bigint NOT NULL,
    certificate bytea NOT NULL,
    pharmacy_name character varying NOT NULL,
    private_key text,
    public_key text
);


ALTER TABLE public."Pharmacist" OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16950)
-- Name: browse_pharmacists(text, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION browse_pharmacists(text DEFAULT ''::text, text DEFAULT ''::text, integer DEFAULT NULL::integer, text DEFAULT ''::text) RETURNS SETOF "Pharmacist"
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		license text;
	BEGIN
		IF $3 is not null
		THEN
			license:= CAST($3 as TEXT);
		ELSE
			license := '';
		END IF;
		RETURN QUERY SELECT * FROM "Pharmacist" p
			WHERE p.name like '%' || $1 || '%'
			AND p.address like '%' || $2 || '%'
			AND CAST(p.license_number AS TEXT) like '%' || '' || '%'
			AND p.pharmacy_name like '%' || $4 || '%';
	END;
$_$;


ALTER FUNCTION public.browse_pharmacists(text, text, integer, text) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 16951)
-- Name: cancel_prescription_transfer(integer, integer, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cancel_prescription_transfer(i_patient_id integer, i_prescription_id integer, i_patient_signature bytea) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE lv_patient_name character varying(255);
	lv_to_hash bytea;
	lv_hash text;
	lv_nonce bigint;
	lv_public_key text;
	lv_signed_hash text;
BEGIN
	lv_nonce := nonce FROM "Patient" WHERE id = i_patient_id;
	lv_to_hash := 'cancel_prescription_transfer' || i_patient_id || i_prescription_id || lv_nonce;

	lv_hash := sha1(lv_to_hash);

	PERFORM dump_hash(lv_hash);

	--lv_temp_signature := (SELECT system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig'));

	PERFORM dump_sig(i_patient_signature);
	lv_public_key := public_key FROM "Patient" WHERE id = i_patient_id;
	PERFORM dump_key(lv_public_key);
	PERFORM system('bash /fixkey.sh');
	lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
	
	IF lv_signed_hash != lv_hash THEN
		RETURN FALSE;
	END IF;
	lv_patient_name := name FROM "Patient_data" WHERE id = i_patient_id;
	IF lv_patient_name IS NULL
	THEN
		RETURN FALSE;
	ELSE
		UPDATE "Prescription" SET owner_id = i_patient_id WHERE id = i_prescription_id AND patient_id = i_patient_id;
		RETURN TRUE;
	END IF;
END;
$$;


ALTER FUNCTION public.cancel_prescription_transfer(i_patient_id integer, i_prescription_id integer, i_patient_signature bytea) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 16944)
-- Name: create_prescription(integer, integer, integer, integer, integer, integer, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_prescription(i_doctor_id integer, i_patient_id integer, i_drug_id integer, i_dosage integer, i_unit integer, i_quantity integer, i_doctor_signature bytea) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	DECLARE lv_result_of_creating_prescription BOOLEAN;
		lv_doctor_name character varying(255);
		lv_patient_name character varying(255);
		lv_drug_name character varying(255);
		lv_to_hash bytea;
		lv_hash text;
		lv_nonce bigint;
		lv_public_key text;
		lv_signed_hash text;
	BEGIN 
		
		lv_doctor_name = name FROM "Doctor" WHERE id = i_doctor_id;
		lv_patient_name = name FROM "Patient" WHERE id = i_patient_id;
		lv_drug_name = name FROM "Drug" WHERE id = i_drug_id;
		IF lv_doctor_name IS NULL OR lv_patient_name IS NULL OR lv_drug_name IS NULL
		THEN 
			lv_result_of_creating_prescription := FALSE;
			RETURN lv_result_of_creating_prescription;
		END IF;
		
		INSERT INTO "Prescription"
			(drug_id, patient_id, owner_id, doctor_id, dosage, unit, quantity, doctor_signature, used_nonce) VALUES
			( i_drug_id, i_patient_id, i_patient_id, i_doctor_id, i_dosage, i_unit, i_quantity, i_doctor_signature, '10101' );
		lv_result_of_creating_prescription := TRUE;
		RETURN lv_result_of_creating_prescription;
	END;
$$;


ALTER FUNCTION public.create_prescription(i_doctor_id integer, i_patient_id integer, i_drug_id integer, i_dosage integer, i_unit integer, i_quantity integer, i_doctor_signature bytea) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 16952)
-- Name: dump_hash(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dump_hash(text DEFAULT ''::text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		license text;
	BEGIN
		create temp table temp1 as
			select $1;
		copy (select * from temp1) to '/tmp/tosign'; -- to '/tmp/prep_ver\';
		drop table temp1;
	END;$_$;


ALTER FUNCTION public.dump_hash(text) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 16953)
-- Name: dump_key(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dump_key(text DEFAULT ''::text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
	declare
		license text;
	BEGIN
		create temp table temp1 as
			select $1;
		copy (select * from temp1) to '/tmp/key'; -- to '/tmp/prep_ver\';
		drop table temp1;
	END;
$_$;


ALTER FUNCTION public.dump_key(text) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16955)
-- Name: dump_sig(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dump_sig(bytea) RETURNS void
    LANGUAGE plpgsql
    AS $_$
	declare
		license text;
	BEGIN
		create temp table temp1 as
			(select $1 as lol);
		copy (select encode(lol, 'base64') from temp1) to '/tmp/sigprep'; -- to '/tmp/prep_ver\';
		--perform system('bash /bejs.sh');
		drop table temp1;
	END;
$_$;


ALTER FUNCTION public.dump_sig(bytea) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 16954)
-- Name: dump_sig(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dump_sig(text DEFAULT ''::text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
	declare
		license text;
	BEGIN
		create temp table temp1 as
			select $1;
		copy (select * from temp1) to '/tmp/sig'; -- to '/tmp/prep_ver\';
		drop table temp1;
	END;
$_$;


ALTER FUNCTION public.dump_sig(text) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 16967)
-- Name: get_doctor_nonce(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_doctor_nonce(i_doctor_id integer) RETURNS bit varying
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nonce FROM "Doctor" WHERE id = i_doctor_id);
END
$$;


ALTER FUNCTION public.get_doctor_nonce(i_doctor_id integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16957)
-- Name: get_patient_nonce(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_patient_nonce(i_patient_id integer) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nonce FROM "Patient" WHERE id = i_patient_id);
END;
$$;


ALTER FUNCTION public.get_patient_nonce(i_patient_id integer) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16959)
-- Name: prepare_verify(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION prepare_verify(text DEFAULT ''::text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
	declare
		license text;
	BEGIN
		create temp table temp1 as
			select $1;
		copy (select * from temp1) to '/tmp/prep_ver'; -- to '/tmp/prep_ver\';
		drop table temp1;
	END;
$_$;


ALTER FUNCTION public.prepare_verify(text) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16960)
-- Name: prescription_realization(integer, integer, integer, integer, integer, bytea, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION prescription_realization(i_prescription_id integer, i_pharmacist_id integer, i_drug_id integer, i_unit integer, i_quantity integer, i_pharmacist_signature bytea, i_patient_signature bytea) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
													 
DECLARE
	lv_quantity integer;
	lv_patient_id integer;
	lv_to_hash bytea;
	lv_hash text;
	lv_nonce bigint;
	lv_public_key text;
	lv_signed_hash text;
BEGIN
		SELECT INTO lv_patient_id patient_id FROM "Prescription" WHERE id = i_prescription_id;
		lv_nonce := nonce FROM "Pharmacist" WHERE id = i_pharmacist_id;

		lv_to_hash := 'prescription_realization' ||  i_prescription_id || i_pharmacist_id || i_drug_id || i_unit || i_quantity || lv_nonce;
		
		lv_hash := sha1(lv_to_hash);
		

		--lv_temp_signature := (SELECT system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig'));

		PERFORM dump_sig(i_patient_signature);
		

		lv_public_key := public_key FROM "Patient" WHERE id = lv_patient_id;
		PERFORM dump_key(lv_public_key);
		PERFORM system('bash /fixkey.sh');
		lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
		
		IF lv_signed_hash != lv_hash THEN
			RETURN FALSE;
		END IF;

		PERFORM dump_sig(i_pharmacist_signature);
		lv_public_key := public_key FROM "Pharmacist" WHERE id = i_pharmacist_id;
		PERFORM dump_key(lv_public_key);
		PERFORM system('bash /fixkey.sh');
		lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
		
		IF lv_signed_hash != lv_hash THEN
			RETURN FALSE;
		END IF;
		
		SELECT INTO lv_quantity quantity FROM "Prescription" WHERE id = i_prescription_id;
		SELECT INTO lv_patient_id patient_id FROM "Prescription" WHERE id = i_prescription_id;
		if lv_quantity < i_quantity THEN
			return FALSE;
		ELSE
			UPDATE "Prescription" SET quantity = lv_quantity - i_quantity WHERE id = i_prescription_id;
			INSERT INTO "Prescription_execution"(
			    prescription_id, pharmacist_id, patient_id, "time", drug_id, 
			    unit, quantity, pharmacist_signature)
		    VALUES (i_prescription_id, i_pharmacist_id, lv_patient_id, NOW(), i_drug_id, i_unit, 
			    i_quantity, i_pharmacist_signature);

		END IF;
		RETURN TRUE;
	END;
$$;


ALTER FUNCTION public.prescription_realization(i_prescription_id integer, i_pharmacist_id integer, i_drug_id integer, i_unit integer, i_quantity integer, i_pharmacist_signature bytea, i_patient_signature bytea) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 16961)
-- Name: sha1(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sha1(bytea) RETURNS text
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN ENCODE(DIGEST($1, 'sha1'), 'hex');
END;
$_$;


ALTER FUNCTION public.sha1(bytea) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 16963)
-- Name: test_signature(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION test_signature() RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE lv_hash text;
	lv_to_hash bytea;
	lv_signed_hash bytea;
	lv_patient_id integer;
	lv_execute BOOLEAN;
	lv_start date;
	lv_end date;
	lv_nonce bigint;
	lv_temp_signature bytea;
	lv_private_key text;
BEGIN
	lv_patient_id := 1;
	lv_start := '2001-10-05';
	lv_end := '2015-10-05';
	lv_nonce := nonce FROM "Patient" WHERE id = lv_patient_id;
	lv_execute := false;
	--lv_to_hash := 'browse_my_prescriptions_history' || lv_patient_id || lv_execute || (SELECT to_char(lv_start, 'HH12:MI:SS')) || (select to_char(lv_end, 'HH12:MI:SS')) || lv_nonce;--- || lv_end::text || lv_nonce;

	lv_to_hash := 'browse_my_prescriptions_history' || lv_patient_id || lv_execute || lv_start || lv_end || lv_nonce;--- || lv_end::text || lv_nonce;
	
	lv_hash := sha1(lv_to_hash);
	PERFORM dump_hash(lv_hash);
	lv_private_key := private_key FROM "Patient" WHERE id = lv_patient_id;
	PERFORM dump_key(lv_private_key);
	PERFORM system('bash /fixkey.sh');
	PERFORM system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig');
	--lv_temp_signature := (SELECT system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig'));
	lv_temp_signature := (SELECT system('cat /tmp/sig'));
	--PERFORM dump_sig(lv_temp_signature);
	PERFORM browse_my_prescriptions_history(lv_patient_id, lv_execute, lv_start, lv_end, lv_temp_signature);
END;$$;


ALTER FUNCTION public.test_signature() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16964)
-- Name: transfer_prescription(integer, bigint, integer, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION transfer_prescription(i_patient_id integer, i_owner_pesel bigint, i_prescription_id integer, i_patient_signature bytea, OUT e_new_owner_id integer, OUT e_is_correct boolean) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE lv_new_owner_id integer;
		lv_current_owner_id integer;
		lv_to_hash bytea;
		lv_hash text;
		lv_public_key text;
		lv_signed_hash text;
		lv_nonce bigint;
		--lv_temp_signature bytea;
BEGIN
	lv_nonce := nonce FROM "Patient" WHERE id = i_patient_id;
	lv_to_hash := 'transfer_prescription' ||  i_owner_pesel || i_prescription_id || lv_nonce;
	
	lv_hash := sha1(lv_to_hash);


	--PERFORM dump_hash(lv_hash);

	--lv_temp_signature := (SELECT system('openssl rsautl -sign -in /tmp/tosign -inkey /tmp/key -out /tmp/sig'));
	
	lv_current_owner_id := owner_id FROM "Prescription" WHERE id = i_patient_id;

	PERFORM dump_sig(i_patient_signature);
	lv_public_key := public_key FROM "Patient" WHERE id = i_patient_id;
	PERFORM dump_key(lv_public_key);
	PERFORM system('bash /fixkey.sh');
	lv_signed_hash := (SELECT system('openssl rsautl -verify -inkey /tmp/key -in /tmp/sig'));
	
	IF lv_signed_hash != lv_hash THEN
		e_new_owner_id := -3;
		e_is_correct := FALSE;
		ELSE
	
	IF i_patient_id <> lv_current_owner_id THEN
		e_new_owner_id := -2;
		e_is_correct := FALSE;
	ELSE
	
		lv_new_owner_id := id FROM "Patient" WHERE "PESEL" = i_owner_pesel;
		IF lv_new_owner_id IS NULL THEN
			e_new_owner_id := -4;
			e_is_correct := FALSE;
		ELSE 
			UPDATE "Prescription" SET owner_id = lv_new_owner_id WHERE id = i_prescription_id AND patient_id = i_patient_id;
			e_new_owner_id := lv_new_owner_id;
			e_is_correct := TRUE;
		END IF;
	END IF;
	END IF;
END;		
$$;


ALTER FUNCTION public.transfer_prescription(i_patient_id integer, i_owner_pesel bigint, i_prescription_id integer, i_patient_signature bytea, OUT e_new_owner_id integer, OUT e_is_correct boolean) OWNER TO postgres;

--
-- TOC entry 176 (class 1259 OID 16870)
-- Name: Drug_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Drug_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Drug_ID_seq" OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 16897)
-- Name: Drug; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Drug" (
    id integer DEFAULT nextval('"Drug_ID_seq"'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    type integer NOT NULL,
    max_dosage integer NOT NULL,
    unit integer NOT NULL,
    prescription_requirement boolean NOT NULL
);


ALTER TABLE public."Drug" OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 16872)
-- Name: Drug_type_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Drug_type_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Drug_type_ID_seq" OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 16901)
-- Name: Drug_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Drug_type" (
    id integer DEFAULT nextval('"Drug_type_ID_seq"'::regclass) NOT NULL,
    type character varying(255) NOT NULL
);


ALTER TABLE public."Drug_type" OWNER TO postgres;

--
-- TOC entry 178 (class 1259 OID 16874)
-- Name: Drug_unit_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Drug_unit_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Drug_unit_ID_seq" OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 16905)
-- Name: Drug_unit; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Drug_unit" (
    id integer DEFAULT nextval('"Drug_unit_ID_seq"'::regclass) NOT NULL,
    unit_name character varying(255)
);


ALTER TABLE public."Drug_unit" OWNER TO postgres;

--
-- TOC entry 179 (class 1259 OID 16876)
-- Name: Patient_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Patient_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Patient_ID_seq" OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 16909)
-- Name: Patient; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Patient" (
    id integer DEFAULT nextval('"Patient_ID_seq"'::regclass) NOT NULL,
    patient_data_id integer NOT NULL,
    "PESEL" bigint NOT NULL,
    nonce bigint NOT NULL,
    certificate bytea NOT NULL,
    private_key text,
    public_key text,
    name text
);


ALTER TABLE public."Patient" OWNER TO postgres;

--
-- TOC entry 180 (class 1259 OID 16878)
-- Name: Patient_data_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Patient_data_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Patient_data_ID_seq" OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 16916)
-- Name: Patient_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Patient_data" (
    id integer DEFAULT nextval('"Patient_data_ID_seq"'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(255) NOT NULL
);


ALTER TABLE public."Patient_data" OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 16882)
-- Name: Prescription_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Prescription_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Prescription_ID_seq" OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 16930)
-- Name: Prescription; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Prescription" (
    id integer DEFAULT nextval('"Prescription_ID_seq"'::regclass) NOT NULL,
    drug_id integer NOT NULL,
    patient_id integer NOT NULL,
    owner_id integer NOT NULL,
    doctor_id integer NOT NULL,
    dosage integer NOT NULL,
    unit integer NOT NULL,
    quantity integer NOT NULL,
    common_set_id integer,
    used_nonce bigint NOT NULL,
    doctor_signature bytea NOT NULL
);


ALTER TABLE public."Prescription" OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 16884)
-- Name: Prescription_execution_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Prescription_execution_ID_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE public."Prescription_execution_ID_seq" OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 16937)
-- Name: Prescription_execution; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Prescription_execution" (
    id integer DEFAULT nextval('"Prescription_execution_ID_seq"'::regclass) NOT NULL,
    prescription_id integer NOT NULL,
    pharmacist_id integer NOT NULL,
    patient_id integer NOT NULL,
    "time" date NOT NULL,
    drug_id integer NOT NULL,
    unit integer NOT NULL,
    quantity integer NOT NULL,
    pharmacist_signature bytea
);


ALTER TABLE public."Prescription_execution" OWNER TO postgres;

--
-- TOC entry 2084 (class 0 OID 16886)
-- Dependencies: 184
-- Data for Name: Doctor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Doctor" (id, name, address, license_number, nonce, certificate, private_key, public_key) FROM stdin;
5	Piotr Lipiak	wys	101110	1011100	\\x616161	\N	\N
\.


--
-- TOC entry 2102 (class 0 OID 0)
-- Dependencies: 175
-- Name: Doctor_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Doctor_ID_seq"', 5, true);


--
-- TOC entry 2085 (class 0 OID 16897)
-- Dependencies: 185
-- Data for Name: Drug; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Drug" (id, name, type, max_dosage, unit, prescription_requirement) FROM stdin;
1	pavulon-50mg	1	100	1	t
2	ketonal-100mg	1	100	1	t
3	ibuprom-150mg	1	100	1	t
\.


--
-- TOC entry 2103 (class 0 OID 0)
-- Dependencies: 176
-- Name: Drug_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Drug_ID_seq"', 3, true);


--
-- TOC entry 2086 (class 0 OID 16901)
-- Dependencies: 186
-- Data for Name: Drug_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Drug_type" (id, type) FROM stdin;
1	ONPres
2	NoRestrictions
3	Made
\.


--
-- TOC entry 2104 (class 0 OID 0)
-- Dependencies: 177
-- Name: Drug_type_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Drug_type_ID_seq"', 3, true);


--
-- TOC entry 2087 (class 0 OID 16905)
-- Dependencies: 187
-- Data for Name: Drug_unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Drug_unit" (id, unit_name) FROM stdin;
1	package
2	mg
3	g
\.


--
-- TOC entry 2105 (class 0 OID 0)
-- Dependencies: 178
-- Name: Drug_unit_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Drug_unit_ID_seq"', 3, true);


--
-- TOC entry 2088 (class 0 OID 16909)
-- Dependencies: 188
-- Data for Name: Patient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Patient" (id, patient_data_id, "PESEL", nonce, certificate, private_key, public_key, name) FROM stdin;
1	1	123456789	10101	\\x61616161	aaa	aaaa	Piotr Lipiak
\.


--
-- TOC entry 2106 (class 0 OID 0)
-- Dependencies: 179
-- Name: Patient_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Patient_ID_seq"', 1, true);


--
-- TOC entry 2089 (class 0 OID 16916)
-- Dependencies: 189
-- Data for Name: Patient_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Patient_data" (id, name, address) FROM stdin;
1	Piotr Lipiak	wys
\.


--
-- TOC entry 2107 (class 0 OID 0)
-- Dependencies: 180
-- Name: Patient_data_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Patient_data_ID_seq"', 1, true);


--
-- TOC entry 2090 (class 0 OID 16923)
-- Dependencies: 190
-- Data for Name: Pharmacist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Pharmacist" (id, name, address, license_number, nonce, certificate, pharmacy_name, private_key, public_key) FROM stdin;
\.


--
-- TOC entry 2108 (class 0 OID 0)
-- Dependencies: 181
-- Name: Pharmacist_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Pharmacist_ID_seq"', 1, false);


--
-- TOC entry 2091 (class 0 OID 16930)
-- Dependencies: 191
-- Data for Name: Prescription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Prescription" (id, drug_id, patient_id, owner_id, doctor_id, dosage, unit, quantity, common_set_id, used_nonce, doctor_signature) FROM stdin;
1	1	1	1	5	1	1	1	1	1001	\\x616161
2	1	1	1	5	1	1	1	1	1001	\\x616161
5	1	1	1	5	1	1	1	\N	10101	\\x6161
\.


--
-- TOC entry 2109 (class 0 OID 0)
-- Dependencies: 182
-- Name: Prescription_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Prescription_ID_seq"', 5, true);


--
-- TOC entry 2092 (class 0 OID 16937)
-- Dependencies: 192
-- Data for Name: Prescription_execution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Prescription_execution" (id, prescription_id, pharmacist_id, patient_id, "time", drug_id, unit, quantity, pharmacist_signature) FROM stdin;
\.


--
-- TOC entry 2110 (class 0 OID 0)
-- Dependencies: 183
-- Name: Prescription_execution_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Prescription_execution_ID_seq"', 1, false);


--
-- TOC entry 1965 (class 2606 OID 16896)
-- Name: Doctor_license_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Doctor"
    ADD CONSTRAINT "Doctor_license_number_key" UNIQUE (license_number);


--
-- TOC entry 1967 (class 2606 OID 16894)
-- Name: Doctor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Doctor"
    ADD CONSTRAINT "Doctor_pkey" PRIMARY KEY (id);


--
-- TOC entry 2099 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2014-06-15 23:23:26

--
-- PostgreSQL database dump complete
--

