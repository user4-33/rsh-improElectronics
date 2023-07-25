// rsh-improElectronics
// Some simple code for testing your current speaker setup.


// check your inputs...
ServerOptions.inDevices;

// and outputs...
ServerOptions.outDevices;


// Two channels:
Ndef(\speakerTest, { PanX.ar(2, PinkNoise.ar(0.03), pos: MouseX.kr(0, 1).poll, level: 0.8, width: 2.0) }).play;
Ndef(\speakerTest, { PanX.ar(2, Dust.ar(2.8), pos: MouseX.kr(0, 1), level: 1.0, width: 2.0) }).play;
Ndef(\speakerTest, { PanX.ar(2, PinkNoise.ar(0.3), pos: 0.25, level: 1.0, width: 2.0) }).play;
Ndef(\speakerTest).free;


// n-channels:
~nChannels = 4;
Ndef(\speakerTest, { PanX.ar(~nChannels, PinkNoise.ar(0.10), pos: MouseX.kr(0, 1).poll, level: 0.8, width: 2.0) }).play;
Ndef(\speakerTest, { PanX.ar(~nChannels, PinkNoise.ar(0.1), pos: 0.5, level: 0.8, width: 2.0) }).play;
Ndef(\speakerTest, { PinkNoise.ar(0.2) ! ~nChannels }).play;
Ndef(\speakerTest, { Dust.ar(2.83) ! ~nChannels }).play;
Ndef(\speakerTest, { PanX.ar(~nChannels, Dust.ar(2.8) ! ~nChannels, pos: MouseX.kr(0, 1), level: 1.0, width: 2.0) }).play;
Ndef(\speakerTest, { Out.ar(3, PinkNoise.ar(0.1)) }).play;
Ndef(\speakerTest).free;