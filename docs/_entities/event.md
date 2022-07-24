---
title: Event
---

This entity represents an event.

See also: [EventParticipation][event_participation]

## Properties

| Property  | Type (Length)                | Editable | Description                                   |
| --------- | ---------------------------- | :------: | --------------------------------------------- |
| `author`  | [diaspora\* ID][diaspora-id] |    ✘     | The diaspora\* ID of the author of the event. |
| `guid`    | [GUID][guid]                 |    ✘     | The GUID of the event.                        |
| `summary` | [String][string] (255)       |    ✔     | The summary of the event.                     |
| `start`   | [Timestamp][timestamp]       |    ✔     | The start time of the event (in UTC).         |

## Optional Properties

| Property      | Type (Length)                | Editable | Description                                                                                                                                                                                                                                     |
| ------------- | ---------------------------- | :------: | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `end`         | [Timestamp][timestamp]       |    ✔     | The end time of the event (in UTC). If missing it is an open-end or a single `all_day` event.                                                                                                                                                   |
| `all_day`     | [Boolean][boolean]           |    ✔     | `true` if it is an all day event. Time/timezone is ignored. `false` by default.                                                                                                                                                                 |
| `timezone`    | [Timezone][timezone]         |    ✔     | If the event is fixed to a specific timezone, this can be set. The `start`/`end` timestamps are then displayed in this timezone. This is useful for local events. If missing or empty the timestamps are displayed in the timezone of the user. |
| `description` | [Markdown][markdown] (65535) |    ✔     | Description of the event.                                                                                                                                                                                                                       |
| `location`    | [Location][location]         |    ✔     | Location of the event.                                                                                                                                                                                                                          |
| `edited_at`   | [Timestamp][timestamp]       |    ✔     | The timestamp when the event was edited.                                                                                                                                                                                                        |

## Examples

### With start, end and timezone

```xml
<event>
  <author>alice@example.org</author>
  <guid>bb8371f0b1c901342ebd55853a9b5d75</guid>
  <summary>Cool event</summary>
  <start>2016-12-27T12:00:00Z</start>
  <end>2016-12-27T13:00:00Z</end>
  <all_day>false</all_day>
  <timezone>Europe/Berlin</timezone>
  <description>You need to see this!</description>
  <location>
    <address>Vienna, Austria</address>
    <lat>48.208174</lat>
    <lng>16.373819</lng>
  </location>
</event>
```

### All day event

```xml
<event>
  <author>alice@example.org</author>
  <guid>bb8371f0b1c901342ebd55853a9b5d75</guid>
  <summary>Cool event</summary>
  <start>2016-12-27T00:00:00Z</start>
  <end/>
  <all_day>true</all_day>
  <timezone/>
  <description>You need to see this!</description>
  <location>
    <address>Vienna, Austria</address>
    <lat>48.208174</lat>
    <lng>16.373819</lng>
  </location>
</event>
```

[event_participation]: {{ site.baseurl }}/entities/event_participation.html
[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[string]: {{ site.baseurl }}/federation/types.html#string
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[markdown]: {{ site.baseurl }}/federation/types.html#markdown
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
[timezone]: {{ site.baseurl }}/federation/types.html#timezone
[location]: {{ site.baseurl }}/entities/location.html
