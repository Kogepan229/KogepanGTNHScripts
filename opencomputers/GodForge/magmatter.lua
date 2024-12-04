local component = require("component")
local sides = require("sides")
local invoke = component.invoke
local controller = component.me_controller

local rs = "f8bea2cd-8a51-407a-9e39-c7fc09253667"
local tr_pile = "9a47e14b-b47d-4794-941b-42cd675d4fbb"
local tr_fluid_rich = "7c750a4e-6530-4ea1-9e04-240a5a50062d"
local tr_fluid_enlarged = "b4c13db8-e9cb-4248-80af-0affee9e3231"

local side_rs = sides.east
local side_tr_pile_src = sides.south
local side_tr_pile_dest = sides.north
local side_tr_fluid_src = sides.north
local side_tr_fluid_dest = sides.south

local materials = {
  [0] = { [0] = "Tiny Pile of Awakened Draconium Dust", [1] = "Awakened Draconium Plasma" },
  [1] = { [0] = "Tiny Pile of Ichorium Dust", [1] = "Ichorium Plasma" },
  [2] = { [0] = "Tiny Pile of Draconium Dust", [1] = "Draconium Plasma" },
  [3] = { [0] = "Tiny Pile of Neutronium Dust", [1] = "Neutronium Plasma" },
  [4] = { [0] = "Tiny Pile of Celestial Tungsten Dust", [1] = "Celestial Tungsten Plasma" },
  [5] = { [0] = "Tiny Pile of Infinity Dust", [1] = "Infinity Plasma" },
  [6] = { [0] = "Tiny Pile of Bedrockium Dust", [1] = "Bedrockium Plasma" },
  [7] = { [0] = "Tiny Pile of Flerovium Dust", [1] = "Flerovium Plasma" },
  [8] = { [0] = "Tiny Pile of Cosmic Neutronium Dust", [1] = "Cosmic Neutronium Plasma" },
  [9] = { [0] = "Tiny Pile of Six-Phased Copper Dust", [1] = "Six-Phased Copper Plasma" },
  [10] = { [0] = "Tiny Pile of Chromatic Glass Dust", [1] = "Chromatic Glass Plasma" },
  [11] = { [0] = "Tiny Pile of Rhugnor Dust", [1] = "Rhugnor Plasma" },
  [12] = { [0] = "Tiny Pile of Dragonblood Dust", [1] = "Dragonblood Plasma" },
  [13] = { [0] = "Tiny Pile of Hypogen Dust", [1] = "Hypogen Plasma" },
}

local function regist_craftables()
  --- Regist
  local craftables = controller.getCraftables()
  for i, c in pairs(craftables) do
    local tmp = c.getItemStack()["fluidDrop"]["label"]
    for j, m in pairs(materials) do
      if m[1] == tmp then
        materials[j][2] = c
      end
    end
  end

  -- Check
  local failed = false
  for i, m in pairs(materials) do
    if m[2] == nil then
      print("Error", m[1], "craftable is nil.")
      failed = true
    end
  end
  if failed == true then
    os.exit(1)
  end
end

---@return AECraftable | nil
local function get_craftable(pile)
  for j, m in pairs(materials) do
    if m[0] == pile then
      return materials[j][2]
    end
  end
end

---@return number
local function check_rich_amount()
  return invoke(tr_fluid_rich, "getTankLevel", side_tr_fluid_src, 1)
end

---@return number
local function check_enlarged_amount()
  return invoke(tr_fluid_enlarged, "getTankLevel", side_tr_fluid_src, 1)
end

---@return number
local function calc_plasma_amount()
  local amount = check_rich_amount() - check_enlarged_amount()
  return math.abs(amount) * 144
end

---@return string | nil
local function check_pile()
  local stack = invoke(tr_pile, "getStackInSlot", side_tr_pile_src, 1)
  if stack == nil then
    return nil
  end
  return stack["label"]
end

local function transfer_fluids()
  local rich_amount = check_rich_amount()
  local success_rich, value_rich = invoke(tr_fluid_rich, "transferFluid", side_tr_fluid_src, side_tr_fluid_dest,
    rich_amount)

  local enlarged_amount = check_enlarged_amount()
  local success_enlarged, value_enlarged = invoke(tr_fluid_enlarged, "transferFluid", side_tr_fluid_src,
    side_tr_fluid_dest,
    enlarged_amount)

  if success_rich == false or success_enlarged == false then
    print("Error: Failed to transfer fluids.")
    os.exit(4)
  end
  print("Transfered fluids.")
end

local function trash_pile()
  local success, value = invoke(tr_pile, "transferItem", side_tr_pile_src, side_tr_pile_dest, 1, 1, 1)
  if success == false then
    print("Failed to trash pile")
    os.exit(5)
  end
  print("Trashed pile.")
end

---@return boolean
local function check_exists()
  local rich = check_rich_amount()
  local enlarged = check_enlarged_amount()
  local pile = check_pile()
  if rich == 0 or enlarged == 0 or pile == nil then
    return false
  end
  print("----------------------------")
  print(string.format("Rich: %d", rich))
  print(string.format("Enlarged: %d", enlarged))
  print(string.format("Pile: %s", pile))
  return true
end

local function cycle()
  local craftable = get_craftable(check_pile())
  local amount = calc_plasma_amount()
  if craftable == nil then
    print("Error: craftable is nil.")
    os.exit(2)
  end

  local status = craftable.request(amount, false, "")
  print(string.format("Requested: %dL", amount))
  while true do
    os.sleep(1)
    if status.isCanceled() == true then
      local can, reason = status.isCanceled()
      print("Error: request is canceled.")
      print(reason)
      os.exit(3)
    end
    if status.isDone() == true then
      transfer_fluids()
      trash_pile()
      break
    end
  end
end

print("Start Magmatter System")
regist_craftables()
while true do
  local level = invoke(rs, "getInput", side_rs)
  if level > 0 and check_exists() then
    cycle()
  else
    os.sleep(1)
  end
end
