---
title: "Keycloak"
---

CRM Gateway uses Keycloak for authentication.

## Gems

The plan is to use a combination of three gems to perform authentication:

- omniauth-keycloak
- omniauth
- devise

Instructions for beginning integration can be found at [https://github.com/ccrockett/omniauth-keycloak#devise-usage](https://github.com/ccrockett/omniauth-keycloak#devise-usage).

An important implementation note is that while the user session will be backed by a Mongoid model, the User model will not. The token from keycloak should provide all required user attributes and roles.

The role we want to ensure the user has in order to visit the application is called `crm_transaction_admin`.

## Outstanding Questions and Problems to Solve

1. What gem is used (or is it provided by devise/omniauth) to persist user sessions in Mongoid?
2. How are timeouts and renewal of tokens against keycloak handled?

## Configuration in Keycloak

The following steps in Keycloak will need to be performed for any realm to which we are planning to authenticate:

1. Creation of a new client using the existing keycloak OAuth identity provider.
2. Creation of a new role called `crm_transaction_admin` in the realm.
