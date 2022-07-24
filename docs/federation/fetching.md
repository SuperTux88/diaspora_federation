---
title: Fetching
---

## Public entity fetching

If a server receives an entity with another related entity (parent, root, etc.), which is not yet known, the related
entity maybe needs to be fetched.

It is only possible to fetch public entities.

### Request

```
GET /fetch/:type/:guid
```

#### Parameters

| Name   | Description                                      |
| ------ | ------------------------------------------------ |
| `type` | The type of the entity to fetch in `snake_case`. |
| `guid` | The [GUID][guid] of the entity to fetch.         |

#### Example

```
GET /fetch/post/cbd482201fe1013486fe3131731751e9
Host: example.org
```

### Response

If the server is the owner of the requested entity, it should respond with the entity, signed with
[Magic Signatures][magicsig]. The status-code should be `200 OK`.

If the server is not the owner of the requested entity, but knows the owner, it should redirect to the fetch-url on the
owner server. The status-code should be `301 Moved Permanently` or `302 Found`.

If the server doesn't know the entity, the entity is private or does not support fetching for this type, it should
respond with the status-code `404 Not Found`.

#### Example

```
Status: 200 OK
Content-Type: application/magic-envelope+xml; charset=utf-8
```

```xml
<me:env xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <me:data type="application/xml">PHN0YXR1c19tZXNzYWdlPgogIDxhdXRob3I-YWxpY2VAZXhhbXBsZS5vcmc8L2F1dGhvcj4KICA8Z3VpZD5jYmQ0ODIyMDFmZTEwMTM0ODZmZTMxMzE3MzE3NTFlOTwvZ3VpZD4KICA8Y3JlYXRlZF9hdD4yMDE2LTA2LTI5IDA0OjQyOjIzIFVUQzwvY3JlYXRlZF9hdD4KICA8cmF3X21lc3NhZ2U-aSBhbSBhIHZlcnkgaW50ZXJlc3Rpbmcgc3RhdHVzIHVwZGF0ZTwvcmF3X21lc3NhZ2U-CiAgPHB1YmxpYz50cnVlPC9wdWJsaWM-Cjwvc3RhdHVzX21lc3NhZ2U-</me:data>
  <me:encoding>base64url</me:encoding>
  <me:alg>RSA-SHA256</me:alg>
  <me:sig key_id="YWxpY2VAZXhhbXBsZS5vcmc=">OBv90p9RfAvML28f5H-XDpAWpjk7f4W3I6JMY81OSzXEwPJVndNHRjAxifXd_Id1T7lHylyL0cly4ZBI9frTN5bZZg_03SfiEssZSj0a6KgEnNFIBh1ZG_7WUWon92jJCAO6f2SzVCjdcPSuRYZElFsQSp7zLxAV-Fz5oTdZanY=</me:sig>
</me:env>
```

## Additional information and specifications

- [Magic Signatures][magicsig]

[magicsig]: {{ site.baseurl }}/federation/magicsig.html
[guid]: {{ site.baseurl }}/federation/types.html#guid
