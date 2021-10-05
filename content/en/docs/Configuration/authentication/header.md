---
title: "Header strategy"
date: 2021-01-08T00:00:00+02:00
draft: false
weight: 9
---

## Introduction

The `header` strategy assumes a reverse proxy is in front of Kiali, such as 
OpenUnison or OAuth2 Proxy, injecting the user's identity into each request to
Kiali as an `Authorization` header.  This token can be an OpenID Connect
token or any other token the cluster recognizes.  All requests to Kubernetes
will be made with this token, allowing Kiali to use the user's own RBAC 
context.

In addition to a user token, the `header` strategy supports impersonation
headers.  If the impersonation headers are present in the request, then Kiali
will act on behalf of the user specified by the impersonation (assuming the
token supplied in the `Authorization` header is authorized to do so).

The `header` strategy takes advantage of the cluster's RBAC. See the
[Role-based access control documentation]({{< relref "../rbac" >}}) for more details.

## Set-up

The `header` strategy will work with any Kubernetes cluster.  The token provided 
must be supported by that cluster.  For instance, most "on-prem" clusters support
OpenID Connect, but cloud hosted clusters do not.  For clusters that don't support 
a token, the [impersonation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation)
headers can be injected by the reverse proxy.

```yaml
spec:
  auth:
    strategy: header
```

The `header` strategy doesn't have any additional configuration.

## HTTP Header

The `header` strategy looks for a token in the `Authorization` HTTP header with the 
`Bearer` prefix.  The HTTP header should look like:

```
Authorization: Bearer TOKEN
```

Where `TOKEN` is the appropriate token for your cluster.  This `TOKEN` will be 
submitted to the API server via a `TokenReview` to validate the token *ONLY*
on the first access to Kiali.  On subsequent calls the `TOKEN` is passed through
directly to the API server.

## Security Considerations

### Network Policies

A policy should be put in place to make sure that the only "client" for Kiali is
the authenticating reverse proxy.  This helps limit potential abuse and ensures 
that the authenticating reverse proxy is the source of truth for who accessed
Kiali.

### Short Lived Tokens

The authenticating reverse proxy should inject a short lived token in the 
`Authorization` header.  A shorter lived token is less likely to be abused if 
leaked.  Kiali will take whatever token is passed into the reqeuest, so as tokens 
are regenerated Kiali will use the new token.

### Impersonation

#### TokenRequest API

The authenticating reverse proxy should use the TokenRequest API instead of static 
`ServiceAccount` tokens when possible while using impersonation. The 
`ServiceAccount` that can impersonate users and groups is privileged and having it
be short lived cuts down on the possibility of a token being leaked while it's being 
passed between different parts of the infrastructure.

#### Drop Incoming Impersonation Headers

The authenticating proxy *MUST* drop any headers it receives from a remote client 
that match the impersonation headers.  Not only do you want to make sure that the
authenticating proxy can't be overriden on which user to authenticate, but also
what groups they're a member of. 

