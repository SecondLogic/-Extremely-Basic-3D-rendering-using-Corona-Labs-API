local Vector3 = {}
Vector3.__index = Vector3

setmetatable(Vector3, {	
	__call = function(class, ...)
		return class.new(...)
	end
})

function Vector3.new(x, y, z)
	local self = setmetatable({}, Vector3)
	
	self.X = x or 0
	self.Y = y or 0
	self.Z = z or 0
	
	return self
end

function Vector3:getMagnitude()
	return math.sqrt(self.X^2 + self.Y^2 + self.Z^2)
end

Vector3.__add = function(v1, v2)
	return Vector3.new(v1.X + v2.X, v1.Y + v2.Y, v1.Z + v2.Z)
end

Vector3.__sub = function(v1, v2)
	return Vector3.new(v1.X - v2.X, v1.Y - v2.Y, v1.Z - v2.Z)
end

Vector3.__mul = function(v1, v2)
	return Vector3.new(v1.X * v2.X, v1.Y * v2.Y, v1.Z * v2.Z)
end

Vector3.__div = function(v1, v2)
	return Vector3.new(v1.X / v2.X, v1.Y / v2.Y, v1.Z / v2.Z)
end

return Vector3