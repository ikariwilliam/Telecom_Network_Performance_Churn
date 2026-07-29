--
-- PostgreSQL database dump
--

\restrict tuX3oMHX4zfTMJfIgQcLNAa85lmsToVQpRPECnHvhU9XLDILCmSUbaapfULHYCf

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cell_towers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cell_towers (
    cell_tower_id integer NOT NULL,
    service_zone_id integer NOT NULL,
    technology character varying(20) NOT NULL,
    subscriber_capacity integer,
    installation_date date
);


ALTER TABLE public.cell_towers OWNER TO postgres;

--
-- Name: macro_regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.macro_regions (
    macro_region_id integer NOT NULL,
    macro_region_name character varying(100) NOT NULL
);


ALTER TABLE public.macro_regions OWNER TO postgres;

--
-- Name: network_incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.network_incidents (
    incident_id integer NOT NULL,
    cell_tower_id integer NOT NULL,
    incident_date date NOT NULL,
    incident_category character varying(50),
    incident_type character varying(100),
    severity character varying(50),
    duration_hours integer
);


ALTER TABLE public.network_incidents OWNER TO postgres;

--
-- Name: network_kpis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.network_kpis (
    cell_tower_id integer NOT NULL,
    kpi_date date NOT NULL,
    signal_strength_rsrp numeric(6,2),
    dropped_call_rate_pct numeric(6,2),
    latency_ms numeric(8,2),
    packet_loss_pct numeric(6,2),
    availability_pct numeric(6,2)
);


ALTER TABLE public.network_kpis OWNER TO postgres;

--
-- Name: plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plans (
    plan_id integer NOT NULL,
    plan_name character varying(100) NOT NULL,
    plan_type character varying(50) NOT NULL,
    monthly_fee_ngn numeric(10,2) NOT NULL,
    data_mb integer,
    voice_min integer,
    target_share numeric(10,6)
);


ALTER TABLE public.plans OWNER TO postgres;

--
-- Name: recharges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recharges (
    recharge_id integer NOT NULL,
    subscriber_id integer NOT NULL,
    recharge_date date NOT NULL,
    amount_ngn numeric(10,2) NOT NULL,
    channel character varying(50)
);


ALTER TABLE public.recharges OWNER TO postgres;

--
-- Name: retention_offers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.retention_offers (
    retention_offer_id integer NOT NULL,
    subscriber_id integer NOT NULL,
    offer_type character varying(100),
    offer_channel character varying(50),
    offer_date date NOT NULL,
    status character varying(50)
);


ALTER TABLE public.retention_offers OWNER TO postgres;

--
-- Name: service_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_zones (
    service_zone_id integer NOT NULL,
    macro_region_id integer NOT NULL,
    zone_name character varying(100) NOT NULL,
    zone_type character varying(50),
    target_share numeric(10,6)
);


ALTER TABLE public.service_zones OWNER TO postgres;

--
-- Name: subscriber_status_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriber_status_history (
    subscriber_id integer NOT NULL,
    status character varying(50) NOT NULL,
    status_date date NOT NULL,
    notes character varying(255)
);


ALTER TABLE public.subscriber_status_history OWNER TO postgres;

--
-- Name: subscribers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscribers (
    subscriber_id integer NOT NULL,
    service_zone_id integer NOT NULL,
    home_tower_id integer NOT NULL,
    plan_id integer NOT NULL,
    gender character varying(20),
    age integer,
    join_date date NOT NULL,
    churn_category character varying(100)
);


ALTER TABLE public.subscribers OWNER TO postgres;

--
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_tickets (
    ticket_id integer NOT NULL,
    subscriber_id integer NOT NULL,
    issue_type character varying(100),
    ticket_date date NOT NULL,
    first_response_time_hours numeric(6,2),
    resolution_time_hours numeric(6,2),
    status character varying(50)
);


ALTER TABLE public.support_tickets OWNER TO postgres;

--
-- Name: usage_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usage_records (
    subscriber_id integer NOT NULL,
    usage_date date NOT NULL,
    cell_tower_id integer NOT NULL,
    peak_period character varying(20),
    is_home_tower boolean,
    voice_minutes numeric(10,2),
    sms_count integer,
    data_mb numeric(10,2)
);


ALTER TABLE public.usage_records OWNER TO postgres;

--
-- Name: cell_towers cell_towers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cell_towers
    ADD CONSTRAINT cell_towers_pkey PRIMARY KEY (cell_tower_id);


--
-- Name: macro_regions macro_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.macro_regions
    ADD CONSTRAINT macro_regions_pkey PRIMARY KEY (macro_region_id);


--
-- Name: network_incidents network_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_incidents
    ADD CONSTRAINT network_incidents_pkey PRIMARY KEY (incident_id);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (plan_id);


--
-- Name: recharges recharges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recharges
    ADD CONSTRAINT recharges_pkey PRIMARY KEY (recharge_id);


--
-- Name: retention_offers retention_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retention_offers
    ADD CONSTRAINT retention_offers_pkey PRIMARY KEY (retention_offer_id);


--
-- Name: service_zones service_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_pkey PRIMARY KEY (service_zone_id);


--
-- Name: subscribers subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_pkey PRIMARY KEY (subscriber_id);


--
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (ticket_id);


--
-- Name: idx_kpis_tower_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kpis_tower_date ON public.network_kpis USING btree (cell_tower_id, kpi_date);


--
-- Name: idx_usage_sub_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usage_sub_date ON public.usage_records USING btree (subscriber_id, usage_date);


--
-- Name: idx_usage_tower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usage_tower ON public.usage_records USING btree (cell_tower_id);


--
-- Name: network_incidents fk_incidents_tower; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_incidents
    ADD CONSTRAINT fk_incidents_tower FOREIGN KEY (cell_tower_id) REFERENCES public.cell_towers(cell_tower_id);


--
-- Name: network_kpis fk_kpis_tower; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_kpis
    ADD CONSTRAINT fk_kpis_tower FOREIGN KEY (cell_tower_id) REFERENCES public.cell_towers(cell_tower_id);


--
-- Name: retention_offers fk_offers_subscriber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retention_offers
    ADD CONSTRAINT fk_offers_subscriber FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(subscriber_id);


--
-- Name: recharges fk_recharges_subscriber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recharges
    ADD CONSTRAINT fk_recharges_subscriber FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(subscriber_id);


--
-- Name: subscriber_status_history fk_ssh_subscriber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriber_status_history
    ADD CONSTRAINT fk_ssh_subscriber FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(subscriber_id);


--
-- Name: subscribers fk_subs_plan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT fk_subs_plan FOREIGN KEY (plan_id) REFERENCES public.plans(plan_id);


--
-- Name: subscribers fk_subs_tower; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT fk_subs_tower FOREIGN KEY (home_tower_id) REFERENCES public.cell_towers(cell_tower_id);


--
-- Name: subscribers fk_subs_zone; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT fk_subs_zone FOREIGN KEY (service_zone_id) REFERENCES public.service_zones(service_zone_id);


--
-- Name: service_zones fk_sz_macro_region; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT fk_sz_macro_region FOREIGN KEY (macro_region_id) REFERENCES public.macro_regions(macro_region_id);


--
-- Name: support_tickets fk_tickets_subscriber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT fk_tickets_subscriber FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(subscriber_id);


--
-- Name: cell_towers fk_towers_service_zone; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cell_towers
    ADD CONSTRAINT fk_towers_service_zone FOREIGN KEY (service_zone_id) REFERENCES public.service_zones(service_zone_id);


--
-- Name: usage_records fk_usage_subscriber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_records
    ADD CONSTRAINT fk_usage_subscriber FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(subscriber_id);


--
-- Name: usage_records fk_usage_tower; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_records
    ADD CONSTRAINT fk_usage_tower FOREIGN KEY (cell_tower_id) REFERENCES public.cell_towers(cell_tower_id);


--
-- PostgreSQL database dump complete
--

\unrestrict tuX3oMHX4zfTMJfIgQcLNAa85lmsToVQpRPECnHvhU9XLDILCmSUbaapfULHYCf

