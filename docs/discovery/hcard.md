---
title: hCard
---

diaspora\* uses [hCard][hcard] to provide the profile information.

## hCard

### Request

Use the URL provided in the [WebFinger][webfinger] response with rel `http://microformats.org/profile/hcard`.

#### Example

```
GET /hcard/users/7dba7ca01d64013485eb3131731751e9
Host: example.org
```

### Response

The response must be a valid [hCard][hcard] html document, but there are no other requirements to the structure of
the document.

#### Mandatory Properties

The hCard response must contain the following properties:

| CSS selector                       | Type (Length)            | Description                                                                                                                                                            |
| ---------------------------------- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.uid`                             | [GUID][guid]             | The GUID of the person.                                                                                                                                                |
| `.fn`                              | [Name][name] (70)        | The full name of the person.                                                                                                                                           |
| `.given_name`                      | [Name][name] (32)        | The first name of the person.                                                                                                                                          |
| `.family_name`                     | [Name][name] (32)        | The last name of the person.                                                                                                                                           |
| `.key`                             | [String][string] (65535) | The public key of the person. The format is a DER-encoded PKCS\#1 key beginning with the text `-----BEGIN PUBLIC KEY-----` and ending with `-----END PUBLIC KEY-----`. |
| `.entity_photo .photo[src]`        | [URL][url] (255)         | The URL to the big avatar (300x300) of the person.                                                                                                                     |
| `.entity_photo_medium .photo[src]` | [URL][url] (255)         | The URL to the medium avatar (100x100) of the person.                                                                                                                  |
| `.entity_photo_small .photo[src]`  | [URL][url] (255)         | The URL to the small avatar (50x50) of the person.                                                                                                                     |
| `.searchable`                      | [Boolean][boolean]       | The flag if the person is searchable by name.                                                                                                                          |

#### Example

```
Status: 200 OK
Content-Type: text/html; charset=utf-8
```

<!-- prettier-ignore-start -->
```html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta charset="UTF-8" />
    <title>Alice Smith</title>
  </head>
  <body>
    <div id="content">
      <h1>Alice Smith</h1>
      <div id="content_inner" class="entity_profile vcard author">
        <h2>User profile</h2>
        <dl class="entity_uid">
          <dt>Uid</dt>
          <dd>
            <span class="uid">7dba7ca01d64013485eb3131731751e9</span>
          </dd>
        </dl>
        <dl class="entity_full_name">
          <dt>Full_name</dt>
          <dd>
            <span class="fn">Alice Smith</span>
          </dd>
        </dl>
        <dl class="entity_searchable">
          <dt>Searchable</dt>
          <dd>
            <span class="searchable">true</span>
          </dd>
        </dl>
        <dl class="entity_key">
          <dt>Key</dt>
          <dd>
            <pre class="key">-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEArxic3b0VuKA+Z1uc6OP4
ha/tRGLYvoxrRjfllnp5hfKyKQfhjVA6xDvvBwamLbzZM+ZEY/4vOhLbC/S3FjVe
opkfQaMvg0uXOB7UhcuKqDM6rFHafsl0LjvBw13p/zQoUxELxK9HAnRLCAAlJ+Fk
MNMR37Rw9Z0Am13Zh4jl64Fn6qkoTHQ/NICbGgRpTmRUrc6KpOKQuQQUJpnGFrJB
g/srgPH4Xdd45VzR6vxjbnEp95F2BOmHLBdGgZAhX+NVY2vuPj2yTn6fFpbVxuUi
XXHSgszLHuH1Nssx7o+KS0jPkQp78ZkW2+fB55MESJSSbWwHuXob5ke7VziHyCFh
3up2kZ5eKPNSpgWqZ3L7HeGjhc+ZtBgJhoUO65Dm/1VOsw8I9uSBNyX7XMa13aO/
Ywn53Rv0L+LDS1yBiirwb6qSCjvvayDeaGLOFoSQ2hNIO+goi3FjrVDYJ1+63NzH
IHj7qcitKxISsPnPYCs49inl8TQC26C43YunEuq8zBDEopeeyXAsnKuX+is6mb6W
hzhzJthFLkmyBd2idgxS/tW6XR9yJ9L0VPafvdth9JUjj510g44BSfJYESRh+4uJ
OFxcL+/diwyswWkVbeaNCrrdfz8LTDQcWv8GA6olBOx7RlgVb7k3HonHaQjaI+xv
9S7fSw27PVS8csWZHwkFGukCAwEAAQ==
-----END PUBLIC KEY-----
</pre>
          </dd>
        </dl>
        <dl class="entity_first_name">
          <dt>First_name</dt>
          <dd>
            <span class="given_name">Alice</span>
          </dd>
        </dl>
        <dl class="entity_family_name">
          <dt>Family_name</dt>
          <dd>
            <span class="family_name">Smith</span>
          </dd>
        </dl>
        <dl class="entity_photo">
          <dt>Photo</dt>
          <dd>
            <img class="photo avatar" width="300" height="300" src="https://example.org/images/thumb_large_a795f872c93309597345.jpg" />
          </dd>
        </dl>
        <dl class="entity_photo_medium">
          <dt>Photo_medium</dt>
          <dd>
            <img class="photo avatar" width="100" height="100" src="https://example.org/images/thumb_medium_a795f872c93309597345.jpg" />
          </dd>
        </dl>
        <dl class="entity_photo_small">
          <dt>Photo_small</dt>
          <dd>
            <img class="photo avatar" width="50" height="50" src="https://example.org/images/thumb_small_a795f872c93309597345.jpg" />
          </dd>
        </dl>
      </div>
    </div>
  </body>
</html>
```
<!-- prettier-ignore-end -->

## Additional information and specifications

- [hCard 1.0][hcard]

[hcard]: http://microformats.org/wiki/hCard

[webfinger]: {{ site.baseurl }}/discovery/webfinger.html
[guid]: {{ site.baseurl }}/federation/types.html#guid
[name]: {{ site.baseurl }}/federation/types.html#name
[string]: {{ site.baseurl }}/federation/types.html#string
[url]: {{ site.baseurl }}/federation/types.html#url
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
