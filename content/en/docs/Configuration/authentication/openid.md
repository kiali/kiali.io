---
title: "OpenID Connect strategy"
linktitle: "OpenID Connect"
description: "Access Kiali requiring authentication through a third-party _OpenID Connect_ provider."
weight: 30
---

## Introduction

The `openid` authentication strategy lets you integrate Kiali to an external
identity provider that implements [OpenID Connect](https://openid.net/connect/), and allows
users to login to Kiali using their existing accounts of a
third-party system.

If your
[Kubernetes cluster is also integrated with your OpenId provider](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens),
then Kiali's `openid` strategy can offer 
[namespace access control]({{< relref "../rbac" >}}).

Kiali only supports the _authorization code flow_ of the [OpenId Connect spec](https://openid.net/connect/).

## Requirements

The [Kiali's signing key]({{< relref "session-configs" >}}) needs to be 16, 24
or 32 byte long. If you install Kiali via the operator and don't set a custom
signing key, the operator should create a 16 byte long signing key.

If you *_don't need_* namespace access control support, you can use any
working OpenId Server where Kiali can be configured as a client application.

If you *_do need_* namespace access control support, you need either:

* A [Kubernetes cluster configured with OpenID connect integration](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens),
which results in the API server accepting tokens issued by your identity provider.
* A replacement or reverse proxy for the Kubernetes cluster API capable of handling the OIDC authentication.

The first option is preferred if you can manipulate your cluster API server
startup flags, which will result in your cluster to also be integrated with the
external OpenID provider.

The second option is provided for cases where you are using a managed
Kubernetes and your cloud provider does not support configuring OpenID
integration. Kiali assumes an implementation of a Kubernetes API server. For
example, a community user has reported to successfully configure Kiali's OpenID
strategy by using
[`kube-oidc-proxy`](https://github.com/jetstack/kube-oidc-proxy) which is a
reverse proxy that handles the OpenID authentication and forwards the
authenticated requests to the Kubernetes API.

## Set-up with namespace access control support {#setup-with-rbac}

Assuming you already have a working Kubernetes cluster with OpenId integration
(or a working alternative like `kube-oidc-proxy`), you should already had
configured an _application_ or a _client_ in your OpenId server (some cloud
providers configure this app/client automatically for you). You must re-use
this existing _application/client_ by adding the root path of your Kiali
instance as an allowed/authorized callback URL. If the OpenID server provided
you a _client secret_ for the application/client, or if you had manually set a
_client secret_, issue the following command to create a Kubernetes secret
holding the OpenId client secret:

```
kubectl create secret generic kiali --from-literal="oidc-secret=$CLIENT_SECRET" -n $NAMESPACE
```

where `$NAMESPACE` is the namespace where you installed Kiali and
`$CLIENT_SECRET` is the secret you configured or provided by your OpenId
Server. If Kiali is already running, you may need to restart the Kiali pod so
that the secret is mounted in Kiali.

{{% alert color="warning" %}}
It's worth emphasizing that to configure OpenID
integration you must re-use the OpenID application/client that you created for
your Kubernetes cluster. If you create a new application/client for Kiali in
your OpenId server, Kiali will fail to properly authenticate users.
{{% /alert %}}

Then, to enable the OpenID Connect strategy, the minimal configuration you need to
set in the Kiali CR is like the following:

```yaml
spec:
  auth:
    strategy: openid
    openid:
      client_id: "kiali-client"
      issuer_uri: "https://openid.issuer.com"
```

This assumes that your Kubernetes cluster is configured with OpenID Connect
integration. In this case, the `client-id` and `issuer_uri` attributes must
match the `--oidc-client-id` and `--oidc-issuer-url` flags
[used to start the cluster API server](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#configuring-the-api-server).
If these values don't match, users will fail to login to Kiali.

If you are using a replacement or a reverse proxy for the Kubernetes API
server, the minimal configuration is like the following:

```yaml
spec:
  auth:
    strategy: openid
    openid:
      api_proxy: "https://proxy.domain.com:port"
      api_proxy_ca_data: "..."
      client_id: "kiali-client"
      issuer_uri: "https://openid.issuer.com"
```

The value of `client-id` and `issuer_uri` must match the values of the
configuration of your reverse proxy or cluster API replacement. The `api_proxy`
attribute is the URI of the reverse proxy or cluster API replacement (only
HTTPS is allowed). The `api_proxy_ca_data` is the public certificate authority
file encoded in a base64 string, to trust the secure connection.

## Set-up with no namespace access control support

Register Kiali as a client application in your OpenId Server. Use the root path
of your Kiali instance as the callback URL. If the OpenId Server provides you a
_client secret_, or if you manually set a _client secret_, issue the following
command to create a Kubernetes secret holding the OpenId client secret:

```
kubectl create secret generic kiali --from-literal="oidc-secret=$CLIENT_SECRET" -n $NAMESPACE
```

where `$NAMESPACE` is the namespace where you installed Kiali and
`$CLIENT_SECRET` is the secret you configured or provided by your OpenId
Server. If Kiali is already running, you may need to restart the Kiali pod so
that the secret is mounted in Kiali.

Then, to enable the OpenID Connect strategy, the minimal configuration you need
to set in the Kiali CR is like the following:

```yaml
spec:
  auth:
    strategy: openid
    openid:
      client_id: "kiali-client"
      disable_rbac: true
      issuer_uri: "https://openid.issuer.com"
```

{{% alert color="warning" %}}
As namespace access control is disabled, all users logging into Kiali
will share the same cluster-wide privileges.
{{% /alert %}}

## Additional configurations

### Configuring the displayed user name

The Kiali front-end will, by default, retrieve the string of the `sub` claim of
the OpenID token and display it as the user name. You can customize which field
to display as the user name by setting the `username_claim` attribute of the
Kiali CR. For example:

```yaml
spec:
  auth:
    openid:
      username_claim: "email"
```

If you enabled namespace access control, you will want the `username_claim`
attribute to match the `--oidc-username-claim` flag used to start the
Kubernetes API server, or the equivalent option if you are using a replacement
or reverse proxy of the API server. Else, any user-friendly claim will be OK as
it is purely informational.

### Configuring requested scopes {#configure-scopes}

By default, Kiali will request access to the `openid`, `profile` and `email`
standard scopes. If you need a different set of scopes, you can set the
`scopes` attribute in the Kiali CR. For example:

```yaml
spec:
  auth:
    openid:
      scopes:
      - "openid"
      - "email"
      - "groups"
```

The `openid` scope is forced. If you don't add it to the list of scopes to
request, Kiali will still request it from the identity provider.

### Configuring authentication timeout

When the user is redirected to the external authentication system, by default
Kiali will wait at most 5 minutes for the user to authenticate. After that time
has elapsed, Kiali will reject authentication. You can adjust this timeout by
setting the `authentication_timeout` with the number of seconds that Kiali
should wait at most. For example:

```yaml
spec:
  auth:
    openid:
      authentication_timeout: 60 # Wait only one minute.
```

### Configuring allowed domains

Some identity providers use a shared login and regardless of configuring your
own application under your domain (or organization account), login can succeed
even if the user that is logging in does not belong to your account or
organization. Google is an example of this kind of provider.

To prevent foreign users from logging into your Kiali instance, you can
configure a list of allowed domains:

```yaml
spec:
  auth:
    openid:
      allowed_domains:
      - example.com
      - foo.com
```

The e-mail reported by the identity provider is used for the validation. Login
will be allowed if the domain part of the e-mail is listed as an allowed
domain; else, the user will be rejected. Naturally, you will need to
[configure the `email` scope to be requested](#configure-scopes).

There is a special case: some identity providers include a `hd` claim in the
`id_token`. If this claim is present, this is used instead of extracting the
domain from the user e-mail.  For example, Google Workspace (aka G Suite)
[includes this `hd` claim for hosted
domains](https://developers.google.com/identity/protocols/oauth2/openid-connect#an-id-tokens-payload).

### Using an OpenID provider with a self-signed certificate

If your OpenID provider is using a self-signed certificate, you can disable
certificate validation by setting the `insecure_skip_verify_tls` to `true` in
the Kiali CR:

```yaml
spec:
  auth:
    openid:
      insecure_skip_verify_tls: true
```

{{% alert color="warning" %}}
You should use self-signed certificates only for
testing purposes.
{{% /alert %}}

However, if your organization or internal network has an internal trusted
certificate authority (CA), and your OpenID server is using a certificate
issued by this CA, you can configure Kiali to trust certificates from this CA
rather than disabling verification.

See the [TLS Configuration]({{< relref "../p8s-jaeger-grafana/tls-configuration" >}})
page for detailed instructions on configuring custom CA certificates. You can use either
the global `additional-ca-bundle.pem` key (which makes the CA trusted for all
HTTPS connections) or the OpenID-specific `openid-server-ca.crt` key in the
`kiali-cabundle` ConfigMap.

### Using an HTTP/HTTPS Proxy

In some network configurations, there is the need to use proxies to connect to
the outside world. OpenID requires outside world connections to get metadata and
do key validation, so you can configure it by setting the `http_proxy` and
`https_proxy` keys in the Kiali CR. They use the same format as the `HTTP_PROXY`
and `HTTPS_PROXY` environment variables.

```yaml
spec:
  auth:
    openid:
      http_proxy: http://USERNAME:PASSWORD@10.0.1.1:8080/
      https_proxy: https://USERNAME:PASSWORD@10.0.0.1:8080/
```

### Passing additional options to the identity provider

When users click on the _Login_ button on Kiali, a redirection occurs to the
authentication page of the external identity provider. Kiali sends a fixed set
of parameters to the identity provider to enable authentication. If you need to
add an additional set of parameters to your identity provider, you can use the
`additional_request_params` setting of the Kiali CR, which accepts key-value
pairs. For example:

```yaml
spec:
  auth:
    openid:
      additional_request_params:
        prompt: login
```

The `prompt` parameter is a
[standard OpenID parameter](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest).
When the `login` value is passed in this parameter, the
identity provider is instructed to ask for user credentials regardless if the
user already has an active session because of a previous login in some other
system.

If your OpenId provider supports other non-standard parameters, you can specify
the ones you need in this `additional_request_params` setting.

Take into account that you should *not* add the `client_id`, `response_type`,
`redirect_uri`, `scope`, `nonce` nor `state` parameters to this list. These are
already in use by Kiali and some already have a dedicated setting.

## Provider-specific instructions

### Using with Keycloak

When using OpenId with Keycloak, you will need to enable the `Standard Flow Enabled`
option on the Client (in the Administration Console):

![Client configuration screen on Keycloak](/images/documentation/authentication/keycloak-implicit-client.png)

The _Standard Flow_ described on the options is the same as the _authorization
code flow_ from the rest of the documentation.

### Using with Google Cloud Platform / GKE OAuth2

If you are using Google Cloud Platform (GCP) and its products such as
Google Kubernetes Engine (GKE), it should be straightforward to configure Kiali's OpenID
strategy to authenticate using your Google credentials.

First, you'll need to go to your GCP Project and to the Credentials screen which
is available at `(Menu Icon) > APIs & Services > Credentials`.

![Credentials Screen on in GCP Project](/images/documentation/authentication/gcp-credentials-screen.png)

On the Credentials screen you can select to create a new OAuth client ID.

![Select OAuth on Credentials Screen](/images/documentation/authentication/gcp-select-oauth.png)

{{% alert color="warning" %}}
If you've never setup the OAuth consent screen you will need to
do that before you can create an OAuth client ID. On screen you'll have multiple
warnings and prompts to walk you through this.
{{% /alert %}}

On the _Create OAuth client ID_ screen, set the _Application type_ to `Web Application`
and enter a name for your key.

![Select Web Application](/images/documentation/authentication/gcp-select-web-app.png)

Then enter in the _Authorized Javascript origins_ and _Authorized redirect URIs_ for your project.
You can enter in `localhost` as appropriate during testing. You can also enter multiple URIs as appropriate.

![Enter URLs](/images/documentation/authentication/gcp-enter-urls.png)

After clicking _Create_ you'll be shown your newly minted client id and secret. These are important
and needed for your Kiali CR yaml and Kiali secrets files.

![Get Credentials](/images/documentation/authentication/gcp-get-credentials.png)

You'll need to update your Kiali CR file to include the following `auth` block.

```yaml
spec:
  auth:
    strategy: "openid"
    openid:
      client_id: "<your client id from GCP>"
      disable_rbac: true
      issuer_uri: "https://accounts.google.com"
      scopes: ["openid", "email"]
      username_claim: "email"
```

{{% alert color="warning" %}}
Don't get creative here. The `issuer_uri` should be `https://accounts.google.com`.
{{% /alert %}}

Finally you will need to create a secret, if you don't have one already, that sets the `oidc-secret` for the openid flow.
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  oidc-secret: "<base64 encode your client secret from GCP and enter here>"
```

Once all these settings are complete just set your Kiali CR and the Kiali secret to your cluster. You may need to
refresh your Kiali Pod to _set_ the Secret if you add the Secret after the Kiali pod is created.

### Using with OpenShift and an external OIDC provider {#openshift-oidc}

Starting with OpenShift 4.20, you can configure your OpenShift cluster to
authenticate users against an external OpenID Connect (OIDC) provider instead
of using the built-in OAuth server. This is sometimes called
"Bring Your Own OIDC" (BYO OIDC). When OpenShift is configured this way, Kiali
can use the `openid` authentication strategy with full namespace access control
support.

{{% alert color="info" %}}
This section applies when you want to use an external OIDC provider (such as
Keycloak, Okta, Auth0, or others) with OpenShift. If you want to use
OpenShift's built-in OAuth server, use the [`openshift` authentication
strategy]({{< relref "openshift" >}}) instead.
{{% /alert %}}

#### Prerequisites

- OpenShift 4.20 or later
- An external OIDC provider configured and accessible from your OpenShift cluster
- The OIDC provider must be configured as an authentication source for both
  OpenShift and Kiali (they share the same provider)
- A certificate-based kubeconfig or long-lived service account token for
  emergency cluster access (the built-in OAuth will be disabled)

#### Step 1: Configure OpenShift for external OIDC authentication

First, configure your OpenShift cluster to use your external OIDC provider.
This involves modifying the cluster's `Authentication` resource to specify your
OIDC provider details.

Refer to the official OpenShift documentation for detailed instructions:
[Enabling direct authentication with an external OIDC identity provider](https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/authentication_and_authorization/external-auth).

The key configuration elements include:

- **Issuer URL**: The URL of your OIDC provider
- **Client ID**: The OAuth2 client ID registered with your OIDC provider
- **Audiences**: The list of acceptable audiences for tokens (must include your Kiali client ID)
- **Username claim mapping**: How the OIDC token claims map to Kubernetes usernames
- **Username prefix**: Optional prefix to distinguish OIDC users (e.g., `oidc:`)
- **CA certificate**: If your OIDC provider uses a private CA
- **`webhookTokenAuthenticator: null`**: Must be set when `type` is `OIDC`

{{% alert color="warning" %}}
When OpenShift is configured with external OIDC authentication, the built-in
OAuth server is disabled. This means:
- Users cannot log in using OpenShift's standard login page
- The `OAuthClient` API becomes unavailable
- Keep a certificate-based kubeconfig (or other long-lived admin credentials) available for emergency access because the normal OAuth login paths and OAuth APIs are unavailable in this mode

Ensure your OIDC provider is properly configured and you have set up RBAC
policies **before** enabling external OIDC authentication.
{{% /alert %}}

#### Step 2: Configure user RBAC

When using external OIDC with OpenShift, user identities in Kubernetes are
derived from the OIDC token claims. OpenShift typically adds a configurable
prefix to the username (e.g., `oidc:`) to distinguish OIDC users from other
identity sources.

For example, if your OIDC provider returns `user@example.com` in the email
claim and you configured a prefix of `oidc:`, the Kubernetes username becomes
`oidc:user@example.com`.

Create RBAC resources to grant users access to the namespaces they need. See
[Namespace access control]({{< relref "../rbac" >}}) for details on the required
privileges.

Example `Role` and `RoleBinding` to grant a user access to the `istio-system` namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kiali-user-access
  namespace: istio-system
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods/log
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kiali-user-access
  namespace: istio-system
subjects:
- kind: User
  name: "oidc:user@example.com"  # Use the prefixed username
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: kiali-user-access
  apiGroup: rbac.authorization.k8s.io
```

{{% alert color="info" %}}
The username prefix (e.g., `oidc:`) is configured in OpenShift's
`Authentication` resource under `spec.oidcProviders[].claimMappings.username.prefix.prefixString`.
Make sure your RBAC resources use the same prefixed username format.
{{% /alert %}}

#### Step 3: Create the OIDC client secret

If your OIDC provider requires a client secret, create a Kubernetes secret to
store it:

```bash
oc create secret generic kiali --from-literal="oidc-secret=$CLIENT_SECRET" -n istio-system
```

Replace `$CLIENT_SECRET` with the client secret from your OIDC provider.

#### Step 4: Configure the CA certificate (if needed)

If your OIDC provider uses a certificate issued by a private CA (not a public
CA), you need to configure Kiali to trust it. Create a ConfigMap with the CA
certificate:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-cabundle
  namespace: istio-system
data:
  openid-server-ca.crt: |
    -----BEGIN CERTIFICATE-----
    MIIDxTCCAq2gAwIBAgIQAqxcJmoLQ...
    ... (your OIDC provider's CA certificate) ...
    -----END CERTIFICATE-----
```

See [TLS Configuration]({{< relref "../p8s-jaeger-grafana/tls-configuration" >}})
for more details on configuring custom CA certificates.

#### Step 5: Configure the Kiali CR

Configure Kiali to use the `openid` authentication strategy. The `client_id`
and `issuer_uri` must match the values configured in OpenShift's
`Authentication` resource:

```yaml
spec:
  auth:
    strategy: openid
    openid:
      client_id: "kiali-client"
      issuer_uri: "https://your-oidc-provider.example.com"
      scopes:
      - "openid"
      - "email"
      username_claim: "email"
```

{{% alert color="warning" %}}
The `client_id` must be listed in the `audiences` array of your OpenShift OIDC
configuration, and the `issuer_uri` must exactly match the issuer URL configured
in OpenShift. If these don't match, authentication will fail.
{{% /alert %}}

**Important configuration notes:**

- **`username_claim`**: Should match the claim mapping configured in OpenShift
  (commonly `email` or `preferred_username`)
- **`scopes`**: Request the scopes that provide the claims you need (typically
  `openid` and `email`)
- **`disable_rbac`**: Do **not** set this to `true` if you want per-user
  namespace access control. When `disable_rbac` is `false` (the default), Kiali
  uses the user's OIDC token for Kubernetes API calls, enabling per-user RBAC.

#### Complete example

Here's a complete example of the Kiali CR configuration for OpenShift with an
external OIDC provider:

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  auth:
    strategy: openid
    openid:
      client_id: "kiali-client"
      issuer_uri: "https://your-oidc-provider.example.com"
      scopes:
      - "openid"
      - "email"
      username_claim: "email"
```

With the supporting resources:

```yaml
# OIDC client secret (if required by your provider)
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
type: Opaque
stringData:
  oidc-secret: "your-client-secret-here"
---
# CA certificate (if using a private CA)
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-cabundle
  namespace: istio-system
data:
  openid-server-ca.crt: |
    -----BEGIN CERTIFICATE-----
    ... (your CA certificate) ...
    -----END CERTIFICATE-----
---
# RBAC for a user (repeat for each user/namespace combination)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kiali-user-access
  namespace: istio-system
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods/log
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kiali-user-access
  namespace: istio-system
subjects:
- kind: User
  name: "oidc:user@example.com"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: kiali-user-access
  apiGroup: rbac.authorization.k8s.io
```

### Using with Azure: AKS and AAD

{{% alert color="warning" %}}
The OpenID authentication strategy can be used
with Azure Kubernetes Service (AKS) and Azure Active Directory (AAD) with Kiali
versions 1.33 and later. Prior Kiali versions do not support namespace access control on Azure.
{{% /alert %}}

AKS has support for a feature named _AKS-managed Azure Active Directory_, which
enables integration between AKS and AAD. This has the advantage that users can
use their AAD credentials to access AKS clusters and can also use Kubernetes
RBAC features to assign privileges to AAD users.

However, Azure is implementing this integration via the
[Kubernetes Webhook Token Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication)
rather than via the [Kubernetes OpenID Connect Tokens authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens)
(see [the Azure AD integration section in AKS Concepts documentation](https://docs.microsoft.com/en-us/azure/aks/concepts-identity#azure-ad-integration)).
Because of this difference, authentication in AKS behaves slightly different from a standard
OpenID setup, but Kiali's OpenID authentication strategy can still be used with
namespace access control support by following the next steps.

First, enable the AAD integration on your AKS cluster. See the
[official AKS documentation to learn how](https://docs.microsoft.com/en-us/azure/aks/managed-aad).
Once it is enabled, your AKS panel should show the following:

![AKS-managed AAD is enabled,700](/images/documentation/authentication/azure-managed-aad-enabled.png)

Create a web application for Kiali in your Azure AD panel:

1. Go to _AAD > App Registration_, create an application with a redirect url like `https://<your-kiali-url>/kiali`
2. Go to _Certificates & secrets_ and create a client secret.
   1. After creating the client secret, take note of the provided secret. Create a
   Kubernetes secret in your cluster as mentioned in the [Set-up
   with namespace access control support](#setup-with-rbac) section. Please, note that the suggested name for the
   Kubernetes Secret is `kiali`. If you want to customize the secret name, you
   will have to specify your custom name in the Kiali CR. See: [secret_name in Kial CR Reference](/docs/configuration/kialis.kiali.io/#.spec.deployment.secret_name).
3. Go to _API Permissions_ and press the _Add a permission_ button. In the new page that appears, switch to the
  _APIs my organization uses_ tab.
  1. Type the following ID in the search field:
  `6dae42f8-4368-4678-94ff-3960e28e3630` (this is a shared ID for all Azure
clusters). And select the resulting entry.
  2. Select the _Delegated permissions_ square.
  3. Select the `user.read` permission.
4. Go to _Authentication_ and make sure that the _Access tokens_ checkbox is ticked.

![Access tokens enabled](/images/documentation/authentication/azure-access-token-ticked.png)

Then, create or modify your Kiali CR and include the following settings:

```yaml
spec:
  auth:
    strategy: "openid"
    openid:
      client_id: "<your Kiali application client id from Azure>"
      issuer_uri: "https://sts.windows.net/<your AAD tenant id>/"
      username_claim: preferred_username
      api_token: access_token
      additional_request_params:
        resource: "6dae42f8-4368-4678-94ff-3960e28e3630"
```

You can find your `client_id` and `tenant_id` in the Overview page of the Kiali
App registration that you just created. See [this documentation for more information](https://docs.microsoft.com/en-us/azure/digital-twins/how-to-create-app-registration#collect-client-id-and-tenant-id).

