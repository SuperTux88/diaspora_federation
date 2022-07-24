---
title: StatusMessage
---

This entity represents a reshare of a status message. It inherits from [Post][post].

## Properties

| Property     | Type (Length)                | Editable | Description                                            |
| ------------ | ---------------------------- | :------: | ------------------------------------------------------ |
| `author`     | [diaspora\* ID][diaspora-id] |    ✘     | The diaspora\* ID of the author of the status message. |
| `guid`       | [GUID][guid]                 |    ✘     | The GUID of the status message.                        |
| `created_at` | [Timestamp][timestamp]       |    ✘     | The create timestamp of the status message.            |
| `public`     | [Boolean][boolean]           |    ✘     | `true` if the status message is public.                |
| `text`       | [Markdown][markdown] (65535) |    ✔     | The status message text.                               |

## Optional Properties

| Property                | Type (Length)          | Editable | Description                                                                                                             |
| ----------------------- | ---------------------- | :------: | ----------------------------------------------------------------------------------------------------------------------- |
| `edited_at`             | [Timestamp][timestamp] |    ✔     | The timestamp when the status message was edited.                                                                       |
| `provider_display_name` | [String][string] (255) |    ✘     | The means by which the author has posted the status message.                                                            |
| `location`              | [Location][location]   |    ✔     | The Location information of the status message.                                                                         |
| `photo`                 | [Photo][photo]s        |    ✔     | The attached Photos of the status message, the `status_message_guid` and the `author` need to match the status message. |
| `poll`                  | [Poll][poll]           |    ✘     | The attached Poll of the status message.                                                                                |
| `event`                 | [Event][event]         |    ✘     | The attached Event of the status message.                                                                               |
| `embed`                 | [Embed][embed]         |    ✔     | The Embed information of an URL that should be embedded in the status message.                                          |

## Examples

### Minimal

```xml
<status_message>
  <author>alice@example.org</author>
  <guid>17418fb029e6013487743131731751e9</guid>
  <created_at>2016-07-11T22:38:19Z</created_at>
  <text>I am a very interesting status update</text>
  <public>true</public>
</status_message>
```

### With [Location][location]

```xml
<status_message>
  <author>alice@example.org</author>
  <guid>c3893bf029e7013487753131731751e9</guid>
  <created_at>2016-07-11T22:50:18Z</created_at>
  <text>I am a very interesting status update</text>
  <public>true</public>
  <location>
    <address>Vienna, Austria</address>
    <lat>48.208174</lat>
    <lng>16.373819</lng>
  </location>
</status_message>
```

### With [Photo][photo]s

```xml
<status_message>
  <author>alice@example.org</author>
  <guid>e05828d029e7013487753131731751e9</guid>
  <created_at>2016-07-11T22:52:56Z</created_at>
  <text>I am a very interesting status update</text>
  <public>true</public>
  <photo>
    <guid>0788070029e8013487753131731751e9</guid>
    <author>alice@example.org</author>
    <public>true</public>
    <created_at>2016-07-11T22:52:12Z</created_at>
    <remote_photo_path>https://example.org/uploads/images/</remote_photo_path>
    <remote_photo_name>ad7631fac432a281b185.jpg</remote_photo_name>
    <status_message_guid>e05828d029e7013487753131731751e9</status_message_guid>
    <height>480</height>
    <width>800</width>
  </photo>
  <photo>
    <guid>1601f9c029e8013487753131731751e9</guid>
    <author>alice@example.org</author>
    <public>true</public>
    <created_at>2016-07-11T22:52:36Z</created_at>
    <remote_photo_path>https://example.org/uploads/images/</remote_photo_path>
    <remote_photo_name>74bef24b055bd4e6dcf3.jpg</remote_photo_name>
    <status_message_guid>e05828d029e7013487753131731751e9</status_message_guid>
    <height>480</height>
    <width>800</width>
  </photo>
</status_message>

```

### With [Poll][poll]

```xml
<status_message>
  <author>alice@example.org</author>
  <guid>378473f029e9013487753131731751e9</guid>
  <created_at>2016-07-11T23:00:42Z</created_at>
  <text>I am a very interesting status update</text>
  <public>true</public>
  <poll>
    <guid>2a22d6c029e9013487753131731751e9</guid>
    <question>Select an answer</question>
    <poll_answer>
      <guid>2a22db2029e9013487753131731751e9</guid>
      <answer>Yes</answer>
    </poll_answer>
    <poll_answer>
      <guid>2a22e5e029e9013487753131731751e9</guid>
      <answer>No</answer>
    </poll_answer>
    <poll_answer>
      <guid>2a22eca029e9013487753131731751e9</guid>
      <answer>Maybe</answer>
    </poll_answer>
  </poll>
</status_message>
```

### With [Embed][embed]

```xml
<status_message>
  <author>alice@example.org</author>
  <guid>378473f029e9013487753131731751e9</guid>
  <created_at>2016-07-11T23:00:42Z</created_at>
  <text>I am a very interesting status update</text>
  <public>true</public>
  <embed>
    <url>https://example.org/</url>
    <title>Example Website</title>
    <description>This is an example!</description>
    <image>https://example.org/example.png</image>
  </embed>
</status_message>
```

### With all

```xml
<status_message>
  <author>alice@example.org</author>
  <guid>74139da029e9013487753131731751e9</guid>
  <created_at>2016-07-11T23:02:24Z</created_at>
  <provider_display_name>mobile</provider_display_name>
  <text>i am a very interesting status update</text>
  <public>true</public>
  <photo>
    <guid>0788070029e8013487753131731751e9</guid>
    <author>alice@example.org</author>
    <public>true</public>
    <created_at>2016-07-11T23:02:24Z</created_at>
    <remote_photo_path>https://example.org/uploads/images/</remote_photo_path>
    <remote_photo_name>520d78fbe91fbb6641f7.jpg</remote_photo_name>
    <status_message_guid>74139da029e9013487753131731751e9</status_message_guid>
    <height>480</height>
    <width>800</width>
  </photo>
  <photo>
    <guid>1601f9c029e8013487753131731751e9</guid>
    <author>alice@example.org</author>
    <public>true</public>
    <created_at>2016-07-11T23:02:24Z</created_at>
    <remote_photo_path>https://example.org/uploads/images/</remote_photo_path>
    <remote_photo_name>8cf7ca6250b4043a78d8.jpg</remote_photo_name>
    <status_message_guid>74139da029e9013487753131731751e9</status_message_guid>
    <height>480</height>
    <width>800</width>
  </photo>
  <location>
    <address>Vienna, Austria</address>
    <lat>48.208174</lat>
    <lng>16.373819</lng>
  </location>
  <poll>
    <guid>2a22d6c029e9013487753131731751e9</guid>
    <question>Select an answer</question>
    <poll_answer>
      <guid>2a22db2029e9013487753131731751e9</guid>
      <answer>Yes</answer>
    </poll_answer>
    <poll_answer>
      <guid>2a22e5e029e9013487753131731751e9</guid>
      <answer>No</answer>
    </poll_answer>
    <poll_answer>
      <guid>2a22eca029e9013487753131731751e9</guid>
      <answer>Maybe</answer>
    </poll_answer>
  </poll>
  <embed>
    <url>https://example.org/</url>
    <title>Example Website</title>
    <description>This is an example!</description>
    <image>https://example.org/example.png</image>
  </embed>
</status_message>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
[markdown]: {{ site.baseurl }}/federation/types.html#markdown
[string]: {{ site.baseurl }}/federation/types.html#string
[post]: {{ site.baseurl }}/entities/post.html
[location]: {{ site.baseurl }}/entities/location.html
[photo]: {{ site.baseurl }}/entities/photo.html
[poll]: {{ site.baseurl }}/entities/poll.html
[event]: {{ site.baseurl }}/entities/event.html
[embed]: {{ site.baseurl }}/entities/embed.html
