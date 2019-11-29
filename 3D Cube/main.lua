--[[
3D Cube
main.lua

(c) Amos Cabudol
Created 12/08/2015
Updated 11/28/2019
]]

local mSin = math.sin
local mCos = math.cos

local COLORS = {
	Red		= {1, 0, 0},
	Green	= {0, 1, 0},
	Blue	= {0, 0, 1}
}

--Matrix multiplication
function multiplyMatrices(matrix1, matrix2, ...)
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
		resultMatrix = multiplyMatrices(resultMatrix, ...)
	end
	return resultMatrix
end

--3D Vector Contstructor
local function Vector3D(x, y, z)
	local self = {}
	self.X = x or 0
	self.Y = y or 0
	self.Z = z or 0
	return self
end

--Coordinate Frame Constructor
local function genCoordinateFrame(pos, rot)
	pos = pos or Vector3D()
	rot = rot or Vector3D()

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
	
	return multiplyMatrices(rotationX, rotationY, rotationZ, position)
end

--Cube Mesh Constructor
local function newCube(cubeScale)
	local self = {}

	self.Vertices = {
		Vector3D(cubeScale/2, cubeScale/2, cubeScale/2),
		Vector3D(cubeScale/2, -cubeScale/2, cubeScale/2),
		Vector3D(-cubeScale/2, -cubeScale/2, cubeScale/2),
		Vector3D(-cubeScale/2, cubeScale/2, cubeScale/2),
		Vector3D(cubeScale/2, cubeScale/2, -cubeScale/2),
		Vector3D(cubeScale/2, -cubeScale/2, -cubeScale/2),
		Vector3D(-cubeScale/2, -cubeScale/2, -cubeScale/2),
		Vector3D(-cubeScale/2, cubeScale/2, -cubeScale/2)
	}

	self.Faces = {
		{1, 5, 6, 2},
		{4, 8, 7, 3},
		{1, 5, 8, 4},
		{2, 6, 7, 3},
		{1, 2, 3, 4},
		{5, 6, 7, 8}
	}

	self.FaceNormals = {
		Vector3D(1, 0, 0),
		Vector3D(-1, 0, 0),
		Vector3D(0, 1, 0),
		Vector3D(0, -1, 0),
		Vector3D(0, 0, 1),
		Vector3D(0, 0, -1),
	}

	self.CFrame = genCoordinateFrame()
	
	self.DrawnFaces = {}
	function self.ClearFaces()
		for i=#self.DrawnFaces,1,-1 do
			if self.DrawnFaces[i]~=nil then
				self.DrawnFaces[i]:removeSelf()
				self.DrawnFaces[i] = nil
			end
		end
	end
	
	return self
end

local function drawFace(vertices, vertexReferences, color)
	local faceData = {}
	local maxX = vertices[vertexReferences[1]].X
	local minX = maxX
	local maxY = vertices[vertexReferences[1]].Y
	local minY = maxY
	for _,vIndex in pairs(vertexReferences) do
		local vertex = vertices[vIndex]
		table.insert(faceData, vertex.X)
		table.insert(faceData, vertex.Y)
		maxX = math.max(maxX, vertex.X)
		minX = math.min(minX, vertex.X)
		maxY = math.max(maxY, vertex.Y)
		minY = math.min(minY, vertex.Y)
	end
	
	local posX = display.contentWidth/2 + (maxX+minX)/2
	local posY = display.contentHeight/2 + (maxY+minY)/2
	local face = display.newPolygon(posX,posY,faceData)
	
	face:setFillColor(unpack(color))
	return face
end

local function draw(mesh)
	--Get transformed vertices
	local transformedMesh = {}
	for _,vertex in pairs(mesh.Vertices) do
		local vCFrame = multiplyMatrices(mesh.CFrame, genCoordinateFrame(vertex))
		table.insert(transformedMesh, Vector3D(vCFrame[1][4], vCFrame[2][4], vCFrame[3][4]))
	end
	
	--Get transformed face normals
	local transformedNormals = {}
	for fIndex,fNormal in pairs(mesh.FaceNormals) do
		local fCFrame = multiplyMatrices(mesh.CFrame, genCoordinateFrame(fNormal))
		table.insert(transformedNormals, {faceIndex = fIndex, Normal = Vector3D(fCFrame[1][4], fCFrame[2][4], fCFrame[3][4])})
	end
	
	--Sort face Z-order
	local sortZ = {}
	for i=1,#transformedNormals do
		local closestZDistance = transformedNormals[1].Normal.Z
		local closestFaceIndex = 1
		for currentIndex,currentNormal in pairs(transformedNormals) do
			if currentNormal.Normal.Z < closestZDistance then
				closestZDistance = currentNormal.Normal.Z
				closestFaceIndex = currentIndex
			end
		end
		table.insert(sortZ, transformedNormals[closestFaceIndex].faceIndex)
		table.remove(transformedNormals, closestFaceIndex)
	end
	
	--Dont render back faces
	for i = 1, #sortZ/2 do
		table.remove(sortZ,1)
	end
	
	--Draw faces
	mesh.ClearFaces()
	for _,faceIndex in pairs(sortZ) do
		local color = COLORS.Red
		if faceIndex==3 or faceIndex==4 then
			color = COLORS.Green
		elseif faceIndex==5 or faceIndex==6 then
			color = COLORS.Blue
		end
		local face = drawFace(transformedMesh, mesh.Faces[faceIndex], color)
		if face~=nil then
			table.insert(mesh.DrawnFaces, face)
		end
	end
end

local cube = newCube(500)
draw(cube)

local touchX = 0
local touchY = 0
local deltaMult = .5

--Rotate Cube
Runtime:addEventListener("touch", function(event)
	if event.phase == "moved" then
		--Rotate deltaMult degrees per pixel moved
		local deltaX = math.rad((event.x-touchX) * deltaMult)
		local deltaY = math.rad((event.y-touchY) * deltaMult)
		
		--Transform cube coordinate frame
		local deltaRot = genCoordinateFrame(Vector3D(), Vector3D(deltaY, -deltaX, 0))
		cube.CFrame = multiplyMatrices(deltaRot, cube.CFrame)
		
		--Draw cube
		draw(cube)
		
		touchX = event.x
		touchY = event.y
	elseif event.phase == "began" then
		touchX = event.x
		touchY = event.y	
	end
end)