// rsh-improElectronics – Main file for live performing

// Before booting the server and evaluating snippets, ensure correct input and output configurations in your startup file.

// Note that some lines are out commented. They are often alternatives that one can also use or modify.

// Expressions like "B-B-7" are shortcuts of corresponding buttons on a Behringer X-Touch Mini, an affordable MIDI controller that is used in this setup. First letter A or B indicating the MIDI layer. Second one tells if top (T) or bottom (B) row. Last numbers tell you which column exactly.





(
// Basic reverb & delay
Ndef(\template, {
	var input, sig;
	input = SoundIn.ar(~input4);
	sig = HPF.ar(input, freq: 30);

	sig = sig * 0.dbamp * ~mainVol.kr(1);
	sig = PanX.ar(~numOutputChannels, sig, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0));
	sig = Limiter.ar(sig, 1.0);

	Out.ar(\delBus.kr, sig * 0.0 * EnvGate.new);
	Out.ar(\revBus.kr, sig * 1.0 * EnvGate.new);

	sig * EnvGate.new;
}).set(\delBus, ~delBus, \revBus, ~revBus).play(out: ~outBus).fadeTime_(~ndefFadeTime);
)

Ndef(\template).free;





(
// Horizontal reflection. Shifts your live-input by ~shift
~shift = -0.5.midiratio;

Ndef(\horizontalReflection, {
	var input, buffer, sig;

	input = SoundIn.ar(~input4);
	input = HPF.ar(input, freq: 30);

	buffer = RecordBuf.ar(input, ~b_shift.bufnum, loop: 1);

	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buffer,
		rate: ~shift,
		loop: 1
	);

	sig = sig * 0.dbamp * ~mainVol.kr(1);
	sig = PanX.ar(~numOutputChannels, sig, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0));
	sig = Limiter.ar(sig, 1.0);

	Out.ar(\delBus.kr, sig * 0.4 * EnvGate.new);
	Out.ar(\revBus.kr, sig * 1.0 * EnvGate.new);

	sig * EnvGate.new
}).set(\delBus, ~delBus, \revBus, ~revBus).play(out: ~outBus).fadeTime_(0.02);

// Constant rebuilding to vanish clicks
Tdef(\rebuild, {
	var loopOffset = ((~b_shift.duration / (1 - ~shift)) / 2);
	loop({
		Ndef(\horizontalReflection).rebuild;
		loopOffset.wait;
	});
}).play;
)

Ndef(\horizontalReflection).free;





(
// Frequency scrambling. Randomly swaps frequency bins of your live input with every new trigger.
Ndef(\frequencyScrambling, {
	arg fftSize = 2048;
	var input, chain;

	input = SoundIn.ar(~input2);
	input = HPF.ar(input, freq: 30);

	chain = FFT(LocalBuf(fftSize, 1), input);

	chain = PV_BinScramble(
		chain,
		wipe: 0.5,
		width: 0.6,
		// trig: Dust.kr(10)
		trig: { InTrig.kr(~trigBus) } // Push A-T-1 to trigger a new random order.
	);

	chain = IFFT(chain);
	chain = chain * -3.dbamp * ~mainVol.kr(1);
	chain = PanX.ar(~numOutputChannels, chain, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0));
	chain = Limiter.ar(chain, 1.0);

	Out.ar(\delBus.kr, chain * 0.3 * EnvGate.new);
	Out.ar(\revBus.kr, chain * 1.0 * EnvGate.new);

	chain * EnvGate.new;
}).set(\delBus, ~delBus, \revBus, ~revBus).play(out: ~outBus).fadeTime_(~ndefFadeTime);
)

Ndef(\frequencyScrambling).free;





(
// Spectral enhancement. Enriches your live input with additional partials.
Ndef(\spectralEnhancement, {
	arg fftSize = 2048, amp = 2.0;
	var input, chain;

	input = SoundIn.ar(~input3);
	input = HPF.ar(input, freq: 30);

	chain = FFT(LocalBuf(fftSize, 1), input);

	chain = PV_SpectralEnhance(
		chain,
		numPartials: 16,
		// numPartials: LFNoise0.kr(1).curverange(1, 32, 5),

		// ratio: 1.5,
		ratio: ~ratioBus.kr(1), // Use MIDI encoder A-7. Watch out: When ratio is going below 1.0 this will get you into a spectral panic attack.
		// ratio: Phasor.kr(Dust.kr(0.1), rate: 1, start: 1, end: LFNoise2.kr(0.1).range(1.0, 5.5), resetPos: 1.0),

		strength: 1.0
	);

	chain = IFFT(chain);
	chain = chain * -6.dbamp * ~mainVol.kr(1);
	chain = PanX.ar(~numOutputChannels, chain, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: amp);
	chain = Limiter.ar(chain, 1.0);

	Out.ar(\delBus.kr, chain * 0.3 * EnvGate.new);
	Out.ar(\revBus.kr, chain * 0.8 * EnvGate.new);

	chain * EnvGate.new;
}).set(\delBus, ~delBus, \revBus, ~revBus).play(out: ~outBus).fadeTime_(~ndefFadeTime);
)

Ndef(\spectralEnhancement).free;





(
// Granulation with pitch shifting

// Use custom grain envelope
var winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
var grainEnv = Buffer.sendCollection(s, winenv.discretize, 1);

Ndef(\granulation, {
	arg gate = 1;
	var input, env, sig;

	input = SoundIn.ar(~input2);
	input = HPF.ar(input, freq: 30);
	RecordBuf.ar(input, ~b_gran, loop: 1, doneAction: 0);
	env = EnvGen.kr(Env.asr, gate, doneAction: 2);

	sig = GrainBuf.ar(

		trigger: Impulse.kr(8),

		dur: 0.2,

		sndbuf: ~b_gran.bufnum,

		// rate: LFNoise0.kr(10).range(-0.5.midiratio, 0.5.midiratio),
		rate: Demand.kr(
			trig: Dust.kr(9),

			reset: 0,

			demandUGens: Dwrand(
				// list: [LFNoise0.kr(5).range(-1.midiratio, 1.0), 1, LFNoise0.kr(5).range(1, 1.midiratio)], // Clusters
				list: [-7.midiratio, 1, 7.midiratio], // Fifths
				// list: [-0.5.midiratio, 1, 0.5.midiratio], // quarter-tones
				weights: [0.05, 0.9, 0.05],
				repeats: inf
			)
		),

		interp: 4,

		envbufnum: grainEnv // choose grainEnv or -1 for built-in grain envelope

	);

	sig = sig * env * ~mainVol.kr(1);
	sig = PanX.ar(~numOutputChannels, sig, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: -2.dbamp);
	sig = Limiter.ar(sig, 1.0);

	Out.ar(\delBus.kr, sig * 0.0 * EnvGate.new);
	Out.ar(\revBus.kr, sig * 1.0 * EnvGate.new);

	sig * EnvGate.new;
}).set(\delBus, ~delBus, \revBus, ~revBus).play(out: ~outBus).fadeTime_(~ndefFadeTime);
)

Ndef(\granulation).free;





(
// Interpolate the spectra between input A and B
Ndef(\spectrumInterpolation, {
	arg amp = 1;
	var inputA, inputB, sig;

	// choose from ~sourceWater, ~sourceFire, ~sourceBirds
	inputA = PlayBuf.ar(1, ~sourceBirds.bufnum, loop: 1);
	// inputA = SoundIn.ar(~input1);

	inputB = SoundIn.ar(~input2);

	// sig = FluidAudioTransport.ar(inputA, inputB, 0.95);
	// sig = FluidAudioTransport.ar(inputA, inputB, MouseX.kr(0, 1));
	sig = FluidAudioTransport.ar(inputA, inputB, ~interpolBus.kr(1)); // Use MIDI encoder A-8

	sig = sig * -2.dbamp * ~mainVol.kr(1);
	sig = PanX.ar(~numOutputChannels, sig, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: amp);
	sig = Limiter.ar(sig, 1.0);

	Out.ar(\delBus.kr, sig * 0.1 * EnvGate.new);
	Out.ar(\revBus.kr, sig * 0.4 * EnvGate.new);

	sig * EnvGate.new;
}).set(\delBus, ~delBus, \revBus, ~revBus).play(out: ~outBus).fadeTime_(~ndefFadeTime);
)

Ndef(\spectrumInterpolation).free;





// Sample Playback
// Fire up via buttons on Layer B...
// Order of MIDI-assignment starting at B-T-1:
// Top: #1 Finnegans Sake, #2 Berge, #3 Trumpet, #4 Signature
// Control each volume with MIDI encoder B-1 to B-4
// Of course you can use your own samples by adding them into the "buffers" folder before you adjust the corresponding code

// In case of complications free what you need to free:
Node.basicNew(s, 1036).free;





// Source-Target-Resynthesis with optional live-recording-playback
// Please evaluate the block below to start via MIDI on A-B-1 to A-B-4
(
// #1: Record some live input for x seconds and free it
~dur = 4; // x seconds
~recording = {
	Tdef(\strRecording, {
		~target = Buffer.alloc(s, s.sampleRate * ~dur, numChannels: 1);
		1.do({
			(~recorder = SynthDef(\recorder, {
				arg bufnum;
				var input;
				input = SoundIn.ar(~input1);
				input = HPF.ar(input, freq: 70);
				RecordBuf.ar(input, bufnum, recLevel: 1.0, preLevel: 0.0, doneAction: 2);
			}).play(s, [\bufnum, ~target]);
		)});
		(~dur + 0.1).wait;
		~recorder.free;
		"ready for playback/resynthesis!".postln
	}).play;
};

// #2 If wanted: play it back
~recPlayBack = {
	SynthDef(\playBack, {
		arg bufnum, amp;
		var sig, env;
		env = Env([0, 1, 1, 0], [0.2, ~dur-0.3, 0.1], 'sin').kr(2);
		sig = PlayBuf.ar(1, bufnum, doneAction: 2);
		sig = sig * ~mainVol.kr(1);
		sig = PanX.ar(~numOutputChannels, sig * env, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: amp);
		sig = Limiter.ar(sig, 1);
		Out.ar(\outBus.kr, sig);
	}).play(s, [\bufnum, ~target, \amp, -2.dbamp, \outBus, ~outBus]);
};

// #3 Resynthesise the target sound based on the source sound. Wait some time...
~resynthesis = {
	Routine{
		~crossSynthesis = FluidBufNMFCross.process(
			s,
			~sourceWater, // choose from ~sourceWater, ~sourceFire, ~sourceBirds
			~target,
			~output,
			timeSparsity: 4,
			polyphony: 7,
			continuity: 20,
			windowSize: 2048
		);
		{ FreeSelfWhenDone.kr(~crossSynthesis.kr).poll }.play;
		~crossSynthesis.wait;
		"Resynthesis done".postln;
	}.play;
};

// #4 fire up!
~resynthesisPlayback = {
	~mainVol.set(1); // For unknown reasons FluidBufNMFCross sets the ~mainVol bus to 0 after performing the ~resynthesis.
	SynthDef(\strPlayBack, {
		arg bufnum, amp;
		var sig, env;
		env = Env([0, 1, 1, 0], [0.2, ~dur-0.4, 0.2], 'sin').kr(2);
		sig = PlayBuf.ar(1, bufnum, doneAction: 2);
		sig = sig * ~mainVol.kr(1);
		sig = PanX.ar(~numOutputChannels, sig * env, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: amp);
		sig = Limiter.ar(sig, 1);
		Out.ar(\outBus.kr, sig);
	}).play(s, [\bufnum, ~output, \amp, 1, \outBus, ~outBus]);
};
)





(
// Pulsar synthesis!
// Based on Alberto de Campos approach in chapter 16, p. 487 - 488 of the SuperCollider book (MIT press, 2011)
// Code taken from here: https://github.com/madskjeldgaard/scbookcode/blob/master/Ch%2016%20Microsound/c16_micro_figures5_pulsar.scd
// Please follow the notes in the _readMe.txt.
// Input Touch OSC data first, then evaluate:
Ndef(\pulsar, {
	arg waveBuf, envBuf = -1;
	var fundFreq, formFreq, trig, grDur, rate, sig;

	fundFreq = ~fundFreqBus.kr(1).lag(0.01);
	// fundFreq = MouseX.kr(1, 3000.0, 1);

	formFreq = ~formFreqBus.kr(1).lag(0.01);
	// formFreq = MouseY.kr(1, 10000.0, 1);

	// trig = Impulse.ar(fundFreq * Duty.kr(dur: LFNoise0.kr(15).range(0.01, 0.05), level: Dseq([1, 0, 1, 1, 0, 0, 1, 0], inf))); // masking
	trig = Impulse.ar(fundFreq);
	grDur = formFreq.reciprocal;
	rate = formFreq * BufDur.kr(waveBuf);
	sig = GrainBuf.ar(1, trig, grDur, waveBuf, rate, 0, 4, envbufnum: envBuf);

	sig = sig * -12.dbamp * ~mainVol.kr(1);
	sig = PanX.ar(~numOutputChannels, sig, pos: LFNoise2.kr(~panFreq.kr(1)).range(0.0, 1.0), level: ~pulsarVolBus.kr(1));
	sig = Limiter.ar(sig, 1);
}).play(out: ~outBus);
)

Ndef(\pulsar).free;