-- +migrate Up
-- +migrate StatementBegin
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS tokens (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id uuid NOT NULL REFERENCES clients (id) ON DELETE CASCADE,
    user_id uuid DEFAULT NULL REFERENCES users (id) ON DELETE CASCADE,
    redirect_uri VARCHAR NOT NULL,
    scope VARCHAR NOT NULL,
    code VARCHAR NOT NULL,
    code_challenge VARCHAR NOT NULL,
    code_challenge_method VARCHAR NOT NULL,
    code_create_at TIMESTAMP NOT NULL DEFAULT now(),
    code_expires_in BIGINT NOT NULL,
    access_id uuid NOT NULL,
    access_create_at TIMESTAMP NOT NULL DEFAULT now(),
    access_expires_in BIGINT NOT NULL,
    refresh_id uuid NOT NULL,
    refresh_create_at TIMESTAMP NOT NULL DEFAULT now(),
    refresh_expires_in BIGINT NOT NULL,
    user_agent VARCHAR DEFAULT NULL,
    ip_address VARCHAR DEFAULT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS tokens_code ON tokens USING BTREE (code) WHERE code IS NOT NULL AND code != '';
CREATE UNIQUE INDEX IF NOT EXISTS tokens_access ON tokens USING BTREE (access_id);
CREATE UNIQUE INDEX IF NOT EXISTS tokens_refresh ON tokens USING BTREE (refresh_id);
CREATE UNIQUE INDEX IF NOT EXISTS tokens_client_user_uniq ON tokens USING BTREE (client_id, user_id) 
    WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS tokens_user_agent ON tokens (user_id, user_agent) 
    WHERE user_agent IS NOT NULL AND user_agent != '' AND user_id IS NOT NULL;
-- +migrate StatementEnd

-- +migrate Down
DROP TABLE IF EXISTS tokens;
