--[[
Copyright (c) 2010-2012 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local _PATH = (...):match('^(.*[%./])[^%.%/]+$') or ''
local vec = require(_PATH..'vector-light')

local camera = {}
camera.__index = camera

local function new(x,y, z, rot, w, h)
	if not w or not h then
		w=love.graphics.getWidth()
		h=love.graphics.getHeight()
	end
	x,y  = x or w/2, y or h/2
	z = z or 1
	rot  = rot or 0
	return setmetatable({x = x, y = y, z = z, rot = rot, w=w, h=h}, camera)
end

function camera:rotate(phi)
	self.rot = self.rot + phi
	return self
end

function camera:move(x,y)
	self.x, self.y = self.x + x, self.y + y
	return self
end

function camera:zoom(f)
	self.z=self.z*f
	return self
end

function camera:attach()
	local cx,cy = vec.div(self.z*2, self.w, self.h)
	love.graphics.push()
	love.graphics.scale(self.z)
	love.graphics.translate(cx, cy)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
	love.graphics.pop()
end

function camera:draw(func)
	self:attach()
	func()
	self:detach()
end

function camera:cameraCoords(x,y)
	x,y = vec.rotate(self.rot, x-self.x, y-self.y)
	return x*self.z + self.w/2, y*self.z + self.h/2
end

function camera:worldCoords(x,y)
	x,y = vec.rotate(-self.rot, vec.div(self.z, x-self.w/2, y-self.h/2))
	return x+self.x, y+self.y
end

function camera:mousepos()
	return self:worldCoords(love.mouse.getPosition())
end

-- the module
return setmetatable({new = new},
	{__call = function(_, ...) return new(...) end})
