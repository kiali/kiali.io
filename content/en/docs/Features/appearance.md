---
title: "Appearance"
description: "How to customize color scheme, contrast, and theme in the standalone Kiali Console."
---

The standalone Kiali Console lets you customize how the interface looks on your device. Open the user dropdown in the top-right corner and select **Preferences** to adjust color scheme, contrast mode, and theme. These choices are saved in your browser and persist across sessions.

For language settings, see [Internationalization]({{< relref "./internationalization" >}}).

![Preferences appearance settings](/images/documentation/features/appearance-preferences.png "Preferences appearance settings")

## Color scheme

Choose how light or dark the interface appears:

| Option | Behavior |
|--------|----------|
| **System** | Follows your operating system's `prefers-color-scheme` setting. |
| **Light** | Always uses the light color scheme. |
| **Dark** | Always uses the dark color scheme. |

When **System** is selected, Kiali updates automatically if you change the OS color scheme while the console is open.

## Contrast mode

Choose the visual contrast style applied to the interface:

| Option | Behavior |
|--------|----------|
| **System** | Follows your operating system's `prefers-contrast` setting. |
| **Default** | Standard PatternFly contrast (traditional appearance). |
| **Glass** | PatternFly glass contrast mode with translucent surfaces and opaque control fills for buttons and toggles. |
| **High contrast** | PatternFly high-contrast mode for stronger visual separation. |

Glass and high contrast modes are not applied together. When the OS requests both, Kiali applies high contrast.

## Theme

Choose the PatternFly theme variant:

| Option | Behavior |
|--------|----------|
| **Default** | Standard PatternFly theme. |
| **Project Felt** | PatternFly Project Felt theme variant. |

Theme is independent of color scheme and contrast mode. You can combine, for example, dark color scheme with Project Felt.

## Standalone vs. OSSMC

These appearance controls are available in the **standalone Kiali Console** only.

In the [OSSMC plugin]({{< relref "/docs/OSSMC" >}}), the **Preferences** modal does not expose appearance settings. OSSMC follows the OpenShift Console appearance, including color scheme, glass, felt, and high-contrast modes applied to the console `<html>` element.

If you use both standalone Kiali and OSSMC, your standalone appearance choices are preserved in browser storage and are not overwritten when you visit OSSMC.
