---
title: Entities
---

The diaspora\* federation protocol currently knows the following entities:

<!-- prettier-ignore-start -->

{% for entity in site.entities %}

- [{{ entity.title }}]({{ site.baseurl }}{{ entity.url }})
{% endfor %}
<!-- prettier-ignore-end -->
