---
title: "Session options"
description: "Session timeout and signing key configuration"
weight: 60
---

There are two settings that are available for the user's session. The first one
is the **session expiration time**, which is only applicable to
[token]({{< relref "token" >}}) and [header]({{< relref "header" >}})
authentication strategies:

```yaml
spec:
  login_token:
    # By default, users session expires in 24 hours.
    expiration_seconds: 86400
```

The session expiration time is the amount of time before the user is asked to
extend his session by another cycle. It does not matter if the user is actively
using Kiali, the user will be asked if the session should be extended.

The second available option is the **signing key** configuration, which is unset by
default, meaning that a random 16-character signing key will be generated
and stored to a secret named `kiali-signing-key`, in Kiali's installation
namespace:

```yaml
spec:
  login_token:
    # By default, create a random signing key and store it in
    # a secret named "kiali-signing-key".
    signing_key: ""
```

If the secret already exists (which may mean a previous Kiali installation was
present), then the secret is reused. 

The signing key is used on security sensitive data. For example, one of the
usages is to sign HTTP cookies related to the user session to prevent session
forgery.

If you need to set a custom fixed key, you can pre-create or modify the
`kiali-signing-key` secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  namespace: "kiali-installation-namespace"
  name: kiali-signing-key
type: Opaque
data:
  key: "<your signing key encoded in base64>"
```

{{% alert color="info" %}}
The signing key must be 16, 24 or 32 bytes length. Otherwise, Kiali will fail to start.
{{% /alert %}}

If you prefer a different secret name for the signing key and/or a different
key-value pair of the secret, you can specify your preferred names in the Kiali
CR:

```yaml
spec:
  login_token:
    signing_key: "secret:<secretName>:<secretDataKey>"
```

{{% alert color="danger" %}}
It is possible to specify the signing key directly in the Kiali CR, in the
`spec.login_token.signing_key` attribute. However, this should be only for
testing purposes. The signing key is sensitive and should be treated like a
password that must be protected.
{{% /alert %}}
