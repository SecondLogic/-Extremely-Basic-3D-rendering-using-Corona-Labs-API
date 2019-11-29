--[[
3D Mesh
(c) Amos Cabudol
Created 11/28/2019

main.lua
]]

local Vector3 = require("Vector3")
local CFrame = require("CFrame")
local Mesh = require("Mesh")

local mesh = Mesh("Torus.obj")
if type(mesh)~="string" then
	mesh:draw()

	local touchX = 0
	local touchY = 0
	local deltaMult = .5

	--Rotate Mesh
	Runtime:addEventListener("touch", function(event)
		if event.phase == "moved" then
			--Rotate deltaMult degrees per pixel moved
			local deltaX = math.rad((event.x-touchX) * deltaMult)
			local deltaY = math.rad((event.y-touchY) * deltaMult)
			
			--Transform mesh coordinate frame
			local deltaRot = CFrame(Vector3(), Vector3(deltaY, -deltaX, 0))
			mesh.CFrame = deltaRot * mesh.CFrame
			
			--Draw mesh
			mesh:draw()
			
			touchX = event.x
			touchY = event.y
		elseif event.phase == "began" then
			touchX = event.x
			touchY = event.y
		end
	end)
else
	print(mesh)
end