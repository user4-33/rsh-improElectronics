// rsh-improElectronics – Startup File

"\n\n➤➤➤ rsh-improElectronics startup file loaded!\n\n\n".postln;

(
s.options.sampleRate = 44100;

// The number of kilobytes of real time memory allocated to the server. This memory is used to allocate synths and any memory that unit generators themselves allocate (for instance in the case of delay ugens which do not use buffers, such as CombN), and is separate from the memory used for buffers. Setting this too low is a common cause of 'exception in real time: alloc failed' errors. The default is 8192.
s.options.memSize = 65536 * 4;

// The number of samples in one control period. The default is 64.
// s.options.blockSize = 64 * 2;

// The current latency of the server.
s.latency = 0.05;

~numInputChannels = 8;
~numOutputChannels = 16;
s.options.numInputBusChannels = ~numInputChannels;
s.options.numOutputBusChannels = ~numOutputChannels;

// s.options.inDevice = "YOUR DEVICE";
// s.options.outDevice = "YOUR DEVICE";

s.doWhenBooted({

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

	s.sync;

});
)