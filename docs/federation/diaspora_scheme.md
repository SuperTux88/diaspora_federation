---
title: diaspora:// URI scheme
---

## Server and software independent links

A `diaspora://` URL is used if a user wants to link to another post. It doesn't
contain a server hostname so it is independent of the senders server. And it
isn't software specific, it is thought to be compatible with every software
that is compatible with the protocol, so the receiving software can display
it as software specific URL.

The format is similar to the route used for [fetching][fetching], so if the
receiving server doesn't know the linked entity yet, it can just be fetched.

When the entity with that `guid` is already available locally, the recipient
should validate that it's from `author` before linking to it.

### Format

`diaspora://:author/:type/:guid`

#### Parameters

| Name     | Description                                                          |
| -------- | -------------------------------------------------------------------- |
| `author` | The [diaspora\* ID][diaspora-id] of the author of the linked entity. |
| `type`   | The type of the linked entity in `snake_case`.                       |
| `guid`   | The [GUID][guid] of the linked entity.                               |

#### Example

`diaspora://alice@example.org/post/17faf230675101350d995254001bd39e`

[fetching]: {{ site.baseurl }}/federation/fetching.html
[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
