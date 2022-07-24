---
title: Comment
---

This entity represents a comment to some kind of [Post][post] ([StatusMessage][status_message]
or currently still a [Reshare][reshare]).

See also: [Relayable][relayable]

## Properties

| Property           | Type (Length)                | Editable | Description                                     |
| ------------------ | ---------------------------- | :------: | ----------------------------------------------- |
| `author`           | [diaspora\* ID][diaspora-id] |    ✘     | The diaspora\* ID of the author of the comment. |
| `guid`             | [GUID][guid]                 |    ✘     | The GUID of the comment.                        |
| `parent_guid`      | [GUID][guid]                 |    ✘     | The GUID of the parent entity.                  |
| `text`             | [Markdown][markdown] (65535) |    ✔     | The comment text.                               |
| `created_at`       | [Timestamp][timestamp]       |    ✘     | The create timestamp of the comment.            |
| `author_signature` | [Signature][signature]       |    ✔     | The signature from the author of the comment.   |

## Optional Properties

| Property             | Type (Length)          | Editable | Description                                   |
| -------------------- | ---------------------- | :------: | --------------------------------------------- |
| `edited_at`          | [Timestamp][timestamp] |    ✔     | The timestamp when the comment was edited.    |
| `thread_parent_guid` | [GUID][guid]           |    ✘     | The GUID of the parent comment in the thread. |

## Examples

```xml
<comment>
  <author>alice@example.org</author>
  <guid>5c241a3029f8013487763131731751e9</guid>
  <created_at>2016-07-12T00:49:06Z</created_at>
  <parent_guid>c3893bf029e7013487753131731751e9</parent_guid>
  <text>this is a very informative comment</text>
  <author_signature>cGIsxB5hU/94+rmgIg/Z+OUvXVYcY/kMOvc267ybpk1pT44P1JiWfnI26F1Mta62UjzIW/SjeAO0RIsJRguaISLpXX/d5DJCMpePAZaZiagUbdgH/w4L++fXiPxBKkSm+PB4txxmHGN8FHjwEUJFHJ1m3VfU4w2JC8+IBU93eag=</author_signature>
</comment>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[markdown]: {{ site.baseurl }}/federation/types.html#markdown
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[signature]: {{ site.baseurl }}/federation/types.html#signature
[post]: {{ site.baseurl }}/entities/post.html
[status_message]: {{ site.baseurl }}/entities/status_message.html
[reshare]: {{ site.baseurl }}/entities/reshare.html
[relayable]: {{ site.baseurl }}/federation/relayable.html
