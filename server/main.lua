-- Adjust the file paths as needed.

local vehiclesPath = "D:\\FmSERVER\\txData\\CFXDefaultFiveM_A82B05.base\\resources\\[vehicles]"
local vehListFile = "D:\\FmSERVER\\txData\\CFXDefaultFiveM_A82B05.base\\resources\\[scripts]\\VehicleList\\VehList.txt"

local vehList = {}

local function ReadVehicleList()
    local vehList = {}
    local file = io.open(vehListFile, "r")
    if file then
        for line in file:lines() do
            table.insert(vehList, line)
        end
        file:close()
    end
    return vehList
end

local function WriteVehicleList(vehList)
    local file = io.open(vehListFile, "w")
    if file then
        for _, vehicle in ipairs(vehList) do
            file:write(vehicle .. "\n")
        end
        file:close()
    end
end

local function UpdateAndRefreshVehicleList()
    print("Checking for new vehicle folders...")

    local newVehList = {}  -- Create a new list to avoid duplicating entries

    for folder in io.popen("dir /b /ad \"" .. vehiclesPath .. "\""):lines() do
        table.insert(newVehList, folder)
    end

    -- Compare the new list with the previous list to find new entries
    for _, newVehicle in ipairs(newVehList) do
        local found = false
        for _, vehicle in ipairs(vehList) do
            if newVehicle == vehicle then
                found = true
                break
            end
        end
        if not found then
            table.insert(vehList, newVehicle)
            print("New folder found:", newVehicle)
            -- Automatically add the new folder to the server.cfg
            local serverCfgFile = io.open("D:\\FmSERVER\\txData\\CFXDefaultFiveM_A82B05.base\\server.cfg", "r")
            local serverCfgContent = ""
            if serverCfgFile then
                serverCfgContent = serverCfgFile:read("*a")
                serverCfgFile:close()
            end

            local searchString = "start " .. newVehicle
            if not serverCfgContent:find(searchString, 1, true) then
                local newLine = "start " .. newVehicle
                serverCfgContent = serverCfgContent .. "\n" .. newLine
                local serverCfgFile = io.open("D:\\FmSERVER\\txData\\CFXDefaultFiveM_A82B05.base\\server.cfg", "w")
                if serverCfgFile then
                    serverCfgFile:write(serverCfgContent)
                    serverCfgFile:close()
                end
                print("Added to server.cfg:", newLine)
            end
        end
    end

    WriteVehicleList(vehList)

    print("Vehicle name checking completed.")
    print("Total vehicle folders found:", #vehList)
    print("Vehicle list after update:")
    for _, vehicle in ipairs(vehList) do
        print(vehicle)
    end

    for i, vehicle in ipairs(vehList) do
        vehList[i] = vehicle:gsub("!", "")
    end
    WriteVehicleList(vehList)

    print("Vehicle list updated and exclamation marks removed.")

    -- Trigger a client event to refresh the vehicle list in-game
    TriggerClientEvent("refreshVehicleList", -1, vehList)
end

RegisterServerEvent("requestVehicleList")
AddEventHandler("requestVehicleList", function()
    TriggerClientEvent("showVehicleList", source, vehList)
end)

UpdateAndRefreshVehicleList()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(45000)  -- Wait for 45 seconds before the next update
        UpdateAndRefreshVehicleList()
    end
end)
