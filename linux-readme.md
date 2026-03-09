# FWAI Widget - Linux (KDE Plasma) Setup

## Google Login Fix

### Problem

Some AI providers (like Claude) use Google OAuth for login. Google blocks sign-in attempts from embedded browsers by checking `Sec-CH-UA` HTTP headers. Qt WebEngine (the browser engine used by KDE Plasma widgets) sends headers that identify it as "Chromium" rather than "Google Chrome", which causes Google to reject the login with:

> "This browser or app may not be secure. Try using a different browser."

This is a server-side check - Google inspects the HTTP headers before the page even loads, so JavaScript workarounds cannot bypass it.

### Solution

Create an environment script that disables the `Sec-CH-UA` (User-Agent Client Hints) headers. Without these headers, Google falls back to checking only the standard `User-Agent` string, which the widget sets to match a regular Chrome browser.

**Create the file:**

```bash
mkdir -p ~/.config/plasma-workspace/env
```

```bash
echo 'export QTWEBENGINE_CHROMIUM_FLAGS="--disable-features=UserAgentClientHint"' > ~/.config/plasma-workspace/env/fwai-webengine.sh
```

**Then log out and log back in** (or restart plasmashell):

```bash
plasmashell --replace &
```

> **Note:** The environment script in `~/.config/plasma-workspace/env/` is sourced automatically by KDE Plasma at session startup. A simple `plasmashell --replace` may work, but a full re-login guarantees the variable is loaded.

### How it works

- `QTWEBENGINE_CHROMIUM_FLAGS` passes Chromium command-line flags to all Qt WebEngine instances in the session
- `--disable-features=UserAgentClientHint` prevents sending `Sec-CH-UA`, `Sec-CH-UA-Platform`, and related headers
- Google then checks only the `User-Agent` header, which the widget sets to a standard Chrome user agent matching the embedded Chromium version
- This affects all Qt WebEngine-based apps in your Plasma session (Plasma widgets, Falkon, etc.), but has no negative side effects

### Matching Chrome version to Qt WebEngine

The widget's User-Agent should match the Chromium version embedded in your Qt WebEngine. Common mappings:

| Qt Version | Chromium Version |
|------------|-----------------|
| 6.6        | 112             |
| 6.7        | 118             |
| 6.8        | 122             |
| 6.9        | 126             |
| 6.10       | 130             |

Check your version:

```bash
pacman -Q qt6-webengine    # Arch/Manjaro
apt show libqt6webengine6  # Debian/Ubuntu
```

The widget auto-sets the User-Agent, but if login still fails after applying the fix, the Chrome version in the UA string may need updating in the widget configuration to match your Qt WebEngine version.

## Installation

1. Copy the widget to the Plasma plasmoids directory:

```bash
cp -r com.freewill.ai.widget ~/.local/share/plasma/plasmoids/
```

2. Apply the Google login fix (see above)

3. Add the widget to your panel or desktop via right-click > Add Widgets > search "FWAI"

## Requirements

- KDE Plasma 6
- Qt 6.6+ with Qt WebEngine
- No additional packages required (avoid mode uses native KDE TaskManager API)

## Keyboard Shortcuts

- **Global shortcut**: Set in System Settings > Shortcuts > search "FWAI"
- **Ctrl+Tab / Ctrl+Shift+Tab**: Switch between AI providers
- **F5 / Ctrl+R**: Refresh
- **Escape**: Close side window
- **Configurable maximize shortcut** (default: F11)
