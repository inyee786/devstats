CREATE TABLE gha_logs (
    id integer NOT NULL,
    dt timestamp without time zone DEFAULT now(),
    msg text
);
ALTER TABLE gha_logs OWNER TO gha_admin;
CREATE SEQUENCE gha_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE gha_logs_id_seq OWNER TO gha_admin;
ALTER SEQUENCE gha_logs_id_seq OWNED BY gha_logs.id;
ALTER TABLE ONLY gha_logs ALTER COLUMN id SET DEFAULT nextval('gha_logs_id_seq'::regclass);
CREATE INDEX logs_dt_idx ON gha_logs USING btree (dt);
CREATE INDEX logs_id_idx ON gha_logs USING btree (id);
