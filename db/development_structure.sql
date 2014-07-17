--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cards (
    id integer NOT NULL,
    user_id integer,
    stripe_card_id character varying(255),
    last4 character varying(255),
    brand character varying(255),
    funding character varying(255),
    exp_month character varying(255),
    exp_year character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cards_id_seq OWNED BY cards.id;


--
-- Name: cars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cars (
    id integer NOT NULL,
    driver_id integer,
    make character varying(255),
    model character varying(255),
    license_plate character varying(255),
    state character varying(255),
    location geography(Point,4326),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    year character varying(255),
    car_photo_file_name character varying(255),
    car_photo_content_type character varying(255),
    car_photo_file_size integer,
    car_photo_updated_at timestamp without time zone
);


--
-- Name: cars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cars_id_seq OWNED BY cars.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE devices (
    id integer NOT NULL,
    user_id integer,
    hardware character varying(255),
    os character varying(255),
    platform character varying(255),
    push_token character varying(255),
    uuid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE devices_id_seq OWNED BY devices.id;


--
-- Name: driver_location_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE driver_location_histories (
    id integer NOT NULL,
    driver_id integer,
    fare_id integer,
    datetime timestamp without time zone,
    location geography(Point,4326),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: driver_location_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE driver_location_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: driver_location_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE driver_location_histories_id_seq OWNED BY driver_location_histories.id;


--
-- Name: driver_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE driver_roles (
    id integer NOT NULL,
    state character varying(255),
    user_id integer,
    drivers_license_file_name character varying(255),
    drivers_license_content_type character varying(255),
    drivers_license_file_size integer,
    drivers_license_updated_at timestamp without time zone,
    vehicle_registration_file_name character varying(255),
    vehicle_registration_content_type character varying(255),
    vehicle_registration_file_size integer,
    vehicle_registration_updated_at timestamp without time zone,
    proof_of_insurance_file_name character varying(255),
    proof_of_insurance_content_type character varying(255),
    proof_of_insurance_file_size integer,
    proof_of_insurance_updated_at timestamp without time zone,
    car_photo_file_name character varying(255),
    car_photo_content_type character varying(255),
    car_photo_file_size integer,
    car_photo_updated_at timestamp without time zone,
    national_database_check_file_name character varying(255),
    national_database_check_content_type character varying(255),
    national_database_check_file_size integer,
    national_database_check_updated_at timestamp without time zone,
    drivers_license_number character varying(255)
);


--
-- Name: driver_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE driver_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: driver_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE driver_roles_id_seq OWNED BY driver_roles.id;


--
-- Name: offered_rides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offered_rides (
    id integer NOT NULL,
    driver_id integer,
    ride_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255)
);


--
-- Name: offered_rides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE offered_rides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offered_rides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE offered_rides_id_seq OWNED BY offered_rides.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    fare_id integer,
    rider_id integer,
    driver_id integer,
    stripe_customer_id character varying(255),
    stripe_charge_id character varying(255),
    amount_cents integer,
    stripe_charge_status character varying(255),
    initiation character varying(255),
    captured_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    driver_earnings_cents integer
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: ride_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ride_requests (
    id integer NOT NULL,
    user_id integer,
    ride_id integer,
    state character varying(255),
    request_type character varying(255),
    requested_datetime timestamp without time zone,
    origin geography(Point,4326),
    origin_place_name character varying(255),
    destination geography(Point,4326),
    destination_place_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    desired_arrival timestamp without time zone
);


--
-- Name: ride_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ride_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ride_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ride_requests_id_seq OWNED BY ride_requests.id;


--
-- Name: rider_rides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rider_rides (
    id integer NOT NULL,
    rider_id integer,
    ride_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rider_rides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rider_rides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rider_rides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rider_rides_id_seq OWNED BY rider_rides.id;


--
-- Name: rider_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rider_roles (
    id integer NOT NULL,
    state character varying(255),
    user_id integer
);


--
-- Name: rider_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rider_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rider_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rider_roles_id_seq OWNED BY rider_roles.id;


--
-- Name: rides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rides (
    id integer NOT NULL,
    driver_id integer,
    car_id integer,
    state character varying(255),
    scheduled timestamp without time zone,
    started timestamp without time zone,
    finished timestamp without time zone,
    meeting_point geography(Point,4326),
    meeting_point_place_name character varying(255),
    drop_off_point geography(Point,4326),
    drop_off_point_place_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pickup_time timestamp without time zone
);


--
-- Name: rides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rides_id_seq OWNED BY rides.id;


--
-- Name: rpush_apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rpush_apps (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    environment character varying(255),
    certificate text,
    password character varying(255),
    connections integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying(255) NOT NULL,
    auth_key character varying(255),
    client_id character varying(255),
    client_secret character varying(255),
    access_token character varying(255),
    access_token_expiration timestamp without time zone
);


--
-- Name: rpush_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rpush_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rpush_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rpush_apps_id_seq OWNED BY rpush_apps.id;


--
-- Name: rpush_feedback; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rpush_feedback (
    id integer NOT NULL,
    device_token character varying(64) NOT NULL,
    failed_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    app character varying(255)
);


--
-- Name: rpush_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rpush_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rpush_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rpush_feedback_id_seq OWNED BY rpush_feedback.id;


--
-- Name: rpush_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rpush_notifications (
    id integer NOT NULL,
    badge integer,
    device_token character varying(64),
    sound character varying(255) DEFAULT 'default'::character varying,
    alert character varying(255),
    data text,
    expiry integer DEFAULT 86400,
    delivered boolean DEFAULT false NOT NULL,
    delivered_at timestamp without time zone,
    failed boolean DEFAULT false NOT NULL,
    failed_at timestamp without time zone,
    error_code integer,
    error_description text,
    deliver_after timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    alert_is_json boolean DEFAULT false,
    type character varying(255) NOT NULL,
    collapse_key character varying(255),
    delay_while_idle boolean DEFAULT false NOT NULL,
    registration_ids text,
    app_id integer NOT NULL,
    retries integer DEFAULT 0,
    uri character varying(255),
    fail_after timestamp without time zone
);


--
-- Name: rpush_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rpush_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rpush_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rpush_notifications_id_seq OWNED BY rpush_notifications.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    stripe_customer_id character varying(255),
    stripe_recipient_id character varying(255),
    company_id integer,
    first_name character varying(255),
    last_name character varying(255),
    is_driver boolean,
    is_rider boolean,
    commuter_balance_cents integer,
    commuter_refill_amount_cents integer,
    location geography(Point,4326),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rider_location geometry(Point,4326),
    phone character varying(255),
    password character varying(255),
    email character varying(255),
    referral_code character varying(255),
    salt character varying(255),
    token character varying(255),
    driver_request_region character varying(255),
    driver_referral_code character varying(255),
    webtoken character varying(255),
    demo boolean,
    current_fare_id integer,
    car_id integer
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards ALTER COLUMN id SET DEFAULT nextval('cards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cars ALTER COLUMN id SET DEFAULT nextval('cars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices ALTER COLUMN id SET DEFAULT nextval('devices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY driver_location_histories ALTER COLUMN id SET DEFAULT nextval('driver_location_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY driver_roles ALTER COLUMN id SET DEFAULT nextval('driver_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY offered_rides ALTER COLUMN id SET DEFAULT nextval('offered_rides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ride_requests ALTER COLUMN id SET DEFAULT nextval('ride_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rider_rides ALTER COLUMN id SET DEFAULT nextval('rider_rides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rider_roles ALTER COLUMN id SET DEFAULT nextval('rider_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rides ALTER COLUMN id SET DEFAULT nextval('rides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_apps ALTER COLUMN id SET DEFAULT nextval('rpush_apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_feedback ALTER COLUMN id SET DEFAULT nextval('rpush_feedback_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_notifications ALTER COLUMN id SET DEFAULT nextval('rpush_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: cars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cars
    ADD CONSTRAINT cars_pkey PRIMARY KEY (id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: driver_location_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY driver_location_histories
    ADD CONSTRAINT driver_location_histories_pkey PRIMARY KEY (id);


--
-- Name: driver_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY driver_roles
    ADD CONSTRAINT driver_roles_pkey PRIMARY KEY (id);


--
-- Name: offered_rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offered_rides
    ADD CONSTRAINT offered_rides_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: rapns_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rpush_apps
    ADD CONSTRAINT rapns_apps_pkey PRIMARY KEY (id);


--
-- Name: rapns_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rpush_feedback
    ADD CONSTRAINT rapns_feedback_pkey PRIMARY KEY (id);


--
-- Name: rapns_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rpush_notifications
    ADD CONSTRAINT rapns_notifications_pkey PRIMARY KEY (id);


--
-- Name: ride_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ride_requests
    ADD CONSTRAINT ride_requests_pkey PRIMARY KEY (id);


--
-- Name: rider_rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rider_rides
    ADD CONSTRAINT rider_rides_pkey PRIMARY KEY (id);


--
-- Name: rider_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rider_roles
    ADD CONSTRAINT rider_roles_pkey PRIMARY KEY (id);


--
-- Name: rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rides
    ADD CONSTRAINT rides_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_rpush_feedback_on_device_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rpush_feedback_on_device_token ON rpush_feedback USING btree (device_token);


--
-- Name: index_rpush_notifications_multi; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rpush_notifications_multi ON rpush_notifications USING btree (app_id, delivered, failed, deliver_after);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

