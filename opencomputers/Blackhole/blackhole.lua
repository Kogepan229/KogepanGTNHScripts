local component = require("component")
local sides = require("sides")
local invoke = component.invoke
local controller = component.me_controller

local rs_machine = "58f17c68-66a3-4f49-9907-9b0aa699b06e"        --マシンのON/OFF信号
local rs_machine_active = "2e4124d8-f10b-4a27-a8da-5154be46ca54" --マシンのアクティブ信号
local tr_seed = "758785b9-9c7d-430e-aef8-0424f909f8a5"
local tr_collapser = "fba53bbb-9226-4d2b-9624-5995ae758beb"
local tr_spacetime = "d9a27a85-5208-4ae5-a613-a46f081d561c"

local side_rs_machine = sides.north
local side_rs_machine_active = sides.north
local side_tr_item_src = sides.up
local side_tr_item_dest = sides.down
local side_tr_spacetime_src = sides.up
local side_tr_spacetime_dest = sides.down

local function activate(active)
  if active == true then
    invoke(rs_machine, "setOutput", side_rs_machine, 15)
  else
    invoke(rs_machine, "setOutput", side_rs_machine, 0)
  end
end

local function open()
  local value = invoke(tr_seed, "transferItem", side_tr_item_src, side_tr_item_dest, 1, 1, 1)
  if value ~= 1 then
    print("Failed to open Black Hole")
    os.exit()
  end
end

local function close()
  local value = invoke(tr_collapser, "transferItem", side_tr_item_src, side_tr_item_dest, 1, 1, 1)
  if value ~= 1 then
    print("Failed to close Black Hole")
    activate(false)
    os.exit()
  end
end

local function insert_spacetime(amount)
  local success, value = invoke(tr_spacetime, "transferFluid", side_tr_spacetime_src, side_tr_spacetime_dest, amount)
  if success == true and value == amount then
    return true
  end
  return false
end

local function check_processing()
  local level = invoke(rs_machine_active, "getInput", side_rs_machine_active)
  if level > 0 then
    return true
  else
    return false
  end
end

local function check_should_start()
  ---@diagnostic disable-next-line: missing-parameter
  local item_num = #controller.getItemsInNetwork()
  local fluid_num = #controller.getFluidsInNetwork()
  if item_num > 0 or fluid_num > 0 then
    return true
  else
    return false
  end
end

local function cycle()
  print("Open Black Hole")
  open()
  os.sleep(2) --- Wait 1s
  -- activate(true)
  local stability = 100

  while true do
    if stability < 18 then
      local success = insert_spacetime(30690)
      if success == true then
        print("Insert SpaceTime")
        os.sleep(303) --- 3秒余裕を持たせる
      else
        print("Failed insert SpaceTime")
      end
      close()
      while check_processing() == true do
        os.sleep(1)
      end
      os.sleep(2)
      print("Closed Black Hole")
      break
    end

    stability = stability - 1
    os.sleep(1)
  end
end


print("Start Black Hole System")
activate(true)
while true do
  if check_should_start() == true then
    cycle()
  else
    os.sleep(1)
  end
end
