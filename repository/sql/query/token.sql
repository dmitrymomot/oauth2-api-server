-- name: CreateToken :exec
INSERT INTO tokens (client_id, user_id, redirect_uri, scope, code, code_challenge, code_challenge_method, code_create_at, code_expires_in, access_id, access_create_at, access_expires_in, refresh_id, refresh_create_at, refresh_expires_in) 
VALUES (@client_id, @user_id, @redirect_uri, @scope, @code, @code_challenge, @code_challenge_method, @code_create_at, @code_expires_in, @access_id, @access_create_at, @access_expires_in, @refresh_id, @refresh_create_at, @refresh_expires_in) 
ON CONFLICT (client_id, user_id) 
DO UPDATE SET 
    redirect_uri = @redirect_uri, 
    scope = @scope, 
    code = @code, 
    code_challenge = @code_challenge, 
    code_challenge_method = @code_challenge_method, 
    code_create_at = @code_create_at, 
    code_expires_in = @code_expires_in, 
    access_id = @access_id, 
    access_create_at = @access_create_at, 
    access_expires_in = @access_expires_in, 
    refresh_id = @refresh_id, 
    refresh_create_at = @refresh_create_at, 
    refresh_expires_in = @refresh_expires_in;

-- name: GetTokenByCode :one
SELECT * FROM tokens WHERE code = $1;

-- name: GetTokenByAccess :one
SELECT * FROM tokens WHERE access_id = $1;

-- name: GetTokenByRefresh :one
SELECT * FROM tokens WHERE refresh_id = $1;

-- name: RemoveTokenByCode :exec
DELETE FROM tokens WHERE code = $1;

-- name: RemoveTokenByAccess :exec
DELETE FROM tokens WHERE access_id = $1;

-- name: RemoveTokenByRefresh :exec
DELETE FROM tokens WHERE refresh_id = $1;