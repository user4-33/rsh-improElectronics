# rsh-improElectronics

Version 1.0

The rsh-improElectronics is a straightforward SuperCollider live improvisation architecture holding several live-effects, sample-playback-structures and electronic instruments. The setup consists of a bunch of SuperCollider files which are meant to be used while performing live with acoustic instruments. You therefore need some microphones (for example DPA-4099), a compatible audio-interface and a flexible number of speakers.

The setup was developed by Luis Küffner (former student in Musikinformatik, Prof. Julian Rohrhuber, institute for music and media) within the fellowship for innovations in digital university teaching called „Digitalgestützes Improvisieren“ by Dr. Hubertus Dreyer. The project was funded between April 1st 2022 and March 31st 2023 at the Robert Schumann Hochschule Düsseldorf.

If you need any advice or support, please contact mail@luiskueffner.com or visit [GitHub](https://github.com/user4-33/rsh-improElectronics). 

The setup consists of the following parts and works with [SuperCollider](https://supercollider.github.io/) 3.13.0:

- rsh-improElectronics_main.scd
  - The main file for performing live.

- rsh-improElectronics_setup.scd
  - A setup file for all the things needed to be loaded in the background.

- rsh-improElectronics_midiSetup.scd
  - A file to assign parameters to a MIDI-controller.
  - Note that this is written compatible with a Behringer X-Touch Mini.
  - If you don't have access to such, you'll have to rewrite this file and change all MIDIdefs to the corresponding MIDI Note-Numbers and/or MIDI channels as well as the feedback-strings if desired.

- rsh-improElectronics_startupFile.scd
  - A startup file which sets up even more things in the background. This file has to be put into
    - `~/Library/Application Support/SuperCollider/startup.scd` for macOS,
    - `~/.config/SuperCollider/startup.scd`, according to the xdg base directory specification for Linux or
    - `C:\\SuperCollider\\startup.scd` (or similar, depending on the location of the SuperCollider installation) for Windows
  - and to be chosen via "File" -> "Open startup file" in SuperCollider. Of course, you can also use your own startup file but take a look at this one first.

- a folder called "buffers"
  - This folder contains several .wav-soundfiles/buffers for playback and source-target-resynthesis.

- rsh-improElectronics_speakerTesting.scd
  - Some simple code for testing your current speaker setup.

- license.txt
  - A license statement regarding the .scd- as well as the soundfiles.

- this README.md


To have all things work correctly, you need to have the following SuperCollider extensions
- [sc3-plugins](https://github.com/supercollider/sc3-plugins/releases)
- [FluCoMa](https://github.com/flucoma/flucoma-sc/releases/latest)
as well as the following quark
- StartupFile
installed.





Some more notes:
- This whole architecture was constructed in a flexible way and is meant to be adjusted according to your current live improvisation setup.


- To start your performance after everything is connected, follow the comments regarding the order of execution in "rsh-improElectronics_main.scd" and "rsh-improElectronics_setup.scd".


- In "rsh-improElectronics_main.scd" some lines are out-commented. They are often alternatives that one can also use or modify (like anything else).


- To control the \pulsar Ndef, TouchOSC was used.
	In TouchOSC you therefore need to create 
		- one fader object (which address is to be put in the path argument of the \fader1 OSCdef),
		- one xy object (which address is to be put in the path argument of the \xyPulsar OSCdef) and
		- six button objects (which address are to be put in the path arguments of the \button1, \button2, etc OSCdefs).
	Also make sure to set your computer's IP-address as well as the right port in TouchOSC (here port 9999 was used, but you can use any free port in your current network).


- To test this setup in your studio environment, you'd have to simulate some live inputs. I can recommend using an internal feedback routing done with BlackHole or Soundflower. Set the output from your DAW which is playing some audio to BlackHole/SoundFlower and take BlackHole/Soundflower as your input device in SuperCollider.


- Enjoy! =)





Berlin, 25th of July 2023
