---
title: Message
---

This entity represents a private message exchanged in private conversation. It can be nested in a
[Conversation][conversation] if it is the first message.

## Properties

| Property            | Type (Length)                | Editable | Description                                     |
| ------------------- | ---------------------------- | :------: | ----------------------------------------------- |
| `author`            | [diaspora\* ID][diaspora-id] |    ✘     | The diaspora\* ID of the author of the message. |
| `guid`              | [GUID][guid]                 |    ✘     | The GUID of the message.                        |
| `conversation_guid` | [GUID][guid]                 |    ✘     | The GUID of the [Conversation][conversation].   |
| `text`              | [Markdown][markdown] (65535) |    ✔     | The message text.                               |
| `created_at`        | [Timestamp][timestamp]       |    ✘     | The create timestamp of the message.            |

## Optional Properties

| Property    | Type (Length)          | Editable | Description                                |
| ----------- | ---------------------- | :------: | ------------------------------------------ |
| `edited_at` | [Timestamp][timestamp] |    ✔     | The timestamp when the message was edited. |

## Example

```xml
<message>
  <author>alice@example.org</author>
  <guid>5cc5692029eb013487753131731751e9</guid>
  <conversation_guid>9b1376a029eb013487753131731751e9</conversation_guid>
  <text>this is a very informative text</text>
  <created_at>2016-07-11T23:17:48Z</created_at>
</message>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[markdown]: {{ site.baseurl }}/federation/types.html#markdown
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[conversation]: {{ site.baseurl }}/entities/conversation.html
