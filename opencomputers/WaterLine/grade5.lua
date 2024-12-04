local component = require("component")
local sides = require("sides")
local invoke = component.invoke

local rs_machine = "d3ff8563-ab4a-4da6-864e-40f3b42f7131" --マシンのアクティブ信号
local rs_heater = "8c286ca5-5f57-4200-b2b4-8c70c6ca53bc"  --ヒーターのアクティブ信号
local rs_cooler = "b2889f99-3d42-46ff-ae82-1f829f073c5d"  --クーラーのアクティブ信号

local side_rs_machine = sides.east
local side_rs_heater = sides.east
local side_rs_cooler = sides.east

local function updown()
  invoke(rs_heater, "setOutput", side_rs_heater, 15)
  os.sleep(10.5)

  invoke(rs_heater, "setOutput", side_rs_heater, 0)
  os.sleep(1)

  invoke(rs_cooler, "setOutput", side_rs_cooler, 15)
  os.sleep(22)

  invoke(rs_cooler, "setOutput", side_rs_cooler, 0)
  os.sleep(1)
end

local function cycle()
  local count = 0
  while count < 3 do
    updown()
    count = count + 1
  end
end


print("Start Grade5 Water Line System")
invoke(rs_heater, "setOutput", side_rs_heater, 0)
invoke(rs_cooler, "setOutput", side_rs_cooler, 0)
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
