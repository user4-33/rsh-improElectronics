// rsh-improElectronics – Startup File

"\n\n➤➤➤ rsh-improElectronics startup file loaded!\n\n\n".postln;

(
s.options.sampleRate = 48000;

// The number of kilobytes of real time memory allocated to the server. This memory is used to allocate synths and any memory that unit generators themselves allocate (for instance in the case of delay ugens which do not use buffers, such as CombN), and is separate from the memory used for buffers. Setting this too low is a common cause of 'exception in real time: alloc failed' errors. The default is 8192.
s.options.memSize = 65536 * 4;

// The number of samples in one control period. The default is 64.
s.options.blockSize = 64 * 2;

// The current latency of the server.
s.latency = 0.05;

~numInputChannels = 4;
~numOutputChannels = 2;
s.options.numInputBusChannels = ~numInputChannels;
s.options.numOutputBusChannels = ~numOutputChannels;

s.options.inDevice = "BlackHole 16ch";
// s.options.outDevice = "YOUR DEVICE";

// Current project directory
~projectDir = "/Users/luis/Nextcloud/Künstlerische Arbeit/Impro-Elektronik/rsh-improElectronics";

s.doWhenBooted({

	Buffer.freeAll;
	Ndef.clear;
	Ndef.defaultReshaping = \elastic;

	// Inputs
	~input1 = 0; // (comment with the corresponding instrument to not get lost)
	~input2 = 1; // (comment with the corresponding instrument to not get lost)
	~input3 = 2; // (comment with the corresponding instrument to not get lost)
	~input4 = 3; // (comment with the corresponding instrument to not get lost)

	// Out.ar output bus
	~outBus = 0;

	// Groups
	~effectGroup = Group.after(s.defaultGroup);

	// Ndef fadeTime
	~ndefFadeTime = 3.0;



	s.sync;



	// Busses
	// Audio
	~revBus = Bus.audio(s, ~numOutputChannels); // Reverb Bus
	~delBus = Bus.audio(s, ~numOutputChannels); // Delay Bus

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



	s.sync;



	// Buffers
	~b_shift = Buffer.alloc(s, s.sampleRate * 0.2, numChannels: 1); // 0.2 s
	~b_gran = Buffer.alloc(s, s.sampleRate * 0.2, numChannels: 1); // 0.2 s

	// Buffers for source-target-resynthesis
	~sourceWater = Buffer.read(s, ~projectDir +/+ "buffers/water_mono.wav");
	~sourceFire = Buffer.read(s, ~projectDir +/+ "buffers/fire_mono.wav");
	~sourceBirds = Buffer.read(s, ~projectDir +/+ "buffers/birds_mono.wav");
	~output = Buffer(s);

	// Playback Buffers
	~finnegansSake = Buffer.read(s, ~projectDir +/+ "buffers/finnegansSake_mono.wav");
	~berge = Buffer.read(s, ~projectDir +/+ "buffers/berge_mono.wav");
	~trumpet = Buffer.read(s, ~projectDir +/+ "buffers/trumpet_mono.wav");
	~signature = Buffer.read(s, ~projectDir +/+ "buffers/signature_mono.wav");



	s.sync;



	// OSCdefs for TouchOSC
	// Make sure to put the correct addresses of the corresponding TouchOSC objects for all path arguments as well as the current recvPort.
	OSCdef(\fader1, {
		arg msg, time, addr, recvPort;
		~pulsarVolBus.set(msg[1]); // doesn't need a mapping because values need to be between 0.0 and 1.0
		("current pulsar volume: " ++~pulsarVolBus.getSynchronous).postln;
	}, path: '/fader1', recvPort: 9999);

	OSCdef(\xy1, {
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



	s.sync;



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



	// SynthDef for sample playback
	SynthDef(\samplePlayback, {
		arg bufnum = 0, bufDur = 1, rate = 1, amp = 0.1, volBus;
		var env, sig;
		env = Env([0, 1, 1, 0], [0.01, bufDur, 1], 'wel').kr(2);
		sig = PlayBuf.ar(1, bufnum, rate: rate);
		sig = PanX.ar(~numOutputChannels, sig * env, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: amp);
		sig = sig * In.kr(volBus, 1);
		sig = Limiter.ar(sig, 1.0);
		Out.ar(~outBus, sig);
	}).add;



	s.sync;



	// Reverb
	Ndef(\reverb).group_(~effectGroup);
	Ndef(\reverb, {
		var sig;

		sig = ~revBus.ar(~numOutputChannels);

		sig = 0 ! ~numOutputChannels + JPverb.ar(
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
	}).play(out: ~outBus);

	// Delay
	Ndef(\delay).group_(~effectGroup);
	Ndef(\delay, {
		var sig;

		sig = ~delBus.ar(~numOutputChannels) + LocalIn.ar(~numOutputChannels, 0);

		sig = DelayL.ar(sig, ~maxDelay.kr(1), { 1.0.rrand(1.5) } ! ~numOutputChannels * SinOsc.ar(0.2, 0, 0.005, 1)); // Use MIDI encoder A-6

		sig = HPF.ar(sig, 200);
		sig = MoogVCF.ar(sig, 5500, 0.3);

		sig = sig.tanh * ~delVol.kr(1) * ~mainVol.kr(1); // Use MIDI encoder A-3
		LocalOut.ar(sig);
		sig = Limiter.ar(sig, 1);
		sig * -1.dbamp;
	}).play(out: ~outBus);



	// Load MIDI Setup
	(~projectDir +/+ "midi-setup.scd").load;



	s.sync;



	// Freq scope (can only show for one Bus at a time)
	~w1 = Window.new("Freq Scope", Rect(75, 550, 520, 325)).front;
	~freqScope = FreqScopeView.new(
		parent: ~w1,
		bounds: Rect(5, 5, 510, 315),
		server: s
	).active_(true).freqMode_(1);
	~w1.onClose_({ ~freqScope.kill });

	// Server meter
	~w2 = Window.new("Server Meter", Rect(75, 150, 520, 225)).front;
	ServerMeterView.new(s, ~w2, 0@0, ~numInputChannels, ~numOutputChannels);

	// Node tree
	~w3 = Window.new("Node Tree", Rect(650, 150, 420, 765)).front;
	NodeTreeView(s, parent: ~w3).start;



	3.wait;



	"➤➤➤ Ready to evaluate some instruments!".postln;

});
)