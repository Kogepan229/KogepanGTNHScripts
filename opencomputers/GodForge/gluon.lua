local component = require("component")
local sides = require("sides")

local tr_drive = component.proxy("a4eb6bd5-fdb9-4eb6-b29f-ce203335a130", "transposer")

local controller_storage = component.proxy("e7c74249-db5b-4d0b-b6ad-beb8fe71e6de", "me_controller")
local controller_plasma = component.proxy("5819fc7a-d662-42e8-bfeb-ee2e87e1dedf", "me_controller")

local rs_active = component.proxy("91ff8de7-286d-47eb-8400-c4e1657105ab", "redstone")
local side_rs_active = sides.east

---@return number | nil
local function getPlasmaAmountFromList(plasmaList, plasmaName)
  for i, plasma in ipairs(plasmaList) do
    if plasma["name"] == plasmaName then
      return plasma["amount"]
    end
  end
  return nil
end

local function requestPlasma(plasmaList)
  local craftables = controller_plasma.getCraftables()
  ---@type AECraftingJob[]
  local jobs = {}

  for i, craftable in ipairs(craftables) do
    local craftablePlasmaName = craftable.getItemStack()["fluidDrop"]["label"]
    local amount = getPlasmaAmountFromList(plasmaList, craftablePlasmaName)
    if amount ~= nil then
      print("Request " .. craftablePlasmaName .. " " .. amount .. "L")
      local job = craftable.request(amount, false, "")
      table.insert(jobs, job)
    end
  end

  while true do
    local crafting = false
    for i, job in ipairs(jobs) do
      if job.isCanceled() == true then
        local can, reason = job.isCanceled()
        print("Error: request is canceled.")
        print(reason)
        os.exit(0)
      end
      if job.isDone() == false then
        crafting = true
      end
    end

    if crafting == false then
      break
    end

    os.sleep(20)
  end
end

local function calcPlasma()
  local plasmaList = {}

  local items = controller_storage.getItemsInNetwork({})
  for i, item in ipairs(items) do
    print(item.label .. " " .. item.size)
    local plasmaName = string.gsub(item.label, "Dust", "Plasma")
    local plasmaAmount = item.size * 144 * 9
    table.insert(plasmaList, { name = plasmaName, amount = plasmaAmount })
  end

  local fluids = controller_storage.getFluidsInNetwork()
  for i, fluid in ipairs(fluids) do
    print(fluid.label .. " " .. fluid.amount)
    local plasmaName = string.gsub(fluid.label, " Gas", "") .. " Plasma"
    local plasmaAmount = fluid.amount * 1000
    table.insert(plasmaList, { name = plasmaName, amount = plasmaAmount })
  end

  return plasmaList
end

local function voidItemAndFluid()
  tr_drive.transferItem(sides.bottom, sides.up, 1, 3, 1)
  tr_drive.transferItem(sides.bottom, sides.up, 1, 2, 2)
  tr_drive.transferItem(sides.bottom, sides.up, 1, 1, 3)

  while tr_drive.getSlotStackSize(sides.up, 9) == 0 do
    os.sleep(1)
  end

  tr_drive.transferItem(sides.up, sides.bottom, 1, 7, 1)
  tr_drive.transferItem(sides.up, sides.bottom, 1, 8, 2)
  tr_drive.transferItem(sides.up, sides.bottom, 1, 9, 3)

  while tr_drive.getSlotStackSize(sides.bottom, 3) == 0 do
    os.sleep(1)
  end
end

local function getContainedTypeNum()
  local fluids = controller_storage.getFluidsInNetwork()
  local items = controller_storage.getItemsInNetwork({})
  return #fluids + #items
end


local function cycle()
  local plasmaList = calcPlasma()
  voidItemAndFluid()
  requestPlasma(plasmaList)

  print("----------------------------")
end

local function check_exists()
  return getContainedTypeNum() == 7
end



print("Start Degenerate Quark Gluon Plasma System")

while true do
  local level = rs_active.getInput(side_rs_active)
  if level > 0 and check_exists() then
    cycle()
  else
    os.sleep(1)
  end
end
