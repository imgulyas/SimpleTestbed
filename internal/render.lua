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

local function drawCircleShape(shape, body)
	local x,y	= body:getPosition()
	local r		= shape:getRadius()
	local bt=body:getType()
	if bt=="dynamic" then
		love.graphics.setColor(dynColor)
	elseif bt=="static" then
		love.graphics.setColor(statColor)
	elseif bt=="kinematic" then
		love.graphics.setColor(kinColor)
	end
	love.graphics.circle("fill", x, y, r)
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
			points[i]=(math.cos(a)*points[i]-math.sin(a)*points[i+1] +bx)
		-- Y coordinates of the shapes
		else
			points[i]=(math.sin(a)*xcopy+math.cos(a)*points[i] +by)
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
	love.graphics.setColor(statEdgeColor)
	love.graphics.line(points)
end

local function drawAABB(shape, body)
	local points={shape:computeAABB(0, 0, body:getAngle())}
	local bx, by = body:getPosition()
	for i in ipairs(points) do
		if i%2==1 then
			points[i]=(points[i]+bx)
		else
			points[i]=(points[i]+by)
		end
	end
	love.graphics.setColor(AABBColor)
	love.graphics.rectangle("line", points[1], points[2], points[3]-points[1], points[4]-points[2])
end

local function drawJoint(joint)
	local t=joint:getType()
	local points={joint:getAnchors()}
	if t=="mouse" then
		love.graphics.setColor(mouseJointColor)
		love.graphics.line(points)
	else
		love.graphics.setColor(jointColor)
		love.graphics.line(points)
	end
end

local function drawBodyPos(body)
	local x=body:getX()
	local y=body:getY()
	love.graphics.setPointSize(2)
	love.graphics.setColor(bodyPosColor)
	love.graphics.points(x, y)
end

-- local function drawContact(contact)
	-- local t = {contact:getPositions()}
	-- for i = 1,#t,2 do
		-- love.graphics.point(t[i],t[i+1])
	-- end
-- end

local function drawWorld()
	love.graphics.setLineWidth(1/camera.sx)
	love.graphics.setLineStyle('rough')
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
	
	-- if settings.drawContactPoints then
		-- local clist = world:getContactList()
		-- for i,v in ipairs(clist) do
			-- drawContact(v)
		-- end
	-- end
end

function love.draw()
    camera:attach()
		drawWorld()
		-- test draw stuff
		currentTest:draw()
	camera:detach()
	
	--drawing coordinates
	if settings.drawCoordinates then	
		--http://stackoverflow.com/questions/361681/algorithm-for-nice-grid-line-intervals-on-a-graph
		love.graphics.setColor(255, 255, 255)
		local x1,y1,x2,y2 = camera:worldBbox()
		local w = x2-x1
		local minWidth = w/7
		local mag = 10^math.floor(math.log10(minWidth))
		local residual = minWidth/mag
		local dx,dy
		
		if residual > 5 then
			dx=10*mag
			dy=dx
		elseif residual > 2 then
			dx=5*mag
			dy=dx
		elseif residual > 1 then
			dx=2*mag
			dy=dx
		else
			dx=mag
			dy=dx
		end
		
		for i = x1,x2+dx,dx do
			i = math.floor(i/dx)*dx
			for j = y1,y2+dy,dy do
				j = math.ceil(j/dy)*dy
				local x,y = camera:cameraCoords(i,j)
				love.graphics.print("("..i..","..j..")", x, y)
			end
		end
	end
	
	--drawing texts
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(currentTest.title,10,10)
	love.graphics.print(currentTest.text, 10, 25)
	
	if settings.pause then
		love.graphics.print('**PAUSED**',10,love.graphics.getHeight()-20)
	end
	
	--FPS
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("FPS: "..math.floor(1/love.timer.getDelta()), w-panel:GetWidth()-50, 10)
	
	--GUI
	loveframes.draw()
end
