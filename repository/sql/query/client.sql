-- name: CreateClient :one
INSERT INTO clients (
    user_id,
    domain,
    secret,
    name,
    description,
    logo,
    internal
) VALUES (
    @user_id,
    @domain,
    @secret,
    @name,
    @description,
    @logo,
    @internal
) RETURNING *;

-- name: GetClient :one
SELECT * FROM clients WHERE id = @id;

-- name: GetClientsByUserID :many
SELECT * FROM clients WHERE user_id = @user_id ORDER BY created_at DESC;

-- name: UpdateClient :one
UPDATE clients SET
    domain = @domain,
    name = @name,
    description = @description,
    logo = @logo
WHERE id = @id
RETURNING *;

-- name: UpdateClientSecret :one
UPDATE clients SET secret = @secret WHERE id = @id RETURNING *;

-- name: DeleteClient :exec
DELETE FROM clients WHERE id = @id;