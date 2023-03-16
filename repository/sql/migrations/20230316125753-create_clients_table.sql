-- +migrate Up
-- +migrate StatementBegin
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE
OR REPLACE FUNCTION clients_update_updated_at_column() RETURNS TRIGGER AS $$
BEGIN NEW .updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TABLE IF NOT EXISTS clients (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid DEFAULT NULL,
    domain VARCHAR NOT NULL,
    secret bytea DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    logo VARCHAR DEFAULT NULL,
    internal boolean NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP DEFAULT NULL
);

CREATE TRIGGER update_clients_modtime BEFORE
UPDATE ON clients FOR EACH ROW EXECUTE PROCEDURE clients_update_updated_at_column();
CREATE INDEX clients_user_id ON clients USING BTREE (user_id) WHERE user_id IS NOT NULL;
-- +migrate StatementEnd

-- +migrate Down
DROP TRIGGER IF EXISTS update_clients_modtime ON clients;
DROP TABLE IF EXISTS clients;
DROP FUNCTION IF EXISTS clients_update_updated_at_column();