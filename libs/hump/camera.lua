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
local lg = love.graphics

local camera = {}
camera.__index = camera
-------------------
-- public interface
-------------------
local function new(shape,x,y,r,sx,sy)
	-- new camera with shape boundary
	shape._invertScale = 1
	
	-------------------
	-- modified scaling
	-------------------
	local scale = shape.scale
	
	local _setScale = function(self,s)
		assert(s > 0, 'scale must be greater than 0!')
		scale(self,self._invertScale)
		scale(self,s)
		self._invertScale = 1/s
	end
	local _scale = function(self,s)
		assert(s > 0, 'scale must be greater than 0!')
		scale(self,s)
		self._invertScale = self._invertScale / s
	end
	local _getScale = function(self)
		return 1/self._invertScale
	end
	
	shape.scale		= _scale
	shape.setScale	= _setScale
	shape.getScale	= _getScale
	
	local _stencil = lg.newStencil(function()
		shape:draw('fill')
	end)
	x,y		= x or lg.getWidth()/2, y or lg.getHeight()/2
	sx = sx or 1
	sy,r	= sy or sx,r or 0
	return setmetatable(
		{x = x, y = y, sx = sx, sy = sy, r = r, 
		_stencil = _stencil,shape = shape}, camera)
end

function camera:rotate(phi)
	self.r = self.r + phi
	return self
end

function camera:move(x,y)
	self.x, self.y = self.x + x, self.y + y
	return self
end

function camera:setScale(sx,sy)
	self.sx,self.sy = sx,sy or sx
end

function camera:scale(sx,sy)
	self.sx,self.sy = self.sx * sx,self.sy * (sy or sx)
end

function camera:attach()
	-- draw poly mask
	lg.push()
	local shapecx,shapecy = self.shape:center()
	lg.setStencil(self._stencil)
	-- transform view in viewport
	local cx,cy = shapecx*2/(self.sx*2),shapecy*2/(self.sy*2)
	lg.scale(self.sx,self.sy)
	lg.translate(cx, cy)
	lg.rotate(self.r)
	lg.translate(-self.x, -self.y)
end

function camera:detach()
	lg.setStencil()
	lg.pop()
end

function camera:draw(func)
	self:attach()
	func()
	self:detach()
end

function camera:cameraCoords(x,y)
	local scx,scy = self.shape:center()
	local w,h = scx*2,scy*2
	x,y = vec.rotate(self.r, x-self.x, y-self.y)
	return x*self.sx + w/2, y*self.sy + h/2
end

function camera:worldCoords(x,y)
	local scx,scy = self.shape:center()
	local w,h = scx*2,scy*2
	x,y = vec.rotate(-self.r, (x-w/2)/self.sx, (y-h/2)/self.sy)
	return x+self.x, y+self.y
end

function camera:mousepos()
	return self:worldCoords(love.mouse.getPosition())
end

-------------------
-- world functions
-------------------
function camera:worldContains(x,y)
	return self.shape:contains(self:cameraCoords(x,y))
end

function camera:worldBbox()
	local x1,y1,x2,y2 = self.shape:bbox()
	x1,y1 = self:worldCoords(x1,y1)
	x2,y2 = self:worldCoords(x2,y2)
	-- for negative scaling
	if x1 > x2 then
		x1,x2 = x2,x1
	end
	if y1 > y2 then
		y1,y2 = y2,y1
	end
	return x1,y1,x2,y2
end

function camera:worldIntersectsRay(x,y,dx,dy)
	local x2,y2 = self:cameraCoords(x+dx,y+dy)
	x,y = self:cameraCoords(x,y)
	dx,dy = x2-x,y2-y
	return self.shape:intersectsRay(x,y,dx,dy)
end

-- the module
return setmetatable({new = new},
	{__call = function(_, ...) return new(...) end})