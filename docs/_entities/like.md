---
title: Like
---

This entity represents a like to some kind of post (e.g. status message).

The `parent_type` can be one of:

- [Post][post] (if it's a [StatusMessage][status_message] or currently still a [Reshare][reshare])
- [Comment][comment] (diaspora\* doesn't fully support this at the moment, but likes of comments are relayed)

See also: [Relayable][relayable]

## Properties

| Property           | Type                         | Description                                         |
| ------------------ | ---------------------------- | --------------------------------------------------- |
| `author`           | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the like.        |
| `guid`             | [GUID][guid]                 | The GUID of the like.                               |
| `parent_guid`      | [GUID][guid]                 | The GUID of the parent entity.                      |
| `parent_type`      | [Type][type]                 | The entity type of the parent.                      |
| `positive`         | [Boolean][boolean]           | `true` if it is a like, `false` if it is a dislike. |
| `author_signature` | [Signature][signature]       | The signature from the author of the like.          |

## Examples

```xml
<like>
  <positive>true</positive>
  <guid>947a88f029f7013487753131731751e9</guid>
  <parent_type>Post</parent_type>
  <parent_guid>947a854029f7013487753131731751e9</parent_guid>
  <author>alice@example.org</author>
  <author_signature>gk8e+K7XRjVRblv8B8PVOf7BpURbf5HrXO5rmq8D/AkPO7lA0+Akwouu5JGKAHIhPR3dfXVp0o6bIDD+e8gtMYRdDd5IHRfBGNk3WsQecnbhmesHy40Qca/dCQcdcXd5aeWHJKeyUrSAvS55U6VUpk/DK/4IIEZfnr0T9+jM8I0=</author_signature>
</like>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[type]: {{ site.baseurl }}/federation/types.html#type
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
[signature]: {{ site.baseurl }}/federation/types.html#signature
[post]: {{ site.baseurl }}/entities/post.html
[status_message]: {{ site.baseurl }}/entities/status_message.html
[reshare]: {{ site.baseurl }}/entities/reshare.html
[comment]: {{ site.baseurl }}/entities/comment.html
[relayable]: {{ site.baseurl }}/federation/relayable.html
