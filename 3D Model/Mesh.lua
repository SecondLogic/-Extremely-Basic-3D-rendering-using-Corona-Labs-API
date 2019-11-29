local Vector3 = require("Vector3")
local CFrame = require("CFrame")

local Mesh = {}
Mesh.__index = Mesh

setmetatable(Mesh, {
	__call = function(class, ...)
		return class.new(...)
	end
})

local SCALE = 400

local function parseObj(objFile)
	local meshData = {}
	for line in string.gmatch(objFile, "[^\n]+") do
		local t = string.match(line,"%a+")
		if t~=nil and string.len(t)==1 then
			if meshData[t]==nil then meshData[t] = {} end
			table.insert(meshData[t],string.sub(line,3))
		end
	end
	
	for _,group in pairs({"v","vn"}) do
		if meshData[group]~=nil then
			for i,vertex in pairs(meshData.v) do
				local point = {}
				for value in string.gmatch(vertex,"%S+") do
					table.insert(point,value)
				end
				meshData[group][i] = CFrame(Vector3(point[1] * SCALE, point[2] * SCALE, point[3] * SCALE))
			end
		end
	end
	return meshData
end

function drawTriangle(verts, color)	
	local faceData = {}
	local maxX = verts[1].X
	local minX = maxX
	local maxY = verts[1].Y
	local minY = maxY
	for _,vertex in pairs(verts) do
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

function Mesh.new(fileName)
	local filePath = system.pathForFile(fileName)
	local meshFile, err = io.open(filePath , "r")
	if not meshFile then
		return err
	end

	local self = setmetatable({}, Mesh)
	
	self.meshData = parseObj(meshFile:read("*a"))
	meshFile:close()
	print(#self.meshData.f .. " faces found")
	
	self.drawnFaces = {}
	self.CFrame = CFrame(Vector3(), Vector3(math.rad(180), math.rad(180), 0))
	
	return self
end

function Mesh:draw()
	local faces = {}
	for i,face in pairs(self.meshData.f) do
		local verts = {}
		for value in string.gmatch(face,"%S+") do
			table.insert(verts, self.meshData.v[string.match(value,"%d+")+0])
		end
		if #verts>=3 then
			for i,vertex in pairs(verts) do
				verts[i] = (self.CFrame * vertex):getPosition()
			end
			local avgPosition = Vector3()
			for _,v in pairs(verts) do
				avgPosition = avgPosition + v
			end
			local faceData = {
				vertices = verts,
				zPosition = avgPosition.Z
			}
			table.insert(faces, faceData)
		end
	end
	local sortedZ = {}
	for _,face in pairs(faces) do
		local inserted = false
		for i,otherFace in pairs(sortedZ) do
			if face.zPosition <= otherFace.zPosition then
				table.insert(sortedZ, i, face)
				inserted = true
				break
			end
		end
		if not inserted then
			table.insert(sortedZ, face)
		end
	end
	
	--Draw faces
	for i=#self.drawnFaces,1,-1 do
		if self.drawnFaces[i]~=nil then
			self.drawnFaces[i]:removeSelf()
			self.drawnFaces[i] = nil
		end
	end
	for i,face in pairs(sortedZ) do
		local gradient = ((i/#sortedZ)^1.5)*.8
		table.insert(self.drawnFaces, drawTriangle(face.vertices, {gradient + .6, gradient, gradient}))
	end
end

return Mesh