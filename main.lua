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

function loadTest(test)
	if world then
		world:destroy()
		mouseJoint=nil
	end

	local s="currentTest="..test.."()"
	loadstring(s)()
	currentTest.title=test
	world=currentTest.world
	camera=currentTest.camera
	settings=currentTest.settings
	mouseJoint=currentTest.mouseJoint
	settings.pause=not settings.enableWarmStarting
	slider:SetValue(settings.hz)
end

function love.load()
	w=love.graphics.getWidth()
	h=love.graphics.getHeight()

	love.physics.setMeter(1)
    worldScale=15
	
   require "libs/loveframes/init"
   require "internal/gui"
   require "internal/test"
   require "internal/render"
	
	
   --adding all the tests from the tests lib
   local testsTable = love.filesystem.enumerate( "tests" )
   for i, v in ipairs(testsTable) do
		print(v)
		local s=string.gsub(v, ".lua", "")
		require("tests/"..s)
		testChoice:AddChoice(s)
	end
	
	local s=string.gsub(testsTable[1], ".lua", "")
	
	--loading the first test manually
	testChoice:SetChoice(s)
	loadTest(s)
end

local worldUpdateCounter=0
function love.update(dt)
	
	if world then
		if not settings.pause then 
			worldUpdateCounter=worldUpdateCounter+dt
			if worldUpdateCounter> 1/settings.hz then
					world:update(1/settings.hz)
					worldUpdateCounter=worldUpdateCounter-1/settings.hz
			end
		end
	end
	
		
	if love.mouse.isDown("l") or love.mouse.isDown("r") then
		local x, y=love.mouse.getPosition()
		
		--updating the mousejoint's position
		if world and mouseJoint and love.mouse.isDown("l") then
			local tx, ty = x-(w-panel:GetWidth())/2, -(y-h/2)
			tx, ty=camera:worldCoords(tx, ty)
			tx, ty=tx/worldScale, ty/worldScale
			if mouseJoint then
				mouseJoint:setTarget(tx, ty)
			end
		end
		
		--dragging the camera
		if love.mouse.isDown("r") then
			local dx=mx-x
			local dy=my-y
			camera:move(dx*(1/camera.z), -dy*(1/camera.z))
			mx=x
			my=y
		end
		
	end
	
	currentTest:update(dt)
	
	loveframes.update(dt)
end


function love.mousepressed(x, y, button)

	if(button=="l" or button=="r") then
		mx=x
		my=y
		if (button=="l")then
			currentTest:tryMouseJoint(x,y)
		end
	elseif(button=="wu") then
		camera:zoom(currentTest.zoomPerSec)
	elseif(button=="wd") then
		camera:zoom(1/ currentTest.zoomPerSec)
	end

	loveframes.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

	if (button=="l") and mouseJoint then
		mouseJoint:destroy()
		mouseJoint=nil
	end

	loveframes.mousereleased(x, y, button)

end

function love.keypressed(key, unicode)
   
    if key=="escape" then
		love.event.push("quit") 
	end
	
	currentTest:keypressed(key)
	
	loveframes.keypressed(key, unicode)

end

function love.keyreleased(key)

	-- your code

	loveframes.keyreleased(key)

end