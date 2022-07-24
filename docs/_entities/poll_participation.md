---
title: PollParticipation
---

This entity represents a participation in a [Poll][poll].

See also: [Relayable][relayable]

## Properties

| Property           | Type                         | Description                                                |
| ------------------ | ---------------------------- | ---------------------------------------------------------- |
| `author`           | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the poll participation. |
| `guid`             | [GUID][guid]                 | The GUID of the poll participation.                        |
| `parent_guid`      | [GUID][guid]                 | The GUID of the [Poll][poll].                              |
| `poll_answer_guid` | [GUID][guid]                 | The GUID of the [PollAnswer][poll_answer].                 |
| `author_signature` | [Signature][signature]       | The signature from the author of the poll participation.   |

## Examples

```xml
<poll_participation>
  <guid>f1eb866029f7013487753131731751e9</guid>
  <parent_guid>2a22d6c029e9013487753131731751e9</parent_guid>
  <author>alice@example.org</author>
  <poll_answer_guid>2a22db2029e9013487753131731751e9</poll_answer_guid>
  <author_signature>dT6KbT7kp0bE+s3//ZErxO1wvVIqtD0lY67i81+dO43B4D2m5kjCdzW240eWt/jZmcHIsdxXf4WHNdrb6ZDnamA8I1FUVnLjHA9xexBITQsSLXrcV88UdammSmmOxl1Ac4VUXqFpdavm6a7/MwOJ7+JHP8TbUO9siN+hMfgUbtY=</author_signature>
</poll_participation>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[signature]: {{ site.baseurl }}/federation/types.html#signature
[poll]: {{ site.baseurl }}/entities/poll.html
[poll_answer]: {{ site.baseurl }}/entities/poll_answer.html
[relayable]: {{ site.baseurl }}/federation/relayable.html
