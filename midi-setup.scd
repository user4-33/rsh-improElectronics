// rsh-improElectronics – MIDI Setup (for Behringer X-Touch Mini)
// If you are about to use another MIDI controller you'll have to change all MIDIdefs to the corresponding MIDI Note-Numbers and/or MIDI channels as well as the feedback-strings if desired.
// Expressions like "B-B-7" are named like this: First letter A or B indicating the MIDI Layer. Second one tells if top (T) or bottom (B) row. Last numbers tells you which column exactly.


// get ALL MIDI data for reassignment:
// MIDIFunc.trace(true);
// MIDIFunc.trace(false);


(
// X-Touch Mini
Tdef(\midiSetup, {
	MIDIClient.init; // takes some time...
	2.wait;
	(
		MIDIIn.connectAll;
		~midiNoteSlots = Array.fill(127, { nil });

		// FADER
		// main volume (fader A)
		(
			MIDIdef.cc(\ccDef9, {
				arg vel, key, channel, device;
				~mainVol.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current main volume: " ++~mainVol.getSynchronous).postln;
			}, ccNum: 9, chan: 10);
		);





		// ENCODER
		// panFreq (encoder A-1)
		(
			MIDIdef.cc(\ccDef1, {
				arg vel, key, channel, device;
				~panFreq.set(vel.linlin(0.0, 127.0, 0.1, 20.0));
				("current panFreq: " ++~panFreq.getSynchronous).postln;
			}, ccNum: 1, chan: 10);
		);

		// revVol (encoder A-2)
		(
			MIDIdef.cc(\ccDef2, {
				arg vel, key, channel, device;
				~revVol.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current revVol: " ++~revVol.getSynchronous).postln;
			}, ccNum: 2, chan: 10);
		);

		// delVol (encoder A-3)
		(
			MIDIdef.cc(\ccDef3, {
				arg vel, key, channel, device;
				~delVol.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current delVol: " ++~delVol.getSynchronous).postln;
			}, ccNum: 3, chan: 10);
		);

		// revModDepth (encoder A-4)
		(
			MIDIdef.cc(\ccDef4, {
				arg vel, key, channel, device;
				~revModDepth.set(vel.linlin(0.0, 127.0, 0.1, 1.0));
				("current revModDepth: " ++~revModDepth.getSynchronous).postln;
			}, ccNum: 4, chan: 10);
		);

		// revModFreq (encoder A-5)
		(
			MIDIdef.cc(\ccDef5, {
				arg vel, key, channel, device;
				~revModFreq.set(vel.linlin(0.0, 127.0, 1.0, 200.0));
				("current revModFreq: " ++~revModFreq.getSynchronous).postln;
			}, ccNum: 5, chan: 10);
		);

		// maxDelay (encoder A-6)
		(
			MIDIdef.cc(\ccDef6, {
				arg vel, key, channel, device;
				~maxDelay.set(vel.linlin(0.0, 127.0, 0.1, 3.0));
				("current maxDelay: " ++~maxDelay.getSynchronous).postln;
			}, ccNum: 6, chan: 10);
		);

		// PV_SpectralEnhance ratio (encoder A-7)
		(
			MIDIdef.cc(\ccDef7, {
				arg vel, key, channel, device;
				~ratioBus.set(vel.linlin(0.0, 127.0, 1.1, 4.0));
				("current PV_SpectralEnhance ratio: " ++~ratioBus.getSynchronous).postln;
			}, ccNum: 7, chan: 10);
		);

		// FluidAudioTransport interpolating ratio (encoder A-8)
		(
			MIDIdef.cc(\ccDef8, {
				arg vel, key, channel, device;
				~interpolBus.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current interpolating ratio: " ++~interpolBus.getSynchronous).postln;
			}, ccNum: 8, chan: 10);
		);





		// BUTTONS
		// PV_BinScramble triggering (button A-T-1)
		(
			MIDIdef.noteOn(\onDef1, {
				arg vel, key, channel, device;
				~trigBus.set(1.rrand(127));
				"new random bin order was triggered".postln;
			}, noteNum: 8, chan: 10);
		);



		// source-target-resynthesis: recording (button A-B-1)
		(
			MIDIdef.noteOn(\onDef3, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = ~recording.();
				("source-target-resynthesis: recording started for " ++~dur.() ++" seconds!").postln;
			}, noteNum: 16, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef3, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 16, chan: 10);
		);



		// source-target-resynthesis: Playback (button A-B-2)
		(
			MIDIdef.noteOn(\onDef4, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = ~recPlayBack.();
				"source-target-resynthesis: Playback!".postln;
			}, noteNum: 17, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef4, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 17, chan: 10);
		);



		// source-target-resynthesis: Start resynthesis (button A-B-3)
		(
			MIDIdef.noteOn(\onDef5, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = ~resynthesis.();
				"source-target-resynthesis: Resynthesis has started!".postln;
			}, noteNum: 18, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef5, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 18, chan: 10);
		);



		// source-target-resynthesis: Resynthesis Playback (button A-B-4)
		(
			MIDIdef.noteOn(\onDef6, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = ~resynthesisPlayback.();
				"source-target-resynthesis: Resynthesis is played back!".postln;
			}, noteNum: 19, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef6, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 19, chan: 10);
		);





		// BUTTONS + ENCODER
		// sample playback: Finnegans Sake (button B-T-1)
		(
			MIDIdef.noteOn(\onDef7, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = Synth(\samplePlayback, [\bufnum, ~finnegansSake, \bufDur, ~finnegansSake.duration, \volBus, ~volPlayback1]);
				"sample playback: Finnegans Sake".postln;
			}, noteNum: 32, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef7, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 32, chan: 10);
		);

		// Finnegans Sake volume (encoder B-1)
		(
			MIDIdef.cc(\ccDef10, {
				arg vel, key, channel, device;
				~volPlayback1.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current volume for Finnegans Sake: " ++~volPlayback1.getSynchronous).postln;
			}, ccNum: 11, chan: 10);
		);



		// sample playback: Berge (button B-T-2)
		(
			MIDIdef.noteOn(\onDef8, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = Synth(\samplePlayback, [\bufnum, ~berge, \bufDur, ~berge.duration, \volBus, ~volPlayback2]);
				"sample playback: Berge".postln;
			}, noteNum: 33, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef8, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 33, chan: 10);
		);

		// Berge volume (encoder B-2)
		(
			MIDIdef.cc(\ccDef11, {
				arg vel, key, channel, device;
				~volPlayback2.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current volume for Berge: " ++~volPlayback2.getSynchronous).postln;
			}, ccNum: 12, chan: 10);
		);



		// sample playback: Trumpet (button B-T-3)
		(
			MIDIdef.noteOn(\onDef9, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = Synth(\samplePlayback, [\bufnum, ~trumpet, \bufDur, ~trumpet.duration, \volBus, ~volPlayback3]);
				"sample playback: Trumpet".postln;
			}, noteNum: 34, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef9, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 34, chan: 10);
		);

		// Trumpet volume (encoder B-3)
		(
			MIDIdef.cc(\ccDef12, {
				arg vel, key, channel, device;
				~volPlayback3.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current volume for Trumpet: " ++~volPlayback3.getSynchronous).postln;
			}, ccNum: 13, chan: 10);
		);



		// sample playback: Signature (button B-T-4)
		(
			MIDIdef.noteOn(\onDef10, {
				arg vel, key, channel, device;
				~midiNoteSlots[key] = Synth(\samplePlayback, [\bufnum, ~signature, \bufDur, ~signature.duration, \volBus, ~volPlayback4]);
				"sample playback: Signature".postln;
			}, noteNum: 35, chan: 10);
		);

		(
			MIDIdef.noteOff(\offDef10, {
				arg vel, key, channel, device;
				~midiNoteSlots[key].release;
			}, noteNum: 35, chan: 10);
		);

		// Signature volume (encoder B-4)
		(
			MIDIdef.cc(\ccDef13, {
				arg vel, key, channel, device;
				~volPlayback4.set(vel.linlin(0.0, 127.0, 0.0, 1.0));
				("current volume for Signature: " ++~volPlayback4.getSynchronous).postln;
			}, ccNum: 14, chan: 10);
		);
	);

	"MIDI Setup is ready!".postln;

}).play;
)