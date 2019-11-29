//Dirty code

//main.lua

function multMatrix(m1,m2,...)
	local mT = {}
	for i=1,#m1 do
		local ins = {}
		for n=1, #m2[1] do
			local xX = 0
			for q=1,#m2[1] do
				xX = xX + m1[i][q]*m2[q][n]
			end
			table.insert(ins,xX)
		end
		table.insert(mT,ins)
	end
	if ...~=nil then
		mT = multMatrix(mT, ...)
	end
	return mT
end

function vectorTranslate(p,r,t)
	local pS = {
						{1,0,0, p[1]},
						{0,1,0, p[2]},
						{0,0,1, p[3]},
						{0,0,0, 1},
					}
	local rX = {
						{1,									0,									0,									0},
						{0,									math.cos(math.rad(r[1])),	math.sin(math.rad(r[1])),	0},
						{0,									-math.sin(math.rad(r[1])),	math.cos(math.rad(r[1])),	0},
						{0,									0,									0,									1},
					}
					
	local rY = {
						{math.cos(math.rad(r[2])),		0,									-math.sin(math.rad(r[2])),	0},
						{0,									1,									0,									0},
						{math.sin(math.rad(r[2])),		0,									math.cos(math.rad(r[2])),	0},
						{0,									0,									0,									1},
					}
					
	local rZ = {
						{math.cos(math.rad(r[3])),		math.sin(math.rad(r[3])),	0,									0},
						{-math.sin(math.rad(r[3])),	math.cos(math.rad(r[3])),	0,									0},
						{0,									0,									1,									0},
						{0,									0,									0,									1},
					}
					
	local tR = {
						{1,									0,									0,									t[1]},
						{0,									1,									0,									t[2]},
						{0,									0,									1,									t[3]},
						{0,									0,									0,									1},
					}
	
	local newM = multMatrix(tR,rX,rY,rZ,pS)
	return {newM[1][4], newM[2][4], newM[3][4]}
end

local rot = {0,0,0}

local parts = {}

local pts = {	{100, 100, 100},
					{100, -100, 100},
					{-100, -100, 100},
					{-100, 100, 100},
					{100, 100, -100},
					{100, -100, -100},
					{-100, -100, -100},
					{-100, 100, -100}
				}
local dir = {	{1,0,0},
					{-1,0,0},
					{0,1,0},
					{0,-1,0},
					{0,0,1},
					{0,0,-1},
				}

function newSide(set, pt1, pt2, pt3, pt4, color)

	local part = display.newPolygon(0,0,{set[pt1][1],set[pt1][2],set[pt2][1],set[pt2][2],set[pt3][1],set[pt3][2],set[pt4][1],set[pt4][2]})
	local mux = math.max(set[pt1][1],set[pt2][1],set[pt3][1],set[pt4][1])
	local muy = math.max(set[pt1][2],set[pt2][2],set[pt3][2],set[pt4][2])
	local mlx = math.min(set[pt1][1],set[pt2][1],set[pt3][1],set[pt4][1])
	local mly = math.min(set[pt1][2],set[pt2][2],set[pt3][2],set[pt4][2])
	part.x = display.contentWidth/2 + (mux+mlx)/2
	part.y = display.contentHeight/2 + (muy+mly)/2
	part:setFillColor(unpack(color))
	table.insert(parts,part)

	return
end

function reDraw()
	for i=#parts,1,-1 do
		if parts[i]~=nil then
			parts[i]:removeSelf()
			parts[i] = nil
		end
	end
	local ptSet = {}
	local dirSet = {}
	for _,v in pairs(pts) do
		table.insert(ptSet,vectorTranslate(v,rot,{0,0,0}))
	end
	for i,v in pairs(dir) do
		table.insert(dirSet,{vectorTranslate(v,rot,{0,0,0}),i})
	end
	
	local sortZ = {}
	for i=1,6 do
		local setZ = dirSet[1][1][3]
		local setIndex = 1
		for i,v in pairs(dirSet) do
			if v[1][3] < setZ then
				setZ = v[1][3]
				setIndex = i
			end
		end
		table.insert(sortZ,dirSet[setIndex][2])
		table.remove(dirSet, setIndex)
	end
	for _,v in pairs(sortZ) do
		if v==1 then
			newSide(ptSet, 1,5,6,2, {1,0,0})
		elseif v==2 then
			newSide(ptSet, 4,8,7,3, {1,0,0})
		elseif v==3 then
			newSide(ptSet, 1,5,8,4, {0,1,0})
		elseif v==4 then
			newSide(ptSet, 2,6,7,3, {0,1,0})
		elseif v==5 then
			newSide(ptSet, 1,2,3,4, {0,0,1})
		else
			newSide(ptSet, 5,6,7,8, {0,0,1})
		end
	end
	
end

local prevX = 0
local prevY = 0
Runtime:addEventListener("touch", function(event)
	if event.phase == "moved" then
		rot = {rot[1]+(event.y-prevY), rot[2]+(event.x-prevX), 0}
		reDraw()
		prevX = event.x
		prevY = event.y
	elseif event.phase == "began" then
		prevX = event.x
		prevY = event.y	
	end
end)




