---
title: "Internationalization"
description: "How Kiali is displayed in mutliple languages."
---

Kiali is used worldwide and some users prefer to display Kiali in a language that they are more comfortable with than English. For this reason Kiali supports internationalization, and it can be localized into multiple languages.

Current supported languages are English and Chinese.

## Language Selector

Kiali provides a language selector in the Masthead to be able to switch Kiali between supported languages:

![Masthead language selector](/images/documentation/features/internationalization-masthead.png "Masthead language selector")

By default the language selector is hidden, and English is the default language.

In order to show the language selector a feature flag must be enabled in the Kiali CR:

```yaml
spec:
  kiali_feature_flags:
    ui_defaults:
      i18n:
        language: en
        show_selector: true
```

You can also modify the default language shown in Kiali (values according to ISO 639-1 codes):

| <div style="width:100px">Language</div> | <div style="width:70px">Code</div> |
| --------------------------------------- | ---------------------------------- |
| Chinese                                 | zh                                 |
| English                                 | en                                 |

<br />

As an example, this is how Kiali displays the Overview page in Chinese:

![Overview page in Chinese](/images/documentation/features/internationalization-chinese.png "Overview page in Chinese")

If you want to collaborate with us on adding a new language or improving the translation of an existing one, please refer to the internationalization section of the kiali project's [README for UI](https://github.com/kiali/kiali/blob/master/frontend/README.adoc#internationalization-i18n)
