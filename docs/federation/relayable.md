---
title: Relayable
---

If a person participates on an entity, it needs to be relayed via the author of the root entity, because only the
root author knows, to whom they shared the original entity.

The root is the most top parent of the relayable: If the parent of a relayable is a relayable itself,
the parent of that should be used, until it isn't a relayable anymore.
For example, for both, a `Like` for a `Post` and a `Like` for a `Comment`, the author of the `Post` should be used.

Such relayable entities are:

- [Comment][comment]
- [Like][like]
- [PollParticipation][poll_participation]

## Common Properties

All relayables have the following properties:

| Property           | Type                         | Description                                       |
| ------------------ | ---------------------------- | ------------------------------------------------- |
| `author`           | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the relayable. |
| `guid`             | [GUID][guid]                 | The GUID of the relayable.                        |
| `parent_guid`      | [GUID][guid]                 | The GUID of the parent entity.                    |
| `author_signature` | [Signature][signature]       | The signature from the author of the relayable.   |

## Relaying

If the author is not the same as the root author, the author of the relayable sends the entity to the root author
and the author must include the `author_signature`.

The root author then must envelop it in a new [Magic Envelope][magicsig] and send the entity to all the recipients
of the root entity. If the author and the root author are on the same server, the author must sign the
`author_signature` and the root author needs to sign the Magic Envelope.

If someone other then the root author receives a relayable without a valid Magic Envelope signed from
the root author, it must be ignored. If the author is not the same as the root author and the `author_signature`
is missing or invalid, it also must be ignored. If the author is the same as the root author, the `author_signature`
can be missing, because a valid signature in the Magic Envelope from the author is enough in that case.

## Signatures

The string to sign is built with the content of all properties (except the `author_signature` itself),
concatenated using `;` as separator in the same order as they appear in the XML. The order in the XML is not specified.

This ensures that relayables even work, if the root author or another recipient does not know all properties of the
relayable entity (e.g. older version of diaspora\*).

This string is then signed with the private RSA key using the RSA-SHA256 algorithm and base64-encoded.

The root author must use the same order as the relayable author. Unknown properties must be included again in the XML
and the signature.

To support fetching of the relayables, the root author should save the following information:

- order of the received XML
- additional (unknown) properties
- `author_signature`

## Retraction / Reject

The root author is allowed to retract the entity, so there are no additional signatures required for the
[Retraction][retraction] (only the [Salmon Magic Signature][magicsig]).

If the author retracts the entity, they send a [Retraction][retraction] to the root author. The root author also
must relay this retraction to all recipients of the root entity.

If the root author wants to reject the entity (e.g. if they ignore the author of the relayable), they can simply send
a [Retraction][retraction] for it back to the author.

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[signature]: {{ site.baseurl }}/federation/types.html#signature
[comment]: {{ site.baseurl }}/entities/comment.html
[like]: {{ site.baseurl }}/entities/like.html
[poll_participation]: {{ site.baseurl }}/entities/poll_participation.html
[retraction]: {{ site.baseurl }}/entities/retraction.html
[magicsig]: {{ site.baseurl }}/federation/magicsig.html
