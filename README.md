#           ❄︎ WinterIsComing ❄︎

Let it snow on your Mac! ☃️

Snow falls on your desktop and piles up on your windows and Dock. Roll it into snowballs and build a little snowman. It's all one Swift file, and every flake is drawn in code.

<!-- ![demo](docs/demo.gif) -->

## What it can do ✨

- 🌨️ **Cozy snowfall**: three layers of flakes (near, middle and far) drifting in a gentle wind
- 🏔️ **Snow piles up** on top of your windows, along the Dock and at the bottom of the screen
- 🪟 **Drag a window and *whoosh*!** The snow flies off. The faster you drag, the farther it goes
- ⚪ **Roll snowballs** just by moving your mouse sideways over the snow (no clicking!). They grow as they roll
- 🎳 **Snowballs push each other** along, and one that's pushed off the edge falls down
- 🖐️ **Hold a snowball** with the left mouse button and carry it anywhere
- ⛄ **Stack three snowballs** and they turn into a snowman with a carrot nose and a red scarf
- 💥 **A falling snowball goes *poof*** into a soft heap of snow, ready to be rolled again

## Try it 🚀

```sh
git clone https://github.com/<your-username>/WINTER_IS_COMING.git
cd WINTER_IS_COMING
zsh build.sh
```

Use the ❄︎ in the menu bar to enable or disable snow, customize it, clear it, or quit.

- No `swiftc`? Run `xcode-select --install` first.
- Want snow on the Dock too? Turn on **Terminal** in System Settings → Privacy & Security → Accessibility.

## Install as a startup app 🚀

```sh
zsh install.sh
```

This builds `WinterIsComing.app`, installs it to `~/Applications`, and starts it every time you log in with a LaunchAgent. Your settings are stored in `~/Library/Preferences/com.yike-shi.winteriscoming.plist`, so they survive restarts.

```sh
zsh install.sh --system       # install into /Applications instead
zsh install.sh --no-login     # install but do not start at login
zsh install.sh --keep-alive   # keep relaunching even after a normal quit
zsh install.sh --uninstall    # remove the app, login item and settings
```

By default the login item restarts the app after a crash but respects a normal Quit. When installed as an app, grant Accessibility to **WinterIsComing** (not Terminal) for snow on the Dock.

## Customize from the menu 🎛️

Open the ❄︎ menu:

- **Snow Enabled**: instantly turn the snowfall on or off; the choice survives restarts
- **Snow Amount**: Light, Medium, Heavy or Blizzard
- **Fall Speed**: Slow, Normal or Fast
- **Wind**: Calm, Breezy or Gusty
- **Snow Color**: Classic White, Ice Blue, Rose or Mint
- **Pile Height**: Low, Normal or High
- **Snowballs**: turn rolling balls on or off
- **Snow in Front of Windows**: let the small front layer fall over windows
- **Reset All Settings**: back to the defaults

Every choice is saved immediately and restored the next time the app starts. The defaults still live at the top of `WinterIsComing.swift` if you prefer to change the source.

## Make it yours 🎨

The menu covers the common knobs. For the rest, the defaults live at the top of `WinterIsComing.swift` (`enum Cfg`): gravity, column width, snowball growth, Dock padding and so on. Change a number and run `zsh build.sh` or `zsh install.sh` again.

## License

[MIT](LICENSE) · Made with 💙 and a little help from Claude
