---
title: WebFinger
---

diaspora\* uses [WebFinger][webfinger-rfc] to discover users from other pods.

## WebFinger

### Request

```
GET /.well-known/webfinger
```

Let's assume we are searching for `alice@example.org`, then we need to make a request to `example.org`.

#### Parameters

| Name       | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `resource` | The "acct" URI for the diaspora\* ID of the searched person. |

#### Example

```
GET /.well-known/webfinger?resource=acct:alice@example.org
Host: example.org
```

### Response

The WebFinger document must be in the [JSON Resource Descriptor (JRD) format][jrd] and should be served with the
`application/jrd+json` media type.

If the requested diaspora\* ID is unknown by the server, it must return a 404 status code.

#### Subject

The `subject` element should contain the WebFinger address that was asked for. If it does not, then this WebFinger
profile must be ignored.

#### Mandatory Link Relations

The WebFinger response must contain the following link relations:

| Link Relation                         | Type | Description                            |
| ------------------------------------- | ---- | -------------------------------------- |
| http://microformats.org/profile/hcard | url  | The URL to the person's [hCard][hcard] |
| http://joindiaspora.com/seed_location | url  | The URL to the person's server         |

The WebFinger response may contain other optional link relations.

#### Example

```
Status: 200 OK
Content-Type: application/jrd+json; charset=utf-8
Access-Control-Allow-Origin: *
```

```json
{
  "subject": "acct:alice@example.org",
  "links": [
    {
      "rel": "http://microformats.org/profile/hcard",
      "type": "text/html",
      "href": "https://example.org/hcard/users/7dba7ca01d64013485eb3131731751e9"
    },
    {
      "rel": "http://joindiaspora.com/seed_location",
      "type": "text/html",
      "href": "https://example.org/"
    }
  ]
}
```

## Additional information and specifications

- [RFC 7033: WebFinger][webfinger-rfc]
- [JSON Resource Descriptor (JRD)][jrd]

[webfinger-rfc]: https://tools.ietf.org/html/rfc7033
[jrd]: https://www.packetizer.com/json/jrd/

[hcard]: {{ site.baseurl }}/discovery/hcard.html
