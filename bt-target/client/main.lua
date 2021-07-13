local Entities = {}
local Models = {}
local Zones = {}
local Bones = {}

Citizen.CreateThread(function()
	RegisterKeyMapping("+playerTarget", "Player Targeting", "keyboard", "LMENU") --Removed Bind System and added standalone version
	RegisterCommand('+playerTarget', playerTargetEnable, false)
	RegisterCommand('-playerTarget', playerTargetDisable, false)
	TriggerEvent("chat:removeSuggestion", "/+playerTarget")
	TriggerEvent("chat:removeSuggestion", "/-playerTarget")
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerData.job = playerData.job
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

function playerTargetEnable()
	if success then return end
	if IsPedArmed(PlayerPedId(), 6) then return end
	targetActive = true
	SetInterval(1, 5, function()
		DisableControlAction(0,24,true) -- disable attack
		DisableControlAction(0,25,true) -- disable aim
		DisableControlAction(0,47,true) -- disable weapon
		DisableControlAction(0,58,true) -- disable weapon
		DisableControlAction(0,263,true) -- disable melee
		DisableControlAction(0,264,true) -- disable melee
		DisableControlAction(0,257,true) -- disable melee
		DisableControlAction(0,140,true) -- disable melee
		DisableControlAction(0,141,true) -- disable melee
		DisableControlAction(0,142,true) -- disable melee
		DisableControlAction(0,143,true) -- disable melee
	end)
	SendNUIMessage({response = "openTarget"})



	while targetActive do

		local plyCoords = GetEntityCoords(PlayerPedId())
		local hit, coords, entity = RayCastGamePlayCamera(20.0)
		if hit == 1 then

			if GetEntityType(entity) ~= 0 then

				for _, entityData in pairs(Entities) do
					print()
					if NetworkGetEntityIsNetworked(entity) ==1 and _ == NetworkGetNetworkIdFromEntity(entity) then
						if #(plyCoords - coords) <= Entities[_]["distance"] then
							local options = Entities[_]["options"]
							local send_options = {}
							for l,b in pairs(options) do 
								if (b.job == nil or b.job == ESX.PlayerData.job.name or b.job[ESX.PlayerData.job.name]) and (b.job == nil or b.job[ESX.PlayerData.job.name] == nil or b.job[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade) then 
									if (b.required_item == nil) or (b.required_item and exports['linden_inventory']:CountItems(b.required_item)[b.required_item] > 0) then 
										if b.owner and b.owner == NetworkGetNetworkIdFromEntity(PlayerPedId()) then
											if b.canInteract == nil or b.canInteract() then 
												local slot = #send_options + 1
												send_options[slot] = b
												send_options[slot].entity = entity
											end
										end
									end
								end
							end
							success = true
							if success and #send_options > 0 then 
								SendNUIMessage({response = "validTarget", data = send_options})
								while success and targetActive do
									local plyCoords = GetEntityCoords(PlayerPedId())
									local hit, coords, entity = RayCastGamePlayCamera(20.0)
									DisablePlayerFiring(PlayerPedId(), true)
									if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
										SetNuiFocus(true, true)
										SetCursorLocation(0.5, 0.5)
									end
									if GetEntityType(entity) == 0 or #(plyCoords - coords) > Entities[_]["distance"] then
										success = false
									end
									Citizen.Wait(1)
								end
							end
							SendNUIMessage({response = "leftTarget"})
						end
					end
				end

				for _, model in pairs(Models) do
					if _ == GetEntityModel(entity) then
						if #(plyCoords - coords) <= Models[_]["distance"] then
							local options = Models[_]["options"]
							local send_options = {}
							for l,b in pairs(options) do 
								if (b.job == nil or b.job == ESX.PlayerData.job.name or b.job[ESX.PlayerData.job.name]) and (b.job == nil or b.job[ESX.PlayerData.job.name] == nil or b.job[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade) then 
									if (b.required_item == nil) or (b.required_item and exports['linden_inventory']:CountItems(b.required_item)[b.required_item] > 0) then 
										if b.canInteract == nil or b.canInteract() then 
											local slot = #send_options + 1
											send_options[slot] = b
											send_options[slot].entity = entity
										end
									end
								end
							end
							success = true
							if success and #send_options > 0 then 
								SendNUIMessage({response = "validTarget", data = send_options})
							
								while success and targetActive do
									local plyCoords = GetEntityCoords(PlayerPedId())
									local hit, coords, entity = RayCastGamePlayCamera(20.0)
									DisablePlayerFiring(PlayerPedId(), true)
									if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
										SetNuiFocus(true, true)
										SetCursorLocation(0.5, 0.5)
									end
									if GetEntityType(entity) == 0 or #(plyCoords - coords) > Models[_]["distance"] then
										success = false
									end
									Citizen.Wait(1)
								end
								SendNUIMessage({response = "leftTarget"})
							end 
						end
					end
				end
			end

			if IsEntityAVehicle(entity) then 
				local bone, hitDistanceToBone, boneIndex, bonePos = FindNearestVehicleBoneToRayCast(entity,coords,hit)
				local distanceToBone = #(bonePos - plyCoords)
				if (bone ~= nil and Bones[bone] ~= nil and distanceToBone ~= nil) and distanceToBone <= Bones[bone]["distance"] then 
					local options = Bones[bone]["options"]
					local send_options = {}
					for l,b in pairs(options) do 
						if (b.job == nil or b.job == ESX.PlayerData.job.name or b.job[ESX.PlayerData.job.name]) and (b.job == nil or b.job[ESX.PlayerData.job.name] == nil or b.job[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade) then 
							if (b.required_item == nil) or (b.required_item and exports['linden_inventory']:CountItems(b.required_item)[b.required_item] > 0) then 
								if b.canInteract == nil or b.canInteract() then 
									local slot = #send_options + 1
									send_options[slot] = b
									send_options[slot].entity = entity
								end
							end
						end
					end
					success = true
					if success and #send_options > 0 then 
						SendNUIMessage({response = "validTarget", data = send_options})
						while success and targetActive do
							local plyCoords = GetEntityCoords(PlayerPedId())
							local hit, coords, entity = RayCastGamePlayCamera(20.0)
							local newbone, hitDistanceToBone, boneIndex, bonePos = FindNearestVehicleBoneToRayCast(entity,coords,hit)
							DisablePlayerFiring(PlayerPedId(), true)
							if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
								SetNuiFocus(true, true)
								SetCursorLocation(0.5, 0.5)
							end
							if #(plyCoords - bonePos) > Bones[bone]["distance"] or (not IsEntityAVehicle(entity)) or newbone ~= bone or not DoesEntityExist(entity) or not hit then
								success = false
							end
							Citizen.Wait(1)
						end
					end
					SendNUIMessage({response = "leftTarget"})
				end 
			end

			for _, zone in pairs(Zones) do
				if Zones[_]:isPointInside(coords) then
					if #(plyCoords - Zones[_].center) <= zone["targetoptions"]["distance"] then
						local options = Zones[_]["targetoptions"]["options"]
						local send_options = {}
						for l,b in pairs(options) do 
							if (b.job == nil or b.job == ESX.PlayerData.job.name or b.job[ESX.PlayerData.job.name]) and (b.job == nil or b.job[ESX.PlayerData.job.name] == nil or b.job[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade) then 
								if (b.required_item == nil) or (b.required_item and exports['linden_inventory']:CountItems(b.required_item)[b.required_item] > 0) then 
									if b.canInteract == nil or b.canInteract() then 
										local slot = #send_options + 1
										send_options[slot] = b
										send_options[slot].entity = entity
									end
								end
							end
						end
						success = true
						if success and #send_options > 0 then 
							SendNUIMessage({response = "validTarget", data = send_options})
							while success and targetActive do
								local plyCoords = GetEntityCoords(PlayerPedId())
								local hit, coords, entity = RayCastGamePlayCamera(20.0)
								DisablePlayerFiring(PlayerPedId(), true)
								if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
									SetNuiFocus(true, true)
									SetCursorLocation(0.5, 0.5)
								elseif not Zones[_]:isPointInside(coords) or #(vector3(Zones[_].center.x, Zones[_].center.y, Zones[_].center.z) - plyCoords) > zone.targetoptions.distance then
								end

								if not Zones[_]:isPointInside(coords) or #(plyCoords - Zones[_].center) > zone.targetoptions.distance then
									success = false
								end

								Citizen.Wait(1)
							end
						end
						SendNUIMessage({response = "leftTarget"})
					end
				end
			end
		end
		
		Citizen.Wait(1)
	end
	SendNUIMessage({response = "closeTarget"})
	success = false 
	targetActive = false
	ClearInterval(1)
end




function playerTargetDisable()
	if targetActive then

	success = false
	targetActive = false
	ClearInterval(1)

	SendNUIMessage({response = "closeTarget"})
	end
end

--NUI CALL BACKS

RegisterNUICallback('selectTarget', function(data, cb)
	SetNuiFocus(false, false)

	success = false

	targetActive = false

	if data.server then 
		TriggerServerEvent(data.event,data)
	else
		TriggerEvent(data.event,data)
	end

end)

RegisterNUICallback('closeTarget', function(data, cb)
	SetNuiFocus(false, false)

	success = false

	targetActive = false
end)


function FindNearestVehicleBoneToRayCast()
	local hit, coords, entity = RayCastGamePlayCamera(20.0)
	local pos = GetEntityCoords(PlayerPedId(),true)
	local to = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0,0.0)
	local lowestDistance = 9999
	local lowestDistanceBone = nil
	local lowestDistancePosition = nil
	local lowestBoneIndex = nil
	if hit then 
		if DoesEntityExist(entity) and IsEntityAVehicle(entity) then 
			for k,v in pairs(Config.VehicleBones) do 
				local bone = GetEntityBoneIndexByName(entity,v)
				local from = coords
				local to = GetWorldPositionOfEntityBone(entity,bone)
				local dist = #(from - to)
				if dist ~= -1 then 
					--print(dist)
					if dist < lowestDistance then 
						lowestDistance = dist 
						lowestDistanceBone = v
						lowestDistancePosition = to
						lowestBoneIndex = bone
					end
				end
			end 
		end 
	end
	--print("Lowest distance was "..lowestDistance.." - "..lowestDistanceBone)
	return lowestDistanceBone, lowestDistance, lowestBoneIndex, lowestDistancePosition
end 


--Functions from https://forum.cfx.re/t/get-camera-coordinates/183555/14

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
	local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

function GetNearestVehicle()
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	if not (playerCoords and playerPed) then
		return
	end

	local pointB = GetEntityForwardVector(playerPed) * 0.001 + playerCoords

	local shapeTest = StartShapeTestCapsule(playerCoords.x, playerCoords.y, playerCoords.z, pointB.x, pointB.y, pointB.z, 1.0, 10, playerPed, 7)
	local _, hit, _, _, entity = GetShapeTestResult(shapeTest)

	return (hit == 1 and IsEntityAVehicle(entity)) and entity or false
end

--Exports

function AddCircleZone(name, center, radius, options, targetoptions)
	Zones[name] = CircleZone:Create(center, radius, options)
	Zones[name].targetoptions = targetoptions
end

function AddBoxZone(name, center, length, width, options, targetoptions)
	Zones[name] = BoxZone:Create(center, length, width, options)
	Zones[name].targetoptions = targetoptions
end

function AddPolyzone(name, points, options, targetoptions)
	Zones[name] = PolyZone:Create(points, options)
	Zones[name].targetoptions = targetoptions
end

function AddTargetModel(models, parameteres)
	for _, model in pairs(models) do
		Models[model] = parameteres
	end
end

function AddTargetEntity(entity, parameteres)
	Entities[entity] = parameteres
end

function AddTargetBone(bones, parameteres)
	for _, bone in pairs(bones) do
		Bones[bone] = parameteres
	end
end

function AddEntityZone(name, entity, options, targetoptions)
	Zones[name] = EntityZone:Create(entity, options)
	Zones[name].targetoptions = targetoptions
	end

function RemoveZone(name)
	if not Zones[name] then return end
	if Zones[name].destroy then
		Zones[name]:destroy()
	end

	Zones[name] = nil
end

exports("AddCircleZone", AddCircleZone)

exports("AddBoxZone", AddBoxZone)

exports("AddPolyzone", AddPolyzone)

exports("AddTargetModel", AddTargetModel)

exports("AddTargetEntity", AddTargetEntity)

exports("AddTargetBone", AddTargetBone)

exports("RemoveZone", RemoveZone)

exports("AddEntityZone", AddEntityZone)