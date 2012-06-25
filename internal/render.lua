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

--render.lua
local dynColor={119, 136, 153, 100}
local dynEdgeColor={255, 255, 255}
local statColor={0,255,0, 100}
local statEdgeColor={0, 255, 0}
local kinColor={132,112,200}
local kinEdgeColor={0, 0, 255}
local AABBColor={255, 165, 0}
local bodyPosColor={0, 255, 127}
local jointColor={255, 255, 0}
local mouseJointColor={255, 0, 0}

local function setPhysDrawMode(bool)
	if bool then
		love.graphics.push()
		love.graphics.translate( (w-panel:GetWidth())/2, h/2)
		love.graphics.scale(1, -1)
	else
		love.graphics.pop()
	end
end

local function drawCircleShape(shape, body)
	local x, y=body:getPosition()
	local r= shape:getRadius()
	x, y=camera:cameraCoords(x*worldScale, y*worldScale)
	r=r*worldScale*camera.z
	local bt=body:getType()
	if bt=="dynamic" then
		love.graphics.setColor(dynColor)
	elseif bt=="static" then
		love.graphics.setColor(statColor)
	elseif bt=="kinematic" then
		love.graphics.setColor(kinColor)
	end
	love.graphics.circle("fill", x, y, r)
	love.graphics.setLineWidth(1)
	if bt=="dynamic" then
		love.graphics.setColor(dynEdgeColor)
	elseif bt=="static" then
		love.graphics.setColor(statEdgeColor)
	elseif bt=="kinematic" then
		love.graphics.setColor(kinEdgeColor)
	end
	love.graphics.circle("line", x, y, r)
	local angle=body:getAngle()
	love.graphics.line(x, y, x+math.cos(angle)*r, y+math.sin(angle)*r)
end

local function drawPolygonShape(shape, body)
	local points={shape:getPoints()}
	local a=body:getAngle()
	local bx, by = body:getPosition()
	local xcopy
	for i in ipairs(points) do
		-- X coordinates of the shapes
		if i%2==1 then
			xcopy=points[i]
			points[i]=(math.cos(a)*points[i]-math.sin(a)*points[i+1] +bx)*worldScale
		-- Y coordinates of the shapes
		else
			points[i]=(math.sin(a)*xcopy+math.cos(a)*points[i] +by)*worldScale
			points[i-1], points[i]=camera:cameraCoords(points[i-1], points[i])
		end
	end
	local bt=body:getType()
	if bt=="dynamic" then
		love.graphics.setColor(dynColor)
	elseif bt=="static" then
		love.graphics.setColor(statColor)
	elseif bt=="kinematic" then
		love.graphics.setColor(kinColor)
	end
	love.graphics.polygon("fill", points)
	love.graphics.setLineWidth(1)
	if bt=="dynamic" then
		love.graphics.setColor(dynEdgeColor)
	elseif bt=="static" then
		love.graphics.setColor(statEdgeColor)
	elseif bt=="kinematic" then
		love.graphics.setColor(kinEdgeColor)
	end
	love.graphics.polygon("line", points)
end

local function drawEdgeShape(shape)
	local points={shape:getPoints()}
	for i in ipairs(points) do
		points[i]=points[i]*worldScale
		if i%2==0 then
			points[i-1], points[i]=camera:cameraCoords(points[i-1], points[i])
		end
	end
	love.graphics.setColor(statEdgeColor)
	love.graphics.setLineWidth(1)
	love.graphics.line(points)
end

local function drawAABB(shape, body)
	local points={shape:computeAABB(0, 0, body:getAngle())}
	local bx, by = body:getPosition()
	for i in ipairs(points) do
		if i%2==1 then
			points[i]=(points[i]+bx)*worldScale
		else
			points[i]=(points[i]+by)*worldScale
			points[i-1], points[i]=camera:cameraCoords(points[i-1], points[i])
		end
	end
	love.graphics.setColor(AABBColor)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", points[1], points[2], points[3]-points[1], points[4]-points[2])
end

local function drawJoint(joint)
	local t=joint:getType()
	local points={joint:getAnchors()}
		for i in ipairs(points) do
			points[i]=points[i]*worldScale
			if i%2==0 then
				points[i-1], points[i]=camera:cameraCoords(points[i-1], points[i])
			end
		end
	if t=="mouse" then
		love.graphics.setColor(mouseJointColor)
		love.graphics.setLineWidth(3)
		love.graphics.line(points)
	else
		love.graphics.setColor(jointColor)
		love.graphics.setLineWidth(1)
		love.graphics.line(points)
	end
	-- if t=="distance" then
	-- elseif t=="gear" then
	-- elseif t=="mouse" then
	-- elseif t=="pulley" then
	-- elseif t=="revolute" then
	-- elseif t=="prismatic" then
	-- end
end

local function drawBodyPos(body)
	local x=body:getX()*worldScale
	local y=body:getY()*worldScale
	love.graphics.setPointStyle("rough")
	love.graphics.setPointSize(2)
	love.graphics.setColor(bodyPosColor)
	love.graphics.point(camera:cameraCoords(x, y))
end

function love.draw()
    --camera:attach()
	setPhysDrawMode(true)
	if  not world:isLocked() then
		
		--drawing shapes and AABBs
		if settings.drawShapes or settings.drawAABBs then
			
			local blist=world:getBodyList()
			for i, v in ipairs(blist) do
				local flist=v:getFixtureList()
				if flist~=nil then
					for _, k in ipairs(flist) do
						local shape=k:getShape()
						--draw shapes
						if(settings.drawShapes) then
							local t=shape:getType()
							if t=="edge" then
								drawEdgeShape(shape)
							elseif t=="circle" then
								drawCircleShape(shape, v)
							elseif t=="polygon" then
								drawPolygonShape(shape, v)
							end
						end
						--draw AABBs
						if (settings.drawAABBs) then
							drawAABB(shape, v)
						end
						--draw body positions
						if settings.drawBodyPos then
							drawBodyPos(v)
						end
					end
				end
			end
		end
	
		--drawing joints
		if settings.drawJoints then
			local jlist=world:getJointList()
			for i, v in ipairs(jlist) do
				drawJoint(v)
			end
		end
	end
	
	--drawing coordinates
	if settings.drawCoordinates then
		love.graphics.push()
		love.graphics.scale(1, -1)
		love.graphics.setColor(255, 255, 255)
		for i=-50, 50, 10 do
			for j=-50, 50, 10 do
				local x, y = camera:cameraCoords(i*worldScale, j*worldScale)
				love.graphics.print("("..i..","..j..")", x, -y)
			end
		end
		love.graphics.pop()
	end
	
	setPhysDrawMode(false)
	--camera:detach()
	
	--drawing texts
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(currentTest.title, 10, 10)
	love.graphics.print(currentTest.text, 10, 25)
	
	--FPS
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("FPS: "..math.floor(1/love.timer.getDelta()), w-panel:GetWidth()-50, 10)
	
	--GUI
	loveframes.draw()
end