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

-- The Test class is the superclass of all the test cases you create.

require "../libs/middleclass/middleclass"
local cam = require "libs/hump/camera"


Settings=class('Settings')
function Settings:initialize()
	self.hz=60
	self.drawShapes=true
	self.drawJoints=true
	self.drawAABBs=false
	self.drawPairs=false
	self.drawBodyPos=true
	self.drawContactPoints=false
	self.drawContactNormals=false
	self.drawContactForces=false
	self.drawFrictionForces=false
	self.drawCoordinates=false
	self.drawCOMs=false
	self.drawStats=false
	self.drawProfile=false
	self.enableWarmStarting=true
	self.enableContinuous=true
	self.enableSubStepping=false
	self.pause=false
	self.singleStep=false
end

ContactPoint=class('ContactPoint')
function ContactPoint:initialize()
	self.fixtureA=nil		
	self.fixtureB=nil
	self.normal={}				--vec2
	self.position={}			--vec2
	self.state=nil				--pointstate
end

Test=class('Test')
function Test:initialize()
	
	self.settings=Settings()
	
	self.world=love.physics.newWorld(0, -10, true)
     
	self.camera=cam( (w-panel:GetWidth())/2, 0.75*h, 1, 0, w-panel:GetWidth(), h)
	--self.camera=cam( 0, 0, 1, 0, w-panel:GetWidth(), h)

	self.zoomPerSec=1.35
	self.movePerSec=100

	self.title="TestTitle"
	self.text=""
	
	self.bomb=nil
	self.textLine=30
	self.mouseJoint=nil
	self.pointCount=0
	
	self.bombSpawning=false
	
	self.stepCount=0

end

function Test:update(dt)
	if love.keyboard.isDown("kp+") then
		currentTest.camera:zoom(math.pow( currentTest.zoomPerSec, dt))
	end
	if love.keyboard.isDown("kp-") then
	    currentTest.camera:zoom(math.pow(1/currentTest.zoomPerSec, dt))
    end
	if love.keyboard.isDown("down") then
	    currentTest.camera:move(0, -currentTest.movePerSec*dt)
    end
	if love.keyboard.isDown("up") then
	    currentTest.camera:move(0, currentTest.movePerSec*dt)
    end
	if love.keyboard.isDown("right") then	  
		currentTest.camera:move(currentTest.movePerSec*dt, 0)
    end
	if love.keyboard.isDown("left") then	  
		currentTest.camera:move(-currentTest.movePerSec*dt, 0)
    end
end

--checks if there is a shape at x, y screen coordinates and tries to grab it
function Test:tryMouseJoint(x, y)
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
					points[i]=(points[i]+bx)*worldScale
				else
					points[i]=(points[i]+by)*worldScale
					points[i-1], points[i]=self.camera:cameraCoords(points[i-1], points[i])
				end
			end
		
			local tx, ty = x-(w-panel:GetWidth())/2, -(y-h/2)
			
			local inside=(tx > points[1]) and (tx < points[3]) and (ty > points[2]) and (ty < points[4])
			if inside then
				--creating a new mousejoint!
				if (v:getType()=="dynamic") then
					tx, ty=self.camera:worldCoords(tx, ty)
					tx, ty=tx/worldScale, ty/worldScale
					mouseJoint=love.physics.newMouseJoint(v, tx, ty)
					return
				end
			end
		end
	end
end

function Test:keypressed(key)
end
