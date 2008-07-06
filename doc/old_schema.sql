--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: address; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE address (
    address_street integer,
    address_nr_from smallint,
    address_nr_to smallint,
    address_step smallint,
    address_zip integer,
    address_from_x double precision,
    address_from_y double precision,
    address_to_x double precision,
    address_to_y double precision
);


ALTER TABLE public.address OWNER TO jonas;

--
-- Name: city; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE city (
    city smallint DEFAULT nextval(('city_seq'::text)::regclass) NOT NULL,
    city_name character varying(32),
    city_l smallint,
    city_areg smallint,
    city_x double precision,
    city_y double precision,
    city_precision smallint
);


ALTER TABLE public.city OWNER TO jonas;

--
-- Name: country; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE country (
    country character(2) NOT NULL,
    country_name character varying(64),
    country_x double precision,
    country_y double precision,
    country_precision smallint
);


ALTER TABLE public.country OWNER TO jonas;

--
-- Name: county; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE county (
    county smallint NOT NULL,
    county_code character varying(2),
    county_name character varying(32),
    county_country character(2),
    county_x double precision,
    county_y double precision,
    county_precision smallint
);


ALTER TABLE public.county OWNER TO jonas;

--
-- Name: domain; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE domain (
    domain character varying(128) NOT NULL,
    domain_parent character varying(128),
    domain_type character(1) DEFAULT 'n'::bpchar NOT NULL,
    domain_created timestamp without time zone DEFAULT now(),
    domain_updated timestamp without time zone DEFAULT now(),
    domain_updatedby integer DEFAULT -1 NOT NULL,
    domain_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.domain OWNER TO jonas;

--
-- Name: event; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE event (
    event_id integer NOT NULL,
    event_rule text NOT NULL,
    event_rule_type text NOT NULL,
    event_do_all boolean DEFAULT false NOT NULL,
    event_action text,
    event_params text,
    event_as_user integer,
    event_topic integer,
    event_created timestamp without time zone DEFAULT now() NOT NULL,
    event_createdby integer DEFAULT -1 NOT NULL,
    event_active boolean DEFAULT true NOT NULL,
    event_updated timestamp without time zone,
    event_updatedby integer
);


ALTER TABLE public.event OWNER TO jonas;

--
-- Name: history; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE history (
    history_id integer NOT NULL,
    history_status smallint NOT NULL,
    history_created timestamp without time zone DEFAULT now() NOT NULL,
    history_createdby integer DEFAULT -1 NOT NULL,
    history_secret boolean DEFAULT false NOT NULL,
    history_partof integer,
    history_topic integer,
    history_member integer,
    history_class character varying(24) NOT NULL,
    history_action smallint NOT NULL,
    history_skey character varying(128),
    history_slot character varying(24),
    history_vold text,
    history_vnew text,
    history_comment text
);


ALTER TABLE public.history OWNER TO jonas;

--
-- Name: intrest; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE intrest (
    intrest_member integer NOT NULL,
    intrest_topic integer NOT NULL,
    belief smallint,
    knowledge smallint,
    theory smallint,
    skill smallint,
    practice smallint,
    editor smallint,
    helper smallint,
    meeter smallint,
    bookmark smallint,
    visit_latest timestamp with time zone,
    visit_version integer,
    intrest_updated timestamp with time zone DEFAULT now(),
    experience smallint,
    intrest_description text,
    intrest_defined smallint DEFAULT 0,
    intrest_connected smallint DEFAULT 0,
    intrest smallint
);


ALTER TABLE public.intrest OWNER TO jonas;

--
-- Name: ipfilter; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE ipfilter (
    ipfilter_pattern character varying(128) NOT NULL,
    ipfilter_createdby integer NOT NULL,
    ipfilter_created timestamp without time zone DEFAULT now() NOT NULL,
    ipfilter_updated timestamp without time zone DEFAULT now() NOT NULL,
    ipfilter_changedby integer NOT NULL,
    ipfilter_expire timestamp without time zone,
    ipfilter_reason text
);


ALTER TABLE public.ipfilter OWNER TO jonas;

--
-- Name: mailalias; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE mailalias (
    mailalias_member integer,
    mailalias character varying(128) NOT NULL,
    mailalias_created timestamp with time zone,
    mailalias_working timestamp with time zone,
    mailalias_failed smallint DEFAULT 0
);


ALTER TABLE public.mailalias OWNER TO jonas;

--
-- Name: mailr; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE mailr (
    mailr integer NOT NULL,
    mailr_name character varying(60) NOT NULL,
    mailr_domain character varying(128) NOT NULL,
    mailr_dest character varying(250) NOT NULL,
    mailr_member integer,
    mailr_created timestamp without time zone DEFAULT now(),
    mailr_updated timestamp without time zone DEFAULT now(),
    mailr_updatedby integer DEFAULT -1 NOT NULL,
    mailr_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.mailr OWNER TO jonas;

--
-- Name: media; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE media (
    media integer NOT NULL,
    media_mimetype character varying(32),
    media_url character varying(128),
    media_checked_working timestamp with time zone,
    media_checked_failed smallint,
    media_speed smallint
);


ALTER TABLE public.media OWNER TO jonas;

--
-- Name: member; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE member (
    member integer NOT NULL,
    nickname character varying(24),
    member_level smallint,
    member_created timestamp with time zone,
    member_updated timestamp with time zone,
    latest_in timestamp with time zone,
    latest_out timestamp with time zone,
    latest_host character varying(32),
    mailalias_updated timestamp with time zone,
    intrest_updated timestamp with time zone,
    sys_email character varying(128),
    sys_uid character varying(24),
    sys_logging smallint DEFAULT 30 NOT NULL,
    present_contact smallint DEFAULT 15 NOT NULL,
    present_activity smallint DEFAULT 10 NOT NULL,
    general_belief smallint,
    general_theory smallint,
    general_practice smallint,
    general_editor smallint,
    general_helper smallint,
    general_meeter smallint,
    general_bookmark smallint,
    general_discussion smallint,
    chat_nick character varying(24),
    prefered_chat character varying(24),
    prefered_im character varying(24),
    newsmail smallint DEFAULT 2 NOT NULL,
    show_complexity smallint DEFAULT 5 NOT NULL,
    show_detail smallint DEFAULT 10 NOT NULL,
    show_edit smallint DEFAULT 10 NOT NULL,
    show_style character varying(24),
    name_prefix character varying(24),
    name_given character varying(32),
    name_middle character varying(32),
    name_family character varying(32),
    name_suffix character varying(32),
    bdate_ymd_year smallint,
    bdate_ymd_month smallint,
    bdate_ymd_day smallint,
    bdate_hms_hour smallint,
    bdate_hms_minute smallint,
    bdate_ymd_timezone smallint,
    gender character(1),
    home_online_uri character varying(128),
    home_online_email character varying(128),
    home_online_icq integer,
    home_online_aol character varying(32),
    home_online_msn character varying(32),
    home_tele_phone character varying(32),
    home_tele_phone_comment character varying(128),
    home_tele_mobile character varying(32),
    home_tele_mobile_comment character varying(128),
    home_tele_fax character varying(32),
    home_tele_fax_comment character varying(128),
    home_postal_name character varying(64),
    home_postal_street character varying(64),
    home_postal_visiting character varying(64),
    home_postal_city character varying(64),
    home_postal_code character varying(24),
    home_postal_country character(2),
    presentation text,
    statement character varying(80),
    geo_precision smallint DEFAULT 0,
    geo_x double precision,
    geo_y double precision,
    member_topic integer,
    present_intrests smallint DEFAULT 30 NOT NULL,
    member_payment_period_length smallint DEFAULT 30,
    member_payment_period_expire date DEFAULT (now() + '7 days'::interval),
    member_payment_period_cost integer DEFAULT 0,
    member_payment_level integer DEFAULT 0,
    member_payment_total integer DEFAULT 0,
    chat_level smallint DEFAULT 0 NOT NULL,
    present_contact_public smallint DEFAULT 15 NOT NULL,
    show_level smallint DEFAULT 10 NOT NULL,
    present_gifts smallint DEFAULT 1 NOT NULL,
    newsmail_latest timestamp without time zone DEFAULT now() NOT NULL,
    im_threshold smallint DEFAULT 50 NOT NULL,
    member_comment_admin text,
    sys_level smallint DEFAULT 0 NOT NULL,
    home_online_skype character varying(32),
    present_blog smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.member OWNER TO jonas;

--
-- Name: memberhost; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE memberhost (
    memberhost_member integer,
    memberhost_pattern character varying(128),
    memberhost_status smallint,
    memberhost_updated timestamp with time zone
);


ALTER TABLE public.memberhost OWNER TO jonas;

--
-- Name: memo; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE memo (
    memo_id integer NOT NULL,
    memo_created timestamp without time zone DEFAULT now() NOT NULL,
    memo_sender integer DEFAULT -1 NOT NULL,
    memo_member integer NOT NULL,
    memo_re integer,
    memo_partof integer,
    memo_status smallint NOT NULL,
    memo_class character varying(24) NOT NULL,
    memo_topic integer,
    memo_event integer,
    memo_weight smallint DEFAULT 50 NOT NULL,
    memo_text text,
    memo_url text
);


ALTER TABLE public.memo OWNER TO jonas;

--
-- Name: municipality; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE municipality (
    municipality smallint NOT NULL,
    municipality_name character varying(32),
    municipality_l smallint,
    municipality_x double precision,
    municipality_y double precision,
    municipality_precision smallint
);


ALTER TABLE public.municipality OWNER TO jonas;

--
-- Name: nick; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE nick (
    uid character varying(24) NOT NULL,
    nick_member integer,
    nick_created timestamp with time zone
);


ALTER TABLE public.nick OWNER TO jonas;

--
-- Name: parish; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE parish (
    parish integer NOT NULL,
    parish_name character varying(32),
    parish_lk smallint,
    parish_x double precision,
    parish_y double precision,
    parish_precision smallint
);


ALTER TABLE public.parish OWNER TO jonas;

--
-- Name: passwd; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE passwd (
    passwd_member integer NOT NULL,
    passwd character varying(24),
    passwd_previous character varying(24),
    passwd_failed_latest timestamp with time zone,
    passwd_failed_times smallint,
    passwd_clue character varying(128),
    passwd_updated timestamp with time zone,
    passwd_changedby integer
);


ALTER TABLE public.passwd OWNER TO jonas;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE payment (
    payment_id integer NOT NULL,
    payment_member integer NOT NULL,
    payment_date timestamp without time zone,
    payment_product integer NOT NULL,
    payment_price integer NOT NULL,
    payment_quantity integer NOT NULL,
    payment_method integer NOT NULL,
    payment_reference character varying(50),
    payment_comment text,
    payment_completed boolean DEFAULT false NOT NULL,
    payment_receiver integer NOT NULL,
    payment_message text,
    payment_company integer,
    payment_vat numeric(10,2) NOT NULL,
    payment_receiver_vernr character varying(12),
    payment_order_date timestamp without time zone NOT NULL,
    payment_invoice_date timestamp without time zone,
    payment_log_date timestamp without time zone
);


ALTER TABLE public.payment OWNER TO jonas;

--
-- Name: plan; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE plan (
    plan_id integer NOT NULL,
    plan_start timestamp without time zone NOT NULL,
    plan_started timestamp without time zone,
    plan_end timestamp without time zone,
    plan_ended timestamp without time zone,
    plan_event integer NOT NULL,
    plan_finished boolean DEFAULT false NOT NULL,
    plan_is_action boolean DEFAULT false NOT NULL
);


ALTER TABLE public.plan OWNER TO jonas;

--
-- Name: publ; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE publ (
    publ integer,
    publ_created timestamp with time zone,
    publ_createdby integer,
    publ_updated timestamp with time zone,
    publ_changedby integer,
    publ_status smallint,
    publ_key character varying(64),
    publ_ref text,
    publ_sab character varying(12),
    publ_author character varying(128),
    publ_publisher character varying(128),
    publ_year smallint,
    publ_isbn character varying(32),
    publ_height smallint,
    publ_depth smallint,
    publ_pages smallint,
    publ_title character varying(64),
    publ_subtitle character varying(64),
    publ_original_title character varying(128),
    publ_translator character varying(64),
    publ_active boolean DEFAULT false
);


ALTER TABLE public.publ OWNER TO jonas;

--
-- Name: rel; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE rel (
    rel_topic integer NOT NULL,
    rev integer,
    rel integer,
    rel_type smallint DEFAULT 0,
    rel_status smallint,
    rel_value text,
    rel_comment text,
    rel_updated timestamp with time zone DEFAULT now(),
    rel_changedby integer DEFAULT -1,
    rel_strength smallint DEFAULT 50,
    rel_active boolean DEFAULT false,
    rel_createdby integer DEFAULT -1,
    rel_created timestamp with time zone DEFAULT now(),
    rel_indirect boolean DEFAULT false,
    rel_implicit boolean DEFAULT false
);


ALTER TABLE public.rel OWNER TO jonas;

--
-- Name: reltype; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE reltype (
    reltype smallint NOT NULL,
    rel_name character varying(64),
    rev_name character varying(64),
    reltype_topic integer,
    reltype_description text,
    reltype_updated timestamp with time zone,
    reltype_changedby integer,
    reltype_super smallint,
    reltype_literal boolean DEFAULT false
);


ALTER TABLE public.reltype OWNER TO jonas;

--
-- Name: score; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE score (
    score_member integer NOT NULL,
    logged_in integer DEFAULT 0 NOT NULL,
    time_online integer DEFAULT 0 NOT NULL,
    time_irc integer DEFAULT 0 NOT NULL,
    promoted_user integer DEFAULT 0 NOT NULL,
    demoted_user integer DEFAULT 0 NOT NULL,
    accepted_thing integer DEFAULT 0 NOT NULL,
    rejected_thing integer DEFAULT 0 NOT NULL,
    thing_rejected integer DEFAULT 0 NOT NULL,
    thing_accepted integer DEFAULT 0 NOT NULL,
    thing_finalised integer DEFAULT 0 NOT NULL,
    intrest_stated integer DEFAULT 0 NOT NULL,
    topic_rated integer DEFAULT 0 NOT NULL,
    topic_connected integer DEFAULT 0 NOT NULL,
    entry_submitted integer DEFAULT 0 NOT NULL,
    link_submitted integer DEFAULT 0 NOT NULL,
    event_sbmitted integer DEFAULT 0 NOT NULL,
    topic_submitted integer DEFAULT 0 NOT NULL,
    request_answerd integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.score OWNER TO jonas;

--
-- Name: slogan; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE slogan (
    slogan integer NOT NULL,
    slogan_text text NOT NULL,
    slogan_created timestamp without time zone DEFAULT now()
);


ALTER TABLE public.slogan OWNER TO jonas;

--
-- Name: street; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE street (
    street integer NOT NULL,
    street_nr_from smallint,
    street_nr_to smallint,
    street_name character varying(32),
    street_city smallint NOT NULL,
    street_x double precision,
    street_y double precision,
    street_precision smallint
);


ALTER TABLE public.street OWNER TO jonas;

--
-- Name: t; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE t (
    t integer,
    t_pop smallint,
    t_size integer,
    t_created timestamp with time zone DEFAULT now(),
    t_createdby integer DEFAULT -1,
    t_updated timestamp with time zone DEFAULT now(),
    t_changedby integer DEFAULT -1,
    t_status smallint,
    t_title character varying(128),
    t_text text,
    t_entry boolean DEFAULT false,
    t_entry_parent integer,
    t_entry_next integer,
    t_entry_imported smallint DEFAULT 0,
    t_file character varying(128),
    t_class boolean,
    t_ver smallint DEFAULT 1,
    t_replace integer,
    t_connected smallint DEFAULT 0,
    t_active boolean DEFAULT false,
    t_connected_status smallint DEFAULT 0,
    t_oldfile character varying(128),
    t_urlpart character varying(128),
    t_title_short_old character varying(20),
    t_title_short_plural_old character varying(20),
    t_comment_admin text,
    t_published boolean DEFAULT false,
    t_title_short character varying(50),
    t_title_short_plural character varying(50),
    t_vacuumed timestamp without time zone DEFAULT now()
);


ALTER TABLE public.t OWNER TO jonas;

--
-- Name: talias; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE talias (
    talias_t integer NOT NULL,
    talias character varying(128) DEFAULT '???'::character varying NOT NULL,
    talias_updated timestamp with time zone DEFAULT now() NOT NULL,
    talias_changedby integer,
    talias_status smallint DEFAULT 2 NOT NULL,
    talias_autolink boolean DEFAULT true,
    talias_index boolean DEFAULT false,
    talias_active boolean DEFAULT false,
    talias_created timestamp with time zone DEFAULT now() NOT NULL,
    talias_createdby integer DEFAULT -1 NOT NULL,
    talias_urlpart character varying(128),
    talias_language integer
);


ALTER TABLE public.talias OWNER TO jonas;

--
-- Name: ts; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE ts (
    ts_entry integer,
    ts_topic integer,
    ontopic smallint,
    completeness smallint,
    correctness smallint,
    delight smallint,
    ts_created timestamp with time zone DEFAULT now(),
    ts_changedby integer DEFAULT -1,
    ts_updated timestamp with time zone DEFAULT now(),
    ts_status smallint DEFAULT 2,
    ts_comment text,
    ts_score smallint,
    ts_active boolean DEFAULT false,
    ts_createdby integer DEFAULT -1
);


ALTER TABLE public.ts OWNER TO jonas;

--
-- Name: zip; Type: TABLE; Schema: public; Owner: jonas; Tablespace: 
--

CREATE TABLE zip (
    zip integer NOT NULL,
    zip_city smallint,
    zip_lk integer,
    zip_x double precision,
    zip_y double precision,
    zip_precision smallint
);


ALTER TABLE public.zip OWNER TO jonas;

--
-- Name: city_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE city_seq
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.city_seq OWNER TO jonas;

--
-- Name: event_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE event_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.event_seq OWNER TO jonas;

--
-- Name: history_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE history_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.history_seq OWNER TO jonas;

--
-- Name: mailr_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE mailr_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.mailr_seq OWNER TO jonas;

--
-- Name: member_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE member_seq
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.member_seq OWNER TO jonas;

--
-- Name: memo_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE memo_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.memo_seq OWNER TO jonas;

--
-- Name: plan_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE plan_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.plan_seq OWNER TO jonas;

--
-- Name: reltype_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE reltype_seq
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.reltype_seq OWNER TO jonas;

--
-- Name: slogan_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE slogan_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.slogan_seq OWNER TO jonas;

--
-- Name: street_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE street_seq
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.street_seq OWNER TO jonas;

--
-- Name: t_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE t_seq
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.t_seq OWNER TO jonas;

--
-- Name: tmp_seq; Type: SEQUENCE; Schema: public; Owner: jonas
--

CREATE SEQUENCE tmp_seq
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.tmp_seq OWNER TO jonas;

--
-- Name: city_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country);


--
-- Name: county_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY county
    ADD CONSTRAINT county_pkey PRIMARY KEY (county);


--
-- Name: domain_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY domain
    ADD CONSTRAINT domain_pkey PRIMARY KEY (domain);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (event_id);


--
-- Name: history_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY history
    ADD CONSTRAINT history_pkey PRIMARY KEY (history_id);


--
-- Name: intrest_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY intrest
    ADD CONSTRAINT intrest_pkey PRIMARY KEY (intrest_member, intrest_topic);


--
-- Name: ipfilter_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY ipfilter
    ADD CONSTRAINT ipfilter_pkey PRIMARY KEY (ipfilter_pattern);


--
-- Name: mailr_mailr_name_key; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY mailr
    ADD CONSTRAINT mailr_mailr_name_key UNIQUE (mailr_name, mailr_domain);


--
-- Name: mailr_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY mailr
    ADD CONSTRAINT mailr_pkey PRIMARY KEY (mailr);


--
-- Name: media_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY media
    ADD CONSTRAINT media_pkey PRIMARY KEY (media);


--
-- Name: member_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_pkey PRIMARY KEY (member);


--
-- Name: memo_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY memo
    ADD CONSTRAINT memo_pkey PRIMARY KEY (memo_id);


--
-- Name: municipality_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY municipality
    ADD CONSTRAINT municipality_pkey PRIMARY KEY (municipality);


--
-- Name: nick_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY nick
    ADD CONSTRAINT nick_pkey PRIMARY KEY (uid);


--
-- Name: parish_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY parish
    ADD CONSTRAINT parish_pkey PRIMARY KEY (parish);


--
-- Name: passwd_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY passwd
    ADD CONSTRAINT passwd_pkey PRIMARY KEY (passwd_member);


--
-- Name: payment_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (payment_id);


--
-- Name: plan_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY plan
    ADD CONSTRAINT plan_pkey PRIMARY KEY (plan_id);


--
-- Name: rel_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY rel
    ADD CONSTRAINT rel_pkey PRIMARY KEY (rel_topic);


--
-- Name: reltype_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY reltype
    ADD CONSTRAINT reltype_pkey PRIMARY KEY (reltype);


--
-- Name: score_new_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY score
    ADD CONSTRAINT score_new_pkey PRIMARY KEY (score_member);


--
-- Name: slogan_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY slogan
    ADD CONSTRAINT slogan_pkey PRIMARY KEY (slogan);


--
-- Name: street_new_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY street
    ADD CONSTRAINT street_new_pkey PRIMARY KEY (street, street_city);


--
-- Name: talias_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY talias
    ADD CONSTRAINT talias_pkey PRIMARY KEY (talias_t, talias);


--
-- Name: zip_pkey; Type: CONSTRAINT; Schema: public; Owner: jonas; Tablespace: 
--

ALTER TABLE ONLY zip
    ADD CONSTRAINT zip_pkey PRIMARY KEY (zip);


--
-- Name: city_name; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX city_name ON city USING btree (lower((city_name)::text));


--
-- Name: county_name; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX county_name ON county USING btree (lower((county_name)::text));


--
-- Name: event_active_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX event_active_idx ON event USING btree (event_active);


--
-- Name: intrest_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX intrest_index ON intrest USING btree (intrest);


--
-- Name: intrest_member_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX intrest_member_index ON intrest USING btree (intrest_member);


--
-- Name: mailalias_member_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX mailalias_member_index ON mailalias USING btree (mailalias_member);


--
-- Name: mailr_dest_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX mailr_dest_idx ON mailr USING btree (mailr_dest);


--
-- Name: mailr_domain_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX mailr_domain_idx ON mailr USING btree (mailr_domain);


--
-- Name: mailr_member_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX mailr_member_idx ON mailr USING btree (mailr_member);


--
-- Name: member_chat_level_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX member_chat_level_index ON member USING btree (chat_level);


--
-- Name: member_geo_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX member_geo_index ON member USING btree (geo_x, geo_y);


--
-- Name: member_icq; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX member_icq ON member USING btree (home_online_icq);


--
-- Name: member_level_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX member_level_index ON member USING btree (member_level);


--
-- Name: member_payment_level_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX member_payment_level_index ON member USING btree (member_payment_level);


--
-- Name: member_payment_period_cost_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX member_payment_period_cost_index ON member USING btree (member_payment_period_cost);


--
-- Name: member_payment_period_expire_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX member_payment_period_expire_index ON member USING btree (member_payment_period_expire);


--
-- Name: member_topic; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE UNIQUE INDEX member_topic ON member USING btree (member_topic);


--
-- Name: memberhost_member_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX memberhost_member_idx ON memberhost USING btree (memberhost_member);


--
-- Name: memberhost_pkey; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE UNIQUE INDEX memberhost_pkey ON memberhost USING btree (memberhost_member, memberhost_pattern);


--
-- Name: memo_member_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX memo_member_index ON memo USING btree (memo_member);


--
-- Name: municipality_name; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX municipality_name ON municipality USING btree (lower((municipality_name)::text));


--
-- Name: nick_member_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX nick_member_index ON nick USING btree (nick_member);


--
-- Name: parish_name; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX parish_name ON parish USING btree (lower((parish_name)::text));


--
-- Name: payment_date_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX payment_date_index ON payment USING btree (payment_date, payment_product);


--
-- Name: payment_member_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX payment_member_index ON payment USING btree (payment_member);


--
-- Name: plan_event_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE UNIQUE INDEX plan_event_idx ON plan USING btree (plan_start, plan_event);


--
-- Name: plan_finished_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX plan_finished_idx ON plan USING btree (plan_finished);


--
-- Name: rel_createdby; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX rel_createdby ON rel USING btree (rel_createdby);


--
-- Name: rel_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX rel_index ON rel USING btree (rel, rel_active);


--
-- Name: rev_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX rev_index ON rel USING btree (rev, rel_active);


--
-- Name: t_createdby_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_createdby_idx ON t USING btree (t_createdby);


--
-- Name: t_entry_next_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_entry_next_idx ON t USING btree (t_entry_next, t_active);


--
-- Name: t_entry_parent_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_entry_parent_idx ON t USING btree (t_entry_parent, t_active);


--
-- Name: t_file_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_file_idx ON t USING btree (t_file, t_active);


--
-- Name: t_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_idx ON t USING btree (t, t_active);


--
-- Name: t_oldfile; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_oldfile ON t USING btree (t_oldfile);


--
-- Name: t_pkey; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE UNIQUE INDEX t_pkey ON t USING btree (t, t_ver);


--
-- Name: t_published_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_published_idx ON t USING btree (t_published, t_active);


--
-- Name: t_title_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_title_idx ON t USING btree (t_title, t_active);


--
-- Name: t_vacuumed_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX t_vacuumed_idx ON t USING btree (t_vacuumed);


--
-- Name: talias_urlpart_idx; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX talias_urlpart_idx ON talias USING btree (talias_urlpart);


--
-- Name: ts_entry_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX ts_entry_index ON ts USING btree (ts_entry, ts_status);


--
-- Name: ts_topic_index; Type: INDEX; Schema: public; Owner: jonas; Tablespace: 
--

CREATE INDEX ts_topic_index ON ts USING btree (ts_topic, ts_status);


--
-- Name: domain_domain_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jonas
--

ALTER TABLE ONLY domain
    ADD CONSTRAINT domain_domain_parent_fkey FOREIGN KEY (domain_parent) REFERENCES domain(domain);


--
-- Name: domain_domain_updatedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jonas
--

ALTER TABLE ONLY domain
    ADD CONSTRAINT domain_domain_updatedby_fkey FOREIGN KEY (domain_updatedby) REFERENCES member(member);


--
-- Name: mailr_mailr_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jonas
--

ALTER TABLE ONLY mailr
    ADD CONSTRAINT mailr_mailr_domain_fkey FOREIGN KEY (mailr_domain) REFERENCES domain(domain);


--
-- Name: mailr_mailr_member_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jonas
--

ALTER TABLE ONLY mailr
    ADD CONSTRAINT mailr_mailr_member_fkey FOREIGN KEY (mailr_member) REFERENCES member(member);


--
-- Name: mailr_mailr_updatedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jonas
--

ALTER TABLE ONLY mailr
    ADD CONSTRAINT mailr_mailr_updatedby_fkey FOREIGN KEY (mailr_updatedby) REFERENCES member(member);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: address; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE address FROM PUBLIC;
REVOKE ALL ON TABLE address FROM jonas;
GRANT ALL ON TABLE address TO jonas;
GRANT ALL ON TABLE address TO PUBLIC;


--
-- Name: city; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE city FROM PUBLIC;
REVOKE ALL ON TABLE city FROM jonas;
GRANT ALL ON TABLE city TO jonas;
GRANT ALL ON TABLE city TO PUBLIC;


--
-- Name: country; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE country FROM PUBLIC;
REVOKE ALL ON TABLE country FROM jonas;
GRANT ALL ON TABLE country TO jonas;
GRANT ALL ON TABLE country TO PUBLIC;


--
-- Name: county; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE county FROM PUBLIC;
REVOKE ALL ON TABLE county FROM jonas;
GRANT ALL ON TABLE county TO jonas;
GRANT ALL ON TABLE county TO PUBLIC;


--
-- Name: domain; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE domain FROM PUBLIC;
REVOKE ALL ON TABLE domain FROM jonas;
GRANT ALL ON TABLE domain TO jonas;
GRANT ALL ON TABLE domain TO PUBLIC;


--
-- Name: event; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE event FROM PUBLIC;
REVOKE ALL ON TABLE event FROM jonas;
GRANT ALL ON TABLE event TO jonas;


--
-- Name: history; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE history FROM PUBLIC;
REVOKE ALL ON TABLE history FROM jonas;
GRANT ALL ON TABLE history TO jonas;
GRANT ALL ON TABLE history TO PUBLIC;


--
-- Name: intrest; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE intrest FROM PUBLIC;
REVOKE ALL ON TABLE intrest FROM jonas;
GRANT ALL ON TABLE intrest TO jonas;
GRANT ALL ON TABLE intrest TO PUBLIC;


--
-- Name: ipfilter; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE ipfilter FROM PUBLIC;
REVOKE ALL ON TABLE ipfilter FROM jonas;
GRANT ALL ON TABLE ipfilter TO jonas;
GRANT ALL ON TABLE ipfilter TO PUBLIC;


--
-- Name: mailalias; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE mailalias FROM PUBLIC;
REVOKE ALL ON TABLE mailalias FROM jonas;
GRANT ALL ON TABLE mailalias TO jonas;
GRANT ALL ON TABLE mailalias TO PUBLIC;


--
-- Name: mailr; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE mailr FROM PUBLIC;
REVOKE ALL ON TABLE mailr FROM jonas;
GRANT ALL ON TABLE mailr TO jonas;
GRANT ALL ON TABLE mailr TO PUBLIC;


--
-- Name: media; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE media FROM PUBLIC;
REVOKE ALL ON TABLE media FROM jonas;
GRANT ALL ON TABLE media TO jonas;
GRANT ALL ON TABLE media TO PUBLIC;


--
-- Name: member; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE member FROM PUBLIC;
REVOKE ALL ON TABLE member FROM jonas;
GRANT ALL ON TABLE member TO jonas;
GRANT ALL ON TABLE member TO PUBLIC;


--
-- Name: memberhost; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE memberhost FROM PUBLIC;
REVOKE ALL ON TABLE memberhost FROM jonas;
GRANT ALL ON TABLE memberhost TO jonas;
GRANT ALL ON TABLE memberhost TO PUBLIC;


--
-- Name: memo; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE memo FROM PUBLIC;
REVOKE ALL ON TABLE memo FROM jonas;
GRANT ALL ON TABLE memo TO jonas;
GRANT ALL ON TABLE memo TO PUBLIC;


--
-- Name: municipality; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE municipality FROM PUBLIC;
REVOKE ALL ON TABLE municipality FROM jonas;
GRANT ALL ON TABLE municipality TO jonas;
GRANT ALL ON TABLE municipality TO PUBLIC;


--
-- Name: nick; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE nick FROM PUBLIC;
REVOKE ALL ON TABLE nick FROM jonas;
GRANT ALL ON TABLE nick TO jonas;
GRANT ALL ON TABLE nick TO PUBLIC;


--
-- Name: parish; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE parish FROM PUBLIC;
REVOKE ALL ON TABLE parish FROM jonas;
GRANT ALL ON TABLE parish TO jonas;
GRANT ALL ON TABLE parish TO PUBLIC;


--
-- Name: passwd; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE passwd FROM PUBLIC;
REVOKE ALL ON TABLE passwd FROM jonas;
GRANT ALL ON TABLE passwd TO jonas;
GRANT ALL ON TABLE passwd TO PUBLIC;


--
-- Name: payment; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE payment FROM PUBLIC;
REVOKE ALL ON TABLE payment FROM jonas;
GRANT ALL ON TABLE payment TO jonas;
GRANT ALL ON TABLE payment TO PUBLIC;


--
-- Name: plan; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE plan FROM PUBLIC;
REVOKE ALL ON TABLE plan FROM jonas;
GRANT ALL ON TABLE plan TO jonas;


--
-- Name: publ; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE publ FROM PUBLIC;
REVOKE ALL ON TABLE publ FROM jonas;
GRANT ALL ON TABLE publ TO jonas;
GRANT ALL ON TABLE publ TO PUBLIC;


--
-- Name: rel; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE rel FROM PUBLIC;
REVOKE ALL ON TABLE rel FROM jonas;
GRANT ALL ON TABLE rel TO jonas;
GRANT ALL ON TABLE rel TO PUBLIC;


--
-- Name: reltype; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE reltype FROM PUBLIC;
REVOKE ALL ON TABLE reltype FROM jonas;
GRANT ALL ON TABLE reltype TO jonas;
GRANT ALL ON TABLE reltype TO PUBLIC;


--
-- Name: score; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE score FROM PUBLIC;
REVOKE ALL ON TABLE score FROM jonas;
GRANT ALL ON TABLE score TO jonas;
GRANT ALL ON TABLE score TO PUBLIC;


--
-- Name: slogan; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE slogan FROM PUBLIC;
REVOKE ALL ON TABLE slogan FROM jonas;
GRANT ALL ON TABLE slogan TO jonas;
GRANT ALL ON TABLE slogan TO PUBLIC;


--
-- Name: street; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE street FROM PUBLIC;
REVOKE ALL ON TABLE street FROM jonas;
GRANT ALL ON TABLE street TO jonas;
GRANT ALL ON TABLE street TO PUBLIC;


--
-- Name: t; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE t FROM PUBLIC;
REVOKE ALL ON TABLE t FROM jonas;
GRANT ALL ON TABLE t TO jonas;
GRANT ALL ON TABLE t TO PUBLIC;


--
-- Name: talias; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE talias FROM PUBLIC;
REVOKE ALL ON TABLE talias FROM jonas;
GRANT ALL ON TABLE talias TO jonas;
GRANT ALL ON TABLE talias TO PUBLIC;


--
-- Name: ts; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE ts FROM PUBLIC;
REVOKE ALL ON TABLE ts FROM jonas;
GRANT ALL ON TABLE ts TO jonas;
GRANT ALL ON TABLE ts TO PUBLIC;


--
-- Name: zip; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON TABLE zip FROM PUBLIC;
REVOKE ALL ON TABLE zip FROM jonas;
GRANT ALL ON TABLE zip TO jonas;
GRANT ALL ON TABLE zip TO PUBLIC;


--
-- Name: city_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE city_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE city_seq FROM jonas;
GRANT ALL ON SEQUENCE city_seq TO jonas;
GRANT ALL ON SEQUENCE city_seq TO PUBLIC;


--
-- Name: event_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE event_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE event_seq FROM jonas;
GRANT ALL ON SEQUENCE event_seq TO jonas;


--
-- Name: history_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE history_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE history_seq FROM jonas;
GRANT ALL ON SEQUENCE history_seq TO jonas;
GRANT ALL ON SEQUENCE history_seq TO PUBLIC;


--
-- Name: member_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE member_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE member_seq FROM jonas;
GRANT ALL ON SEQUENCE member_seq TO jonas;
GRANT ALL ON SEQUENCE member_seq TO PUBLIC;


--
-- Name: memo_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE memo_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE memo_seq FROM jonas;
GRANT ALL ON SEQUENCE memo_seq TO jonas;
GRANT ALL ON SEQUENCE memo_seq TO PUBLIC;


--
-- Name: plan_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE plan_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE plan_seq FROM jonas;
GRANT ALL ON SEQUENCE plan_seq TO jonas;


--
-- Name: reltype_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE reltype_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE reltype_seq FROM jonas;
GRANT ALL ON SEQUENCE reltype_seq TO jonas;
GRANT ALL ON SEQUENCE reltype_seq TO PUBLIC;


--
-- Name: slogan_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE slogan_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE slogan_seq FROM jonas;
GRANT ALL ON SEQUENCE slogan_seq TO jonas;
GRANT ALL ON SEQUENCE slogan_seq TO PUBLIC;


--
-- Name: street_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE street_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE street_seq FROM jonas;
GRANT ALL ON SEQUENCE street_seq TO jonas;
GRANT ALL ON SEQUENCE street_seq TO PUBLIC;


--
-- Name: t_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE t_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE t_seq FROM jonas;
GRANT ALL ON SEQUENCE t_seq TO jonas;
GRANT ALL ON SEQUENCE t_seq TO PUBLIC;


--
-- Name: tmp_seq; Type: ACL; Schema: public; Owner: jonas
--

REVOKE ALL ON SEQUENCE tmp_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE tmp_seq FROM jonas;
GRANT ALL ON SEQUENCE tmp_seq TO jonas;
GRANT ALL ON SEQUENCE tmp_seq TO PUBLIC;


--
-- PostgreSQL database dump complete
--

