---
title: Participation
---

A participation is sent to subscribe a person on updates for some [Post][post].

The `parent_type` can only be a [Post][post] (if it's a [StatusMessage][status_message] or [Reshare][reshare])

## Properties

| Property      | Type                         | Description                                           |
| ------------- | ---------------------------- | ----------------------------------------------------- |
| `author`      | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the participation. |
| `guid`        | [GUID][guid]                 | The GUID of the participation.                        |
| `parent_guid` | [GUID][guid]                 | The GUID of the parent entity.                        |
| `parent_type` | [Type][type]                 | The entity type of the parent.                        |

## Example

```xml
<participation>
  <author>alice@example.org</author>
  <guid>0840a9b029f6013487753131731751e9</guid>
  <parent_type>Post</parent_type>
  <parent_guid>c3893bf029e7013487753131731751e9</parent_guid>
</participation>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[type]: {{ site.baseurl }}/federation/types.html#type
[post]: {{ site.baseurl }}/entities/post.html
[status_message]: {{ site.baseurl }}/entities/status_message.html
[reshare]: {{ site.baseurl }}/entities/reshare.html
