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

function loadSandbox(test)
	if world then
		world:destroy()
		mouseJoint=nil
	end

	local s="currentSandbox="..test.."()"
	loadstring(s)()
	currentSandbox.title=test
	world=currentSandbox.world
	camera=currentSandbox.camera
	settings=settings or Settings()
	mouseJoint=currentSandbox.mouseJoint
	-- settings.pause=not settings.enableWarmStarting
	slider:SetValue(settings.hz)
end

function love.load()
	require "libs/loveframes/init"
	require "internal/gui"
	require 'internal/settings'
	require "internal/sandbox"
	require "internal/render"

	w=love.graphics.getWidth()
	h=love.graphics.getHeight()

	love.physics.setMeter(1)

   --adding all the sandboxes from the sandboxes lib
	local sandboxesTable = love.filesystem.getDirectoryItems("sandboxes")
	for i, v in ipairs(sandboxesTable) do
		local s=string.gsub(v, ".lua", "")
		require("sandboxes/"..s)
		sandboxChoice:AddChoice(s)
	end

	local s=string.gsub(sandboxesTable[1], ".lua", "")

	--loading the first test manually
	sandboxChoice:SetChoice(s)
	loadSandbox(s)
end

local worldUpdateCounter=0
mx, my = 0, 0 -- camera:mousepos()
function love.update(dt)
	-- time control
	if world then
		if not settings.pause then
			worldUpdateCounter=worldUpdateCounter+dt
			if worldUpdateCounter > 1 then
				worldUpdateCounter = 1
			end

			while worldUpdateCounter >= 1/settings.hz do
				world:update(1/settings.hz)
				worldUpdateCounter = worldUpdateCounter-1/settings.hz
			end
		end
	end

	if love.mouse.isDown(1) or love.mouse.isDown(2) then
		local x, y=love.mouse.getPosition()

		--updating the mousejoint's position
		if world and mouseJoint and love.mouse.isDown(1) then
			local tx, ty = camera:mousepos()
			if mouseJoint then
				mouseJoint:setTarget(tx, ty)
			end
		end

		--dragging the camera
		if love.mouse.isDown(2) then
			local wx,wy = camera:worldCoords(x,y)
			local owx,owy = camera:worldCoords(mx,my)
			local dx=owx-wx
			local dy=owy-wy
			camera:move(dx,dy)
			mx=x
			my=y
		end

	end

	if love.keyboard.isDown('left') then
		camera:move(-1/camera.sx*dt*currentSandbox.moveSpeed,0)
	elseif love.keyboard.isDown('right') then
		camera:move(1/camera.sx*dt*currentSandbox.moveSpeed,0)
	end
	if love.keyboard.isDown('up') then
		camera:move(0,-1/camera.sy*dt*currentSandbox.moveSpeed)
	elseif love.keyboard.isDown('down') then
		camera:move(0,1/camera.sy*dt*currentSandbox.moveSpeed)
	end

	if love.keyboard.isDown('kp+') then
		camera:scale(currentSandbox.zoomSpeed^(dt*4))
	elseif love.keyboard.isDown('kp-') then
		camera:scale(1/(currentSandbox.zoomSpeed^(dt*4)))
	end

	currentSandbox:update(dt)
	loveframes.update(dt)
end


function backwardCompatibility08(button)
  if button == 1 then
    return "l"
  elseif button == 2 then
    return "r"
  elseif button == 3 then
    return "m"
  end
end

function love.mousepressed(x, y, button)
	if(button==1 or button==2) then
		mx=x
		my=y
		if (button==1) then
				currentSandbox:tryMouseJoint(x,y)
    end
	end

	currentSandbox:mousepressed(x,y,button)
	loveframes.mousepressed(x, y, backwardCompatibility08(button))
end

function love.mousereleased(x, y, button)
	if (button==1) and mouseJoint then
		mouseJoint:destroy()
		mouseJoint=nil
	end

	currentSandbox:mousereleased(x,y,button)
	loveframes.mousereleased(x, y, backwardCompatibility08(button))
end

function love.wheelmoved(x, y)
  if y > 0 then
    camera:scale(currentSandbox.zoomSpeed)
  elseif y < 0 then
		camera:scale(1/currentSandbox.zoomSpeed)
  end
end

function love.keypressed(key, unicode)
  if key=="escape" then
		love.event.push("quit")
	end

	currentSandbox:keypressed(key)
	loveframes.keypressed(key, unicode)
end

function love.keyreleased(key)
	currentSandbox:keyreleased(key)
	loveframes.keyreleased(key)
end
