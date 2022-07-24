---
title: Profile
---

This entity contains all the profile data of a person.

The profile consists of two parts. The first is the base profile with the name,
the avatar and the tags of the person. This part is always public and visible to
everyone. The boolean flags (`searchable`, `public` and `nsfw`) are metadata and
public too.

The second part is the extended profile consisting of `bio`, `birthday`, `gender`
and `location` is not public by default (and only visible to contacts the person
shares with). The owner of the profile can decide if this information should be
public (that's what the `public` flag is for) and then the extended profile is
visible to non-contacts too.

Because of that there is a special case where the `public`-flag is `false`, but
the profile was received via the public route. In this case the profile should
only contain the base profile.

## Properties

| Property | Type                         | Editable | Description                      |
| -------- | ---------------------------- | :------: | -------------------------------- |
| `author` | [diaspora\* ID][diaspora-id] |    ✘     | The diaspora\* ID of the person. |

## Optional Properties

| Property           | Type (Length)                | Editable | Description                                                                                              |
| ------------------ | ---------------------------- | :------: | -------------------------------------------------------------------------------------------------------- |
| `edited_at`        | [Timestamp][timestamp]       |    ✔     | The timestamp when the profile was edited.                                                               |
| `full_name`        | [Name][name] (70)            |    ✔     | The full name of the person.                                                                             |
| `first_name`       | [Name][name] (32)            |    ✔     | The first name of the person.                                                                            |
| `last_name`        | [Name][name] (32)            |    ✔     | The last name of the person.                                                                             |
| `image_url`        | [URL][url] (255)             |    ✔     | The URL to the big avatar (300x300) of the person.                                                       |
| `image_url_medium` | [URL][url] (255)             |    ✔     | The URL to the medium avatar (100x100) of the person.                                                    |
| `image_url_small`  | [URL][url] (255)             |    ✔     | The URL to the small avatar (50x50) of the person.                                                       |
| `bio`              | [Markdown][markdown] (65535) |    ✔     | The description of the person. This field can contain markdown.                                          |
| `birthday`         | [Date][date]                 |    ✔     | The birthday of the person. The year may be `1004` or less, if the person specifies only day and month.  |
| `gender`           | [String][string] (255)       |    ✔     | The gender of the person.                                                                                |
| `location`         | [String][string] (255)       |    ✔     | The location of the person.                                                                              |
| `searchable`       | [Boolean][boolean]           |    ✔     | `false` if the person doesn't want to be searchable by name.                                             |
| `public`           | [Boolean][boolean]           |    ✔     | `true` if the profile is visible to everyone.                                                            |
| `nsfw`             | [Boolean][boolean]           |    ✔     | `true` if all posts of this person should be marked as NSFW.                                             |
| `tag_string`       | [String][string]             |    ✔     | A list of hashtags for this person, each tag beginning with `#` and seperated by spaces, at most 5 tags. |

## Example

```xml
<profile>
  <author>alice@example.org</author>
  <edited_at>2018-01-23T01:19:56Z</edited_at>
  <full_name>Alice Smith</full_name>
  <first_name>Alice</first_name>
  <last_name>Smith</last_name>
  <image_url>https://example.org/images/thumb_large_a795f872c93309597345.jpg</image_url>
  <image_url_medium>https://example.org/images/thumb_medium_a795f872c93309597345.jpg</image_url_medium>
  <image_url_small>https://example.org/images/thumb_small_a795f872c93309597345.jpg</image_url_small>
  <bio>some text about me</bio>
  <birthday>1988-07-15</birthday>
  <gender>Male</gender>
  <location>github</location>
  <searchable>true</searchable>
  <public>false</public>
  <nsfw>false</nsfw>
  <tag_string>#i #love #tags</tag_string>
</profile>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[name]: {{ site.baseurl }}/federation/types.html#name
[url]: {{ site.baseurl }}/federation/types.html#url
[date]: {{ site.baseurl }}/federation/types.html#date
[string]: {{ site.baseurl }}/federation/types.html#string
[markdown]: {{ site.baseurl }}/federation/types.html#markdown
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
