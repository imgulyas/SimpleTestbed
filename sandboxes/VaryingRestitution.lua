VaryingRestitution=class('VaryingRestitution', Sandbox)
function VaryingRestitution:initialize()
	Sandbox.initialize(self)
	
	local count=7
	local radius=1
	
	local groundBody=love.physics.newBody(self.world, 0, 0, "static")
	local groundShape=love.physics.newEdgeShape(-20, 0, 20, 0)
	local groundFixture=love.physics.newFixture(groundBody, groundShape, 1)
	
	local restitution={ 0, 0.1, 0.3, 0.5, 0.75, 0.9, 1 }
	
	
	for i=1, count do
		local spherebody=love.physics.newBody(self.world, -10+3*i, 20, "dynamic")
		local circleshape=love.physics.newCircleShape(radius)
		local fixture=love.physics.newFixture(spherebody, circleshape, 1)
		fixture:setRestitution(restitution[i])
	end
end
