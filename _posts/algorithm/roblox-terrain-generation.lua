local rock = 6
local snow = 4
local ice = 7
local grass = 1
local ground = 18
local mud = 10
local slate = 13
local concrete = 14
local lava = 8
local basalt = 20
local air = 0
local sand = 5
local sandstone = 17
local water = 3

local noise = math.noise
local min = math.min
local max = math.max
local sin = math.sin
local cos = math.cos
local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt
local randomseed = math.randomseed
local random = math.random
local pi = math.pi
local tau = math.pi*2

-- original code by Ken Perlin: http://mrl.nyu.edu/~perlin/noise/
local function BitAND(a,b)--Bitwise and
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

perlin = {}
perlin.p = {}
perlin.permutation = { 151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}
perlin.size = 256
perlin.gx = {}
perlin.gy = {}
perlin.randMax = 256

function perlin:load(  )
    for i=1,self.size do
        self.p[i] = self.permutation[i]
        self.p[255+i] = self.p[i]
    end
end

function perlin:noise( x, y, z )
    local X = BitAND(math.floor(x), 255) + 1
    local Y = BitAND(math.floor(y), 255) + 1
    local Z = BitAND(math.floor(z), 255) + 1

    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)
    local u = fade(x)
    local v = fade(y)
    local w = fade(z)
    local A  = self.p[X]+Y
    local AA = self.p[A]+Z
    local AB = self.p[A+1]+Z
    local B  = self.p[X+1]+Y
    local BA = self.p[B]+Z
    local BB = self.p[B+1]+Z

    return lerp(w, lerp(v, lerp(u, grad(self.p[AA  ], x  , y  , z  ),
                                   grad(self.p[BA  ], x-1, y  , z  )),
                           lerp(u, grad(self.p[AB  ], x  , y-1, z  ),
                                   grad(self.p[BB  ], x-1, y-1, z  ))),
                   lerp(v, lerp(u, grad(self.p[AA+1], x  , y  , z-1),
                                   grad(self.p[BA+1], x-1, y  , z-1)),
                           lerp(u, grad(self.p[AB+1], x  , y-1, z-1),
                                   grad(self.p[BB+1], x-1, y-1, z-1))))
end


function fade( t )
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function lerp( t, a, b )
    return a + t * (b - a)
end

function grad( hash, x, y, z )
    local h = BitAND(hash, 15)
    local u = h < 8 and x or y
    local v = h < 4 and y or ((h == 12 or h == 14) and x or z)
    return ((h and 1) == 0 and u or -u) + ((h and 2) == 0 and v or -v)
end

local masterSeed = 618033988
local mapWidth = 30
local mapHeight = 30
local biomeSize = 100
local generateCaves = false
local waterLevel = .48
local surfaceThickness = .018
local biomes = {}

randomseed(6180339)
theseed={}
for i=1,999 do
	table.insert(theseed,math.random())
end
perlin:load()

local function getNoise(x,y,z,seed1)
	local x = x or 0
	local y = y or 0
	local z = z or 0
	local seed1 = seed1 or 7
	local wtf=x+y+z+seed1+masterSeed + (masterSeed-x)*(seed1+z) + (seed1-y)*(masterSeed+z)		-- + x*(y+z) + z*(masterSeed+seed1) + seed1*(x+y)			--x+y+z+seed1+masterSeed + x*y*masterSeed-y*z+(z+masterSeed)*x	--((x+y)*(y-seed1)*seed1)-(x+z)*seed2+x*11+z*23-y*17
	return theseed[(floor(wtf%(#theseed)))+1]
end

local function getPerlin(x,y,z,seed,scale,raw)
	local seed = seed or 0
	local scale = scale or 1
	if not raw then
		return perlin:noise(x/scale+(seed*17)+masterSeed,y/scale-masterSeed,z/scale-seed*seed)*.5 + .5 -- accounts for bleeding from interpolated line
	else
		return perlin:noise(x/scale+(seed*17)+masterSeed,y/scale-masterSeed,z/scale-seed*seed)
	end
end

local function thresholdFilter(value, bottom, size)
	if value <= bottom then
		return 0
	elseif value >= bottom+size then
		return 1
	else
		return (value-bottom)/size
	end
end

local function ridgedFilter(value)	--absolute and flip for ridges. and normalize
	return value<.5 and value*2 or 2-value*2
end

local function ridgedFlippedFilter(value)					--unflipped
	return value < .5 and 1-value*2 or value*2-1
end

local function advancedRidgedFilter(value, cutoff)
	local cutoff = cutoff or .5
	value = value - cutoff
	return 1 - (value < 0 and -value or value) * 1/(1-cutoff)
end


local function fractalize(operation,x,y,z, operationCount, scale, offset, gain)
	local operationCount = operationCount or 3
	local scale = scale or .5
	local offset = 0
	local gain = gain or 1
	local totalValue = 0
	local totalScale = 0
	for i=1, operationCount do
		local thisScale = scale^(i-1)
		totalScale = totalScale + thisScale
		totalValue = totalValue + (offset + gain * operation(x,y,z,i))*thisScale
	end
	return totalValue/totalScale
end


local function mountainsOperation(x,y,z,i)
	return ridgedFilter(getPerlin(x,y,z,100+i,(1/i)*160))
end

local canyonBandingMaterial = {rock,mud,sand,sand,sandstone,sandstone,sandstone,sandstone,sandstone,sandstone,}

local function findBiomeInfo(choiceBiome,x,y,z,verticalGradientTurbulence)
	local choiceBiomeValue = .5
	local choiceBiomeSurface = grass
	local choiceBiomeFill = rock
	if choiceBiome == 'City' then
		choiceBiomeValue = .55
		choiceBiomeSurface = concrete
		choiceBiomeFill = slate
	elseif choiceBiome == 'Water' then
		choiceBiomeValue = .36+getPerlin(x,y,z,2,50)*.08
		choiceBiomeSurface = 
			(1-verticalGradientTurbulence < .44 and slate)
			or sand
	elseif choiceBiome == 'Marsh' then
		local preLedge = getPerlin(x+getPerlin(x,0,z,5,7,true)*10+getPerlin(x,0,z,6,30,true)*50,0,z+getPerlin(x,0,z,9,7,true)*10+getPerlin(x,0,z,10,30,true)*50,2,70)	--could use some turbulence
		local grassyLedge = thresholdFilter(preLedge,.65,0)
		local largeGradient = getPerlin(x,y,z,4,100)
		local smallGradient = getPerlin(x,y,z,3,20)
		local smallGradientThreshold = thresholdFilter(smallGradient,.5,0)
		choiceBiomeValue = waterLevel-.04
			+preLedge*grassyLedge*.025
			+largeGradient*.035
			+smallGradient*.025
		choiceBiomeSurface =
			(grassyLedge >= 1 and grass)
			or (1-verticalGradientTurbulence < waterLevel-.01 and mud)
			or (1-verticalGradientTurbulence < waterLevel+.01 and ground)
			or grass
		choiceBiomeFill = slate
	elseif choiceBiome == 'Plains' then
		local rivulet = ridgedFlippedFilter(getPerlin(x+getPerlin(x,y,z,17,40)*25,0,z+getPerlin(x,y,z,19,40)*25,2,200))
		local rivuletThreshold = thresholdFilter(rivulet,.01,0)

		local rockMap = thresholdFilter(ridgedFlippedFilter(getPerlin(x,0,z,101,7)),.3,.7)		--rocks
			 * thresholdFilter(getPerlin(x,0,z,102,50),.6,.05)									--zoning

		choiceBiomeValue = .5			--.51
		+getPerlin(x,y,z,2,100)*.02		--.05
		+rivulet*.05					--.02
		+rockMap*.05		--.03
		+rivuletThreshold*.005

		local verticalGradient = 1-((y-1)/(mapHeight-1))
		local surfaceGradient = verticalGradient*.5 + choiceBiomeValue*.5
		local thinSurface = surfaceGradient > .5-surfaceThickness*.4 and surfaceGradient < .5+surfaceThickness*.4
		choiceBiomeSurface =
			(rockMap>0 and rock)
			or (not thinSurface and mud)
			or (thinSurface and rivuletThreshold <=0 and water)
			or (1-verticalGradientTurbulence < waterLevel-.01 and sand)
			or grass
		choiceBiomeFill =
			(rockMap>0 and rock)
			or sandstone
	elseif choiceBiome == 'Canyons' then
		local canyonNoise = ridgedFlippedFilter(getPerlin(x,0,z,2,200))
		local canyonNoiseTurbed = ridgedFlippedFilter(getPerlin(x+getPerlin(x,0,z,5,20,true)*20,0,z+getPerlin(x,0,z,9,20,true)*20,2,200))
		local sandbank = thresholdFilter(canyonNoiseTurbed,0,.05)
		local canyonTop = thresholdFilter(canyonNoiseTurbed,.125,0)
		local mesaSlope = thresholdFilter(canyonNoise,.33,.12)
		local mesaTop = thresholdFilter(canyonNoiseTurbed,.49,0)
		choiceBiomeValue = .42
			+getPerlin(x,y,z,2,70)*.05
			+canyonNoise*.05
			+sandbank*.04										--canyon bottom slope
			+thresholdFilter(canyonNoiseTurbed,.05,0)*.08		--canyon cliff
			+thresholdFilter(canyonNoiseTurbed,.05,.075)*.04	--canyon cliff top slope
			+canyonTop*.01										--canyon cliff top ledge

			+thresholdFilter(canyonNoiseTurbed,.0575,.2725)*.01	--plane slope

			+mesaSlope*.06			--mesa slope
			+thresholdFilter(canyonNoiseTurbed,.45,0)*.14		--mesa cliff
			+thresholdFilter(canyonNoiseTurbed,.45,.04)*.025	--mesa cap
			+mesaTop*.02										--mesa top ledge
		choiceBiomeSurface =
			(1-verticalGradientTurbulence < waterLevel+.015 and sand)		--this for biome blending in to lakes
			or (sandbank>0 and sandbank<1 and sand)							--this for canyonbase sandbanks
			--or (canyonTop>0 and canyonTop<=1 and mesaSlope<=0 and grass)		--this for grassy canyon tops
			--or (mesaTop>0 and mesaTop<=1 and grass)							--this for grassy mesa tops
			or sandstone
		choiceBiomeFill = canyonBandingMaterial[ceil((1-getNoise(1,y,2))*10)]
	elseif choiceBiome == 'Hills' then
		local rivulet = ridgedFlippedFilter(getPerlin(x+getPerlin(x,y,z,17,20)*20,0,z+getPerlin(x,y,z,19,20)*20,2,200))^(1/2)
		local largeHills = getPerlin(x,y,z,3,60)
		choiceBiomeValue = .48
			+largeHills*.05
				+(.05
				+largeHills*.1
				+getPerlin(x,y,z,4,25)*.125)
				*rivulet
		local surfaceMaterialGradient = (1-verticalGradientTurbulence)*.9 + rivulet*.1
		choiceBiomeSurface =
			(surfaceMaterialGradient < waterLevel-.015 and mud)
			or (surfaceMaterialGradient < waterLevel and ground)
			or grass
		choiceBiomeFill = slate
	elseif choiceBiome == 'Dunes' then
		local duneTurbulence = getPerlin(x,0,z,227,20)*24
		local layer1 = ridgedFilter(getPerlin(x,0,z,201,40))
		local layer2 = ridgedFilter(getPerlin(x/10+duneTurbulence,0,z+duneTurbulence,200,48))
		choiceBiomeValue = .4+.1*(layer1 + layer2)
		choiceBiomeSurface = sand
		choiceBiomeFill = sandstone
	elseif choiceBiome == 'Mountains' then
		local rivulet = ridgedFlippedFilter(getPerlin(x+getPerlin(x,y,z,17,20)*20,0,z+getPerlin(x,y,z,19,20)*20,2,200))
		choiceBiomeValue = -.4		--.3
			+fractalize(mountainsOperation,x,y/20,z, 8, .65)*1.2
			+rivulet*.2
		choiceBiomeSurface =
			(verticalGradientTurbulence < .275 and snow)
			or (verticalGradientTurbulence < .35 and rock)
			or (verticalGradientTurbulence < .4 and ground)
			or (1-verticalGradientTurbulence < waterLevel and rock)
			or (1-verticalGradientTurbulence < waterLevel+.01 and mud)
			or (1-verticalGradientTurbulence < waterLevel+.015 and ground)
			or grass
	elseif choiceBiome == 'Lavaflow' then
		local crackX = x+getPerlin(x,y*.25,z,21,8,true)*5
		local crackY = y+getPerlin(x,y*.25,z,22,8,true)*5
		local crackZ = z+getPerlin(x,y*.25,z,23,8,true)*5
		local crack1 = ridgedFilter(getPerlin(crackX+getPerlin(x,y,z,22,30,true)*30,crackY,crackZ+getPerlin(x,y,z,24,30,true)*30,2,120))
		local crack2 = ridgedFilter(getPerlin(crackX,crackY,crackZ,3,40))*(crack1*.25+.75)
		local crack3 = ridgedFilter(getPerlin(crackX,crackY,crackZ,4,20))*(crack2*.25+.75)

		local generalHills = thresholdFilter(getPerlin(x,y,z,9,40),.25,.5)*getPerlin(x,y,z,10,60)

		local cracks = max(0,1-thresholdFilter(crack1,.975,0)-thresholdFilter(crack2,.925,0)-thresholdFilter(crack3,.9,0))

		local spireVec = CFrame.Angles(.7,.7,0)*Vector3.new(crackX,crackY,crackZ)
		local spires = thresholdFilter(getPerlin(spireVec.x/40,spireVec.y/300,spireVec.z/30,123,1),.6,.4)

		choiceBiomeValue = waterLevel+.02
			+cracks*(.5+generalHills*.5)*.02
			+generalHills*.05
			+spires*.3
			+((1-verticalGradientTurbulence > waterLevel+.01 or spires>0) and .04 or 0)			--This lets it lip over water

		choiceBiomeFill = (spires>0 and rock) or (cracks<1 and lava) or basalt
		choiceBiomeSurface = (choiceBiomeFill == lava and 1-verticalGradientTurbulence < waterLevel and basalt) or choiceBiomeFill
	elseif choiceBiome == 'Arctic' then
		local preBoundary = getPerlin(x+getPerlin(x,0,z,5,8,true)*5,y/8,z+getPerlin(x,0,z,9,8,true)*5,2,20)
		--local cliffs = thresholdFilter(preBoundary,.5,0)
		local boundary = ridgedFilter(preBoundary)
		local roughChunks = getPerlin(x,y/4,z,436,2)
		local boundaryMask = thresholdFilter(boundary,.8,.1)	--,.7,.25)
		local boundaryTypeMask = getPerlin(x,0,z,6,74)-.5
		local boundaryComp = 0
		if boundaryTypeMask < 0 then							--divergent
			boundaryComp = (boundary > (1+boundaryTypeMask*.5) and -.17 or 0)
							--* boundaryTypeMask*-2
		else													--convergent
			boundaryComp = boundaryMask*.1*roughChunks
							* boundaryTypeMask
		end
		choiceBiomeValue = .55
			+boundary*.05*boundaryTypeMask		--.1	--soft slope up or down to boundary
			+boundaryComp								--convergent/divergent effects
			+getPerlin(x,0,z,123,25)*.025	--*cliffs	--gentle rolling slopes

		choiceBiomeSurface = (1-verticalGradientTurbulence < waterLevel-.1 and ice) or (boundaryMask>.6 and boundaryTypeMask>.1 and roughChunks>.5 and ice) or snow
		choiceBiomeFill = ice
	end
	return choiceBiomeValue, choiceBiomeSurface, choiceBiomeFill
end

function findBiomeTransitionValue(biome,weight,value,averageValue)
	if biome == 'Arctic' then
		return (weight>.2 and 1 or 0)*value
	elseif biome == 'Canyons' then
		return (weight>.7 and 1 or 0)*value
	elseif biome == 'Mountains' then
		local weight = weight^3			--This improves the ease of mountains transitioning to other biomes
		return averageValue*(1-weight)+value*weight
	else
		return averageValue*(1-weight)+value*weight
	end
end

local allBiomes = {
	['Mountains'] = true,
	['Canyons'] = false,
	['Dunes'] = false,
	['Arctic'] = false,
	['Lavaflow'] = false,
	['Hills'] = true,
	['Plains'] = true,
	['Marsh'] = false,
	['Water'] = false,
}

function writeFile(content)
	local f = assert(io.open('roblox.txt', 'a+'))
	f:wirte(content)
	f:close()
end

function generate()
		local mapWidth = mapWidth
		local biomeSize = biomeSize
		local biomeBlendPercent = .25	--(biomeSize==50 or biomeSize == 100) and .5 or .25
		local biomeBlendPercentInverse = 1-biomeBlendPercent
		local biomeBlendDistortion = biomeBlendPercent
		local smoothScale = .5/mapHeight

		biomes = {}
		for i,v in pairs(allBiomes) do
			if v then
				table.insert(biomes,i)
			end
		end
		if #biomes<=0 then
			--table.insert(biomes,'Hills')
			--table.insert(biomes, 'Mountains')
			table.insert(biomes, 'Dunes')
		end
		--local oMap = {}
		--local mMap = {}
		for x = 1, mapWidth do
			local oMapX = {}
			--oMap[x] = oMapX
			local mMapX = {}
			--mMap[x] = mMapX
			for z = 1, mapWidth do
				local biomeNoCave = false
				local cellToBiomeX = x/biomeSize + getPerlin(x,0,z,233,biomeSize*.3)*.25 + getPerlin(x,0,z,235,biomeSize*.05)*.075
				local cellToBiomeZ = z/biomeSize + getPerlin(x,0,z,234,biomeSize*.3)*.25 + getPerlin(x,0,z,236,biomeSize*.05)*.075
				local closestPoint = {0,0,0}
				local closestDistance = 1000000
				local biomePoints = {}
				for vx=-1,1 do
					for vz=-1,1 do
						local gridPointX = floor(cellToBiomeX+vx+.5)
						local gridPointZ = floor(cellToBiomeZ+vz+.5)
						--local pointX, pointZ = getBiomePoint(gridPointX,gridPointZ)
						local pointX = gridPointX+(getNoise(gridPointX,gridPointZ,53)-.5)*.75	--de-uniforming grid for vornonoi
						local pointZ = gridPointZ+(getNoise(gridPointX,gridPointZ,73)-.5)*.75

						local dist = sqrt((pointX-cellToBiomeX)^2 + (pointZ-cellToBiomeZ)^2)
						if dist < closestDistance then
							closestPoint = {pointX,0,pointZ}
							closestDistance = dist
						end
						table.insert(biomePoints,{
							x = pointX,
							z = pointZ,
							dist = dist,
							biomeNoise = getNoise(gridPointX,gridPointZ),
							weight = 0
						})
					end
				end
				local weightTotal = 0
				local weightPoints = {}
				for _,point in pairs(biomePoints) do
					local weight = point.dist == closestDistance and 1 or ((closestDistance / point.dist)-biomeBlendPercentInverse)/biomeBlendPercent
					if weight > 0 then
						local weight = weight^2.1		--this smooths the biome transition from linear to cubic InOut
						weightTotal = weightTotal + weight
						local biome = biomes[ceil(#biomes*(1-point.biomeNoise))]	--inverting the noise so that it is limited as (0,1]. One less addition operation when finding a random list index
						weightPoints[biome] = {
							weight = weightPoints[biome] and weightPoints[biome].weight + weight or weight
						}
					end
				end
				for biome,info in pairs(weightPoints) do
					info.weight = info.weight / weightTotal
					if biome == 'Arctic' then		--biomes that don't have caves that breach the surface
						biomeNoCave = true
					end
				end


				for y = 1, mapHeight do
					local oMapY = oMapX[y] or {}
					oMapX[y] = oMapY
					local mMapY = mMapX[y] or {}
					mMapX[y] = mMapY

					--[[local oMapY = {}
					oMapX[y] = oMapY
					local mMapY = {}
					mMapX[z] = mMapY]]


					local verticalGradient = 1-((y-1)/(mapHeight-1))
					local caves = 0
					local verticalGradientTurbulence = verticalGradient*.9 + .1*getPerlin(x,y,z,107,15)
					local choiceValue = 0
					local choiceSurface = lava
					local choiceFill = rock
	
					if verticalGradient > .65 or verticalGradient < .1 then
						--under surface of every biome; don't get biome data; waste of time.
						choiceValue = .5
					elseif #biomes == 1 then
						choiceValue, choiceSurface, choiceFill = findBiomeInfo(biomes[1],x,y,z,verticalGradientTurbulence)
					else
						local averageValue = 0
						--local findChoiceMaterial = -getNoise(x,y,z,19)
						for biome,info in pairs(weightPoints) do
							local biomeValue, biomeSurface, biomeFill = findBiomeInfo(biome,x,y,z,verticalGradientTurbulence)
							info.biomeValue = biomeValue
							info.biomeSurface = biomeSurface
							info.biomeFill = biomeFill
							local value = biomeValue * info.weight
							averageValue = averageValue + value
							--[[if findChoiceMaterial < 0 and findChoiceMaterial + weight >= 0 then
								choiceMaterial = biomeMaterial
							end
							findChoiceMaterial = findChoiceMaterial + weight]]
						end
						for biome,info in pairs(weightPoints) do
							local value = findBiomeTransitionValue(biome,info.weight,info.biomeValue,averageValue)
							if value > choiceValue then
								choiceValue = value
								choiceSurface = info.biomeSurface
								choiceFill = info.biomeFill
							end
						end
					end

					local preCaveComp = verticalGradient*.5 + choiceValue*.5

					local surface = preCaveComp > .5-surfaceThickness and preCaveComp < .5+surfaceThickness

					if generateCaves																--user wants caves
						and (not biomeNoCave or verticalGradient > .65)								--biome allows caves or deep enough
							and not (surface and (1-verticalGradient) < waterLevel+.005)			--caves only breach surface above waterlevel
								and not (surface and (1-verticalGradient) > waterLevel+.58) then	--caves don't go too high so that they don't cut up mountain tops
									local ridged2 = ridgedFilter(getPerlin(x,y,z,4,30))
									local caves2 = thresholdFilter(ridged2,.84,.01)
									local ridged3 = ridgedFilter(getPerlin(x,y,z,5,30))
									local caves3 = thresholdFilter(ridged3,.84,.01)
									local ridged4 = ridgedFilter(getPerlin(x,y,z,6,30))
									local caves4 = thresholdFilter(ridged4,.84,.01)
									local caveOpenings = (surface and 1 or 0) * thresholdFilter(getPerlin(x,0,z,143,62),.35,0)	--.45
									caves = caves2 * caves3 * caves4 - caveOpenings
									caves = caves < 0 and 0 or caves > 1 and 1 or caves
					end

					local comp = preCaveComp - caves

					local smoothedResult = thresholdFilter(comp,.5,smoothScale)

					---below water level				  -above surface		-no terrain
					if 1-verticalGradient < waterLevel and preCaveComp <= .5 and smoothedResult <= 0 then
						smoothedResult = 1
						choiceSurface = water
						choiceFill = water
						surface = true
					end

					oMapY[z] = (y == 1 and 1) or smoothedResult
					mMapY[z] = (y == 1 and lava) or (smoothedResult <= 0 and air) or (surface and choiceSurface) or choiceFill
					
					--sdf and material
					--print(x, y, z, oMapY[z], mMapY[z]);
					writeFile(x, y, z, oMapY[z], mMapY[z]);
				end
			end
		end
		--print('Generation Complete')
end

generate()