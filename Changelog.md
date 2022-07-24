# 1.0.1

- Disable rails forgery protection for the federation controller by default [#127](https://github.com/diaspora/diaspora_federation/pull/127)

# 1.0.0

- Add rails 7 support [#126](https://github.com/diaspora/diaspora_federation/pull/126)
- Add faraday 2 support [#126](https://github.com/diaspora/diaspora_federation/pull/126)

# 0.3.0

## Breaking changes

- Drop support for rails 5.1 and older [4b4375c](https://github.com/diaspora/diaspora_federation/commit/4b4375cf787e09537f53aff92b054a0386681747) [ecfe0ea](https://github.com/diaspora/diaspora_federation/commit/ecfe0ea850d203e8144adab744c4b43263200902)
- Drop support for ruby 2.6 and older [68df3cf](https://github.com/diaspora/diaspora_federation/commit/68df3cf555efafc72942cfec2c8fb3e8852ddec1) [#121](https://github.com/diaspora/diaspora_federation/pull/121)
- Drop support for faraday 0.x [#116](https://github.com/diaspora/diaspora_federation/pull/116)
- Remove support to receive old federation protocol [#114](https://github.com/diaspora/diaspora_federation/pull/114)
- Remove support for old non-RFC WebFinger [#122](https://github.com/diaspora/diaspora_federation/pull/122)

## Features

- Add rails 6 support [afee784](https://github.com/diaspora/diaspora_federation/commit/afee78476b1715ba32e2b97d7cbf2584d57718dd)
- Add faraday 1.x support [#116](https://github.com/diaspora/diaspora_federation/pull/116)
- Add support for up to ruby 3.1 [#121](https://github.com/diaspora/diaspora_federation/pull/121)

# 0.2.8

- Re-release which allows rails 6 to be used

# 0.2.7

## Features

- Add `remote_photo_path` to `AccountMigration` entity [#119](https://github.com/diaspora/diaspora_federation/pull/119)

## Bug fixes

- Only parse each nested element name once from the XML [#118](https://github.com/diaspora/diaspora_federation/pull/118)

# 0.2.6

## Bug fixes

- Make `width` and `height` optional for photos in the JSON schema [#110](https://github.com/diaspora/diaspora_federation/pull/110)

# 0.2.5

## Features

- Add `full_name` to `Profile` entity [#100](https://github.com/diaspora/diaspora_federation/pull/100)
- Add `Embed` entity [#101](https://github.com/diaspora/diaspora_federation/pull/101)

## Refactor

- Include `web+` prefix in `diaspora://` URL parsing [#108](https://github.com/diaspora/diaspora_federation/pull/108)

## Bug fixes

- Various bug fixes in the `federation_entities.json` [#102](https://github.com/diaspora/diaspora_federation/pull/102) [#104](https://github.com/diaspora/diaspora_federation/pull/104) [#107](https://github.com/diaspora/diaspora_federation/pull/107)
- Allow fetching of entities with dot in the GUID [#106](https://github.com/diaspora/diaspora_federation/pull/106)

# 0.2.4

## Features

- Make some entities editable and add `edited_at` property [#94](https://github.com/diaspora/diaspora_federation/pull/94)

## Bug fixes

- Fix validation of optional properties (for example for WebFinger) [#97](https://github.com/diaspora/diaspora_federation/pull/97)

# 0.2.3

## Features

- Add `blocking` flag to `Contact` entity [#80](https://github.com/diaspora/diaspora_federation/pull/80)
- Introduce alternative form for `AccountMigration` entity signature [#89](https://github.com/diaspora/diaspora_federation/pull/89)

## Refactor

- Extract signing of `AccountMigration` to a different module [#89](https://github.com/diaspora/diaspora_federation/pull/89)
- Remove participants limit for conversations [#91](https://github.com/diaspora/diaspora_federation/pull/91)

## Bug fixes

- Fix when booleans in relayables are false [#90](https://github.com/diaspora/diaspora_federation/pull/90)
- Fix relayable signatures for messages with invalid XML characters [#95](https://github.com/diaspora/diaspora_federation/pull/95)

# 0.2.2

## Features

- Add support for [diaspora://](https://diaspora.github.io/diaspora_federation/federation/diaspora_scheme.html) URIs and fetch linked entities (see [#75](https://github.com/diaspora/diaspora_federation/pull/75)) [#78](https://github.com/diaspora/diaspora_federation/pull/78) [#85](https://github.com/diaspora/diaspora_federation/pull/85)
- Fetch RFC 7033 WebFinger with fallback to legacy WebFinger [#74](https://github.com/diaspora/diaspora_federation/pull/74)
- Add support to receive and relay likes for comments [#81](https://github.com/diaspora/diaspora_federation/pull/81)

## Refactor

- Always raise a DiscoveryError when something with the discovery fails [#77](https://github.com/diaspora/diaspora_federation/pull/77)
- Tighten the validation of diaspora\* IDs [#86](https://github.com/diaspora/diaspora_federation/pull/86)
- Allow to receive non-public profiles without private data [#79](https://github.com/diaspora/diaspora_federation/pull/79)
- Remove `public` and `provider_display_name` from `Reshare` entity [#84](https://github.com/diaspora/diaspora_federation/pull/84)

## Bug fixes

- Allow reshares with no root [#73](https://github.com/diaspora/diaspora_federation/pull/73)
- Make `height` and `width` optional for photos [#76](https://github.com/diaspora/diaspora_federation/pull/76)
- Detect loops when fetching entities [#87](https://github.com/diaspora/diaspora_federation/pull/87)

## Documentation

- Add documentation for the future of the `Reshare` entity (see [#83](https://github.com/diaspora/diaspora_federation/pull/83)) [#84](https://github.com/diaspora/diaspora_federation/pull/84)

# 0.2.1

## Features

- Add `DiasporaFederation::Schemas` to access the JSON schema [#70](https://github.com/diaspora/diaspora_federation/pull/70)

## Refactor

- Don't add optional properties to generated XML and JSON when nil [#71](https://github.com/diaspora/diaspora_federation/pull/71)

# 0.2.0

## Features

- Add JSON support to entities [#52](https://github.com/diaspora/diaspora_federation/pull/52)
- Add `AccountMigration` entity [#54](https://github.com/diaspora/diaspora_federation/pull/54)
- Add `public` flag to `Profile` entity [#59](https://github.com/diaspora/diaspora_federation/pull/59)
- Allow to generate WebFinger with additional data [#61](https://github.com/diaspora/diaspora_federation/pull/61) [1b9dfc8](https://github.com/diaspora/diaspora_federation/commit/1b9dfc812e8b63c64a2d98db8999cae21d102c87)
- Provide RFC 7033 WebFinger [#63](https://github.com/diaspora/diaspora_federation/pull/63)
- Validate the author of the root post for a reshare [92ce4ea](https://github.com/diaspora/diaspora_federation/commit/92ce4eacf842f7a2fa74f298407062a4e0c891a3)

## Refactor

- Replace `factory_girl` with `fabrication` [184954e](https://github.com/diaspora/diaspora_federation/commit/184954e09ce72242cb7ec06c15fed0ad7b6c57c6)
- Use `actionpack` as dependency instead of `rails` (for `diaspora_federation-rails`) [f860a62](https://github.com/diaspora/diaspora_federation/commit/f860a62382999dcf0adaf41a24b50b74611f6ed9)
- Remove old backward-compatibility from WebFinger [#60](https://github.com/diaspora/diaspora_federation/pull/60)
- Make optional properties optional when generating WebFinger [#61](https://github.com/diaspora/diaspora_federation/pull/61) [5fef763](https://github.com/diaspora/diaspora_federation/commit/5fef7633c3aaf47db2592749e506f40b581c0371)
- Make `Message` entity non-relayable (see [#36](https://github.com/diaspora/diaspora_federation/issues/36)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [b7167b9](https://github.com/diaspora/diaspora_federation/commit/b7167b9fde4d614fb8f7510720918e029d3624f4)
- Make `Participation` entity non-relayable (see [#35](https://github.com/diaspora/diaspora_federation/issues/35)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [41ebe13](https://github.com/diaspora/diaspora_federation/commit/41ebe13126a28b95dbe5acc5db3939ee9dae7e4b)
- Remove legacy signature order and order by property order in entity (see [#26](https://github.com/diaspora/diaspora_federation/issues/26)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [87033e4](https://github.com/diaspora/diaspora_federation/commit/87033e4cd63f7d237b9d02d95b739e971d205ea1)
- Send new property names in XML (see [#29](https://github.com/diaspora/diaspora_federation/issues/29)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [52a8c89](https://github.com/diaspora/diaspora_federation/commit/52a8c89d4c0f1f66b188ab4a2ac36ffafb0bfa1a)
- Send unwrapped entities (see [#28](https://github.com/diaspora/diaspora_federation/issues/28)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [221d87d](https://github.com/diaspora/diaspora_federation/commit/221d87d7fe664bde8718182178cb31ba532977c6)
- Send the raw magic envelope and new encrypted magic envelope with crypt-json-wrapper (see [#30](https://github.com/diaspora/diaspora_federation/issues/30)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [1f99518](https://github.com/diaspora/diaspora_federation/commit/1f99518706e6bef3dca51453bf571373cd389942) [e5b2ef7](https://github.com/diaspora/diaspora_federation/commit/e5b2ef71e8cfa299874e3f80175526b8999839f7)
- Remove sign-code and prevent creation of `SignedRetraction` and `RelayableRetraction` (see [#27](https://github.com/diaspora/diaspora_federation/issues/27)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [cd3a7ab](https://github.com/diaspora/diaspora_federation/commit/cd3a7abf4d778f7e3139bcb73a42a9dc4cbcb835)
- Rename `xml_order` to `signature_order` on relayables [b510ed8](https://github.com/diaspora/diaspora_federation/commit/b510ed868f12e15fd5c7b91909cc35281efeb10e)
- Prevent creation of `Request` entity (see [#32](https://github.com/diaspora/diaspora_federation/issues/32)) [#62](https://github.com/diaspora/diaspora_federation/pull/62) [deed1c3](https://github.com/diaspora/diaspora_federation/commit/deed1c3f3ea76658074a4e34f534a12f083e8622)
- Don't check `parent_author_signature` and don't check the `author_signature` when the author is the parent author for relayables (see [#64](https://github.com/diaspora/diaspora_federation/issues/64)) [#65](https://github.com/diaspora/diaspora_federation/pull/65) [6817579](https://github.com/diaspora/diaspora_federation/commit/681757907204885735bc60b18929938ec2ad04bb) [57edc8b](https://github.com/diaspora/diaspora_federation/commit/57edc8baabcf884b0ac5395266ffe148cff5da1d)
- Add `created_at` to `Comment` entity [#67](https://github.com/diaspora/diaspora_federation/pull/67)
- Improve logging when validation fails [c0ea38d](https://github.com/diaspora/diaspora_federation/commit/c0ea38d258ccd76a7499bff0197434d8e42768e8)

## Bug fixes

- Fix issues when used without rails [ed2c2b7](https://github.com/diaspora/diaspora_federation/commit/ed2c2b7f47b91c308321076344459aee839318a8) [b25e229](https://github.com/diaspora/diaspora_federation/commit/b25e2293b0b83bc083bccdbf1523ee691dbb7b2e) [6615233](https://github.com/diaspora/diaspora_federation/commit/66152337f2b47c1cf6639646f55d21f69fe99708)

# 0.1.9

## Bug fixes

- Don't log encrypted private messages [8859c96](https://github.com/diaspora/diaspora_federation/commit/8859c960ac2b771399ad42ccf795043aea4ec9a5)

# 0.1.8

## Feature

- Add ruby 2.4 support

## Documentation

- Various improvements in the protocol documentation

# 0.1.7

## Feature

- Add event entities [#44](https://github.com/diaspora/diaspora_federation/pull/44)

## Refactor

- Add generated signatures of relayables to `#to_h` [#48](https://github.com/diaspora/diaspora_federation/pull/48)

## Bug fixes

- Fix parsing of false value [9a7fd27](https://github.com/diaspora/diaspora_federation/commit/9a7fd278b528c809b3a8c53b86c5fa8d6efaf8aa)

# 0.1.6

## Feature

- Add rails 5 support [82ea57e](https://github.com/diaspora/diaspora_federation/commit/82ea57ef34fe25d2ffbd6067171d73802735043b)

## Refactor

- Add property types [#43](https://github.com/diaspora/diaspora_federation/pull/43)
- Change timestamp format to ISO 8601 [#43](https://github.com/diaspora/diaspora_federation/pull/43)
- Move protocol documentation to master branch [a15d285](https://github.com/diaspora/diaspora_federation/commit/a15d285a6e778a04c5e0c2f9428be099d6abddce)

# 0.1.5

## Refactor

- Use `head` method instead of `:nothing` option [44f6527](https://github.com/diaspora/diaspora_federation/commit/44f6527d64489c212c0f6b050ad343ea0e53e964)
- Add `sender` parameter to `:receive_entity` callback [fb60f83](https://github.com/diaspora/diaspora_federation/commit/fb60f8392698f49b9291f3461e7a68ec84def9e2)

## Bug fixes

- HydraWrapper: Validate hostname after redirect [d18e623](https://github.com/diaspora/diaspora_federation/commit/d18e623082ac620a89e0542ceb97a9f2501c16bf)

# 0.1.4

## Refactor

- Improve magic envelope validation [90d12e7](https://github.com/diaspora/diaspora_federation/commit/90d12e71d00bd4874c09f81cde968360111933f9)
- Raise ValidationError if properties are missing [4295237](https://github.com/diaspora/diaspora_federation/commit/4295237e9e6e8e0ff23a5d8d732654b865f44944)

# 0.1.3

## Refactor

- Improve handling of `xml_order` in relayables [36a787d](https://github.com/diaspora/diaspora_federation/commit/36a787dd87f9770e16fbc1bbc0a6c0d6f059e727) [ba129aa](https://github.com/diaspora/diaspora_federation/commit/ba129aafa38f978f69565d39b7a881a245b03bab) [41de99b](https://github.com/diaspora/diaspora_federation/commit/41de99bd5e4ed2779d574183a58f9ac9550c658a)

# 0.1.2

## Refactor

- Improve code documentation [#38](https://github.com/diaspora/diaspora_federation/pull/38)
- Improve validation [9b32315](https://github.com/diaspora/diaspora_federation/commit/9b3231583d85e6007bf43cedc4480f043c8bde15) [eb8cdef](https://github.com/diaspora/diaspora_federation/commit/eb8cdef604cc8fe71e8455f36a317d80657f1582) [0980294](https://github.com/diaspora/diaspora_federation/commit/0980294a0d259cba1fa2a2a655163b3fa844d239)
- Photo: `status_message_guid` is optional [4136fb9](https://github.com/diaspora/diaspora_federation/commit/4136fb973e7ad27158ef605df12727f4e959c3a3)
- A GUID is at most 255 chars long [f7d269c](https://github.com/diaspora/diaspora_federation/commit/f7d269cd6a4c1b48a7b34083f5fea04ac0835a48)
- hCard: `nickname` is optional [4b94949](https://github.com/diaspora/diaspora_federation/commit/4b949491df3a16b30f6e27113d6fa95c165c1edc)
- StatusMessage: Rename `raw_message` to `text` [2aaff56](https://github.com/diaspora/diaspora_federation/commit/2aaff56e147b505626a615d60564fbbf22c2f452) [#29](https://github.com/diaspora/diaspora_federation/issues/29)

## Bug fixes

- Do not reuse cURL sockets to avoid issues caused by too many simultaneous connections [#37](https://github.com/diaspora/diaspora_federation/pull/37)
- Handle empty xml-elements for nested entities [26b7991](https://github.com/diaspora/diaspora_federation/commit/26b7991defe1d84d10c1186a151676076946b26f)
- Gracefully handle missing xml elements of relayables [9097097](https://github.com/diaspora/diaspora_federation/commit/90970973a58cbc3d897d21a43c0a6c93a30605be)

# 0.1.1

## Features

- Fetch root posts for reshares [9b090a3](https://github.com/diaspora/diaspora_federation/commit/9b090a39501705f00403f124e215e78866039f1e)

# 0.1.0

## Features

- Added Salmon support
