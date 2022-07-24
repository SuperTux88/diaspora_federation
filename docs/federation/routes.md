---
title: Routes
---

## Public

For public messages, a `POST`-request with the [Magic Envelope][magicsig] is sent to `/receive/public`. It should be
sent with the Content-Type `application/magic-envelope+xml`.

The receiving pod should respond with a `200 OK` or `202 Accepted` status-code.

### Example

#### Request

```
POST /receive/public
Host: example.org
Content-Type: application/magic-envelope+xml
```

```xml
<me:env xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <me:data type="application/xml">PHN0YXR1c19tZXNzYWdlPgogIDxhdXRob3I-YWxpY2VAZXhhbXBsZS5vcmc8L2F1dGhvcj4KICA8Z3VpZD5jYmQ0ODIyMDFmZTEwMTM0ODZmZTMxMzE3MzE3NTFlOTwvZ3VpZD4KICA8Y3JlYXRlZF9hdD4yMDE2LTA2LTI5IDA0OjQyOjIzIFVUQzwvY3JlYXRlZF9hdD4KICA8cmF3X21lc3NhZ2U-aSBhbSBhIHZlcnkgaW50ZXJlc3Rpbmcgc3RhdHVzIHVwZGF0ZTwvcmF3X21lc3NhZ2U-CiAgPHB1YmxpYz50cnVlPC9wdWJsaWM-Cjwvc3RhdHVzX21lc3NhZ2U-</me:data>
  <me:encoding>base64url</me:encoding>
  <me:alg>RSA-SHA256</me:alg>
  <me:sig key_id="YWxpY2VAZXhhbXBsZS5vcmc=">OBv90p9RfAvML28f5H-XDpAWpjk7f4W3I6JMY81OSzXEwPJVndNHRjAxifXd_Id1T7lHylyL0cly4ZBI9frTN5bZZg_03SfiEssZSj0a6KgEnNFIBh1ZG_7WUWon92jJCAO6f2SzVCjdcPSuRYZElFsQSp7zLxAV-Fz5oTdZanY=</me:sig>
</me:env>
```

#### Response

```
Status: 202 Accepted
```

## Private

For private messages, a `POST`-request with the [Encrypted Magic Envelope][encrypted-magicsig] is sent to the private
receive-url of the recipient. The private receive-url of a user is `/receive/users/:guid`. The request should be sent
with the Content-Type `application/json`.

The receiving pod should respond with a `200 OK` or `202 Accepted` status-code.

### Parameters

```
POST /receive/users/:guid
```

| Name   | Description                               |
| ------ | ----------------------------------------- |
| `guid` | The [GUID][guid] of the recipient person. |

### Example

#### Request

```
POST /receive/users/7dba7ca01d64013485eb3131731751e9
Host: example.org
Content-Type: application/json
```

```json
{
  "aes_key": "...",
  "encrypted_magic_envelope": "..."
}
```

#### Response

```
Status: 202 Accepted
```

## Additional information and specifications

- [Magic Envelope][magicsig]
- [Encrypted Magic Envelope][encrypted-magicsig]

[magicsig]: {{ site.baseurl }}/federation/magicsig.html#magic-envelope
[encrypted-magicsig]: {{ site.baseurl }}/federation/encryption.html#encrypted-magic-envelope
[guid]: {{ site.baseurl }}/federation/types.html#guid
