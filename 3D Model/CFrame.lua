local Vector3 = require("Vector3")

local CFrame = {}
CFrame.__index = CFrame

setmetatable(CFrame, {	
	__call = function(class, ...)
		return class.new(...)
	end
})

local mSin = math.sin
local mCos = math.cos

local function multMatrices(matrix1, matrix2, ...)
	local resultMatrix = {}
	for row = 1,#matrix1 do
		local resultRow = {}
		for column = 1, #matrix2[1] do
			local dotProduct = 0
			for entry = 1,#matrix2[1] do
				dotProduct = dotProduct + matrix1[row][entry] * matrix2[entry][column]
			end
			table.insert(resultRow, dotProduct)
		end
		table.insert(resultMatrix, resultRow)
	end
	if select("#", ...)>0 then
		resultMatrix = multMatrices(resultMatrix, ...)
	end
	
	return resultMatrix
end

function CFrame.new(pos, rot)
	pos = pos or Vector3()
	rot = rot or Vector3()

	local position = {
		{1, 0, 0, pos.X},
		{0, 1, 0, pos.Y},
		{0, 0, 1, pos.Z},
		{0, 0, 0, 1},
	}
	local rotationX = {
		{1, 0, 0, 0},
		{0, mCos(rot.X), mSin(rot.X), 0},
		{0, -mSin(rot.X), mCos(rot.X), 0},
		{0, 0, 0, 1},
	}
					
	local rotationY = {
		{mCos(rot.Y), 0, -mSin(rot.Y), 0},
		{0, 1, 0, 0},
		{mSin(rot.Y), 0, mCos(rot.Y), 0},
		{0, 0, 0, 1},
	}
					
	local rotationZ = {
		{mCos(rot.Z), mSin(rot.Z), 0, 0},
		{-mSin(rot.Z), mCos(rot.Z), 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	}
	
	local self = setmetatable(multMatrices(rotationX, rotationY, rotationZ, position), CFrame)
	
	return self
end

function CFrame:getPosition()
	return Vector3(self[1][4], self[2][4], self[3][4])
end

CFrame.__mul = function(cf1, cf2)
	return setmetatable(multMatrices(cf1, cf2), CFrame)
end

return CFrame