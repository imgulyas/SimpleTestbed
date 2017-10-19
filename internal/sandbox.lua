-- Copyright (c) 2012 Gulyás Imre Miklós imgulyas@gmail.com
-- 
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
-- 
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-- The Sandbox class is the superclass of all the test cases you create.

require "../libs/middleclass/middleclass"
local cam = require "libs/hump/camera"
local shapes = require 'libs.hardoncollider.shapes'

Sandbox=class('Sandbox')
function Sandbox:initialize()
	local w = w-panel:GetWidth()

	self.world=love.physics.newWorld(0, -10, true)

	-- aim camera at point(0,10) for test initialization
	self.camera=cam(shapes.newPolygonShape(0,0,w,0,w,h,0,h),0, 0, 0, 1)
	self.camera:setScale(15,-15)
	self.camera:move(0,10)

	self.zoomSpeed=1.35
	self.moveSpeed=300

	self.title="SandboxTitle"
	self.text=""

	-- self.bomb=nil
	-- self.textLine=30
	self.mouseJoint=nil
	-- self.pointCount=0

	-- self.bombSpawning=false

	-- self.stepCount=0
end

function Sandbox:update(dt)
end

--checks if there is a shape at x, y screen coordinates and tries to grab it
function Sandbox:tryMouseJoint(x, y)
	--check if there is a shape at x, y
	local blist=self.world:getBodyList()
	for i, v in ipairs(blist) do
		local flist=v:getFixtureList()
		--CHECK FOR EVERY SHAPE
		for j, u in ipairs(flist) do
			local shape=u:getShape()
			local points={shape:computeAABB(0, 0, v:getAngle())}
			local bx, by = v:getPosition()
			for i in ipairs(points) do
				if i%2==1 then
					points[i]=(points[i]+bx)
				else
					points[i]=(points[i]+by)
				end
			end

			local tx, ty = self.camera:worldCoords(x,y)

			local inside=(tx > points[1]) and (tx < points[3]) and (ty > points[2]) and (ty < points[4])
			if inside then
				--creating a new mousejoint!
				if (v:getType()=="dynamic") then
					mouseJoint=love.physics.newMouseJoint(v, tx, ty)
					return true
				end
			end
		end
	end
end

function Sandbox:keypressed(key)
end

function Sandbox:keyreleased(key)
end

function Sandbox:mousepressed(x,y,button)
end

function Sandbox:mousereleased(x,y,button)
end

function Sandbox:draw()
end
