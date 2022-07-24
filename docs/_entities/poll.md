---
title: Poll
---

This entity represents a poll, it is nested in a [StatusMessage][status_message].

## Properties

| Property      | Type (Length)              | Description                    |
| ------------- | -------------------------- | ------------------------------ |
| `guid`        | [GUID][guid]               | The GUID of the poll.          |
| `question`    | [String][string] (255)     | The question of the poll.      |
| `poll_answer` | [PollAnswer][poll_answer]s | At least 2 nested PollAnswers. |

## Example

```xml
<poll>
  <guid>2a22d6c029e9013487753131731751e9</guid>
  <question>Select an answer</question>
  <poll_answer>
    <guid>2a22db2029e9013487753131731751e9</guid>
    <answer>Yes</answer>
  </poll_answer>
  <poll_answer>
    <guid>2a22e5e029e9013487753131731751e9</guid>
    <answer>No</answer>
  </poll_answer>
  <poll_answer>
    <guid>2a22eca029e9013487753131731751e9</guid>
    <answer>Maybe</answer>
  </poll_answer>
</poll>
```

[guid]: {{ site.baseurl }}/federation/types.html#guid
[string]: {{ site.baseurl }}/federation/types.html#string
[poll_answer]: {{ site.baseurl }}/entities/poll_answer.html
[status_message]: {{ site.baseurl }}/entities/status_message.html
