local component = require("component")
local sides = require("sides")
local invoke = component.invoke

local rs_machine = "98544c4d-7656-4904-8c1c-aa60a5276058" --マシンのアクティブ信号
local tr_quark_up = "bfeaf30c-4e11-4b40-b65b-1ea44ee32873"
local tr_quark_down = "8b5f02d6-316e-4384-b2d3-9d91379d24ab"
local tr_quark_strange = "e43c0571-dbc6-41af-834e-8a1a9b203714"
local tr_quark_charm = "bbe63d6d-95d2-4320-ac90-bbde976e7293"
local tr_quark_bottom = "8aef9f09-52be-420b-b27d-ce8835e546af"
local tr_quark_top = "48189b23-9ce4-483e-a745-fb14266202e5"
local tr_infinity = "ea8b706b-14f4-42f2-9950-94713911cd61"
local tr_matter = "932002cc-f2aa-404b-97b8-6c0859efceb1"

local side_rs_machine = sides.north
local side_tr_src = sides.south
local side_tr_dest = sides.north

local up = "up"
local down = "down"
local strange = "strange"
local charm = "charm"
local bottom = "bottom"
local top = "top"

local quark_list = {
    up = tr_quark_up,
    down = tr_quark_down,
    strange = tr_quark_strange,
    charm = tr_quark_charm,
    bottom = tr_quark_bottom,
    top = tr_quark_top,
}

local quark_order = {
    [0] = { [0] = up, [1] = down },
    [1] = { [0] = up, [1] = strange },
    [2] = { [0] = up, [1] = charm },
    [3] = { [0] = up, [1] = bottom },
    [4] = { [0] = up, [1] = top },
    [5] = { [0] = down, [1] = strange },
    [6] = { [0] = down, [1] = charm },
    [7] = { [0] = down, [1] = bottom },
    [8] = { [0] = down, [1] = top },
    [9] = { [0] = strange, [1] = charm },
    [10] = { [0] = strange, [1] = bottom },
    [11] = { [0] = strange, [1] = top },
    [12] = { [0] = charm, [1] = bottom },
    [13] = { [0] = charm, [1] = top },
    [14] = { [0] = bottom, [1] = top },
}

local quark_infinity

local function init_infinity()
    quark_infinity = {}
    quark_infinity[up] = 144
    quark_infinity[down] = 144
    quark_infinity[strange] = 144
    quark_infinity[charm] = 144
    quark_infinity[bottom] = 144
    quark_infinity[top] = 144
end

local function insert_quark(quark)
    local infinity = quark_infinity[quark]
    local success_infinity, value_infinity = invoke(tr_infinity, "transferFluid", side_tr_src, side_tr_dest, infinity)
    if success_infinity == true then
        os.sleep(0.5)
        local quark_tr = quark_list[quark]
        local success, value = invoke(quark_tr, "transferItem", side_tr_src, side_tr_dest, 1, 1, 1)
        if success == false then
            print("Failed to insert " .. quark)
        end
        quark_infinity[quark] = infinity * 2
    else
        print("Failed to transfer infinity")
    end
end

local function check_matter()
    return invoke(tr_matter, "getTankLevel", side_tr_src, 1)
end

local function transfer_matter()
    local amount = check_matter()
    if amount <= 0 then
        return
    end
    local success, value = invoke(tr_matter, "transferFluid", side_tr_src, side_tr_dest, amount)
    if success == false then
        print("Failed to transfer matter")
    end
end

local function cycle()
    init_infinity()
    transfer_matter()
    for key, val in pairs(quark_order) do
        insert_quark(val[0])
        insert_quark(val[1])
        os.sleep(1.5) --- Wait 30 ticks
        if check_matter() == 2000 then
            break
        end
    end
end

print("Start Grade 8 Water Line System")
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
