# NOTICE: NO LONGER MAINTAINED
## This repository is no longer maintained, we've moved over to a re-written and optimised version, [qtarget](https://github.com/QuantusRP/qtarget/)
 
 
## Old Readme: 

Dependencies:
* PolyZone: https://github.com/mkafrin/PolyZone
* Linden Inventory (Latest version): https://github.com/thelindat/linden_inventory/
* Linden ESX Legacy (es_extended) (Latest): https://github.com/thelindat/es_extended AND follow instructions


Icons: https://fontawesome.com/

## Version noms 0.2
* Added support for networked Entity bt-targets - you can attach a bt-target to a spawned entity and it'll be removed with that entity when it gets deleted, and the target only applies to that specific entity
* Added support for EntityZones - spawn a zone around an entity which can be interacted with 
* Ability to pass any parameters through the bt-target option (see examples)
* Pass the entity interacted with through the event
* Moved job/grade checks to a per-option basis, and made it optional so you don't have to define it (see examples)
* Added a `required_item` check that works with Linden Inventory exports to check if you have an item before showing an option (see examples)
* Added a `canInteract()` function (see examples)

## Version noms 0.1
My fork of bt-target includes the following options:
* Pass all data through to the target event in the data table 
* Add vehicle bone support
* Disable the ability to aim/attack while in interactive mode
* Check overall job grade to access the menu 
* Check individual option job grades 

## Installation instructions
Installation is very straightforward but as we use a few custom imports for performance you'll want to include them yourself:
In `es_extended\imports.lua` Add the following to the bottom of the file (if it does not already exist):
```lua
------------------------------------------------------------------------
-- SHARED
------------------------------------------------------------------------
local Intervals = {}
local CreateInterval = function(name, interval, action, clear)
	local self = {interval = interval}
	CreateThread(function()
		local name, action, clear = name, action, clear
		repeat
			action()
			Citizen.Wait(self.interval)
		until self.interval == -1
		if clear then clear() end
		Intervals[name] = nil
	end)
	return self
end

SetInterval = function(name, interval, action, clear)
	if Intervals[name] and interval then Intervals[name].interval = interval
	else
		Intervals[name] = CreateInterval(name, interval, action, clear)
	end
end

ClearInterval = function(name)
	Intervals[name].interval = -1
end
```

## Examples 

### Passing Item Data / AddTargetModel 
```lua

local coffee = {
    690372739,
}
exports['bt-target']:AddTargetModel(coffee, {
    options = {
        {
            event = "coffee:buy",
            icon = "fas fa-coffee",
            label = "Coffee",
            item = "coffee",
            price = 5,
        },
    },
    distance = 2.5
})


RegisterNetEvent('coffee:buy')
AddEventHandler('coffee:buy',function(data)
    ESX.ShowNotification("You purchased a " .. data.item .. " for $" .. data.price .. ". Enjoy!")
    -- server event to buy the item here
end)
```
`AddTargetModel` requires a table of model hashes to function correctly. You can use the direct hash number: `690372739` or direct object name with backticks: ``prop_vend_coffe_01``. 
Define a table like: 
```lua 
local coffee = {
    `prop_vend_coffe_01`,
    `p_ld_coffee_vend_01`
}
```


### Checking job / BoxZone

```lua
exports['bt-target']:AddBoxZone("MissionRowDutyClipboard", vector3(441.7989, -982.0529, 30.67834), 0.45, 0.35, {
    name="MissionRowDutyClipboard",
    heading=11.0,
    debugPoly=false,
    minZ=30.77834,
    maxZ=30.87834,
    }, {
        options = {
            {
                event = "qrp_duty:goOnDuty",
                icon = "fas fa-sign-in-alt",
                label = "Sign In",
                job = "police",
            },
            {
                event = "qrp_duty:goOffDuty",
                icon = "fas fa-sign-out-alt",
                label = "Sign Out",
                job = "police",
            },
        },
        distance = 3.5
})
```
In this example I'm defining police as a straight string to check if the player interacting has that job before showing the option. You can also define it as `[key] = value` pairs for grade, for example:
```lua
job = {
    ["police"] = 5, -- minimum grade required to see this option
    ["ambulance"] = 0,
}
```

### Removing Zones
You can and SHOULD remove zones in various situations, as a rule I tend to remove a zone with the same name before creating one to prevent clutter, and it helps if you're using debugPoly. 
```lua
exports['bt-target']:RemoveZone("MissionRowDutyClipboard")
```
Just make sure you're using the exact name of the zone you defined.

### CanInteract / EntityZone
In this example we're making a specifc zone around an entity that was created. This can help if you can't interact with a particular entity, but also don't have a static location to define.
The EntityZone is typically removed with the entity. 

The `canInteract()` function defined here allows you to do any particular checks you want to be executed at the time of interaction, in this instance, it checks if the plant has a statebag defined for growth that is higher than or equal to 100.
You can do any check you want as long as you return true or false. 

```lua
local playerPed = PlayerPedId()
local coords = GetEntityCoords(playerPed)
model = `prop_plant_fern_02a`
RequestModel(model)
while not HasModelLoaded(model) do
    Citizen.Wait(50)
end
local plant = CreateObject(model, coords.x, coords.y, coords.z, true, true)
Citizen.Wait(50)
PlaceObjectOnGroundProperly(plant)
SetEntityInvincible(plant, true)

exports['bt-target']:AddEntityZone("potato-growing-"..plant, plant, {
    name = "potato-growing-"..plant,
    heading=GetEntityHeading(plant),
    debugPoly=false,
}, {
    options = {
    {
        event = "farming:harvestPlant",
        icon = "fa-solid fa-scythe",
        label = "Harvest potato",
        plant = plant,
        job = "farmer",
        canInteract = function()
            if Entity(plant).state.growth >= 100 then 
                return true
            else 
                return false
            end 
        end,
    },
},
    distance = 3.5
})
```

### AddTargetEntity
You can also define an entity target that only that entity will have the interaction. This is very simular to EntityZone except attached to the network entity instead of a static zone.

```lua
exports['bt-target']:AddTargetEntity(NetworkGetNetworkIdFromEntity(vehicle), {
    options = {
        {
            event = "postop:getPackage",
            icon = "fa-solid fa-box-circle-check",
            label = "Get Package",
            owner = NetworkGetNetworkIdFromEntity(PlayerPedId()),
            job = "postop",
        },
    },
    distance = 3.0
})
```

### AddTargetBone
Use this in conjunction with the bone index in the `config.lua` file to define bones you would like to interact with on a vehicle.

```lua
	exports['bt-target']:AddTargetBone({"boot"}, {
	options = {
		{
			event = "qrp_vehicle:toggleVehicleDoor",
			icon = "fas fa-door-open",
			label = "Toggle Boot",
			door = 5,
		},
	},
	distance = 1.5
	})
```
