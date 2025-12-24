![gitHub](https://github.com/user4-33/rsh-improElectronics/assets/119926454/a0020673-daae-412c-a304-e01612e475a8)
# rsh-improElectronics
rsh-improElectronics is an accessible SuperCollider-based live-electronics architecture for improvisation ensembles. Including a range of live-effects, sample-playback structures, and electronic instruments, the setup serves as a solid starting point for developing a custom live-electronics setup. You will need several microphones (e.g., DPA 4099), a compatible audio interface and a flexible amount of loudspeakers.

This setup was developed by [Luis Küffner](https://luiskueffner.com) (Musikinformatik, Prof. Julian Rohrhuber, [institute for music and media](https://www.rsh-duesseldorf.de/institute/institut-fuer-musik-und-medien)) as part of *Digitalgestützes Improvisieren* – a fellowship for innovation in digital university teaching lead by Dr. Hubertus Dreyer. The project was funded at Robert Schumann Hochschule Düsseldorf from April 1, 2022 to March 31, 2023.

For any advice or support, contact mail@luiskueffner.com or open an issue on [GitHub](https://github.com/user4-33/rsh-improElectronics).



## Overview
The [SuperCollider](https://supercollider.github.io/) codebase consists of:

- `main.scd`
  - Main file for live performing.

- `startup_rsh-improElectronics.scd`
  - Startup file that initializes all required infrastructure for performance.
  
  Move this file to the directory opened by `StartupFile.openDir;`. In `startup.scd` (located at `StartupFile.currentPath`), select it via `StartupFile.redirectLoad('startup_rsh-improElectronics');`.

- `midi-setup.scd`
  - Loaded by the startup file, assigning parameters to a MIDI-controller, in this case a Behringer X-Touch Mini because of its affordability and accessibility.<br>
  If you use a different one, you'll need to adapt this file by updating all MIDIdefs to the corresponding MIDI note-numbers and/or MIDI channels as well as the feedback strings if desired.

- `buffers/`
  - Contains soundfiles/buffers for playback and source-target-resynthesis. Put custom files here.

- `speaker-testing.scd`
  - Some simple utilites for testing your current loudspeaker setup.

- `license.txt`
  - A license statement regarding the .scd- as well as the soundfiles.

- this `README.md`



### Required dependencies
SuperCollider extensions
- [sc3-plugins](https://github.com/supercollider/sc3-plugins/releases)
- [FluCoMa](https://github.com/flucoma/flucoma-sc/releases/latest)

Quarks
- [StartupFile](https://github.com/aiberlin/StartupFile)



## Additional notes
- This architecture is intentionally flexible and meant to be adapted to your current live improvisation setup.

- In `main.scd`, some lines are commented out. They are often alternatives or inspirations that one can also use or modify (like anything else).

- To control the `\pulsar` Ndef, [TouchOSC](https://hexler.net/touchosc) was used. In TouchOSC, create:
  - 1x `fader` object (set its address in the `path` argument of `\fader1` OSCdef),
  - 1x `xy` object (set its address in the `path` argument of `\xy1` OSCdef) and
  - 6x `button` objects (set their addresses in the `path` arguments of `\button1`, `\button2`, etc OSCdefs).
	- Also make sure to set your computer's IP-address and correct port in TouchOSC. This setup uses port `9999`, but any free port in your current network will work.

- To test this setup in your studio environment, you'd have to simulate some live inputs. A practical option is internal loopback routing using BlackHole or Soundflower. Route your DAW audio output to BlackHole/SoundFlower and select BlackHole/Soundflower as SuperCollider's input device.