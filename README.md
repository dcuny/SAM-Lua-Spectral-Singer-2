# SAM-Lua-Spectral-Singer-2

RUNNING THE PROGRAM
-------------------

This program is loosely based on the vocal synthesis program Software Automatic Mouth, by
Don't Ask Software (now SoftVoice, Inc.).  See: https://simulationcorner.net/index.php?page=sam

The file format for songs is a subset of the .pho format created by SoftVoice, Inc.

The vocal synthesis program is main.lua.

Near the beginning of the file is the instruction:
	
	local songName = "twinkle"

The input file must be the same name as the songName, but have a ".pho" extension.

Note the ".pho" extension is not part of the songName.

The output file will be named the same as the songName, but with a ".wav" extension.



PHO FILE COMMANDS
-----------------

The following commands are implemented:

	transpose <half steps>			  Set the transposition for the song
	tempo <beats per minute>		  Set the tempo for the song
	<step><accidental><octave>		  Pitch
	<amount>%						          Duration modifier (percent)

Commands are enclosed in braces, like so:

  {transpose -7}
  {tempo 120}
  {c#4}
  {50%}
	
Multiple commands can be strung together between braces if seperated by semi-colons:

	{transpose -7; tempo 120}
	
Pitches are specified in the form

  <step><accidental><octave>

The note step is case-insensitive. For example:

	{c#3}
	{E3}
	{Db4}

SYLLABLE DURATIONS
-------------------

Every syllable must contain a nucleus vowel.

The consonants preceding the nucleus are assigned to the prior syllable to ensure that
the nucleus lands on the beat. The duration of consonants following the nucleus are subtracted
from the duration of the prior nucleus to ensure the syllable lasts the requested duration.

The nucleus indicated by preceding it by one or more beat duration indicators.
The beat indicator "*" indicates a single beat. For example, the following is a phonetic rendering
of the word "cat", sung for one beat:

	K*AET

Beat indicators are additive, so this indicates the nucleus is held for two beats:

	K**AET
	
The duration of the next nucleus' beat indicators can be modified with a percent instruction. 

The following example modifies the following beat duration instruction to be 25% the normal duration. 

	{25%}*AE

The percent is then reset back to 100% for the next nucleus.



PHONEMES
--------

The phonemes are based on the Arpabet. See  http://www.speech.cs.cmu.edu/cgi-bin/cmudict

    Phoneme Example Translation
    AA		  odd     AA D
    AE		  at	    AE T
    AH		  hut	    HH AH T
    AO		  ought	  AO T
    AW		  cow	    K AW
    AY		  hide	  HH AY D
    B 		  be	    B IY
    CH		  cheese	CH IY Z
    D 		  dee	    D IY
    DH		  thee	  DH IY
    EH		  Ed	    EH D
    ER		  hurt	  HH ER T
    EY		  ate	    EY T
    F 		  fee	    F IY
    G 		  green	  G R IY N
    HH		  he	    HH IY
    IH		  it	    IH T
    IY		  eat	    IY T
    JH		  gee	    JH IY
    K 		  key	    K IY
    L 		  lee	    L IY
    M 		  me	    M IY
    N 		  knee	  N IY
    NG		  ping	  P IH NG
    OW		  oat	    OW T
    OY		  toy	    T OY
    P 		  pee	    P IY
    R 		  read	  R IY D
    S 		  sea	    S IY
    SH		  she	    SH IY
    T 		  tea	    T IY
    TH		  theta	  TH EY T AH
    UH		  hood	  HH UH D
    UW		  two	    T UW
    V 		  vee	    V IY
    W 		  we	    W IY
    Y 		  yield	  Y IY L D
    Z 		  zee	    Z IY
    ZH		  seizure	S IY ZH ER

The **QX** phoneme is used as silence, and is treated as a nucleus.

Additional phonemes include:

	IX		Short IH sound
	UX		First part of UW sound
	AX 		Short AH sound

	WX		Second half of dipthongs OW, UW
	YX		Second half of dipthongs OY, AY
	UL		Convenience for AX L
	UM		Convenience for AX M
	UN		Convenience for AX N
	IL		Convenience for IX L
	IM		Convenience for IX M
	IN		Convenience for IX N
	RX		Non-initial R sound (R is automatically converted)
	LX		Non-initial L sound (L is automatically converted)
	KX		K preceding back vowels (automatically converted)
	GX		G prededing back vowels (automatically converted)

Dipthongs are created by internally combining two phonemes:

    AW		AA + WX
    AY		AH + YX
    EY		EH + YX
    IY		IH + YX
    OW		AH + WX
    OY		AH + YX
    UW		UH + YX
