--SphereStack test from Box2D's Sandboxbed application


SphereStack=class('SphereStack', Sandbox)
function SphereStack:initialize()
	Sandbox.initialize(self)
	
	local count=10
	local radius=1
	
	local groundBody=love.physics.newBody(self.world, 0, 0, "static")
	local groundShape=love.physics.newEdgeShape(-20, 0, 20, 0)
	local groundFixture=love.physics.newFixture(groundBody, groundShape, 1)
	
	for i=1, count do
		local spherebody=love.physics.newBody(self.world, 0, 4+10*i, "dynamic")
		local circleshape=love.physics.newCircleShape(radius)
		local fixture=love.physics.newFixture(spherebody, circleshape, 1)
		spherebody:setLinearVelocity(0,-10)
	end
end
