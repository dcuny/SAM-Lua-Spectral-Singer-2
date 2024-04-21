-- (c) 2020 David Cuny
-- Voice and Transition data from Software Automatic Mouth, by Don't Ask Software

-- The voiced portion of the voice is a sum of sine waves, one 
-- for each harmonic up to a maximum frequency. The amplitude of
-- each sine wave is determined by the contribution of each formant,
-- which is specified by amplitude and center frequency. The bandwidth
-- is calculated from an ad-hoc equation I came up with, and the 
-- falloff is assumed to be a sine curve.
-- The unvoiced portion is gaussian noise run through a series of 
-- resonators (see Klatt) using the same formant values, but using
-- bandwidths calculated using a tube equation.
-- Unvoiced consonants are simulated using a single filter with
-- noise passed through it.


-- Do not include the .pho entension!
local songName = "red river valley"


-- Audio parameters-- CD sample quality
SAMPLE_RATE = 44100

-- Used to calculate filter response
TWO_PI = 2 * math.pi
MINUS_PI_T = -math.pi / SAMPLE_RATE
TWO_PI_T = TWO_PI / SAMPLE_RATE

-- Flags
local debugFlag = true        -- true if debug messages should be printed

-- frame resolution 1/(frames per second)
local secondsPerFrame = 1/100


-- Build the phoneme database

local pData = {}
local pIndexByName = {}

local function buildPhoneme( data )

	-- insert into the pData table
	table.insert( pData, data )

	-- set the total steps
	data.parts = data.part

	-- if part == 0, insert into name lookup
	if data.part == 1 then
		pIndexByName[data.token] = #pData
	else
		-- get the index of the primary
		local i = pIndexByName[data.token]
		if i == nil then
			error("Phoneme '"..data.token.."' not yet in table.")
		end

		-- set the steps
		pData[i].parts = data.parts
	end
end



-- Return index of phoneme **s** in **pName** table.
-- Throws error if phoneme is not found.
local function getPhoneIndex( s )
	local i = pIndexByName[s]
	if not i then
		error("Phoneme '"..s.."' not found.")
	end
	return i
end


-----------------------
-- THE PHONEME TABLE --
-----------------------

-- token      name of the phoeneme
-- part       some phonemes have multiple parts
-- f1         formant 1 frequency
-- f2         formant 2 frequency
-- f3         formant 3 frequency
-- a1         amplitude of formant 1
-- a2         amplitude of formant 2
-- a3         amplitude of formant 3
-- length     duration, in frames
-- blendRank  precendece of phoneme for selecting transition
-- blendIn    number of frames to transition in from prior phoneme
-- blendOut   number of frames to transition out to next phoneme

buildPhoneme{ token=" ", part=1, f1=0, f2=0, f3=0, a1=0, a2=0, a3=0, length=0, blendRank=0, blendIn=0, blendOut=0 }
buildPhoneme{ token=".", part=1, f1=520, f2=1836, f3=2494, a1=0, a2=0, a3=0, length=18, blendRank=31, blendIn=2, blendOut=2 }
buildPhoneme{ token="?", part=1, f1=520, f2=1836, f3=2494, a1=0, a2=0, a3=0, length=18, blendRank=31, blendIn=2, blendOut=2 }
buildPhoneme{ token=",", part=1, f1=520, f2=1836, f3=2494, a1=0, a2=0, a3=0, length=18, blendRank=31, blendIn=2, blendOut=2 }
buildPhoneme{ token="-", part=1, f1=520, f2=1836, f3=2494, a1=0, a2=0, a3=0, length=8, blendRank=31, blendIn=2, blendOut=2 }
buildPhoneme{ token="IY", part=1, f1=274, f2=2303, f3=3015, a1=11, a2=6, a3=4, length=8, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="IH", part=1, f1=383, f2=1974, f3=2549, a1=11, a2=8, a3=4, length=8, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="EH", part=1, f1=493, f2=1809, f3=2494, a1=14, a2=11, a3=4, length=8, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="AE", part=1, f1=658, f2=1699, f3=2412, a1=16, a2=14, a3=4, length=8, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="AA", part=1, f1=712, f2=1096, f3=2440, a1=16, a2=11, a3=1, length=11, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="AH", part=1, f1=603, f2=1206, f3=2385, a1=16, a2=9, a3=1, length=6, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="AO", part=1, f1=548, f2=822, f3=2412, a1=16, a2=9, a3=0, length=12, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="UH", part=1, f1=438, f2=987, f3=2248, a1=16, a2=8, a3=1, length=10, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="AX", part=1, f1=548, f2=1206, f3=2440, a1=9, a2=5, a3=0, length=5, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="IX", part=1, f1=383, f2=1974, f3=2549, a1=11, a2=8, a3=4, length=5, blendRank=5, blendIn=4, blendOut=4 }
buildPhoneme{ token="ER", part=1, f1=493, f2=1316, f3=1699, a1=9, a2=8, a3=3, length=11, blendRank=5, blendIn=4, blendOut=4 }
buildPhoneme{ token="UX", part=1, f1=383, f2=987, f3=2248, a1=16, a2=9, a3=1, length=10, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="OH", part=1, f1=493, f2=822, f3=2412, a1=16, a2=9, a3=0, length=10, blendRank=10, blendIn=4, blendOut=4 }
buildPhoneme{ token="RX", part=1, f1=493, f2=1370, f3=1699, a1=11, a2=9, a3=3, length=10, blendRank=2, blendIn=3, blendOut=3 }
buildPhoneme{ token="LX", part=1, f1=438, f2=987, f3=3015, a1=11, a2=4, a3=1, length=9, blendRank=8, blendIn=3, blendOut=2 }
buildPhoneme{ token="WX", part=1, f1=329, f2=767, f3=2193, a1=11, a2=4, a3=0, length=8, blendRank=5, blendIn=4, blendOut=4 }
buildPhoneme{ token="YX", part=1, f1=383, f2=1864, f3=2549, a1=14, a2=9, a3=4, length=7, blendRank=5, blendIn=4, blendOut=4 }
buildPhoneme{ token="WH", part=1, f1=274, f2=658, f3=2467, a1=11, a2=4, a3=0, length=9, blendRank=11, blendIn=3, blendOut=2 }
buildPhoneme{ token="R", part=1, f1=493, f2=1370, f3=1645, a1=9, a2=6, a3=3, length=7, blendRank=10, blendIn=3, blendOut=2 }
buildPhoneme{ token="L", part=1, f1=383, f2=822, f3=3015, a1=11, a2=4, a3=1, length=6, blendRank=9, blendIn=3, blendOut=2 }
buildPhoneme{ token="W", part=1, f1=274, f2=658, f3=2467, a1=11, a2=4, a3=0, length=8, blendRank=8, blendIn=3, blendOut=2 }
buildPhoneme{ token="Y", part=1, f1=219, f2=2248, f3=3015, a1=11, a2=6, a3=4, length=6, blendRank=8, blendIn=3, blendOut=2 }
buildPhoneme{ token="M", part=1, f1=164, f2=1261, f3=2220, a1=9, a2=2, a3=0, length=7, blendRank=160, blendIn=1, blendOut=1 }
buildPhoneme{ token="N", part=1, f1=164, f2=1480, f3=3317, a1=5, a2=5, a3=0, length=7, blendRank=8, blendIn=2, blendOut=1 }
buildPhoneme{ token="NX", part=1, f1=164, f2=2357, f3=2769, a1=5, a2=3, a3=2, length=7, blendRank=8, blendIn=3, blendOut=1 }
buildPhoneme{ token="DX", part=1, f1=164, f2=1480, f3=3317, a1=0, a2=0, a3=0, length=2, blendRank=23, blendIn=2, blendOut=1 }
buildPhoneme{ token="Q", part=1, f1=466, f2=1836, f3=2494, a1=0, a2=0, a3=0, length=5, blendRank=31, blendIn=1, blendOut=1 }
--buildPhoneme{ token="S", part=1, f1=164, f2=2001, f3=2714, a1=0, a2=0, a3=0, length=2, blendRank=18, blendIn=3, blendOut=1 }
buildPhoneme{ token="S", part=1, f1=164, f2=2001, f3=2714, a1=0, a2=0, a3=0, length=4, blendRank=18, blendIn=3, blendOut=1 }
--buildPhoneme{ token="SH", part=1, f1=164, f2=2165, f3=2906, a1=0, a2=0, a3=0, length=2, blendRank=18, blendIn=3, blendOut=1 }
buildPhoneme{ token="SH", part=1, f1=164, f2=2165, f3=2906, a1=0, a2=0, a3=0, length=4, blendRank=18, blendIn=3, blendOut=1 }
--buildPhoneme{ token="F", part=1, f1=164, f2=712, f3=2220, a1=0, a2=0, a3=0, length=2, blendRank=18, blendIn=3, blendOut=1 }
buildPhoneme{ token="F", part=1, f1=164, f2=712, f3=2220, a1=0, a2=0, a3=0, length=4, blendRank=18, blendIn=3, blendOut=1 }
buildPhoneme{ token="TH", part=1, f1=164, f2=1809, f3=3317, a1=0, a2=0, a3=0, length=2, blendRank=18, blendIn=3, blendOut=1 }
buildPhoneme{ token="HH", part=1, f1=383, f2=2001, f3=2549, a1=0, a2=0, a3=0, length=2, blendRank=30, blendIn=1, blendOut=1 }
buildPhoneme{ token="QX", part=1, f1=438, f2=1014, f3=2248, a1=0, a2=0, a3=0, length=2, blendRank=30, blendIn=1, blendOut=1 }
buildPhoneme{ token="Z", part=1, f1=246, f2=1398, f3=2549, a1=8, a2=2, a3=0, length=6, blendRank=20, blendIn=3, blendOut=2 }
buildPhoneme{ token="ZH", part=1, f1=274, f2=1809, f3=2823, a1=8, a2=3, a3=1, length=6, blendRank=20, blendIn=3, blendOut=2 }
buildPhoneme{ token="V", part=1, f1=219, f2=1096, f3=2083, a1=8, a2=2, a3=0, length=7, blendRank=20, blendIn=3, blendOut=2 }
buildPhoneme{ token="DH", part=1, f1=274, f2=1288, f3=2549, a1=8, a2=2, a3=0, length=6, blendRank=20, blendIn=2, blendOut=1 }
buildPhoneme{ token="CH", part=1, f1=164, f2=2165, f3=2769, a1=0, a2=0, a3=0, length=6, blendRank=23, blendIn=2, blendOut=0 }
buildPhoneme{ token="CH", part=2, f1=164, f2=2165, f3=2769, a1=0, a2=0, a3=0, length=2, blendRank=23, blendIn=3, blendOut=1 }
buildPhoneme{ token="J", part=1, f1=164, f2=1809, f3=3317, a1=1, a2=0, a3=0, length=8, blendRank=26, blendIn=2, blendOut=0 }
buildPhoneme{ token="J", part=2, f1=137, f2=2165, f3=2769, a1=8, a2=3, a3=1, length=3, blendRank=26, blendIn=3, blendOut=1 }
buildPhoneme{ token="J", part=3, f1=164, f2=3015, f3=3317, a1=0, a2=6, a3=14, length=1, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="J", part=4, f1=0, f2=0, f3=0, a1=2, a2=2, a3=1, length=30, blendRank=29, blendIn=0, blendOut=5 }
buildPhoneme{ token="EY", part=1, f1=493, f2=1974, f3=2467, a1=14, a2=14, a3=5, length=13, blendRank=2, blendIn=5, blendOut=5 }
buildPhoneme{ token="AY", part=1, f1=712, f2=1041, f3=2412, a1=16, a2=11, a3=1, length=12, blendRank=2, blendIn=5, blendOut=5 }
buildPhoneme{ token="OY", part=1, f1=548, f2=822, f3=2412, a1=16, a2=9, a3=0, length=12, blendRank=2, blendIn=5, blendOut=5 }
buildPhoneme{ token="AW", part=1, f1=712, f2=1151, f3=2412, a1=16, a2=11, a3=1, length=12, blendRank=2, blendIn=5, blendOut=5 }
buildPhoneme{ token="OW", part=1, f1=493, f2=822, f3=2412, a1=16, a2=9, a3=0, length=14, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="UW", part=1, f1=329, f2=932, f3=2248, a1=11, a2=4, a3=0, length=9, blendRank=2, blendIn=4, blendOut=4 }
buildPhoneme{ token="B", part=1, f1=164, f2=712, f3=2220, a1=2, a2=0, a3=0, length=6, blendRank=26, blendIn=2, blendOut=2 }
buildPhoneme{ token="B", part=2, f1=164, f2=712, f3=2220, a1=2, a2=1, a3=0, length=1, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="B", part=3, f1=164, f2=712, f3=2220, a1=0, a2=0, a3=0, length=2, blendRank=27, blendIn=2, blendOut=1 }
--buildPhoneme{ token="D", part=1, f1=164, f2=1809, f3=3317, a1=2, a2=0, a3=0, length=5, blendRank=26, blendIn=2, blendOut=2 }
buildPhoneme{ token="D", part=1, f1=164, f2=1809, f3=3317, a1=2, a2=0, a3=0, length=4, blendRank=26, blendIn=1, blendOut=1 }
buildPhoneme{ token="D", part=2, f1=164, f2=1809, f3=3317, a1=2, a2=1, a3=0, length=1, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="D", part=3, f1=164, f2=1809, f3=3317, a1=0, a2=0, a3=0, length=1, blendRank=27, blendIn=3, blendOut=1 }
buildPhoneme{ token="G", part=1, f1=164, f2=3015, f3=3070, a1=1, a2=0, a3=0, length=6, blendRank=26, blendIn=2, blendOut=2 }
buildPhoneme{ token="G", part=2, f1=164, f2=3015, f3=3015, a1=2, a2=1, a3=0, length=1, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="G", part=3, f1=164, f2=3015, f3=3015, a1=0, a2=0, a3=0, length=2, blendRank=27, blendIn=4, blendOut=1 }
buildPhoneme{ token="GX", part=1, f1=164, f2=2303, f3=2577, a1=1, a2=0, a3=0, length=6, blendRank=26, blendIn=2, blendOut=2 }
buildPhoneme{ token="GX", part=2, f1=164, f2=2303, f3=2577, a1=2, a2=1, a3=0, length=1, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="GX", part=3, f1=164, f2=2303, f3=2577, a1=0, a2=0, a3=0, length=2, blendRank=27, blendIn=3, blendOut=1 }
buildPhoneme{ token="P", part=1, f1=164, f2=712, f3=2220, a1=0, a2=0, a3=0, length=8, blendRank=23, blendIn=2, blendOut=2 }
buildPhoneme{ token="P", part=2, f1=164, f2=712, f3=2220, a1=0, a2=0, a3=0, length=2, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="P", part=3, f1=164, f2=712, f3=2220, a1=0, a2=0, a3=0, length=2, blendRank=23, blendIn=2, blendOut=2 }
--buildPhoneme{ token="T", part=1, f1=164, f2=1809, f3=3317, a1=0, a2=0, a3=0, length=4, blendRank=23, blendIn=2, blendOut=2 }
buildPhoneme{ token="T", part=1, f1=164, f2=1809, f3=3317, a1=0, a2=0, a3=0, length=1, blendRank=23, blendIn=2, blendOut=2 }
buildPhoneme{ token="T", part=2, f1=164, f2=1809, f3=3317, a1=0, a2=0, a3=0, length=2, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="T", part=3, f1=164, f2=1809, f3=3317, a1=0, a2=0, a3=0, length=2, blendRank=23, blendIn=2, blendOut=1 }
buildPhoneme{ token="K", part=1, f1=164, f2=2988, f3=2769, a1=0, a2=0, a3=0, length=6, blendRank=23, blendIn=3, blendOut=3 }
buildPhoneme{ token="K", part=2, f1=274, f2=2357, f3=2769, a1=9, a2=6, a3=4, length=1, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="K", part=3, f1=274, f2=2988, f3=3070, a1=0, a2=0, a3=0, length=4, blendRank=23, blendIn=3, blendOut=2 }
buildPhoneme{ token="KX", part=1, f1=164, f2=2303, f3=2577, a1=0, a2=0, a3=0, length=6, blendRank=23, blendIn=3, blendOut=3 }
buildPhoneme{ token="KX", part=2, f1=164, f2=2303, f3=2577, a1=0, a2=6, a3=3, length=1, blendRank=29, blendIn=0, blendOut=0 }
buildPhoneme{ token="KX", part=3, f1=164, f2=2303, f3=2577, a1=0, a2=0, a3=0, length=4, blendRank=23, blendIn=3, blendOut=2 }

buildPhoneme{ token="UL", part=1, f1=1206, f2=3481, f3=219, a1=15, a2=0, a3=19, length=199, blendRank=23, blendIn=176, blendOut=160 }
buildPhoneme{ token="UM", part=1, f1=520, f2=3481, f3=27, a1=15, a2=0, a3=16, length=255, blendRank=23, blendIn=160, blendOut=160 }
buildPhoneme{ token="UN", part=1, f1=0, f2=0, f3=0, a1=0, a2=0, a3=0, length=0, blendRank=0, blendIn=0, blendOut=0 }
buildPhoneme{ token="IL", part=1, f1=44, f2=127, f3=8, a1=15, a2=0, a3=19, length=199, blendRank=23, blendIn=176, blendOut=160 }
buildPhoneme{ token="IM", part=1, f1=19, f2=127, f3=1, a1=15, a2=0, a3=16, length=255, blendRank=23, blendIn=160, blendOut=160 }
buildPhoneme{ token="IN", part=1, f1=0, f2=0, f3=0, a1=0, a2=0, a3=0, length=0, blendRank=0, blendIn=0, blendOut=0 }


-- Set the fricative for the phoneme
local function setFricative( token, part, frequency, bandwidth, amplitude )

	-- find root token
	local p = getPhoneIndex(token)
	if pData[p+part-1].part ~= part then
		error("Phoneme '"..token.."' does not have a part "..part)
	else
		-- offset to the part
		p = p + part - 1
	end

	-- store the values
	pData[p].fricFrq = frequency
	pData[p].fricBw = bandwidth
	pData[p].fricAmp = amplitude

end


-- Add frication data to phonemes
setFricative( "S", 1, 4500, 300, 1 )
setFricative( "SH", 1, 2600, 250, 1 )
setFricative( "CH", 1, 4500, 100, 1 )
setFricative( "CH", 2, 4500, 100, 1 )
setFricative( "TH", 1, 1200, 500, 1 )
setFricative( "F", 1, 1200, 500, 1 )
setFricative( "HH", 1, 500, 500, 1 )

-- Add "stop" frication data to phonemes
setFricative( "P", 1, 2600, 50, 0 )
setFricative( "K", 1, 2600, 50, 0 )
setFricative( "G", 1, 2600, 50, 0 )
setFricative( "KX", 1, 2600, 50, 0 )
setFricative( "GX", 1, 2600, 50, 0 )
setFricative( "B", 1, 2600, 50, 0 )
setFricative( "P", 1, 2600, 50, 0 )
setFricative( "T", 1, 4500, 100, 0)
setFricative( "D", 1, 4500, 100, 0 )

-- Fricative data following stop
setFricative( "K", 2, 2600, 50, 1 )
setFricative( "KX", 2, 2600, 50, 1 )
setFricative( "G", 2, 2600, 50, 1 )
setFricative( "GX", 2, 2600, 50, 1 )
setFricative( "B", 2, 2600, 50, 1 )
setFricative( "P", 2, 2600, 50, 1 )
setFricative( "T", 2, 4500, 100, 1 )
setFricative( "D", 2, 4500, 100, 1 )

-- release aspiration portion of phoneme
setFricative( "K", 3, 500, 500, 1 )
setFricative( "KX", 3, 500, 500, 1 )
setFricative( "G", 3, 500, 500, 1 )
setFricative( "GX", 3, 500, 500, 1 )
setFricative( "B", 3, 500, 500, 1 )
setFricative( "P", 3, 500, 500, 1 )
setFricative( "T", 3, 500, 500, 1 )


-- return a table which returns true if key is in the table
local function flagTable(phoneNames)
	-- the table to build
	local t = {}

	-- set the indexes to true for each phoneme name
	for _, name in ipairs(phoneNames) do
		t[getPhoneIndex(name)] = true
	end

	-- return the table
	return t
end

-- classification data for phonemes
local isUnvoicedPlosive = flagTable{"P","T","K","KX"}
local isDiphthong = flagTable{"EY","AY","OY","AW","OW","UW"}
local isBackVowel = flagTable{"IY","IH","EH","AE","AA","AH","AX","IX","EY","AY","OY"}
local isVowel = flagTable{"IY","IH","EH","AE","AA","AH","AO","UH","AX","IX","ER","UX","OH","RX","LX",
	"WX","YX","EY","AY","OY","AW","OW","UW","UL","UM","UN"}
local isAlveolar = flagTable{"N","DX","S","TH","Z","DH","D","T"}


-- Text input text file is converted to this format
local outIndex = {}   -- index to the pData vocal information
local outLength = {}  -- the duration, in frames, for the phoneme
local outPitch = {}   -- the pitch of the phonemes
local outBlendLeft = {} -- duration of blend in
local outBlendRight = {}

local gTempo = 120    -- default tempo
local gPitch = 220    -- default pitch
local gTranspose = 0  -- current transposition
local gPercent = 1    -- note duration can be modified by percent
local gBeats = 0      -- beat the nucleus gets


-- return true if value is inTable
local function inTable( theValue, theTable)
	for _, value in ipairs( theTable ) do
		if value == theValue then return true end
	end
	return false
end


-- phonemes, arranged by character length
local validPhones = {
	-- vowels
	"IY", "AE", "AH", "ER", "QX", "IH", "AA", "UH", "AX", "EH", "AO", "OH", "IX", "UX",
	-- diphthongs
	"EY", "AW", "AY", "OW", "OY", "UW",
	-- contractions,
	"UL", "IM", "UN", "IL", "IM", "IN",
	-- consonants
	"ZH", "WH", "DH", "DX", "HH", "NX", "SH", "CH", "TH",
	"R", "Y", "M", "S", "B", "K", "J", "L", "N", "Z", "F", "T",
	"G", "W", "V", "P", "D", "CH", "Q"
}

-- phonemes that are nucleus phonemes (core vowels)
local isNucleus = {
	"Q",
	"IY", "AE", "AH", "ER", "QX", "IH", "AA", "UH", "AX", "EH", "AO", "OH", "IX", "UX",
	"EY", "AW", "AY", "OW", "OY", "UW",
	"UL", "IM", "UN", "IL", "IM", "IN"
}





-------------------------------------------
-- CONVERT A .PHO FILE INTO PHONEME DATA --
-------------------------------------------

-- throw an error if the parameter to cmd is not integer
local function isNumericParm(cmd, parm, low, high)
	local i = tonumber( parm )

	if not i then
		-- not a number
		error("Expected number, not '"..parm.."' in command "..cmd)
	elseif (low and i < low) or (high and i > high) then
		-- out of range
		error("Parameter '"..parm.."' in command "..cmd.." must be between "..low.." and "..high)
	end
end


-- throw an error if the parameter to cmd is not integer
local function isIntegerParm(cmd, parm, low, high)
	local i = tonumber( parm )

	-- numeric and integer
	if not i or math.floor(i) ~= i then
		error("Expected integer, not '"..parm.."' in command "..cmd)
	end

	isNumericParm(cmd, parm, low, high)
end



-- Return the frequency of a note
function noteToFrequency( step, octave )

	local pitch, scale

	-- fix case
	step = string.lower(step)

	-- relative to octave 3
	if step == "b#" or step == "c" then
		pitch = 130.81
	elseif step == "c#" or step == "db" then
		pitch = 138.59
	elseif step == "d" then
		pitch = 146.83
	elseif step == "d#" or step == "eb" then
		pitch = 155.56
	elseif step == "e" then
		pitch = 164.81
	elseif step == "e#" or step == "f" then
		pitch = 174.61
	elseif step == "f#" or step == "gb" then
		pitch = 185.00
	elseif step == "g" then
		pitch = 196.00
	elseif step == "g#" or step == "ab" then
		pitch = 207.65
	elseif step == "a" then
		pitch = 220.00
	elseif step == "a#" or step == "bb" then
		pitch = 233.08
	elseif step == "b" then
		pitch = 246.94
	else
		error("Unknown step '"..step.."' in note  '"..step..octave.."'" )
	end

	if octave == "1" then
		scale = .25
	elseif octave == "2" then
		scale = .5
	elseif octave == "3" then
		scale = 1
	elseif octave == "4" then
		scale = 2
	elseif octave == "5" then
		scale = 4
	else
		error("Unknown octave '"..step.."' in note '"..step..octave.."'" )
	end

	return pitch * scale

end


-- return the frequency plus the given number of cents
function transpose(frequency, halfSteps)
  return frequency * math.pow(2, halfSteps/12)
end


local function splitOnSpaces( s )
	local words = {}
	local word = ""

	-- loop through the text
	for i = 1, string.len(s) do
		-- get a character
		local c = string.sub(s, i, i)
		-- space?
		if c == " " then
			-- is there a word accumulated?
			if word ~= "" then
				-- insert into the word table and clear the word
				table.insert( words, word )
				word = ""
			end
		else
			-- add the character to the word
			word = word .. c
		end
	end

	-- final word?
	if word ~= "" then
		-- add to the table
		table.insert(words, word)
	end

	return words

end

local function doCmd( text )
	-- split text into words
	local words = splitOnSpaces( text )

	-- get command and optional parameter
	local cmd = words[1]
	local parm = words[2]
	local parmValue = tonumber(parm)

	-- check length
	if #words == 0 then
		return

  elseif #words == 1
  and string.sub( cmd, -1 ) == "%" then
    -- percent duration change
    gPercent = tonumber(string.sub(cmd, 1, string.len(cmd)-1))/100
    return

	elseif #words == 1 then
		-- note
		local step, accidental, octave
		if string.len( cmd ) == 2 then
			step, octave = string.sub(cmd, 1, 1), string.sub(cmd,2,2)
		else
			step, accidental, octave = string.sub(cmd, 1, 2), string.sub(cmd,2,2), string.sub(cmd,3,3)
		end

		print("Note", step, accidental, octave)

    -- get the pitch frequency
		gPitch = noteToFrequency( step, octave )

    -- transpose?
    if gTranspose ~= 0 then
      gPitch = transpose( gPitch, gTranspose )
    end

		return

	elseif #words > 2 then
		error("Wrong number of parameters in command {"..text.."}")
	end

	print( "Cmd", cmd, parm, parmValue)

	-- nothing

	if cmd == "ahbias" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "avbias" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "f0style" then
	-- FIXME

	elseif cmd == "mod" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "modramp" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "modrate" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "perturb" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "rate" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "tempo" then
		isIntegerParm(cmd, parmValue, 20, 360)
		-- set the global tempo
		gTempo = parmValue

	elseif cmd == "tonebias" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "tonelo" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "transpose" then
		isIntegerParm(cmd, parmValue, -36, 36)
		gTranspose = parmValue

	elseif cmd == "tremelo" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "vfactor" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "vibrato" then
		isNumericParm(cmd, parmValue)

	elseif cmd == "voice" then
		if not inTable( parm, {"male", "female", "child"}) then
			error("Bad parameter '"..parm.."' in command f0style.")
		end

	else
		error("Unknown command '"..cmd.."'")
	end


end

-- parse out the semi-colon demlimited commands
local function parseCommand( text )
	local at = 1

	while true do
		-- look for a semicolon
		local semiAt = string.find( text, ";", at, true )

		-- none found?
		if not semiAt then
			-- execute the remainder of the string
			doCmd( string.sub( text, at ))
			return
		end

		-- execute the portion to the semicolon
		doCmd( string.sub( text, at, semiAt-1 ))

		-- advance
		at = semiAt + 1

	end

end


-- parse out the contents of a .pho file
local function parsePho( text )
	-- fixme: split into commands
	local at = 1
	while at <= string.len( text ) do
		-- get a character from the string
		local c = string.sub(text, at, at)

		-- start of an embedded command?
		if c == "{" then
			-- find the closing brace
			local closeAt = string.find( text, "}", at+1, true )
			if not closeAt then
				error("Missing '}' in string following "..string.sub(text, at))
			end
			-- get the command
			local cmd = string.sub( text, at+1, closeAt-1 )

			-- run the command
			parseCommand( cmd )

			-- move ahead
			at = closeAt+1

		elseif c == " "
    or c == "\n"
    or c == "\r" then
			-- ignore whitespace
			at = at + 1

		elseif c == "*"
    or c == "/" then
			-- eat beat markers
			gBeats = 0
      while true do
        -- get the beat character
        local beatChar = string.sub(text, at, at)
        if beatChar == "*" then
          -- 1 beat
          gBeats = gBeats + 1
        elseif beatChar == "/" then
          -- half beat
          gBeats = gBeats + .5
        else
          break
        end
        -- move past beat character
				at = at + 1
			end

			-- eat dots
			local dots = 0
			while string.sub(text, at, at) == "." do
				dots = dots + 1
				at = at + 1
			end
			if dots == 1 then
				gBeats = gBeats * 1.5
			end

			-- convert into seconds
			gBeats = gBeats * 60 / gTempo

      -- scale by percent and reset percent
      gBeats = gBeats * gPercent
      gPercent = 1

			print("Beats", gBeats)

		elseif c == "'" then
			-- emphasis flag?
			at = at + 1

		else
			-- try matching to a phoneme
			local matchPhone = nil
			for _, value in ipairs(validPhones) do
				if value == string.sub(text, at, at+string.len(value)-1) then
					matchPhone = value
					break
				end
			end

			-- no match?
			if not matchPhone then
				error("Unknown text '"..string.sub(text, at, at+20).."'")
			end

			-- move past match
			at = at + string.len(matchPhone)

			-- emphasis?
			local emphasis = nil
			c = string.sub(text, at, at)
			if c >= "0" and c <= "9" then
				-- FIXME: How to use emphasis?
				local emphasis = c
				at = at + 1
			end

			-- debug
      if debugFlag then
			  print("Phone", matchPhone, emphasis)
      end

			-- find phoneme index
			local phoneIndex = pIndexByName[matchPhone]
			if not phoneIndex then
				error("Unable to match phoneme '"..matchPhone.."'")
			end

			-- insert the index
			table.insert( outIndex, phoneIndex )

			-- nucleus?
			if inTable( matchPhone, isNucleus ) then
				-- set the beats and pitch
				table.insert( outLength, gBeats )
				table.insert( outPitch, gPitch )
			else
				-- set to zero
				table.insert( outLength, 0 )
				table.insert( outPitch, 0 )
			end

		end
	end
end





-- Print debug **msg** if debug flag is true
local function debugPrint( msg )
	if debugFlag then print( msg ) end
end



--------------------------------------
-- REPLACE PHONEMES WITH ALLOPHONES --
--------------------------------------


-- Insert at **position** a phoneme with a given index, and insert zeros
-- in the outLength and outPitch
local function insert( position, phoneName )
	table.insert( outIndex, position, getPhoneIndex( phoneName ) )
	table.insert( outLength, position, 0 )
	table.insert( outPitch, position, 0 )
end



-- Apply allophonic replacements
local function applyAllophones()

	debugPrint("applyRules")
	local pos = 0

	-- Loop through phonemes
	while pos < #outIndex do

		-- increment position and get the phoneme
		pos = pos + 1
		local p = outIndex[pos]

		if p == nil then
			-- safety check, should not happen
			error("nil found in outIndex, missing end of line token")

		elseif p == getPhoneIndex(" ") then
		-- skip spaces

		elseif isDiphthong[p] then

			-- RULE:
			--    <DIPHTHONG> -> <DIPHTHONG> WX | YX
			-- Example: OIL, COW

			-- Ends in IY sound?
			if isBackVowel[p] then
				-- insert YX after
				debugPrint("RULE: insert YX following *Y diphthong")
				insert(pos+1, "YX" )
			else
				-- insert WX after
				debugPrint("RULE: insert WX following *W diphthong")
				insert(pos+1, "WX" )
			end

		elseif p == getPhoneIndex("UL") then

			-- RULE:
			--    UL -> AX L
			-- Example: MEDDLE

			debugPrint("RULE: UL -> AX L")
			outIndex[pos] = getPhoneIndex("AX")
			insert(pos+1, "L" )

		elseif p == getPhoneIndex("UM") then

			-- RULE:
			--        UM -> AX M
			-- Example: ASTRONOMY

			debugPrint("RULE: UM -> AX M")
			outIndex[pos] = getPhoneIndex("AX")
			insert(pos+1, "M" )

			-- don't advance
			pos = pos - 1

		elseif p == getPhoneIndex("UN") then

			-- RULE:
			--       UN -> AX N
			-- Example: FUNCTION

			debugPrint("RULE: UN -> AX N")
			outIndex[pos] = getPhoneIndex("AX")
			insert(pos+1, "N" )

			-- don't advance
			pos = pos - 1

		elseif p == getPhoneIndex("IL") then

			-- RULE:
			--    IL -> IX L
			-- Example: HASTILY

			debugPrint("RULE: IL -> IX L")
			outIndex[pos] = getPhoneIndex("IX")
			insert(pos+1, "L" )

		elseif p == getPhoneIndex("IM") then

			-- RULE:
			--        IM -> IX M
			-- Example: ANIMAL

			debugPrint("RULE: IM -> IX M")
			outIndex[pos] = getPhoneIndex("IX")
			insert(pos+1, "M" )

			-- don't advance
			pos = pos - 1

		elseif p == getPhoneIndex("IN") then

			-- RULE:
			--       IN -> IX N
			-- Example: CABIN

			debugPrint("RULE: IN -> IX N")
			outIndex[pos] = getPhoneIndex("IX")
			insert(pos+1, "N" )

			-- don't advance
			pos = pos - 1

		elseif p == getPhoneIndex("R") and outIndex[pos-1] == getPhoneIndex("T") then

			-- RULES FOR PHONEMES BEFORE R
			--        T R -> CH R
			-- Example: TRACK

			-- change T to CH, but don't advance
			debugPrint("RULE: T R -> CH R")
			outIndex[pos-1] = getPhoneIndex("CH")
			pos = pos - 1

		elseif p == getPhoneIndex("R") and outIndex[pos-1] == getPhoneIndex("D") then

			-- RULES FOR PHONEMES BEFORE R
			--        D R -> J R
			-- Example: DRY

			-- change T to J, but don't advance
			debugPrint("RULE: T R -> J R")
			outIndex[pos-1] = getPhoneIndex("J")
			pos = pos - 1

		elseif p == getPhoneIndex("R") and isVowel[outIndex[pos-1]] then

			-- RULES FOR PHONEMES BEFORE R
			--        <VOWEL> R -> <VOWEL> RX
			-- Example: ART

			-- change R to RX and advance
			debugPrint("RULE: R -> RX")
			outIndex[pos] = getPhoneIndex("RX")

		elseif p == getPhoneIndex("L") and isVowel[outIndex[pos-1]] then

			-- RULE:
			--       <VOWEL> L -> <VOWEL> LX
			-- Example: ALL

			-- change L to LX and advance
			debugPrint("RULE: L -> LX")
			outIndex[pos] = getPhoneIndex("LX")


		elseif p == getPhoneIndex("S") and outIndex[pos-1] == getPhoneIndex("S") then

			-- RULE:
			--       G S -> G Z
			--
			-- Can't get to fire -
			--       1. The G -> GX rule intervenes
			--       2. Reciter already replaces GS -> GZ

			-- change S to Z and advance
			debugPrint("RULE: G S -> G Z")
			outIndex[pos] = getPhoneIndex("Z")

		elseif p == getPhoneIndex("K") and isBackVowel[outIndex[pos+1]] then

			-- RULE:
			--             K <BACK VOWEL> -> KX <BACK VOWEL>
			-- Example: COW

			-- replace K with KX, and advance
			debugPrint("RULE: K <BACK VOWEL> -> KX <BACK VOWEL>")
			outIndex[pos] = getPhoneIndex("KX")


		elseif p == getPhoneIndex("G") and isBackVowel[outIndex[pos+1]] then

			-- RULE:
			--             G <BACK VOWEL> -> GX <BACK VOWEL>
			-- Example: GO

			-- replace G with GX, and advance
			debugPrint("RULE: G <BACK VOWEL> -> GX <BACK VOWEL>")
			outIndex[pos] = getPhoneIndex("GX")


		elseif p == getPhoneIndex("S") and isUnvoicedPlosive[outIndex[pos+1]] then

			-- RULE:
			--      S P -> S B
			--      S T -> S D
			--      S K -> S G
			--      S KX -> S GX
			-- Examples: SPY, STY, SKY, SCOWL

			-- replace unvoiced plosive with voiced plosive, and advance
			if outIndex[pos+1] == getPhoneIndex("P") then
				debugPrint("RULE: S P -> S B")
				outIndex[pos+1] = getPhoneIndex("B")

			elseif outIndex[pos+1] == getPhoneIndex("T") then
				debugPrint("RULE: S T -> S D")
				outIndex[pos+1] = getPhoneIndex("D")

			elseif outIndex[pos+1] == getPhoneIndex("K") then
				debugPrint("RULE: S K -> S G")
				outIndex[pos+1] = getPhoneIndex("G")

			elseif outIndex[pos+1] == getPhoneIndex("KX") then
				debugPrint("RULE: S KX -> S KX")
				outIndex[pos+1] = getPhoneIndex("GX")
			end


		elseif p == getPhoneIndex("UW") and isAlveolar[outIndex[pos-1]] then

			-- RULE:
			--      <ALVEOLAR> UW -> <ALVEOLAR> UX
			--
			-- Example: NEW, DEW, SUE, ZOO, THOO, TOO

			debugPrint("RULE: <ALVEOLAR> UW -> <ALVEOLAR> UX")
			outIndex[pos] = getPhoneIndex("UX")


		elseif (p == getPhoneIndex("T") or p == getPhoneIndex("D"))
			and isVowel[outIndex[pos-1]]
			and isVowel[outIndex[pos+1]] then

			-- FIXME: This had initially been only if the second vowel is stressed
			-- RULE: Soften T or D between a two vowels
			--       <VOWEL> T <VOWEL> -> <VOWEL> DX <VOWEL>
			--       <VOWEL> D <VOWEL>  -> <VOWEL> DX <VOWEL>
			-- Example: PARTY, TARDY

			-- replace T or D with DX and advance
			debugPrint("<VOWEL> T|D <VOWEL> -> <VOWEL> DX <VOWEL>")
			outIndex[pos] = getPhoneIndex("DX")

		end

	end

end



-- Remove duplicate non-nucleus consonants
local function removeDuplicateConsonants()

	local at = 1
	while at < #outIndex do
		if outIndex[at] == outIndex[at+1]
			and outLength[at] == 0 then
			-- remove from the table
			table.remove( outIndex, at )
			table.remove( outLength, at )
			table.remove( outPitch, at )
			-- don't advance, there may be several in a row
		else
			-- move ahead
			at = at + 1
		end
	end

end


local function calculateTimings()

	-- set as first nucleus
	local nucleusAt = nil

	-- loop through the phonemes, skipping initial rest
	for i = 1, #outIndex do

		-- nucleus?
		if outPitch[i] ~= 0 then
			-- set as new nucleus
			nucleusAt = i
		else
			-- get the phoneme index
			local p = outIndex[i]

			-- get the default duration
			local length = pData[p].length * secondsPerFrame

			-- set as the length
			outLength[i] = length

			if nucleusAt then
				-- subtract from prior nucleus
				outLength[nucleusAt] = outLength[nucleusAt] - length
			end

		end
	end

end



-- If a phoneme has multiple steps, insert the next step
local function expandPhonemes()
	local i = 1
	while i <= #outIndex do

		-- get the phoneme at the index
		local p = outIndex[i]

		-- is there a step following this?
		if pData[p].token == pData[p+1].token then
			-- insert the expansion
			insert( i+1, pData[p].token )

			-- change the index to the next step
			outIndex[i+1] = p+1
		end

		-- move ahead
		i = i + 1

	end
end


-- Find the first pitch, and set the phonemes prior to it
local function setInitialPitch()
	local at
	local pitch

	-- find the first pitch
	for i = 1, #outPitch do
		if outPitch[i] ~= 0 then
			at = i
			pitch = outPitch[i]
			break
		end
	end

	-- none found?
	if not at then
		error("No pitches set")
	end

	-- set the initial pitches
	for i = 1, at-1 do
		outPitch[i] = pitch
	end

end


-- Copy the pitch from prior values forward if not set
local function setFollowingPitches()

	-- loop
	for i = 2, #outPitch do
		-- no pitch?
		if outPitch[i] == 0 then
			-- use prior pitch
			outPitch[i] = outPitch[i-1]
		end
	end
end




-- Given a start and end position, interpolates values through the table
function interpolate( t, startIndex, endIndex )
	-- get start and end values
	local startValue = t[startIndex]
	local endValue = t[endIndex]

	-- get ranges
	local valueRange = (endValue - startValue)
	local steps = endIndex - startIndex + 1

	-- interpolate values between start and end
	for i = 1, steps-1 do
		-- interpolate
		t[startIndex+i] = startValue + (i/steps) * valueRange
	end
end



local function createTransitions()

	-- no transition into first frame
	outBlendLeft[1] = 0

	-- no transition out of last frame
	outBlendRight[#outIndex] = 0

	for pos = 1, #outIndex-1 do

		-- get the current and following phoneme
		local pThis = outIndex[pos]
		local pNext = outIndex[pos+1]

		-- get the ranking of each phoneme
		local rankThis = pData[pThis].blendRank
		local rankNext = pData[pNext].blendRank

		local inFrames, outFrames

		-- compare the rank - lower rank value is stronger
		if rankThis == rankNext then
			-- same rank, so use out blend lengths from each phoneme
			inFrames = pData[pThis].blendIn
			outFrames = pData[pNext].blendOut

		elseif rankThis > rankNext then
			-- first phoneme is stronger, so us it's blend lengths
			inFrames = pData[pThis].blendIn
			outFrames = pData[pThis].blendOut
		else
			-- second phoneme is stronger, so use it's blend lengths
			-- note the out/in are swapped
			inFrames = pData[pNext].blendOut
			outFrames = pData[pNext].blendIn
		end

		-- convert to seconds and place with phoneme
		outBlendRight[pos] = inFrames * secondsPerFrame
		outBlendLeft[pos+1] = outFrames * secondsPerFrame

	end

end


-- Adjust the left and right transitions so they don't exceed the
-- duration of the phoneme.
local function adjustTransitions()
	-- loop through the phonemes
	for i = 1, #outIndex do
		-- get the left and right transitions
		local leftTransition = outBlendLeft[i]
		local rightTransition = outBlendRight[i]

		-- are the transitions longer than the duration of the phoneme?
		if leftTransition + rightTransition > outLength[i] then
			-- distribute the transitions, keeping the ratio
			local leftRatio = leftTransition/(leftTransition+rightTransition)
			outBlendLeft[i] = leftRatio * outLength[i]
			outBlendRight[i] = outLength[i] - outBlendLeft[i]
			outLength[i] = 0
		else
			outLength[i] = outLength[i] - (leftTransition + rightTransition)
		end

	end
end


-------------------------
-- RENDER THE PHONEMES --
-------------------------

-- Give a **startValue** and **endValue**, return a linearly
-- interplated value based on **t**, where **t==0** returns **startValue**,
-- and **t==1** returns **endValue**
local function lerp(startValue, endValue, t)
  -- range check
  if t <= 0 then
    return startValue
  elseif t >= 1 then
    return endValue
  else
	  -- interpolate value
	  return startValue + t * (endValue - startValue)
  end
end


-- Given a value **x** between **x1** and **x1**, return
-- the ratio. Inverse of **lerp** function.
local function getRatio( x1, x2, x )
	if x < x1 then
		return 0
	elseif x > x2 then
		return 1
	elseif x2 == x1 then
		return 1
	else
		return (x-x1) / (x2-x1)
	end
end


-----------------------
-- STATE INFORMATION --
-----------------------

--  at                index of current phoneme
--  transition        transition duration from prior phoneme to current phoneme
--  sustain           sustain duration for current phoneme
--  transitionLeft    remaining time in transition from prior phoneme to current phoneme
--  sustainLeft       remaining time in sustain for the current phoneme
--  t                 relative position in transition, equal to **(transitionLeft-1)/transition**


local my

local function initTick()
	my = { at=0, transition=0, transitionLeft=0, sustain=0, sustainLeft=0, t=0 }
end


-- Update to the state information to reflect the currently active phoneme
local function tick( duration )
	-- Call this to advance after a wave is rendered.
	-- This will move forward within the given frame,
	-- or ahead to the next frame as needed. It will also
	-- set the formants and other information so the
	-- wave can be rendered.

	-- get the current pitch
	my.f0 = outPitch[my.at]

	-- print("tick, duration=", duration)

	-- loop until out of phonemes, or return encountered
	while my.at <= #outIndex do

		-- is there an active transition?
		if my.transitionLeft > 0 then
			-- apply time to transition
			if my.transitionLeft > duration then
				-- subtract the duration
				my.transitionLeft = my.transitionLeft - duration

				-- position in transition
				my.t = 1-(my.transitionLeft/my.transition)

				-- leave loop
				break

			else
				-- subtract transition from duration, and zero transition
				duration = duration - my.transitionLeft
				my.transitionLeft = 0
			end
		end

		-- is there an active sustain?
		if my.sustainLeft > 0 then
			-- apply duration to sustain
			if my.sustainLeft > duration then
				-- subtract sustain
				my.sustainLeft = my.sustainLeft - duration

				-- no transition
				my.t = 0

				-- exit loop
				break

			else
				-- subtract sustain from duration, and zero sustain
				duration = duration - my.sustainLeft
				my.sustainLeft = 0
			end

		end

		-- move to the next phoneme
		my.at = my.at + 1

		-- get the transition and sustain
		my.transition = (outBlendRight[my.at-1] or 0) + (outBlendLeft[my.at] or 0)
		my.sustain = outLength[my.at]

		-- reset the remaining amount
		my.transitionLeft = my.transition
		my.sustainLeft = my.sustain

		-- get the pitch
		my.f0 = outPitch[my.at]

	end

end


---------------------
-- FORMANT FILTERS --
---------------------


-- Formant filters (used for fricatives)


local function calculateResponse( resonator )

	if resonator.amplitude == nil then
		resonator.amplitude = 1
	end

	-- calculate resonator response
	local r = math.exp(MINUS_PI_T * resonator.bandwidth)

	resonator.c = -(r*r)
	resonator.b = r * 2 * math.cos(TWO_PI_T * resonator.frequency)
	resonator.a = 1 - resonator.b - resonator.c

end


-- Modify a formant filter
local function resonatorSet( resonator, frequency, bandwidth )

	-- initialize
	resonator.frequency = frequency
	resonator.bandwidth = bandwidth

	calculateResponse( resonator )

end

-- Create a new formant filter
local function resonatorCreate( frequency, bandwidth )

	-- initialize
	local resonator = {}

	resonatorSet( resonator, frequency, bandwidth )

	-- calculate the resonator response
	calculateResponse( resonator )

	-- clear the history
	resonator.out = 0
	resonator.z1 = 0
	resonator.z2 = 0

	return resonator

end

-- Send a single sample through the formant filter
local function resonatorTick( resonator, input )

	-- run filter
	local out = resonator.a*input + resonator.b*resonator.z1 + resonator.c*resonator.z2

	-- shift history values
	resonator.z2, resonator.z1 = resonator.z1, out

	return out

end


-- fill the buffer with silence
local function synthesizeSilence( buffer, seconds )
	local samples = math.floor( seconds * SAMPLE_RATE )
	for _ = 1, samples do
		table.insert(buffer, 0)
	end
end


local fricationFilter = resonatorCreate(220, 100)

-- Add frication from **at** to the end of the buffer
local function synthesizeFrication( buffer, at, frequency, bandwidth, startAmplitude, endAmplitude )

	-- set resonator filter
	resonatorSet(fricationFilter, frequency, bandwidth)

	-- rate of change for amplitude
	local amplitudeStep = (endAmplitude-startAmplitude)/(#buffer-at)
	local amplitude = startAmplitude

	-- render the samples
	local bufferEnd = #buffer
	for i = at, bufferEnd do
		-- calculate frication
		local sample = resonatorTick( fricationFilter, (math.random()*2-1) )

		-- place in buffer
		buffer[i] = (buffer[i] or 0) + (sample * amplitude * 50)

		-- increase amplitude
		amplitude = amplitude + amplitudeStep

	end

end



------------------------
-- SPECTRAL SYNTHESIS --
------------------------



-- Given **frequency**, estimate the bandwidth based on the tube equation.
-- The bandwidth is the estimated frequency where the amplitude drops by half.
local function estimateBandwidth( frequency )
	return (50 * (1+(frequency/1000)))
end


-- Estimate formant width (not bandwidth!)
local function getFormantWidth( f )
	return lerp( 300, 140, f/4000 )
end

-- Return the amplitude of the frequency within
local function getFormantAmp( frq, formantFrq, formantAmp )

	-- calculate formant width
	local wide = getFormantWidth( frq )

	-- formant boundaries
	local low = formantFrq - wide
	local high = formantFrq + wide

	-- is frequency within the formant bounds?
	if frq >= low and frq <= high then
		-- position in formant
		local t = getRatio(low, high, frq)

		-- range from -pi..pi
		local theta = lerp( -math.pi, math.pi, t )

		-- convert cos() range from -1..1 to 0..formantAmp
		return ((math.cos( theta ) + 1) / 2) * formantAmp

	end

	-- not in formant
	return 0

end



-- Given **frq**, return the amplitude from the spectral envelope
local function getSpectralAmp( frq, f1, f2, f3, amp1, amp2, amp3 )

	local t, theta, wide

	-- default amp is non-linear falloff skirt
	t = frq/4000
	local amp = lerp( 2/100, 0, t*t )

  if true then
    -- alternate: sum the contributions from the formants
	  return math.max( amp,  
      getFormantAmp( frq, f1, amp1 ) + getFormantAmp( frq, f2, amp2 ) + getFormantAmp( frq, f3, amp3 )
    )
  end

	-- check each formant to see if the frequency lies inside.
  -- if it's in more than one formant, only use the largest value
	amp = math.max( amp, getFormantAmp( frq, f1, amp1 ) )
	amp = math.max( amp, getFormantAmp( frq, f2, amp2 ) )
	amp = math.max( amp, getFormantAmp( frq, f3, amp3 ) )
  
	-- amp = math.max( amp, getFormantAmp( frq, 3500, amp1/100 ) )
	-- amp = math.max( amp, getFormantAmp( frq, 4500, amp1/200 ) )


	return amp

end


-- Return the frequency of the closest harmonic to **frq**.
local function closestHarmonic( harmonic, frq )
	local closest = math.floor( frq/harmonic ) * harmonic
	if math.abs(closest+harmonic-frq) < math.abs(closest-frq) then
		return closest+harmonic
	end
	return closest
end


local lowpassPrior = 0
local lowpassAlpha = 1 / 5000 -- lowpass value
local function lowpass( x )
	lowpassPrior = lowpassPrior + lowpassAlpha * (x-lowpassPrior);
	return lowpassPrior
end


-- MAKE GAUSSIAN NOISE
-- Gaussian noise is caulculated by generating G_SMOOTH samples and 
-- averaging the value. Because this is expensive, 1 second's worth of
-- gaussian noise samples (SAMPLE_RATE == 1 second) are pre-calculated
local G_NOISE = {}
local G_SMOOTH = 128
for i = 1, SAMPLE_RATE do
	local tmp = 0
	for j = 1, G_SMOOTH do
		tmp = tmp + math.random(-1000, 1000) / 1000
	end
	G_NOISE[i] = tmp / G_SMOOTH
end

-- pick a random noise value
local function gaussianNoise()
	return G_NOISE[ math.random(1, SAMPLE_RATE) ]
end


-- Renders a single cycle of frequency **f0** into the buffer
local function synthesizeVoiced( buffer, f0, f1, f2, f3, amp1, amp2, amp3 )


	-- current position in the buffer
	local at = #buffer

	-- number of samples to render
	local samples = math.floor(SAMPLE_RATE/f0)

	-- render the harmonics
	for i = 1, 64 do

		local harmonic = f0 * i

    -- don't render past 5000Hz
		if harmonic > 5000 then break end

		local harmonicAmp = getSpectralAmp( harmonic, f1, f2, f3, amp1, amp2, amp3 )
		for j = 1, samples do

			local sample = math.sin(j * 2 * math.pi * harmonic / SAMPLE_RATE) * harmonicAmp * 40

			buffer[at+j] = (buffer[at+j] or 0) + sample
		end
	end


	-- "whisper" resonators
	local r1 = resonatorCreate( f1, estimateBandwidth(f1) )
	local r2 = resonatorCreate( f2, estimateBandwidth(f2) )
	local r3 = resonatorCreate( f3, estimateBandwidth(f3) )
	local r4 = resonatorCreate( 3500, estimateBandwidth(3500) )
	local r5 = resonatorCreate( 4500, estimateBandwidth(4500) )

  
	-- "whisper" portion
	for j = 1, samples do

		local sample = gaussianNoise() * 100

		sample = resonatorTick( r5, sample )
		sample = resonatorTick( r4, sample )
		sample = resonatorTick( r3, sample )
		sample = resonatorTick( r2, sample )
		sample = resonatorTick( r1, sample )

		buffer[at+j] = buffer[at+j] + sample

	end



end


-----------------------
-- WAVE FILE SUPPORT --
-----------------------


-- Simple wave file library
-- Based on Euphoria source code by Daryl Van Den Brink
-- vandenbrink@micronet.net.au


-- Write a string
function writeString(fn,x)
  fn:write(x)
end


-- Write an integer out as 4 bytes
function writeInt(fn,x)
  local b4=string.char(x%256) 
  x=(x-x%256)/256

  local b3=string.char(x%256) 
  x=(x-x%256)/256

  local b2=string.char(x%256) 
  x=(x-x%256)/256

  local b1=string.char(x%256) 
  x=(x-x%256)/256

  fn:write(b4,b3,b2,b1)
end


-- Write a short integer out as 2 bytes
function writeShort(fn, x)
  local b4=string.char(x%256) 
  x=(x-x%256)/256
  local b3=string.char(x%256)
  fn:write(b4,b3)
end


-- Write an integer out as 3 bytes
function write24Bits(fn,x)    
  local b3=string.char(x%256) 
  x=(x-x%256)/256

  local b2=string.char(x%256) 
  x=(x-x%256)/256

  local b1=string.char(x%256) 
  x=(x-x%256)/256

  fn:write(b3,b2,b1)
end



-- Given integer wavedata, write a monophonic .wav file out at the
-- requested bit resolution (8, 16, or 24 bit).
function writeWaveFile(filename, bits, wavedata)
  -- write wave data to a wave file
  -- return 0 if successful, -1 if the file couldn't be created

  local fn = io.open(filename, "wb")
  if fn == nil then
    return -1
  end

  local channels = 1    -- mono
  local sps = SAMPLE_RATE     -- cd sample rate
  -- local bits = 8        -- bits per sample: 8, 16 or 24
  local wavelen = #wavedata  -- size of data

  local block_align = channels * bits / 8
  local datasize = wavelen * block_align
  local filesize = datasize + 44

  -- RIFF tag
  fn:write("RIFF")

  -- filesize
  writeInt(fn, filesize-8)

  -- WAVE tag
  fn:write("WAVE");

  -- fmt tag
  fn:write("fmt ")
  writeInt(fn, 16)

  writeShort(fn, 1)        -- format tag
  writeShort(fn, channels) -- number of channels
  writeInt(fn, sps)  -- samples per second
  writeInt(fn, sps * block_align)    -- average bytes per second
  writeShort(fn, block_align) -- block align
  writeShort(fn, bits)        -- bits per sample

  -- data tag
  fn:write("data")
  writeInt(fn, datasize)


  -- what size bits?
  if bits == 8 then
    -- loop through the data
    for i=1,wavelen do
      -- change range from -1..1 to 0..255
      local x = math.floor(wavedata[i] * 127) + 128
      fn:write(string.char(x))
    end

  elseif bits == 16 then
    for i=1,wavelen do
      -- get a value

      local x = math.floor(wavedata[i] * 32767)

      -- convert to a positive value
      if x < 0 then
        x = x + 65536
      end

      -- write two bytes
      writeShort(fn, x)        

    end

  elseif bits == 24 then
    for i=1,wavelen do
      -- get a value
      local x = math.floor(wavedata[i] * 8388607)

      -- convert to a positive value
      if x < 0 then
        x = x + 16777216
      end

      -- write 3 bytes
      write24Bits(fn, x)

    end

  end

  io.close(fn)

end



-- Normalize the data so the max/minimum is between scale..-scale
function normalize(data, scale)

  -- if scale is not specified, use 1.0
  if scale == nil then
    scale = 1.0
  end

  -- find largest value in the table
  local largest = 0
  for i = 1, #data do
    local n = math.abs(data[i])
    if n > largest then
      largest = n
    end
  end

  -- don't divide by zero
  if largest == 0 then
    return
  end


  -- scale the data
  for i = 1, #data do
    data[i] = scale * (data[i] / largest)
  end

end


---------------------
-- RENDER THE DATA --
---------------------


local function render( outFilePath )

	local f1, f2, f3, a1, a2, a3 = 0, 0, 0, 0, 0, 0

	local buffer = {}

	-- initialize tick
	initTick()

	local length = 0
	local time = 0
	while true do
		-- find the parameters at this point
		tick(length)

		-- at the end?
		if my.at > #outIndex then
			break
		end

		-- get the current phone
		local thisPhone = pData[outIndex[my.at]]
		local priorPhone = nil

		-- in transition?
		if my.transitionLeft > 0 then
			-- set prior phone if there's a transition
			priorPhone = pData[outIndex[my.at-1]]
		end

		-- get position in buffer before rendering
		local bufferWasAt = #buffer or 1

		-- current phoneme unvoiced?
		local unvoiced = (thisPhone.a1 == 0 and thisPhone.a2 == 0 and thisPhone.a3 == 0) or thisPhone.fricFrq
		if unvoiced and priorPhone then
			-- transition phoneme unvoiced?
			unvoiced = (priorPhone.a1 == 0 and priorPhone.a2 == 0 and priorPhone.a3 == 0) or priorPhone.fricFrq
		end

		-- unvoiced sustain?
		if unvoiced then

			-- in transition, or sustain?
			if my.transitionLeft > 0 then
				length = my.transitionLeft
			else
				length = my.sustainLeft
			end

			-- render silence into buffer
			synthesizeSilence( buffer, length )

		else
			-- calculate the length of one cycle
			length = 1/my.f0

			-- get the formant frequencies and amplitudes
			if priorPhone then
				-- non-linear movement
				local t = my.t --* my.t

				-- change range from 0..1 to -PI...PI
				t = math.pi * (t*2-1)

				-- get hyperbolic tangent value
				t = math.tanh(t)

				-- change range from -1..1 to 0..1
				t = (t+1)/2

				-- amplitudes
				if thisPhone.fricFreq then
					-- moving from voiced to unvoiced
					f1 = priorPhone.f1
					f2 = priorPhone.f2
					f3 = priorPhone.f3

					a1 = priorPhone.a1 * (t-1)
					a2 = priorPhone.a2 * (t-1)
					a3 = priorPhone.a3 * (t-1)

				elseif priorPhone.fricFreq then
					-- moving from unvoiced to voiced
					f1 = thisPhone.f1
					f2 = thisPhone.f2
					f3 = thisPhone.f3

					a1 = thisPhone.a1 * t
					a2 = thisPhone.a2 * t
					a3 = thisPhone.a3 * t
				else
					-- both are voiced
					f1 = lerp( priorPhone.f1, thisPhone.f1, t)
					f2 = lerp( priorPhone.f2, thisPhone.f2, t)
					f3 = lerp( priorPhone.f3, thisPhone.f3, t)

					a1 = lerp( priorPhone.a1, thisPhone.a1, t)
					a2 = lerp( priorPhone.a2, thisPhone.a2, t)
					a3 = lerp( priorPhone.a3, thisPhone.a3, t)
				end
			else
				-- no transition
				f1 = thisPhone.f1
				f2 = thisPhone.f2
				f3 = thisPhone.f3

				a1 = thisPhone.a1
				a2 = thisPhone.a2
				a3 = thisPhone.a3
			end

			-- render a wave of the given frequency
			synthesizeVoiced( buffer, my.f0, f1, f2, f3, a1, a2, a3 )

		end

		-- is this a transition?
		if priorPhone then
			-- transition

			-- transition out of prior phone's fricative?
			if priorPhone.fricFrq and priorPhone.fricAmp > 0 then
				-- render the first fricative, fading out
				synthesizeFrication( buffer, bufferWasAt, priorPhone.fricFrq, priorPhone.fricBw, priorPhone.fricAmp, 0 )
			end

			-- transition into phone2's fricative?
			if thisPhone.fricFrq and thisPhone.fricAmp > 0 then
				-- render the second fricative, fading in
				synthesizeFrication( buffer, bufferWasAt, thisPhone.fricFrq, thisPhone.fricBw, 0, thisPhone.fricAmp )
			end

		else
			-- is there frication?
			if thisPhone.fricFrq then
				local a = 1
				-- render the fricative
				synthesizeFrication( buffer, bufferWasAt, thisPhone.fricFrq, thisPhone.fricBw, thisPhone.fricAmp, thisPhone.fricAmp )
			end

		end

		-- debug
    if debugFlag then
		  print(math.floor(time*1000)/1000, my.at, thisPhone.token, math.floor(f1), math.floor(f2), math.floor(f3) )
    end

		-- advance clock
		time = time + length
	end

	-- normalize
	print("Normalizing audio data...")
	normalize( buffer )

	-- render
	print("Writing wave file...")
	writeWaveFile( outFilePath, 24, buffer )

end



-- Read a text file **filePath**, returning a table of lines from the file.
function readFile(filePath)
  -- open the file
  local f = assert(io.open(filePath, "rb"))

  -- no file found?
  if f == nil then 
    error("File '"..filePath.."' not found")
  end

  -- get the file contents
  local content = f:read("*all")

  -- close the file
  f:close()

  -- return the file contents
  return content

end

------------------
-- MAIN ROUTINE --
------------------


local function main( songName )

  -- read the .pho file
  local pho = readFile( songName..".pho" )

	-- parse the file
	parsePho(pho)

	-- apply the allophones
	applyAllophones()

	-- expand the phonemes
	expandPhonemes()

	-- remove duplicate phonemes
	removeDuplicateConsonants()

	-- calculate duration of phonemes
	calculateTimings()

	-- set the initial pitch
	setInitialPitch()

	-- set following pitches
	setFollowingPitches()

	-- create and adjust transitions
	createTransitions()
	adjustTransitions()

	-- print the results
	for i = 1, #outIndex do
		local p = outIndex[i]
		print( i,
			p,
			pData[p].token,
			pData[p].length*secondsPerFrame,
			outPitch[i],
			outLength[i],
			outBlendLeft[i],
			outBlendRight[i]
		)
	end

	-- render the waves
	render( songName..".wav" )

  print("Completed.")

end

main( songName )