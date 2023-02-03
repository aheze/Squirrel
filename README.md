<img src="Assets/Logo.png" width="120" alt="Logo">

# Squirrel

🐿️ *Pronounced: Scroll-Wheel*

A menu bar app that adds scrolling to the simulator.

- For some reason, you can't scroll in Xcode's simulator.
- This app enables scrolling again!
- Features: customizable settings, made with SwiftUI, and a cute squirrel.

## Installation

You can download Squirrel [directly](https://github.com/aheze/Squirrel/blob/main/Squirrel.zip), or use Homebrew.

```bash
brew tap hkamran80/things
brew install hkamran80/things/squirrel
```

**Note:** Squirrel requires macOS Ventura (13.0) or higher.

## Screenshots

<table>

<tr>
<td>
Main Menu
</td>
<td>
Advanced Settings
</td>
</tr>

<tr>
</tr>
  
<tr>
<td>
<img src="Assets/MenuBar.png" alt="Menu Bar">
</td>
<td rowspan=5>
<img src="Assets/MenuBar-Expanded.png" alt="Menu Bar Expanded">
</td>
</tr>

<tr>
</tr>
  
<tr>
<td>
Dark Mode
</td>
</tr>
  
<tr>
</tr>

  
<tr>
<td>
<img src="Assets/MenuBar-Dark.png" alt="Menu Bar Dark Mode">
</td>
</tr>
 
</table>

<table>
<tr>
<td>
1. You start scrolling
</td>
<td>
2. Squirrel drags on the screen for you
</td>
<td>
3. Your cursor auto-snaps back to where you started
</td>
</tr>
  
  
<tr>
</tr>  
  
<tr>
<td>
<img src="Assets/Simulator1.png" alt="Screenshot of simulator">
</td>
<td>
<img src="Assets/Simulator2.png" alt="Screenshot of simulator, blue pointer shown at initial cursor position. Cursor is dragged higher up.">
</td>
<td>
<img src="Assets/Simulator3.png" alt="Screenshot of simulator, cursor is back at its original position.">
</td>
</tr>
</table>

## Videos


https://user-images.githubusercontent.com/49819455/216271894-3e2352a4-edd0-41b7-a830-1cc4fb9aa15e.mp4



https://user-images.githubusercontent.com/49819455/216271984-b6672a5f-72ad-40bd-b01b-dad7059d92ae.mp4



## Community

Author | Contributing | Need Help?
--- | --- | ---
Squirrel is made by [aheze](https://github.com/aheze). | All contributions are welcome. Just [fork](https://github.com/aheze/Squirrel/fork) the repo, then make a pull request. | Open an [issue](https://github.com/aheze/Squirrel/issues) or join the [Discord server](https://discord.com/invite/Pmq8fYcus2). You can also ping me on [Twitter](https://twitter.com/aheze0). Or read the source code — there's lots of comments.

### How does it work?

Squirrel uses your Mac's accessibility controls to simulate a "drag" gesture.

### Apple, if you're reading this:

Please add native scroll support to the Simulator! Feels like such a small feature but it'll be very welcome.

## License

```text
MIT License

Copyright (c) 2023 A. Zheng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
