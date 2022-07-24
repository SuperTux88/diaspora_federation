---
title: Magic Signatures
---

diaspora\* uses the Salmon Magic Signatures to send signed messages to other servers.

This is only a summary of the important parts. See the [Magic Signatures Specification][draft-magicsig] for the full details.

## Magic Envelope

### Parameters

| Parameter   | Description                                                                   |
| ----------- | ----------------------------------------------------------------------------- |
| `data`      | The [serialized][serialization] [entity][entities], base64url-encoded.        |
| `data_type` | The MIME-type of the payload before encoding. This must be `application/xml`. |
| `encoding`  | The encoding of the `data`. This must be `base64url`.                         |
| `alg`       | The algorithm used for the signature. This must be `RSA-SHA256`.              |
| `sig`       | The base64url encoded [signature](#signature).                                |
| `key_id`    | The base64url encoded [diaspora\* ID][diaspora-id] of the signer.             |

### Signature

The signature base string is produced by concatenating the following substrings together, separated by periods (`.`):

1. The encoded `data`.
2. The base64url encoding of the `data_type` parameter, which is the literal string `application/xml`. The base64url-encoded string is `YXBwbGljYXRpb24veG1s`.
3. The base64url encoding of the `encoding` parameter, which is the literal string `base64url`. The base64url-encoded string is `YmFzZTY0dXJs`.
4. The base64url encoding of the `alg` parameter, which is the literal string `RSA-SHA256`. The base64url-encoded string is `UlNBLVNIQTI1Ng==`.

This is then signed with the private RSA key of the sender using the RSA-SHA256 algorithm and base64url-encoded.

If someone receives a Magic Envelope without a valid signature, it must be ignored.

### XML Serialization

The Magic Envelope must be XML serialized.

### Example

```xml
<me:env xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <me:data type="application/xml">PHN0YXR1c19tZXNzYWdlPgogIDxhdXRob3I-YWxpY2VAZXhhbXBsZS5vcmc8L2F1dGhvcj4KICA8Z3VpZD5jYmQ0ODIyMDFmZTEwMTM0ODZmZTMxMzE3MzE3NTFlOTwvZ3VpZD4KICA8Y3JlYXRlZF9hdD4yMDE2LTA2LTI5IDA0OjQyOjIzIFVUQzwvY3JlYXRlZF9hdD4KICA8cmF3X21lc3NhZ2U-aSBhbSBhIHZlcnkgaW50ZXJlc3Rpbmcgc3RhdHVzIHVwZGF0ZTwvcmF3X21lc3NhZ2U-CiAgPHB1YmxpYz50cnVlPC9wdWJsaWM-Cjwvc3RhdHVzX21lc3NhZ2U-</me:data>
  <me:encoding>base64url</me:encoding>
  <me:alg>RSA-SHA256</me:alg>
  <me:sig key_id="YWxpY2VAZXhhbXBsZS5vcmc=">OBv90p9RfAvML28f5H-XDpAWpjk7f4W3I6JMY81OSzXEwPJVndNHRjAxifXd_Id1T7lHylyL0cly4ZBI9frTN5bZZg_03SfiEssZSj0a6KgEnNFIBh1ZG_7WUWon92jJCAO6f2SzVCjdcPSuRYZElFsQSp7zLxAV-Fz5oTdZanY=</me:sig>
</me:env>
```

## Additional information and specifications

- [Draft: The Salmon Protocol][draft-salmon]
- [Draft: Magic Signatures][draft-magicsig]

[draft-salmon]: https://cdn.rawgit.com/salmon-protocol/salmon-protocol/master/draft-panzer-salmon-00.html
[draft-magicsig]: https://cdn.rawgit.com/salmon-protocol/salmon-protocol/master/draft-panzer-magicsig-01.html

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[entities]: {{ site.baseurl }}/entities/
[serialization]: {{ site.baseurl }}/federation/xml_serialization.html
