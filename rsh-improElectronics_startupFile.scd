// rsh-improElectronics
// This is a startup file for the rsh-improElectronics

"rsh-improElectronics startup file is loaded".postln;

(
s.options.sampleRate = 44100;
s.options.numOutputBusChannels = 8;
s.options.numInputBusChannels = 16;

s.options.memSize = 65536 * 4;
// The number of kilobytes of real time memory allocated to the server. This memory is used to allocate synths and any memory that unit 	generators themselves allocate (for instance in the case of delay ugens which do not use buffers, such as CombN), and is separate from the memory used for buffers. Setting this too low is a common cause of 'exception in real time: alloc failed' errors. The default is 8192.

// s.options.blockSize = 64 * 2;
// The number of samples in one control period. The default is 64.

s.latency = 0.05;
// The current latency of the server.

// s.options.inDevice = "YOUR DEVICE";
// s.options.outDevice = "YOUR DEVICE";

s.doWhenBooted({

	// Server Meter
	~w1 = Window.new("Server Meter", bounds: Rect(75, 150, 520, 225));
	ServerMeterView.new(s, parent: ~w1, leftUp: 0@0, numIns: 16, numOuts: 8);
	~w1.front;

	// Freq Scope (can only show for one Bus at a time)
	~w2 = Window.new("Freq Scope", bounds: Rect(75, 550, 510, 360));
	~freqScope = FreqScopeView.new(
		parent: ~w2,
		bounds: Rect(5, 5, 500, 350),
		server: s
	).active_(true).freqMode_(1).inBus_(0);
	~w2.onClose_({ ~freqScope.kill });
	~w2.front;

	// Node Tree
	~w3 = Window.new("Node Tree", bounds: Rect(650, 150, 420, 765));
	s.plotTreeView(interval: 0.5, parent: ~w3);
	~w3.front;

});
)