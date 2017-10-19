TheoJansenWalker=class('TheoJansenWalker', Sandbox)

function TheoJansenWalker:CreateLeg(s, wheelAnchor)
	
	local p1={5.4*s, -6.1}
	local p2={7.2*s, -1.2}
	local p3={4.3*s, -1.9}
	local p4={3.1*s, 0.8}
	local p5={6.0*s, 1.5}
	local p6={2.5*s, 3.7}
	
	local v={}               --vertices
	local poly1, poly2
	if(s > 0) then
		v={p1, p2, p3}
		poly1=love.physics.newPolygonShape(  v[1][1], v[1][2], v[2][1], v[2][2], v[3][1], v[3][2] )
	
		v={ 0, 0, p5[1]-p4[1], p5[2]-p4[2], p6[1]-p4[1], p6[2]-p4[2]}
		poly2=love.physics.newPolygonShape( unpack(v) )
	else
		v={p1, p2, p3}
		poly1=love.physics.newPolygonShape(  v[1][1], v[1][2], v[2][1], v[2][2], v[3][1], v[3][2] )
		
		v={ 0, 0, p6[1]-p4[1], p6[2]-p4[2], p5[1]-p4[1], p5[2]-p4[2]}
		poly2=love.physics.newPolygonShape( unpack(v) )
	end
	
	local body1=love.physics.newBody(self.world, self.offset[1], self.offset[2], "dynamic")
	local body2=love.physics.newBody(self.world, p4[1]+self.offset[1], p4[2]+self.offset[2], "dynamic")

	body1:setAngularDamping(10)
	body2:setAngularDamping(10)
	
	local fix1=love.physics.newFixture(body1, poly1, 1)
	local fix2=love.physics.newFixture(body2, poly2, 1)
	fix1:setGroupIndex(-1)
	fix2:setGroupIndex(-1)
	
	--distance joint
	local f=6
	
	--p2  p5
	local djd=love.physics.newDistanceJoint(body1, body2, p2[1]+self.offset[1], p2[2]+self.offset[2], p5[1]+self.offset[1], p5[2]+self.offset[2])
	--djd:setDamping(0.5)
	djd:setFrequency(f)
	
	--p3  p4
	djd=love.physics.newDistanceJoint(body1, body2, p3[1]+self.offset[1], p3[2]+self.offset[2], p4[1]+self.offset[1], p4[2]+self.offset[2])
	--djd:setDamping(0.5)
	djd:setFrequency(f)
	
	djd=love.physics.newDistanceJoint(body1, self.wheel, p3[1]+self.offset[1], p3[2]+self.offset[2], wheelAnchor[1]+self.offset[1], wheelAnchor[2]+self.offset[2])
	--djd:setDamping(0.5)
	djd:setFrequency(f)
	
	djd=love.physics.newDistanceJoint(body2, self.wheel, p6[1]+self.offset[1], p6[2]+self.offset[2], wheelAnchor[1]+self.offset[1], wheelAnchor[2]+self.offset[2])
	--djd:setDamping(0.5)
	djd:setFrequency(f)
	
	--Revolute joint
	love.physics.newRevoluteJoint(body2, self.chassis, p4[1]+self.offset[1], p4[2]+self.offset[2])
	
end

function TheoJansenWalker:initialize()
	Sandbox.initialize(self)
	
	self.text="Keys: left = a, brake = s, right = d, toggle motor = m"
	
	self.offset={0, 8}
	self.motorSpeed=2
	self.motorOn=true
	self.pivot={0, 0.8}
	
	--ground
	local groundBody=love.physics.newBody(self.world, 0, 0, "static")
	local groundShape=love.physics.newEdgeShape(-50, 0, 50, 0)
	local groundFixture=love.physics.newFixture(groundBody, groundShape, 1)
	groundShape=love.physics.newEdgeShape(-50, 0, -50, 10)
	groundFixture=love.physics.newFixture(groundBody, groundShape, 1)
	groundShape=love.physics.newEdgeShape(50, 0, 50, 10)
	groundFixture=love.physics.newFixture(groundBody, groundShape, 1)
	
	--balls. Yes this walker got balls.
	for i=1, 40 do
		local c=love.physics.newCircleShape(0.25)
		local b=love.physics.newBody(self.world, -40+2*i, 0.5, "dynamic")
		love.physics.newFixture(b, c, 1)
	end
	
	--chassis
	self.chassis=love.physics.newBody(self.world, self.pivot[1]+self.offset[1], self.pivot[2]+self.offset[2], "dynamic")
	local chShape=love.physics.newRectangleShape(5, 2)
	local chFix=love.physics.newFixture(self.chassis, chShape, 1)
	chFix:setGroupIndex(-1)
	
	--wheel
	self.wheel=love.physics.newBody(self.world, self.pivot[1]+self.offset[1], self.pivot[2]+self.offset[2], "dynamic")
	local c=love.physics.newCircleShape(1.6)
	local whFix=love.physics.newFixture(self.wheel, c, 1)
	whFix:setGroupIndex(-1)

	--motor joint
	self.motorJoint=love.physics.newRevoluteJoint(self.wheel, self.chassis, self.pivot[1]+self.offset[1], self.pivot[2]+self.offset[2])
	self.motorJoint:setMotorSpeed(self.motorSpeed)
	self.motorJoint:setMaxMotorTorque(400)
	self.motorJoint:enableMotor(self.motorOn)
	
	local wheelAnchor={self.pivot[1], self.pivot[2]-0.8}
	
	self:CreateLeg(-1, wheelAnchor)
	self:CreateLeg(1, wheelAnchor)
	
	self.wheel:setAngle(0.66 * math.pi)
	self:CreateLeg(-1, wheelAnchor)
	self:CreateLeg(1, wheelAnchor)
	
	self.wheel:setAngle(-0.66 * math.pi)
	self:CreateLeg(-1, wheelAnchor)
	self:CreateLeg(1, wheelAnchor)
	
end

function TheoJansenWalker:keypressed(key)
	if(key=="a") then
		self.motorJoint:setMotorSpeed(-self.motorSpeed)
	elseif(key=="s") then
		self.motorJoint:setMotorSpeed(0)
	elseif(key=="d") then
		self.motorJoint:setMotorSpeed(self.motorSpeed)
	elseif(key=="m") then
		self.motorJoint:enableMotor(not self.motorJoint:isMotorEnabled())
	end
end
