local showMenu = false
local vehList = {}

local function DisplayVehicleList(vehicles)
    vehList = vehicles
    showMenu = true
end

RegisterNetEvent("showVehicleList")
AddEventHandler("showVehicleList", DisplayVehicleList)

RegisterCommand("VehicleList", function()
    TriggerServerEvent("requestVehicleList")
end)

RegisterCommand("VehicleListHide", function()
    showMenu = false
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if showMenu then
            local x = 0.92 -- Adjust the X position as needed
            local y = 0.01 -- Adjust the Y position as needed
            local scale = 0.3 -- Adjust the scale as needed

            -- Draw the vehicle list using DrawText2D
            for i, vehicle in ipairs(vehList) do
                DrawText2D(x, y + (i * 0.03), scale, scale, 0.5, vehicle)
            end
        end
    end
end)

function DrawText2D(x, y, scaleX, scaleY, scale, text)
    SetTextFont(0)
    SetTextScale(scaleX, scaleY)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
