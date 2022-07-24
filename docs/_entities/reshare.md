---
title: Reshare
---

This entity represents a reshare of a [StatusMessage][status_message].

{% include warning_box.html
title="Future of reshares"
content="<p>Current versions of diaspora\* handle reshares like they inherit from
<a href=\"/diaspora_federation/entities/post.html\">Post</a> and allow interactions (Comments and
Likes) on the reshare. In the future, the reshare entity will only be used to increase the spread of a
Post, more information about this can be found in
<a href=\"https://github.com/diaspora/diaspora_federation/issues/83\">this issue</a>.</p>

   <p>There currently exists a special case for reshares with a deleted root post. It is valid when the
   reshare doesn't include <code>root_author</code> and <code>root_guid</code>. If only one of
   <code>root_author</code> and <code>root_guid</code> is present, the entity is not valid. Once
   reshares are only used to increase the reach of a post, reshares without <code>root_author</code> and
   <code>root_guid</code> will no longer be valid and reshares will be deleted if the original post is deleted.</p>"
%}

The recipient must [fetch][fetching] the root from `root_author` if the post is not already known.
When the `root_guid` is already available locally, the recipient must validate that it's from `root_author`.

## Properties

| Property      | Type                         | Description                                                   |
| ------------- | ---------------------------- | ------------------------------------------------------------- |
| `author`      | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the reshare.               |
| `guid`        | [GUID][guid]                 | The GUID of the reshare.                                      |
| `created_at`  | [Timestamp][timestamp]       | The create timestamp of the reshare.                          |
| `root_author` | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the reshared [Post][post]. |
| `root_guid`   | [GUID][guid]                 | The GUID of the reshared [Post][post].                        |

## Example

```xml
<reshare>
  <author>alice@example.org</author>
  <guid>a0b53e5029f6013487753131731751e9</guid>
  <created_at>2016-07-12T00:36:42Z</created_at>
  <root_author>bob@example.com</root_author>
  <root_guid>a0b53bc029f6013487753131731751e9</root_guid>
</reshare>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[string]: {{ site.baseurl }}/federation/types.html#string
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
[fetching]: {{ site.baseurl }}/federation/fetching.html
[post]: {{ site.baseurl }}/entities/post.html
[status_message]: {{ site.baseurl }}/entities/status_message.html
