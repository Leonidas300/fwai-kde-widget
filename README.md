# FWAI – AI Assistant Widget for KDE Plasma 6

> Always-on-top AI assistant living in your KDE panel — one click away, no browser tab switching needed.

If you spend your day working in Linux and constantly reaching for Claude, Grok, ChatGPT or other AI assistants, this widget keeps them instantly accessible as a side panel that slides in over your workspace. No new window, no alt-tab, no lost focus — just your AI, right there when you need it.

![KDE Plasma 6](https://img.shields.io/badge/KDE%20Plasma-6-blue?logo=kde)
![Qt](https://img.shields.io/badge/Qt-6.6+-green?logo=qt)
![License](https://img.shields.io/badge/License-GPL--2.0-orange)

---

## Features

- **Instant access** — opens as a frameless side window from your panel icon
- **Multiple AI providers** — switch between Claude, Grok, ChatGPT, Gemini, Copilot, Perplexity, DeepSeek or any custom URL
- **Persistent sessions** — cookies and login state are preserved between opens
- **Avoid mode** — automatically moves to your second monitor when another app is in the foreground on your main screen
- **Keyboard shortcuts** — open/close globally, switch providers, maximize
- **Configurable size** — adjust panel icon padding and popup width
- **Hide header** — hide the top toolbar for a cleaner look

---

## Requirements

- **Manjaro KDE Plasma 6** (or any KDE Plasma 6 distro)
- **Qt 6.6+** with **Qt WebEngine** — already bundled with Manjaro KDE

---

## Installation

### 1. Install Qt WebEngine (if not already installed)

On Manjaro this is usually pre-installed. If not:

```bash
sudo pacman -S qt6-webengine
```

### 2. Download the widget

Clone this repository:

```bash
git clone https://github.com/Leonidas300/fwai-kde-widget.git
```

### 3. Copy to Plasma plasmoids directory

```bash
cp -r fwai-kde-widget/com.freewill.ai.widget ~/.local/share/plasma/plasmoids/
```

### 4. Fix Google login (Claude, Gemini, Copilot)

Providers that use Google OAuth (Claude, Gemini, Microsoft Copilot) require one extra step. Google blocks sign-in from embedded browsers by checking `Sec-CH-UA` headers. Create a startup script to disable them:

```bash
mkdir -p ~/.config/plasma-workspace/env
echo 'export QTWEBENGINE_CHROMIUM_FLAGS="--disable-features=UserAgentClientHint"' \
  > ~/.config/plasma-workspace/env/fwai-webengine.sh
```

Then **log out and log back in** so KDE picks up the new environment variable.

> This only affects Qt WebEngine apps (Plasma widgets, Falkon browser, etc.) and has no negative side effects.

### 5. Add the widget to your panel

Right-click your KDE panel → **Add Widgets** → search for **FWAI** → drag it to the panel.

### 6. Set a global keyboard shortcut (optional but recommended)

**System Settings → Shortcuts → search "FWAI"** → assign a key combo (e.g. `Meta+A`).

---

## Configuration

Right-click the panel icon → **Configure FWAI...**

| Setting | Description |
|---|---|
| Default provider | Which AI opens by default |
| Configured providers | Add, remove, or reorder AI providers |
| Avoid mode | Move widget to other monitor when apps are open |
| Keep open | Don't close when clicking outside the panel |
| Hide header | Remove the top toolbar for a minimal look |
| Panel icon padding | Adjust icon size in the panel |
| Popup width | Width of the side panel in pixels |

### Adding a custom AI provider

In the config dialog, type a name and URL in the **Add new provider** fields and click **Add**. Any web-based AI works — including self-hosted ones like Open WebUI.

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Meta+A` (configurable) | Open / close the side panel |
| `Ctrl+Tab` | Switch to next AI provider |
| `Ctrl+Shift+Tab` | Switch to previous AI provider |
| `F11` (configurable) | Toggle maximize |
| `F5` / `Ctrl+R` | Refresh the page |
| `Escape` | Close the side panel |

---

## Switching Between Providers

Click the provider buttons in the top header bar, or use `Ctrl+Tab` / `Ctrl+Shift+Tab`. You can also add a dedicated shortcut per provider via **System Settings → Shortcuts**.

---

## Google Login — How It Works

Some AI services use Google OAuth, which rejects requests from embedded browsers by inspecting `Sec-CH-UA` HTTP headers. The fix (`--disable-features=UserAgentClientHint`) stops Qt WebEngine from sending those headers. Google then falls back to checking only the standard `User-Agent` string, which the widget sets to match a regular Chrome browser.

If login still fails after applying the fix, your Qt WebEngine version may ship a different Chromium version. Check your Qt version:

```bash
pacman -Q qt6-webengine
```

Common mappings:

| Qt Version | Chromium |
|---|---|
| 6.6 | 112 |
| 6.7 | 118 |
| 6.8 | 122 |
| 6.9 | 126 |
| 6.10 | 130 |

---

## Uninstall

```bash
rm -rf ~/.local/share/plasma/plasmoids/com.freewill.ai.widget
rm -f ~/.config/plasma-workspace/env/fwai-webengine.sh
```

Then log out and back in.

---

## License

GPL-2.0 — see [LICENSE](LICENSE)
