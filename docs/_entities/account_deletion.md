---
title: AccountDeletion
---

This entity is sent when a person closed the account.

## Properties

| Property | Type                         | Description                              |
| -------- | ---------------------------- | ---------------------------------------- |
| `author` | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the closed account. |

## Example

```xml
<account_deletion>
  <author>alice@example.org</author>
</account_deletion>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
