

asteroidHandler = {
	shellNum = 1,
	shells = {},
	defaultShell = {active = true, strength = 25.0, maxDist = 75.0, maxMass = 10},
}

function init()
	RegisterTool("asteroid", "Asteroid Strike")
	SetBool("game.tool.asteroid.enabled", true)
	SetFloat("game.tool.asteroid.ammo", 101)
	
	ballgravity = Vec(0, 0, 0)
	hadoukendamage = 1
	velocity = 0.17
	swingTimer = 0
	
	for i=1, 100 do
		asteroidHandler.shells[i] = deepcopy(asteroidHandler.defaultShell)
	end

	debrissound = LoadSound("snd/var4_meteor_debris.ogg")

        impactsound = LoadSound("snd/var1_meteor_impactV2.ogg")

	multiMissileLoop = LoadLoop("snd/var1_meteor_woosh.ogg")

	gokakyuSprite2 = LoadSprite("img/gokakyuball2.png")
end

function canShoot()
	local vehicle = GetPlayerVehicle()
	if vehicle ~= 0 then
		local driverPos = GetVehicleDriverPos(vehicle)
		local t = GetVehicleTransform(vehicle)
		local worldPos = TransformToParentPoint(t, driverPos)
		local cameraPos = GetCameraTransform().pos
		local length = VecLength(VecSub(cameraPos, worldPos))

		if length < 1 then
			return true
		else
			return false
		end
	end
	return true
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function GetAimPos(range)
	local ct = GetCameraTransform()
	local forwardPos = TransformToParentPoint(ct, Vec(0, 0, -range))
    local direction = VecSub(forwardPos, ct.pos)
    local distance = VecLength(direction)
	local direction = VecNormalize(direction)
	local hit, hitDistance = QueryRaycast(ct.pos, direction, distance)
	if hit then
		forwardPos = TransformToParentPoint(ct, Vec(0, 0, -hitDistance))
	end
	return forwardPos, hit
end

function GetAimPos2()
	local ct = GetCameraTransform()
	local forwardPos = TransformToParentPoint(ct, Vec(0, 0, -100))
    local direction = VecSub(forwardPos, ct.pos)
    local distance = VecLength(direction)
	local direction = VecNormalize(direction)
	local hit, hitDistance = QueryRaycast(ct.pos, direction, distance)
	if hit then
		forwardPos = TransformToParentPoint(ct, Vec(0, 0, -hitDistance))
		distance = hitDistance
	end
	return forwardPos, hit, distance
end

function Shoot()
        local t = GetCameraTransform()
	local fwd = TransformToParentVec(t, Vec(0, 0, -1))
	local maxDist = 200
	local hit, dist, normal, shape = QueryRaycast(t.pos, fwd, maxDist)
	local e = VecAdd(t.pos, VecScale(fwd, dist))	

        local aimpos = TransformToParentPoint(GetCameraTransform(), Vec(0, 0, 0))
        gunpos = TransformToParentPoint(GetCameraTransform(), Vec(50, 450, 50))
	local direction = VecSub(e, gunpos)

	asteroidHandler.shells[asteroidHandler.shellNum] = deepcopy(asteroidHandler.defaultShell)
	loadedShell = asteroidHandler.shells[asteroidHandler.shellNum] 
	loadedShell.active = true
	loadedShell.pos = gunpos
	loadedShell.counter = 1
	loadedShell.predictedBulletVelocity = VecScale(direction, velocity)
	asteroidHandler.shellNum = (asteroidHandler.shellNum%#asteroidHandler.shells) +1

	swingTimer = 0.3
end

function Boom()
	for key, shell in ipairs(asteroidHandler.shells) do
		if shell.active then
			shell.active = false
		end
	end
end

function asteroidOperations(projectile)
	projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity, (VecScale(ballgravity, GetTimeStep())))
	local point2 = VecAdd(projectile.pos, VecScale(projectile.predictedBulletVelocity, GetTimeStep()))

	local mi = VecAdd(projectile.pos, Vec(-2, -2.5, -2))
	local ma = VecAdd(projectile.pos, Vec(2, 2, 2))
	QueryRequire("physical")
	local shapes = QueryAabbShapes(mi, ma)

	if #shapes > 0 and projectile.counter % 1 == 0 then
		hitPos = VecAdd(projectile.pos, VecScale(VecNormalize(VecSub(point2, projectile.pos)), dist))
		--MakeHole(hitPos, hadoukendamage, hadoukendamage, hadoukendamage)
			
			Explosion(VecAdd(hitPos, Vec(0, 1.7, 0)), 3.5)

                        PointLight(hitPos, 1, 0.7, 0.5, 5000)

				ParticleReset()
				ParticleType("smoke")
			        ParticleGravity(-20)
				ParticleTile(3)
			        ParticleDrag(0, 21)
				ParticleColor(0.5, 0.5, 0.5)
				ParticleRadius(2)
				
                                local intervalo5 = 360 / 80
				for degrees = 1, 360, intervalo5 do
				local x = hitPos[1] + 2 * math.sin(degrees) 
				local z = hitPos[3] + 2 * math.cos(degrees)
				local hitPosition5 = Vec(x, hitPos[2],z)
				SpawnParticle(hitPosition5, Vec(0,2,0), 12)
				end

				ParticleReset()
				ParticleType("smoke")
			        ParticleGravity(-3)
				ParticleTile(3)
			        ParticleDrag(0, 21)
				ParticleColor(0.6, 0.6, 0.6)
				ParticleRadius(50)
				
                                local intervalo5 = 360 / 90
				for degrees = 1, 360, intervalo5 do
				local x = hitPos[1] + 1.5 * math.sin(degrees) 
				local z = hitPos[3] + 1.5 * math.cos(degrees)
				local hitPosition5 = Vec(x, hitPos[2],z)
				SpawnParticle(hitPosition5, Vec(0,2,0), 12)
				end

				ParticleReset()
				ParticleType("smoke")
			        ParticleGravity(-3)
				ParticleTile(5)
			        ParticleDrag(0, 21)
				ParticleColor(1, 0.5, 0.3)
				ParticleRadius(0.6)
                                ParticleEmissive(1.6, 0)
                                ParticleAlpha(1.0, 0.0)
				
                                local intervalo5 = 360 / 30
				for degrees = 1, 360, intervalo5 do
				local x = hitPos[1] + 1.5 * math.sin(degrees) 
				local z = hitPos[3] + 1.5 * math.cos(degrees)
				local hitPosition5 = Vec(x, hitPos[2],z)
				SpawnParticle(hitPosition5, Vec(0,2,0), 2.6)

                                end

				ParticleReset()
				ParticleType("smoke")
			        ParticleGravity(-3)
				ParticleTile(5)
			        ParticleDrag(0, 21)
				ParticleColor(1, 0.65, 0.45)
				ParticleRadius(0.6)
                                ParticleEmissive(1.8, 0)
                                ParticleAlpha(1.0, 0.0)
				
                                local intervalo5 = 360 / 30
				for degrees = 1, 360, intervalo5 do
				local x = hitPos[1] + 1.5 * math.sin(degrees) 
				local z = hitPos[3] + 1.5 * math.cos(degrees)
				local hitPosition5 = Vec(x, hitPos[2],z)
				SpawnParticle(hitPosition5, Vec(0,2,0), 2.3)
				
                                end

        end

	if #shapes > 0 and projectile.counter % 3 == 0 then
		hitPos = VecAdd(projectile.pos, VecScale(VecNormalize(VecSub(point2, projectile.pos)), dist))
                PlaySound(LoadSound("snd/var1_meteor_impactV2.ogg"), hitPos, 25, false)	
        end

	asteroidBlast(projectile)
               PointLight(projectile.pos, 1, 0.6, 0.4, 800)

                        SpawnFire(VecAdd(hitPos, Vec(0, 6, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(0, -6, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(6, 0, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(-6, 0, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(0, 0, 6)))
                        SpawnFire(VecAdd(hitPos, Vec(0, 0, -6)))

                        SpawnFire(VecAdd(hitPos, Vec(0, 4, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(0, -4, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(4, 0, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(-4, 0, 0)))
                        SpawnFire(VecAdd(hitPos, Vec(0, 0, 4)))
                        SpawnFire(VecAdd(hitPos, Vec(0, 0, -4)))

                        ParticleReset()
			ParticleGravity(-0.5)
			ParticleRadius(3.5)
			ParticleColor(0.75, 0.6, 0.5)
			ParticleTile(3)
			ParticleDrag(0, 0.5)
                        ParticleStretch(200.0)
                        ParticleAlpha(1, 0.0)
                        ParticleCollide(1, 0, "constant", 0.05)
			SpawnParticle(projectile.pos, Vec(0.4+math.random(-5,10)*0.1, 0, 0.4+math.random(-5,10)*0.1), 2)

                        ParticleReset()
			ParticleGravity(-0.5)
			ParticleRadius(2.5)
			ParticleColor(1, 0.6, 0.4)
			ParticleTile(5)
			ParticleDrag(0, 0.5)
                        ParticleStretch(200.0)
                        ParticleAlpha(0.9, 0.0)
                        ParticleCollide(1, 0, "constant", 0.05)
                        ParticleEmissive(0.2, 0)
			SpawnParticle(projectile.pos, Vec(0.4+math.random(-5,10)*0.1, 0, 0.4+math.random(-5,10)*0.1), 2.5)

                        ParticleReset()
			ParticleGravity(-0.5)
			ParticleRadius(3)
			ParticleColor(1, 0.6, 0.4)
			ParticleTile(5)
			ParticleDrag(0, 0.5)
                        ParticleStretch(200.0)
                        ParticleAlpha(0.9, 0.0)
                        ParticleCollide(1, 0, "constant", 0.05)
                        ParticleEmissive(0.8, 0)
			SpawnParticle(projectile.pos, Vec(0.4+math.random(-5,10)*0.1, 0, 0.4+math.random(-5,10)*0.1), 1.5)

                        ParticleReset()
			ParticleGravity(-0.3)
			ParticleRadius(1.7, 4.5, "linear")
			ParticleColor(0.6, 0.6, 0.6)
			ParticleTile(3)
			ParticleDrag(0, 1.5)
                        ParticleStretch(200.0)
                        ParticleAlpha(0.8, 0.0)
                        ParticleCollide(1, 0, "constant", 0.05)
			SpawnParticle(projectile.pos, Vec(0.4+math.random(-4,10)*0.1, 0, 0.4+math.random(-4,10)*0.1), 6)

                        ParticleReset()
			ParticleGravity(-0.3)
			ParticleRadius(2, 5.5, "linear")
			ParticleColor(0.7, 0.7, 0.7)
			ParticleTile(3)
			ParticleDrag(0, 1.5)
                        ParticleStretch(200.0)
                        ParticleAlpha(0.8, 0.0)
                        ParticleCollide(1, 0, "constant", 0.05)
			SpawnParticle(projectile.pos, Vec(-0.4+math.random(-5,10)*0.1, -0.2+math.random(-4,10)*0.1, -0.5+math.random(-4,10)*0.1), 12)

	local rot = QuatLookAt(projectile.pos, GetCameraTransform().pos)
	local transform = Transform(projectile.pos, rot)
	DrawSprite(gokakyuSprite2, transform, 2, 2, 1, 1, 1, 0.75, true, false)
        PlayLoop(multiMissileLoop, projectile.pos, 35, false)

	projectile.counter = projectile.counter + 1
    projectile.pos = point2
end

function draw()
	if GetString("game.player.tool") == "asteroid" and canShoot() then
		
	end
end

function tick(dt)
	if GetString("game.player.tool") == "asteroid" and canShoot() then
		if InputPressed("lmb") then
			Shoot()
		end

	if GetString("game.player.tool") == "use" and canShoot() then
		if InputPressed("rmb") then
			Shoot()
		end

		local b = GetToolBody()
		if b ~= 0 then
			local offset = Transform(Vec(0.4, -0.5, -0.28))
			SetToolTransform(offset)
			toolTrans = GetBodyTransform(b)
			toolPos = TransformToParentPoint(toolTrans, Vec(0.3, -0.45, -2.4))

		end
	end
	
	for key, shell in ipairs(asteroidHandler.shells) do
		if shell.active then
			asteroidOperations(shell)
		end
	end
end
end

function asteroidBlast(projectile)
	local mi = VecAdd(projectile.pos, Vec(-projectile.maxDist/2, -projectile.maxDist/2, -projectile.maxDist/2))
	local ma = VecAdd(projectile.pos, Vec(projectile.maxDist/2, projectile.maxDist/2, projectile.maxDist/2))
	QueryRequire("physical dynamic")
	local bodies = QueryAabbBodies(mi, ma)

	--Loop through bodies and push them
	for i=1,#bodies do
		local b = bodies[i]

		--Compute body center point and distance
		local bmi, bma = GetBodyBounds(b)
		local bc = VecLerp(bmi, bma, 0.5)
		local dir = VecSub(bc, projectile.pos)
		local dist = VecLength(dir)
		dir = VecScale(dir, 1.0/dist)

		--Get body mass
		local mass = GetBodyMass(b)
		
		--Check if body is should be affected
		if dist < projectile.maxDist and mass < projectile.maxMass then
			--Make sure direction is always pointing slightly upwards
			dir[2] = 0
			dir = VecNormalize(dir)
	
			--Compute how much velocity to add
			local massScale = 1 - math.min(mass/projectile.maxMass, 1.0)
			local distScale = 1 - math.min(dist/projectile.maxDist, 1.0)
			local add = VecScale(dir, projectile.strength * massScale * distScale)
			
			--Add velocity to body
			local vel = GetBodyVelocity(b)
			vel = VecAdd(vel, add)
			SetBodyVelocity(b, vel)
		end
	end
end