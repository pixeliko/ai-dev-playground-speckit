# Local Operator Bootstrap

This design supplies a usable first login for a fresh local Helio installation. It
does not grant an operator access to every project. The first authenticated operator
can create a project and becomes its Owner. Owner and Tech Lead rights remain scoped
to each project.

## First setup

`make install` runs the local bootstrap step on the host. It asks for an operator
name and a passphrase through a private terminal prompt. It creates the first
operator only if no operator exists. It does not use a shared default password, a
test fixture, or an unauthenticated web endpoint. A repeated setup reports that
bootstrap is complete and does not replace the existing credential. The operator
record and a random-salt `hashlib.scrypt` passphrase hash live in a protected
local auth store outside project records. The installer checks file ownership
and restrictive permissions before it starts the API. It never prints or logs
the passphrase.

The local API binds to loopback by default. A non-loopback deployment must provide
TLS and an explicit identity configuration before it accepts credentials. External
identity providers can implement the same identity port later; they are optional
for the local setup.

## Sessions and dashboard

`POST /api/v1/auth/sessions` exchanges valid local credentials for a random,
opaque, expiring bearer token. The response returns the token once. Only a token
hash, operator ID, expiry, and revocation state are stored. Failed logins are
audited without the passphrase and are throttled. `GET
/api/v1/auth/sessions/current` returns the active operator identity. `DELETE
/api/v1/auth/sessions/current` revokes that session. Expired or revoked tokens
receive HTTP 401. A valid token alone does not grant a project role.

The dashboard uses `/dashboard/login` to create the same kind of session. It keeps
the session in an HttpOnly, SameSite cookie; the cookie is Secure when TLS is used.
Cookie-based mutations require a CSRF token. Dashboard logout revokes the current
session and clears the cookie. The machine API uses the bearer header defined in
the [source contract](../../specs/001-helio-agent-platform/contracts/openapi.yaml).

## Recovery and audit

`make operator-recover` is a local host-console operation. It verifies control of
the protected auth store, asks for a new passphrase, rotates the credential, and
revokes all existing local sessions. It does not expose a remote recovery endpoint
or create a global authorization bypass. The state owner records bootstrap,
authentication failure, session revocation, and recovery events without secrets.
Project membership and action denials remain separate project audit events.

## Contract impact

The draft API adds session create, current-session read, and current-session
revoke operations. It changes the `OperatorToken` description to state where the
first local identity comes from. These are additive changes to the unpublished
0.1.0 source contract; no deployed client migration is claimed. The installer,
identity adapter, dashboard, and contract tests must implement this contract
before the local control plane is accepted.
