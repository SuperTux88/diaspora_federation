---
title: Conversation
---

This entity represents a private conversation between persons.

## Properties

| Property       | Type (Length)                 | Description                                                                                        |
| -------------- | ----------------------------- | -------------------------------------------------------------------------------------------------- |
| `author`       | [diaspora\* ID][diaspora-id]  | The diaspora\* ID of the author of the conversation.                                               |
| `guid`         | [GUID][guid]                  | The GUID of the conversation.                                                                      |
| `subject`      | [String][string] (255)        | The subject of the conversation.                                                                   |
| `created_at`   | [Timestamp][timestamp]        | The create timestamp of the conversation.                                                          |
| `participants` | [diaspora\* ID][diaspora-id]s | diaspora\* IDs of all participants of this conversation, including the `author`, seperated by `;`. |
| `message`      | [Message][message]            | The first Message in the conversation, needs to be the same `author`.                              |

## Example

```xml
<conversation>
  <author>alice@example.org</author>
  <guid>9b1376a029eb013487753131731751e9</guid>
  <subject>this is a very informative subject</subject>
  <created_at>2016-07-11T23:17:48Z</created_at>
  <participants>alice@example.org;bob@example.com</participants>
  <message>
    <guid>5cc5692029eb013487753131731751e9</guid>
    <text>this is a very informative text</text>
    <created_at>2016-07-11T23:17:48Z</created_at>
    <author>alice@example.org</author>
    <conversation_guid>9b1376a029eb013487753131731751e9</conversation_guid>
  </message>
</conversation>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[string]: {{ site.baseurl }}/federation/types.html#string
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[message]: {{ site.baseurl }}/entities/message.html
