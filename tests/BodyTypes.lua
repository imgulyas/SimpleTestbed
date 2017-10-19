--BodyTypes test from Box2D's Testbed

BodyTypes=class('BodyTypes', Test)
function BodyTypes:initialize()
	Test.initialize(self)

	self.text="Keys: (d) dynamic, (s) static, (k) kinematic"

	self.speed=3

	--define ground
	local groundBody=love.physics.newBody(self.world, 0, 0, "static")
	local groundShape=love.physics.newEdgeShape(-20, 0, 20, 0)
	local groundFixture=love.physics.newFixture(groundBody, groundShape, 1)

	--define attachment
	local attachment=love.physics.newBody(self.world, 0, 3, "dynamic")
	local shape=love.physics.newRectangleShape(1, 4)
	local fixture=love.physics.newFixture(attachment, shape, 2)

	--define platform
	self.platform=love.physics.newBody(self.world, 0, 5, "dynamic")
	shape=love.physics.newRectangleShape(0, 0, 1, 8, 0.5*math.pi)
	fixture=love.physics.newFixture(self.platform, shape, 2)
	fixture:setFriction(0.6)

	local rjd=love.physics.newRevoluteJoint(attachment, self.platform, 0, 5, false)
	rjd:setMotorEnabled(true)
	rjd:setMaxMotorTorque(50)

	local pj=love.physics.newPrismaticJoint(groundBody, self.platform, 0, 5, 1, 0)
	pj:setMotorEnabled(true)
	pj:setMaxMotorForce(1000)
	pj:setLowerLimit(-10)
	pj:setUpperLimit(10)


	--create a payload
	local pl=love.physics.newBody(self.world, 0, 8, "dynamic")
	local ps=love.physics.newRectangleShape(1.5, 1.5)
	local pf=love.physics.newFixture(pl, ps, 2)
	pf:setFriction(0.6)

end

function BodyTypes:keypressed(key)
	if(key=="d") then
		self.platform:setType("dynamic")
	elseif(key=="s") then
		self.platform:setType("static")
	elseif(key=="k") then
		self.platform:setType("kinematic")
		self.platform:setLinearVelocity(-self.speed, 0)
		self.platform:setAngularVelocity(0)
	end
end

function BodyTypes:update(dt)
	Test:update(dt)
	if self.platform:getType()=="kinematic" then
		vx=self.platform:getLinearVelocity()
		px=self.platform:getX()
		if (px<-10 and vx<0) or (px>10 and vx > 0) then
				self.platform:setLinearVelocity(-vx, 0)
		end
	end
end
