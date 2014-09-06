--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cards (
    id integer NOT NULL,
    rider_id integer,
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
-- Name: fares; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fares (
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
    pickup_time timestamp without time zone,
    fixed_earnings integer DEFAULT 0
);


--
-- Name: fares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fares_id_seq OWNED BY fares.id;


--
-- Name: offers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offers (
    id integer NOT NULL,
    driver_id integer,
    fare_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255)
);


--
-- Name: offers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE offers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE offers_id_seq OWNED BY offers.id;


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
    driver_earnings_cents integer,
    ride_id integer,
    paid boolean
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
-- Name: payouts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payouts (
    id integer NOT NULL,
    driver_id integer,
    date timestamp without time zone,
    amount_cents integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    stripe_transfer_id character varying(255)
);


--
-- Name: payouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payouts_id_seq OWNED BY payouts.id;


--
-- Name: rides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rides (
    id integer NOT NULL,
    rider_id integer,
    fare_id integer,
    state character varying(255),
    request_type character varying(255),
    requested_datetime timestamp without time zone,
    origin geography(Point,4326),
    origin_place_name character varying(255),
    destination geography(Point,4326),
    destination_place_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pickup_time timestamp with time zone,
    driving boolean,
    trip_id integer,
    direction character varying(255),
    fixed_price integer
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
-- Name: rides_summary_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW rides_summary_view AS
 SELECT rides.trip_id,
    rides.direction,
    rides.state,
    rides.pickup_time,
    rides.driving,
    timezone('PDT'::text, rides.pickup_time) AS timezone
   FROM rides;


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
-- Name: trips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trips (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    state character varying(255),
    notified boolean DEFAULT false
);


--
-- Name: trips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trips_id_seq OWNED BY trips.id;


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
    car_id integer,
    commuter_refill_enabled boolean,
    bank_account_name character varying(255),
    driver_state character varying(255),
    rider_state character varying(255),
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
    national_database_check_file_name character varying(255),
    national_database_check_content_type character varying(255),
    national_database_check_file_size integer,
    national_database_check_updated_at timestamp without time zone,
    drivers_license_number character varying(255),
    commuter_pickup_time character varying(255),
    commuter_origin geometry(Point),
    commuter_destination geometry(Point),
    commuter_return_time character varying(255),
    recipient_card_brand character varying(255),
    recipient_card_exp_month character varying(255),
    recipient_card_month character varying(255),
    recipient_card_last4 character varying(255)
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

ALTER TABLE ONLY fares ALTER COLUMN id SET DEFAULT nextval('fares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY offers ALTER COLUMN id SET DEFAULT nextval('offers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payouts ALTER COLUMN id SET DEFAULT nextval('payouts_id_seq'::regclass);


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

ALTER TABLE ONLY trips ALTER COLUMN id SET DEFAULT nextval('trips_id_seq'::regclass);


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
-- Name: offered_rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offers
    ADD CONSTRAINT offered_rides_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payouts
    ADD CONSTRAINT payouts_pkey PRIMARY KEY (id);


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

ALTER TABLE ONLY rides
    ADD CONSTRAINT ride_requests_pkey PRIMARY KEY (id);


--
-- Name: rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fares
    ADD CONSTRAINT rides_pkey PRIMARY KEY (id);


--
-- Name: table_trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT table_trips_pkey PRIMARY KEY (id);


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
-- Name: rides_rider_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rides
    ADD CONSTRAINT rides_rider_id_fk FOREIGN KEY (rider_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140523011016');

INSERT INTO schema_migrations (version) VALUES ('20140523011018');

INSERT INTO schema_migrations (version) VALUES ('20140523011309');

INSERT INTO schema_migrations (version) VALUES ('20140523011345');

INSERT INTO schema_migrations (version) VALUES ('20140523011347');

INSERT INTO schema_migrations (version) VALUES ('20140523011350');

INSERT INTO schema_migrations (version) VALUES ('20140523224324');

INSERT INTO schema_migrations (version) VALUES ('20140523231216');

INSERT INTO schema_migrations (version) VALUES ('20140524014750');

INSERT INTO schema_migrations (version) VALUES ('20140524030533');

INSERT INTO schema_migrations (version) VALUES ('20140524033522');

INSERT INTO schema_migrations (version) VALUES ('20140524040642');

INSERT INTO schema_migrations (version) VALUES ('20140527201119');

INSERT INTO schema_migrations (version) VALUES ('20140528000417');

INSERT INTO schema_migrations (version) VALUES ('20140529231120');

INSERT INTO schema_migrations (version) VALUES ('20140609032342');

INSERT INTO schema_migrations (version) VALUES ('20140609032948');

INSERT INTO schema_migrations (version) VALUES ('20140609033003');

INSERT INTO schema_migrations (version) VALUES ('20140609033104');

INSERT INTO schema_migrations (version) VALUES ('20140609055440');

INSERT INTO schema_migrations (version) VALUES ('20140609060248');

INSERT INTO schema_migrations (version) VALUES ('20140609194806');

INSERT INTO schema_migrations (version) VALUES ('20140609195636');

INSERT INTO schema_migrations (version) VALUES ('20140609195705');

INSERT INTO schema_migrations (version) VALUES ('20140609200048');

INSERT INTO schema_migrations (version) VALUES ('20140609200128');

INSERT INTO schema_migrations (version) VALUES ('20140609200135');

INSERT INTO schema_migrations (version) VALUES ('20140609222744');

INSERT INTO schema_migrations (version) VALUES ('20140610001847');

INSERT INTO schema_migrations (version) VALUES ('20140618203022');

INSERT INTO schema_migrations (version) VALUES ('20140619051846');

INSERT INTO schema_migrations (version) VALUES ('20140619052055');

INSERT INTO schema_migrations (version) VALUES ('20140619071122');

INSERT INTO schema_migrations (version) VALUES ('20140619071629');

INSERT INTO schema_migrations (version) VALUES ('20140619072814');

INSERT INTO schema_migrations (version) VALUES ('20140628071158');

INSERT INTO schema_migrations (version) VALUES ('20140703064003');

INSERT INTO schema_migrations (version) VALUES ('20140707205309');

INSERT INTO schema_migrations (version) VALUES ('20140708221243');

INSERT INTO schema_migrations (version) VALUES ('20140715004033');

INSERT INTO schema_migrations (version) VALUES ('20140715011119');

INSERT INTO schema_migrations (version) VALUES ('20140716041228');

INSERT INTO schema_migrations (version) VALUES ('20140716045214');

INSERT INTO schema_migrations (version) VALUES ('20140716045640');

INSERT INTO schema_migrations (version) VALUES ('20140716205436');

INSERT INTO schema_migrations (version) VALUES ('20140716232620');

INSERT INTO schema_migrations (version) VALUES ('20140717002339');

INSERT INTO schema_migrations (version) VALUES ('20140717013238');

INSERT INTO schema_migrations (version) VALUES ('20140717022308');

INSERT INTO schema_migrations (version) VALUES ('20140717032649');

INSERT INTO schema_migrations (version) VALUES ('20140717044127');

INSERT INTO schema_migrations (version) VALUES ('20140717055403');

INSERT INTO schema_migrations (version) VALUES ('20140717093604');

INSERT INTO schema_migrations (version) VALUES ('20140717100519');

INSERT INTO schema_migrations (version) VALUES ('20140718012544');

INSERT INTO schema_migrations (version) VALUES ('20140718063716');

INSERT INTO schema_migrations (version) VALUES ('20140722212042');

INSERT INTO schema_migrations (version) VALUES ('20140723232128');

INSERT INTO schema_migrations (version) VALUES ('20140724172153');

INSERT INTO schema_migrations (version) VALUES ('20140724173034');

INSERT INTO schema_migrations (version) VALUES ('20140724174513');

INSERT INTO schema_migrations (version) VALUES ('20140724183337');

INSERT INTO schema_migrations (version) VALUES ('20140724183654');

INSERT INTO schema_migrations (version) VALUES ('20140724183911');

INSERT INTO schema_migrations (version) VALUES ('20140724203223');

INSERT INTO schema_migrations (version) VALUES ('20140724211608');

INSERT INTO schema_migrations (version) VALUES ('20140728201331');

INSERT INTO schema_migrations (version) VALUES ('20140803021908');

INSERT INTO schema_migrations (version) VALUES ('20140804025314');

INSERT INTO schema_migrations (version) VALUES ('20140810020443');

INSERT INTO schema_migrations (version) VALUES ('20140810020546');

INSERT INTO schema_migrations (version) VALUES ('20140810073014');

INSERT INTO schema_migrations (version) VALUES ('20140810073441');

INSERT INTO schema_migrations (version) VALUES ('20140810073604');

INSERT INTO schema_migrations (version) VALUES ('20140816173623');

INSERT INTO schema_migrations (version) VALUES ('20140816221915');

INSERT INTO schema_migrations (version) VALUES ('20140816222253');

INSERT INTO schema_migrations (version) VALUES ('20140817024244');

INSERT INTO schema_migrations (version) VALUES ('20140818013652');

INSERT INTO schema_migrations (version) VALUES ('20140823235842');

INSERT INTO schema_migrations (version) VALUES ('20140828014343');

INSERT INTO schema_migrations (version) VALUES ('20140828014459');

INSERT INTO schema_migrations (version) VALUES ('20140828014630');

INSERT INTO schema_migrations (version) VALUES ('20140828015919');

INSERT INTO schema_migrations (version) VALUES ('20140830020701');

INSERT INTO schema_migrations (version) VALUES ('20140905234323');

