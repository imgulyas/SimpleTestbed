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


local currY=0  --this var is used because of some kind bug with the objects getY function..

--------------The parent panel
local panelWidth=200
panel = loveframes.Create("panel")
panel:SetSize(panelWidth, love.graphics.getHeight())
panel:SetPos(love.graphics.getWidth()-panelWidth, 0)
-----------------------------

--------------------Test chooser

testChoice = loveframes.Create("multichoice")
testChoice:SetParent(panel)
testChoice:SetWidth(panelWidth-10)
testChoice.OnChoiceSelected = function(object, chosenTest)
		loadTest(chosenTest)	
	end
-----------------------------------

--------Frequency text + frequency slider

local hzText =loveframes.Create("text")
hzText:SetParent(panel)
--hzText:SetY(testChoice:GetY()+testChoice:GetHeight()+15)
currY=testChoice:GetHeight()+25
hzText:SetY(currY)
hzText:SetMaxWidth(panelWidth-10)
hzText:SetText("Update frequency: 60 Hz")

slider = loveframes.Create("slider")
slider:SetParent(panel)
--slider:SetY(hzText:GetY()+hzText:GetHeight()+60)
currY=currY+hzText:GetHeight()+15
slider:SetY(currY)
slider:SetWidth(panelWidth-10)
slider:SetMinMax(1, 60)
slider:SetDecimals(0)
slider.OnValueChanged = function(object)
	hzText:SetText("Update frequency: "..slider:GetValue().." Hz")
	settings.hz=slider:GetValue()
end
------------------------------------------

-----------Draw option text + draw option checkboxes

local drawText =loveframes.Create("text")
drawText:SetParent(panel)
--drawText:SetY(slider:GetY()+slider:GetHeight()+15)
currY=currY+slider:GetHeight()+30
drawText:SetY(currY)
drawText:SetMaxWidth(panelWidth-10)
drawText:SetText("Drawing options:")

--Checkbox for shapes + text
local cbShapes = loveframes.Create("checkbox")
cbShapes:SetParent(panel)
--cbShapes:SetY(slider:GetY()+slider:GetHeight()+15)
currY=currY+drawText:GetHeight()+15
cbShapes:SetY(currY)
cbShapes:SetChecked(true)
cbShapes.OnChanged = function(object)
	settings.drawShapes=cbShapes:GetChecked()
end
local txtShapes = loveframes.Create("text")
txtShapes:SetParent(panel)
txtShapes:SetY(currY+3)
txtShapes:SetX(30)
txtShapes:SetText("Shapes")

--Checkbox for joints + text
local cbJoints = loveframes.Create("checkbox")
cbJoints:SetParent(panel)
--cbShapes:SetY(slider:GetY()+slider:GetHeight()+15)
currY=currY+cbShapes:GetHeight()+25
cbJoints:SetY(currY)
cbJoints:SetChecked(true)
cbJoints.OnChanged = function(object)
	settings.drawJoints=cbJoints:GetChecked()
end
local txtJoints = loveframes.Create("text")
txtJoints:SetParent(panel)
txtJoints:SetY(currY+3)
txtJoints:SetX(30)
txtJoints:SetText("Joints")

--Checkbox for bounding boxes + text
local cbAABBs = loveframes.Create("checkbox")
cbAABBs:SetParent(panel)
--cbShapes:SetY(slider:GetY()+slider:GetHeight()+15)
currY=currY+cbJoints:GetHeight()+25
cbAABBs:SetY(currY)
cbAABBs:SetChecked(false)
cbAABBs.OnChanged = function(object)
	settings.drawAABBs=cbAABBs:GetChecked()
end
local txtAABBs = loveframes.Create("text")
txtAABBs:SetParent(panel)
txtAABBs:SetY(currY+3)
txtAABBs:SetX(30)
txtAABBs:SetText("AABBs")

--Checkbox for coordinates + text
local cbCoords = loveframes.Create("checkbox")
cbCoords:SetParent(panel)
--cbShapes:SetY(slider:GetY()+slider:GetHeight()+15)
currY=currY+cbAABBs:GetHeight()+25
cbCoords:SetY(currY)
cbCoords:SetChecked(false)
cbCoords.OnChanged = function(object)
	settings.drawCoordinates=cbCoords:GetChecked()
end
local txtCoords = loveframes.Create("text")
txtCoords:SetParent(panel)
txtCoords:SetY(currY+3)
txtCoords:SetX(30)
txtCoords:SetText("Coordinates")

--Checkbox for body positions + text
local cbBPos = loveframes.Create("checkbox")
cbBPos:SetParent(panel)
currY=currY+cbCoords:GetHeight()+25
cbBPos:SetY(currY)
cbBPos:SetChecked(true)
cbBPos.OnChanged = function(object)
	settings.drawBodyPos=cbBPos:GetChecked()
end
local txtBPos = loveframes.Create("text")
txtBPos:SetParent(panel)
txtBPos:SetY(currY+3)
txtBPos:SetX(30)
txtBPos:SetText("Body positions")

------------------------------------------

--------------Control buttons
--Pause button
local btnPause=loveframes.Create("button")
btnPause:SetParent(panel)
btnPause:SetSize(100, 40)
currY=currY+cbBPos:GetHeight()+100
btnPause:SetY(currY)
btnPause:CenterX()
btnPause:SetText("Pause/Unpause")
btnPause.OnClick = function(object)
	settings.pause=not settings.pause
end

--Single Step button
local btnStep=loveframes.Create("button")
btnStep:SetParent(panel)
btnStep:SetSize(100, 40)
currY=currY+btnPause:GetHeight()+10
btnStep:SetY(currY)
btnStep:CenterX()
btnStep:SetText("Single Step")
btnStep.OnClick = function(object)
	settings.pause=true
	if world then
		world:update(1/settings.hz)
	end
end

--Restart button
local btnRestart=loveframes.Create("button")
btnRestart:SetParent(panel)
btnRestart:SetSize(100, 40)
currY=currY+btnStep:GetHeight()+10
btnRestart:SetY(currY)
btnRestart:CenterX()
btnRestart:SetText("Restart Test")
btnRestart.OnClick = function(object)
	--let's keep the settings
	-- local set=settings
	loadTest(testChoice:GetChoice())
	-- settings=set
	-- cbShapes:SetChecked(settings.drawShapes)
	-- cbJoints:SetChecked(settings.drawJoints)
	-- cbCoords:SetChecked(settings.drawCoordinates)
	-- cbAABBs:SetChecked(settings.drawAABBs)
	-- cbBPos:SetChecked(settings.drawBodyPos)
	-- slider:SetValue(settings.hz)
end

--Quit button
local btnQuit=loveframes.Create("button")
btnQuit:SetParent(panel)
btnQuit:SetSize(100, 40)
currY=currY+btnRestart:GetHeight()+10
btnQuit:SetY(currY)
btnQuit:CenterX()
btnQuit:SetText("Quit")
btnQuit.OnClick = function(object)
	love.event.push("quit") 
end
-----------------------------