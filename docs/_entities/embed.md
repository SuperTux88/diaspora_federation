---
title: Embed
---

This entity represents the embed information about an URL that should be
embedded, it is nested in a [StatusMessage][status_message]. To embed a URL
means to keep an embedded representation or a preview of a third party
resource referenced by the URL inside the status message.

- If this entity is present, the receiving server should only embed the included
  `url` and not search for other URLs to embed.
- If the included `url` is a
  trusted oEmbed provider, the server should query the oEmbed data.
- If `title`, `description` or `image` are missing, the server should query the
  information from the URL (oEmbed or OpenGraph).
- If `nothing` is `true` the server should not embed any URLs.

A link to the embedded resource should also be included in the `text` of the
[StatusMessage][status_message] for accessibility reasons, otherwise it could
happen that some people don't see the link, for example when this entity isn't
implemented or where no embeds are supported at all. However, it is possible
that the link in the `text` and the `url` here are different, because some sites
have different URLs in `og:url` as requested.

## Optional Properties

All properties are optional, but either `url` is required or `nothing` must be `true`.

| Property      | Type (Length)            | Description                           |
| ------------- | ------------------------ | ------------------------------------- |
| `url`         | [URL][url] (65535)       | The URL that should be embedded.      |
| `title`       | [String][string] (255)   | The title of the embedded URL.        |
| `description` | [String][string] (65535) | The description of the embedded URL.  |
| `image`       | [URL][url] (65535)       | The image of the embedded URL.        |
| `nothing`     | [Boolean][boolean]       | `true` if nothing should be embedded. |

## Example

### Only `url`

```xml
<embed>
  <url>https://example.org/</url>
</embed>
```

### With metadata

```xml
<embed>
  <url>https://example.org/</url>
  <title>Example Website</title>
  <description>This is an example!</description>
  <image>https://example.org/example.png</image>
</embed>
```

### With `nothing`

```xml
<embed>
  <nothing>true</nothing>
</embed>
```

[string]: {{ site.baseurl }}/federation/types.html#string
[url]: {{ site.baseurl }}/federation/types.html#url
[boolean]: {{ site.baseurl }}/federation/types.html#url
[status_message]: {{ site.baseurl }}/entities/status_message.html
