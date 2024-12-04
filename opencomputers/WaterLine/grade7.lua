local component = require("component")
local sides = require("sides")
local invoke = component.invoke

local rs_machine = "a65a1b3a-a9fe-4ba6-aca5-d00914c7f257" --マシンのアクティブ信号
local rs_signal = "11d8f1d7-a816-4630-a4e7-c8a41fe29f28"
local tr_neutronium_tank = "b1f11013-f4a9-4228-a97a-433dbda0ff8a"
local tr_helium_tank = "d4f1ab8a-f9f9-4624-b105-4e2eaa93f07e"
local tr_neon_tank = "de5fd2d7-a6a9-4a78-8783-a38923c7ad93"
local tr_krypton_tank = "57bf1082-5f3d-4dd9-9daf-b5a62cbb0854"
local tr_xenon_tank = "e83f0a70-f265-459c-8895-0affb75b3f9d"
local tr_umv_tank = "2c595eb3-1266-4379-b098-5d0875d77c28"
local tr_supercoolant_tank = "1a991ccc-2251-4f7c-bac7-84ad05736418"

local side_rs_machine = sides.north
local side_rs_signal = sides.north
local side_fluid_src = sides.south
local side_fluid_target = sides.north

local function transfer_helium()
    local amount = 10000
    local success, value = invoke(tr_helium_tank, "transferFluid", side_fluid_src, side_fluid_target, amount)
    if success == false then
        print("Failed to transfer helium")
    end
    if value ~= amount then
        print("Transferred helium is not correct")
    end
end

local function transfer_neon()
    local amount = 7500
    local success, value = invoke(tr_neon_tank, "transferFluid", side_fluid_src, side_fluid_target, amount)
    if success == false then
        print("Failed to transfer neon")
    end
    if value ~= amount then
        print("Transferred neon is not correct")
    end
end

local function transfer_krypton()
    local amount = 5000
    local success, value = invoke(tr_krypton_tank, "transferFluid", side_fluid_src, side_fluid_target, amount)
    if success == false then
        print("Failed to transfer krypton")
    end
    if value ~= amount then
        print("Transferred krypton is not correct")
    end
end

local function transfer_xenon()
    local amount = 2500
    local success, value = invoke(tr_xenon_tank, "transferFluid", side_fluid_src, side_fluid_target, amount)
    if success == false then
        print("Failed to transfer xenon")
    end
    if value ~= amount then
        print("Transferred xenon is not correct")
    end
end

local function transfer_umv()
    local amount = 1440
    local success, value = invoke(tr_umv_tank, "transferFluid", side_fluid_src, side_fluid_target, amount)
    if success == false then
        print("Failed to transfer umv")
    end
    if value ~= amount then
        print("Transferred umv is not correct")
    end
end

local function transfer_neutronium()
    local amount = 4608
    local success, value = invoke(tr_neutronium_tank, "transferFluid", side_fluid_src, side_fluid_target, amount)
    if success == false then
        print("Failed to transfer neutronium")
    end
    if value ~= amount then
        print("Transferred neutronium is not correct")
    end
end

local function transfer_supercoolant()
    local amount = 10000
    local success, value = invoke(tr_supercoolant_tank, "transferFluid", side_fluid_src, side_fluid_target, amount)
    if success == false then
        print("Failed to transfer supercoolant")
    end
    if value ~= amount then
        print("Transferred supercoolant is not correct")
    end
end

local function cycle()
    local level = invoke(rs_signal, "getInput", side_rs_signal)
    if level == 0 then
        transfer_supercoolant()
    elseif level == 1 then
        transfer_helium()
    elseif level == 2 then
        transfer_umv()
    elseif level == 3 then
        transfer_neon()
        transfer_umv()
    elseif level == 4 then
        transfer_neutronium()
    elseif level == 5 then
        transfer_krypton()
        transfer_neutronium()
    elseif level == 6 then
        transfer_umv()
        transfer_neutronium()
    elseif level == 7 then
        transfer_xenon()
        transfer_umv()
        transfer_neutronium()
    end
    os.sleep(100)
end

print("Start Grade 7 Water Line System")
local prev_level = 0
while true do
    local level = invoke(rs_machine, "getInput", side_rs_machine)
    if prev_level ~= level and level > 0 then
        -- マシンがアクティブのとき
        cycle()
    else
        os.sleep(1)
    end
    prev_level = level
end
