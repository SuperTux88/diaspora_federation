---
title: AccountMigration
---

This entity is sent when a person changes their diaspora\* ID (e.g. when a user migration from one to another pod happens).

## Properties

| Property    | Type                         | Description                                                                                                                                                                                                                                        |
| ----------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `author`    | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the sender of the entity. The entity may be sent by either old user identity or new user identity.                                                                                                                            |
| `profile`   | [Profile][profile]           | New profile of a person.                                                                                                                                                                                                                           |
| `signature` | [Signature][signature]       | Signature that validates original and target diaspora\* IDs with the private key of the second identity, other than the entity author. So if the author is the old identity then this signature is made with the new identity key, and vice versa. |

## Optional Properties

| Property            | Type                         | Description                                                                                                       |
| ------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `old_identity`      | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the closed account. This field is mandatory if the author of the entity is the new identity. |
| `remote_photo_path` | [URL][url]                   | The URL to the path (without filenames) of the migrated photos on the new pod.                                    |

### Signature

The signature base string is produced by concatenating the following substrings together, separated by semicolon (`:`):

1. The entity name specifier: `AccountMigration`.

2. diaspora\* ID of the closed account (old diaspora\* ID).

3. diaspora\* ID of the replacement account (new diaspora\* ID).

Example of a string:

```
AccountMigration:old-diaspora-id@example.org:new-diaspora-id@example.com
```

## Example

```xml
<account_migration>
  <author>alice@example.org</author>
  <profile>
    <author>alice@newpod.example.net</author>
    <first_name>my name</first_name>
    <last_name/>
    <image_url>/assets/user/default.png</image_url>
    <image_url_medium>/assets/user/default.png</image_url_medium>
    <image_url_small>/assets/user/default.png</image_url_small>
    <birthday>1988-07-15</birthday>
    <gender>Female</gender>
    <bio>some text about me</bio>
    <location>github</location>
    <searchable>true</searchable>
    <nsfw>false</nsfw>
    <tag_string>#i #love #tags</tag_string>
  </profile>
  <signature>
    07b1OIY6sTUQwV5pbpgFK0uz6W4cu+oQnlg410Q4uISUOdNOlBdYqhZJm62VFhgvzt4TZXfiJgoupFkRjP0BsaVaZuP2zKMNvO3ngWOeJRf2oRK4Ub5cEA/g7yijkRc+7y8r1iLJ31MFb1czyeCsLxw9Ol8SvAJddogGiLHDhjE=
  </signature>
  <old_identity>alice@example.org</old_identity>
  <remote_photo_path>https://newpod.example.net/uploads/images/</remote_photo_path>
</account_migration>
```

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[profile]: {{ site.baseurl }}/entities/profile.html
[signature]: {{ site.baseurl }}/federation/types.html#signature
[url]: {{ site.baseurl }}/federation/types.html#url
