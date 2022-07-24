---
title: XML Serialization
---

The [entities][entities] are serialized to XML, before they are added to the [Magic Envelope][magicsig].

## Root element

The root element is named like the entity-name in `snake_case`.

Examples: `status_message`, `comment`, `like`

## Properties

The properties are added as child-elements, with the value string-serialized as described in [value formats][types] as
content of the element.

The order of the elements is not specified.

Elements may be empty, if they have no value.

Unknown elements must be ignored while parsing (except for signature-verification of [relayables][relayables]).

## Nested Entities

Some entities have other entities as properties. The XML of the nested entity is nested into the root element of the
parent entity. The same entity-type can be nested multiple times (e.g. `poll_answer` in `poll`).

## Example

```xml
<status_message>
  <author>alice@example.org</author>
  <guid>17418fb029e6013487743131731751e9</guid>
  <created_at>2016-07-11T22:38:19Z</created_at>
  <provider_display_name/>
  <text>I am a very interesting status update</text>
  <public>true</public>
</status_message>
```

[entities]: {{ site.baseurl }}/entities/
[magicsig]: {{ site.baseurl }}/federation/magicsig.html
[types]: {{ site.baseurl }}/federation/types.html
[relayables]: {{ site.baseurl }}/federation/relayable.html
