---
title: Entities
---

The diaspora\* federation protocol currently knows the following entities:

{% for entity in site.entities %}
- [{{ entity.title }}]({{ site.baseurl }}{{ entity.url }})
{% endfor %}
