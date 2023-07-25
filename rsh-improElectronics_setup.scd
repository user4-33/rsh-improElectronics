// rsh-improElectronics
// This file sets up all the things needed to be loaded in the background.
// Make sure to follow the order of execution within this file and "rsh-improElectronics_main".



// #1: Boot the server. Then change the settings from line 22 to 32 corresponding to your setup and evaluate this at first place ...
(
Tdef(\setup, {

	Buffer.freeAll;
	Ndef.clear;
	Ndef.defaultReshaping = \elastic;



	// Load MIDI Setup
	"rsh-improElectronics_midiSetup.scd".loadRelative;



	// Number of speakers
	~numChannels = 2;

	// Inputs
	~input1 = 0; // (comment with the corresponding instrument to not get lost)
	~input2 = 1; // (comment with the corresponding instrument to not get lost)
	~input3 = 2; // (comment with the corresponding instrument to not get lost)
	~input4 = 3; // (comment with the corresponding instrument to not get lost)

	// Out.ar output bus
	~outBus = 0;



	// Groups
	~defaultGroup = Group.new;
	~effectGroup = Group.new(~defaultGroup, \addAfter);



	// Ndef fadeTime
	~ndefFadeTime = 3.0;



	// Buffers
	~b_shift = Buffer.alloc(s, s.sampleRate * 0.2, numChannels: 1); // 0.2 s
	~b_gran = Buffer.alloc(s, s.sampleRate * 0.2, numChannels: 1); // 0.2 s

	// Buffers for source-target-resynthesis
	~sourceWater = Buffer.read(s, "buffers/water_mono.wav".resolveRelative);
	~sourceFire = Buffer.read(s, "buffers/fire_mono.wav".resolveRelative);
	~sourceBirds = Buffer.read(s, "buffers/birds_mono.wav".resolveRelative);
	~output = Buffer(s);

	// Playback Buffers
	~finnegansSake = Buffer.read(s, "buffers/finnegansSake_mono.wav".resolveRelative);
	~berge = Buffer.read(s, "buffers/berge_mono.wav".resolveRelative);
	~trumpet = Buffer.read(s, "buffers/trumpet_mono.wav".resolveRelative);
	~signature = Buffer.read(s, "buffers/signature_mono.wav".resolveRelative);



	// Busses
	// Audio
	~revBus = Bus.audio(s, ~numChannels); // Reverb Bus
	~delBus = Bus.audio(s, ~numChannels); // Delay Bus

	// Control
	~mainVol = Bus.control(s, 1).set(1); // Main Volume - MIDI fader A
	~revVol = Bus.control(s, 1).set(1); // Reverb volume - MIDI encoder A-2
	~delVol = Bus.control(s, 1).set(1); // Delay volume - MIDI encoder A-3
	~volPlayback1 = Bus.control(s, 1).set(1); // for sample playback #1 - MIDI button B-T-1
	~volPlayback2 = Bus.control(s, 1).set(1); // for sample playback #2 - MIDI button B-T-2
	~volPlayback3 = Bus.control(s, 1).set(1); // for sample playback #3 - MIDI button B-T-3
	~volPlayback4 = Bus.control(s, 1).set(1); // for sample playback #4 - MIDI button B-T-4
	~panFreq = Bus.control(s, 1).set(0.5); // Panning frequency - MIDI encoder A-1
	~revModDepth = Bus.control(s, 1).set(0.3); // Reverb modulation depth - MIDI encoder A-4
	~revModFreq = Bus.control(s, 1).set(1); // Reverb modulation frequency - MIDI encoder A-5
	~maxDelay = Bus.control(s, 1).set(3); // maximum delay time - MIDI encoder A-6
	~trigBus = Bus.control(s, 1); // for PV_BinScramble - MIDI button A-T-1
	~ratioBus = Bus.control(s, 1).set(2); // for PV_SpectralEnhance - MIDI encoder A-7
	~interpolBus = Bus.control(s, 1).set(0.0); // for FluidAudioTransport - MIDI encoder A-8

	// TouchOSC control busses
	~fundFreqBus = Bus.control(s, 1); // for pulsar synthesis
	~formFreqBus = Bus.control(s, 1); // for pulsar synthesis
	~pulsarVolBus = Bus.control(s, 1); // for pulsar synthesis



	// Functions for setting pulsarets
	~pulsaretFunc1 = {
		~pulsaret = Signal.sineFill(1024, { 1.0.rand }.dup(7));
		Ndef(\pulsar).set(\waveBuf, Buffer.sendCollection(s, ~pulsaret).bufnum);
	};

	~pulsaretFunc2 = {
		~pulsaret = Array.linrand(1024, -1.0, 1.0);
		Ndef(\pulsar).set(\waveBuf, Buffer.sendCollection(s, ~pulsaret).bufnum);
	};

	~pulsaretFunc3 = {
		~pulsaret = Pbrown(-1.0, 1.0, 0.2).asStream.nextN(1024);
		Ndef(\pulsar).set(\waveBuf, Buffer.sendCollection(s, ~pulsaret).bufnum);
	};

	// Functions for setting pulsaret-envelopes
	~envFunc1 = {
		~env = Env.perc.discretize(1024);
		Ndef(\pulsar).set(\envBuf, Buffer.sendCollection(s, ~env));
	};

	~envFunc2 = {
		~env = Env([0, 1, 1, 0], [0.01.rrand(0.1)], 'wel').discretize(1024);
		Ndef(\pulsar).set(\envBuf, Buffer.sendCollection(s, ~env));
	};

	~envFunc3 = {
		~env = Env([0, 1, 0], [0.rrand(0.1)], 'sin').discretize(1024);
		Ndef(\pulsar).set(\envBuf, Buffer.sendCollection(s, ~env));
	};



	// OSCdefs for TouchOSC
	// Make sure to put the correct addresses of the corresponding TouchOSC objects for all path arguments as well as the current recvPort.
	OSCdef(\fader1, {
		arg msg, time, addr, recvPort;
		~pulsarVolBus.set(msg[1]); // doesn't need a mapping because values need to be between 0.0 and 1.0
		("current pulsar volume: " ++~pulsarVolBus.getSynchronous).postln;
	}, path: '/fader1', recvPort: 9999);

	OSCdef(\xyPulsar, {
		arg msg, time, addr, recvPort;
		~fundFreqBus.set(msg[1].linexp(0.0, 1.0, 1.0, 3000.0));
		~formFreqBus.set(msg[2].linexp(0.0, 1.0, 1.0, 10000.0));
		("current pulsar fundFreq: " ++~fundFreqBus.getSynchronous).postln;
		("current pulsar formFreq: " ++~formFreqBus.getSynchronous).postln;
	}, path: '/xy1', recvPort: 9999);

	OSCdef(\button1, {
		arg msg, time, addr, recvPort;
		~pulsaretFunc1.();
		"Pulsaret #1 was set".postln;
	}, path: '/button1', recvPort: 9999);

	OSCdef(\button2, {
		arg msg, time, addr, recvPort;
		~pulsaretFunc2.();
		"Pulsaret #2 was set".postln;
	}, path: '/button2', recvPort: 9999);

	OSCdef(\button3, {
		arg msg, time, addr, recvPort;
		~pulsaretFunc3.();
		"Pulsaret #3 was set".postln;
	}, path: '/button3', recvPort: 9999);

	OSCdef(\button4, {
		arg msg, time, addr, recvPort;
		~envFunc1.();
		"Envelope #1 was set".postln;
	}, path: '/button4', recvPort: 9999);

	OSCdef(\button5, {
		arg msg, time, addr, recvPort;
		~envFunc2.();
		"Envelope #2 was set".postln;
	}, path: '/button5', recvPort: 9999);

	OSCdef(\button6, {
		arg msg, time, addr, recvPort;
		~envFunc3.();
		"Envelope #3 was set".postln;
	}, path: '/button6', recvPort: 9999);



	2.5.wait;



	// SynthDef for sample playback
	SynthDef(\samplePlayback, {
		arg bufnum = 0, bufDur = 1, rate = 1, amp = 0.1, volBus;
		var env, sig;
		env = Env([0, 1, 1, 0], [0.01, bufDur, 1], 'wel').kr(2);
		sig = PlayBuf.ar(1, bufnum, rate: rate);
		sig = PanX.ar(~numChannels, sig * env, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: amp);
		sig = sig * In.kr(volBus, 1);
		sig = Limiter.ar(sig, 1.0);
		Out.ar(~outBus, sig);
	}).add;



	"Ready to evaluate some instruments!".postln;

}).play;
)





// #3: ... and finally evaluate this after your chosen instruments are running. Your improvisation is ready to start!
(
// Reverb
Ndef(\reverb, {
	var sig;

	sig = ~revBus.ar(~numChannels);

	sig = 0 ! ~numChannels + JPverb.ar(
		sig,
		t60: 5.0,
		damp: 0,
		size: 1.2,
		earlyDiff: 0.70,
		modDepth: ~revModDepth.kr(1), // Use MIDI encoder A-5
		modFreq: ~revModFreq.kr(1), // Use MIDI encoder A-6
		low: 0.4,
		mid: 1,
		high: 1,
		lowcut: 500,
		highcut: 3000
	);

	sig = sig * ~revVol.kr(1) * ~mainVol.kr(1); // Use MIDI encoder A-2
	sig * -1.dbamp;
}).play(out: ~outBus, group: ~effectGroup);


// Delay
Ndef(\delay, {
	var sig;

	sig = ~delBus.ar(~numChannels) + LocalIn.ar(~numChannels, 0);

	sig = DelayL.ar(sig, ~maxDelay.kr(1), { 1.0.rrand(1.5) } ! ~numChannels * SinOsc.ar(0.2, 0, 0.005, 1)); // Use MIDI encoder A-6

	sig = HPF.ar(sig, 200);
	sig = MoogVCF.ar(sig, 5500, 0.3);

	sig = sig.tanh * ~delVol.kr(1) * ~mainVol.kr(1); // Use MIDI encoder A-3
	LocalOut.ar(sig);
	sig = Limiter.ar(sig, 1);
	sig * -1.dbamp;
}).play(out: ~outBus, group: ~effectGroup);
)

(
// freeing
Ndef(\reverb).free;
Ndef(\delay).free;
)