---
title: Photo
---

This entity represents a photo. It can be standalone or nested in a [StatusMessage][status_message]

## Properties

| Property            | Type (Length)                | Editable | Description                                                      |
| ------------------- | ---------------------------- | :------: | ---------------------------------------------------------------- |
| `author`            | [diaspora\* ID][diaspora-id] |    ✘     | The diaspora\* ID of the author of the photo.                    |
| `guid`              | [GUID][guid]                 |    ✘     | The GUID of the photo.                                           |
| `public`            | [Boolean][boolean]           |    ✘     | `true` if the photo is public.                                   |
| `created_at`        | [Timestamp][timestamp]       |    ✘     | The create timestamp of the photo.                               |
| `remote_photo_path` | [URL][url]                   |    ✔     | The URL to the photo, without filename (see `remote_photo_name`) |
| `remote_photo_name` | [String][string] (255)       |    ✔     | The filename of the photo.                                       |

## Optional Properties

| Property              | Type (Length)            | Editable | Description                                                                     |
| --------------------- | ------------------------ | :------: | ------------------------------------------------------------------------------- |
| `edited_at`           | [Timestamp][timestamp]   |    ✔     | The timestamp when the photo was edited.                                        |
| `text`                | [String][string] (65535) |    ✔     | Description text for the photo.                                                 |
| `status_message_guid` | [GUID][guid]             |    ✘     | The GUID of the [StatusMessage][status_message] to which the photo is attached. |
| `height`              | [Integer][integer]       |    ✔     | The height of the photo in pixels.                                              |
| `width`               | [Integer][integer]       |    ✔     | The width of the photo in pixels.                                               |

## Example

```xml
<photo>
  <guid>0ae691e029ea013487753131731751e9</guid>
  <author>alice@example.org</author>
  <public>true</public>
  <created_at>2016-07-11T23:06:37Z</created_at>
  <remote_photo_path>https://example.org/uploads/images/</remote_photo_path>
  <remote_photo_name>f2a41e9d2db4d9a199c8.jpg</remote_photo_name>
  <text>what you see here...</text>
  <height>480</height>
  <width>800</width>
</photo>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[url]: {{ site.baseurl }}/federation/types.html#url
[string]: {{ site.baseurl }}/federation/types.html#string
[integer]: {{ site.baseurl }}/federation/types.html#integer
[status_message]: {{ site.baseurl }}/entities/status_message.html
