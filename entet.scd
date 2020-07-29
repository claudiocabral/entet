s.reboot;

(
  ~euclid =
  {
    arg k, n;
    var result, recursion;
    result = Array.fill(n, { | i | if (i < k, 1.asCollection, 0.asCollection);});
    recursion = {
      arg result;
      var split, size;
      if(result.size == 1,
        { result.flat },
        {
          split = result.separate({|a, b| a != b});
          size = split[0].size.min(split[1].size);
          size.do({|i| split[0][i] = split[0][i] ++ split[1].removeAt(0)});
          if(size == 0,
            { split.flat },
            { recursion.value(split.flatten(1)); });
        });
    };
    recursion.value(result);
  };
)
~euclid.value(3, 7);


~sizes = [2, 8, 12];
~sizes.do({|size| size.postln; size.do({ |i| (i + 1 + ": ").post; ~euclid.value(i + 1, size).postln; }); });

~tmp = ~euclid.value(7, 12).collect({|item, i| if(item == 1, { i }, { -1 });}).reject({|item| item == -1});
~accum = [];
~tmp.doAdjacentPairs({|a, b| ~accum = ~accum ++ (b - a)});
~accum = ~tmp.differentiate.drop(1);
~accum = ~accum.rotate
(
  ~scaling = 1;
  ~semitones = 12 * ~scaling;
  ~steps = 8 * ~scaling;
  ~scale = ~euclid.value(~steps, ~semitones)
                 .rotate(0)
                 .collect({|item, i| if(item == 1, { i }, { -1 });})
                 .reject({|item| item == -1});
                 ~scale.postln;
 Scale.all.put(\entet, Scale(~scale, ~semitones));
 ~thirdChord = [0, 2, 4, 6];
 ~fourthChord = [0, 3, 6, 9];
 ~selectedChord = ~fourthChord;
 ~tonic = [
   0 + ~selectedChord * ~scaling,
   2 + ~selectedChord * ~scaling,
   5 + ~selectedChord * ~scaling
 ];
 ~subdominant = [
   1 + ~selectedChord * ~scaling,
   3 + ~selectedChord * ~scaling,
 ];
 ~dominant = [
   4 + ~selectedChord * ~scaling,
   6 + ~selectedChord * ~scaling,
 ];

~voices = [Pbind(
  \harmony, Plet(\harmony, Pseq([~dominant, ~tonic, ~subdominant], inf)),
  \scale, Scale.at(\entet),
  \degree, Plet(\chord, Pwalk(Pget(\harmony).asArray, repeats: inf)).trace,
  \octave, 4,
  \legato, Prand([0.8, 1], inf),
  \dur, Pwrand(
    [1.5, 2, 4],
    [0.333, 0.333, 0.333],
    inf)
  )
];
Array

 ~voices = ~voices ++ Pbind(
  //\instrument, \FM,
   \ratio, 2,
   //\index, (5 - i) * 0.5,
   \scale, Scale.at(\entet),
   \degree, Prand([Pget(\chord)], inf),
   \octave, 3,
   \dur, Prand(
     //[1, 2 , 4],
     [0.25, 0.5], //1, 2 , 4],
     //[0.25, 0.333, 0.5], //1, 2 , 4],
     //[0.4, 0.1, 0.3, 0.1, 0.05, 0.05],
   inf),
 //\amp, 0.05 * (1.5 / (i + 1)),
 //\amp, 0.05 * (1 - (i * 0.2)),
   //\legato, Pif(Pkey(\dur) > 1, 1, 0.1)
 );
 Pdef(\voices, Plambda(Ppar(~voices))).play;
)
 ~numberOfVoices = 0;
 ~voices = ~voices ++ ~numberOfVoices.collect({|i|
   Pbind(
  //\instrument, \FM,
   \ratio, 2 + i,
   //\index, (5 - i) * 0.5,
   \scale, Scale.at(\entet),
   \degree, Prand([Pget(\chord).flatten], inf),
   \octave, 3 + (i),
   \dur, Prand(
     //[1, 2 , 4],
     [0.25, 0.333, 0.5], //1, 2 , 4],
     //[0.4, 0.1, 0.3, 0.1, 0.05, 0.05],
   inf),
 //\amp, 0.05 * (1.5 / (i + 1)),
 //\amp, 0.05 * (1 - (i * 0.2)),
   //\legato, Pif(Pkey(\dur) > 1, 1, 0.1)
 )});
 Pdef(\voices, Plambda(Ppar(~voices))).play;
)
Pdef(\voices).stop


 Pbindef(\test,
   \scale, Scale.at(\entet),
   \degree, Prand(Array.series(~steps), inf),
   \octave, 5,
   \dur, Pwrand(
     [0.25, 0.333, 0.5, 1, 2 , 4],
     [0.4, 0.1, 0.3, 0.1, 0.05, 0.05],
   inf)
 ).play.quant(4);

 Pbindef(\chords,
   \scale, Scale.at(\entet),
   \degree, Prand([
     Prand(~dominant),
     Prand(~tonic),
     Prand(~subdominant)
   ], inf),
   \octave, 4,
   \legato, Prand([0.5, 1], inf),
   \dur, Pwrand(
     [1.5, 2, 4],
     [0.333, 0.333, 0.333],
     inf)
 ).play.quant(4);

 Pbindef(\chords).stop
 Pbindef(\test).stop

Ndef(\test).stop
Ndef(\test, {
  var base = 48;
  var offset = 4;
  var chords = Array.fill(1, {|i| i * offset * ~scaling});
  var scale = Scale.at(\entet);
  var pitches = DegreeToKey.kr(
                scale.as(LocalBuf),
                MouseX.kr(chords, chords + (scale.degrees.size * 2 + 1)), // mouse indexes into scale
                scale.stepsPerOctave, 1, 48);
  var sig = Saw.ar(pitches.midicps, 0.1);
  sig = RLPF.ar(sig, 880, LFTri.ar(0.1, mul: 1, add: 1));
  Mix(sig)!2;
}).play(0, 2);
)
