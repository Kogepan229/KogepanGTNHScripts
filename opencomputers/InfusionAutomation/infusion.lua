-- こんすたんたんさんのスクリプトを元参考にしたもの
-- Code Link: https://gist.github.com/cons-tan-tan/a54a86b86a5fba56767aedfae4da3aec
-- 記事: https://note.com/cons_tan_tan/n/n2f48b8355fb5

local component = require("component")
local sides = require("sides")
local invoke = component.invoke
local controller = component.me_controller

local rs_wand = "9171ff91-1b1f-4292-90e1-94a587cd1067" -- Infusion Claw起動用のRedstone I/O
local rs_acce = "389682ab-f0d4-4062-9df2-7b8583182433" -- World Accelerator起動用のRedstone I/O
local rs_expo = "6e04bcae-decd-420c-af3c-9fd263d853d1" -- Export Busを機能させる用のRedstone I/O
local tr_wand = "0267fb98-d861-4012-b95e-31dca457f6b8" -- Infusion Clawの杖管理用のTransposer
local tr_cent = "9316e0b8-4d55-40de-a27b-6b4f2ae6e56e" -- 中央の台座管理用のTransposer

local side_rs_wand = sides.down
local side_rs_acce = sides.down
local side_rs_expo = sides.south
local side_tr_wand = sides.east
local side_tr_wand_chest = sides.west
local side_tr_cent = sides.east
local side_tr_output = sides.west


local function wandIsFine() -- 杖のVisがすべて10以上かどうか
  if invoke(tr_wand, "getSlotStackSize", side_tr_wand, 1) == 0 then
    return false
  end

  local wand_aspects = invoke(tr_wand, "getStackInSlot", side_tr_wand, 1).aspects
  for i = 1, 6 do
    if wand_aspects[i].amount <= 1000 then -- ここでの1000はゲーム中の表記だと10.00vis
      return false
    end
  end
  return true
end

local function swapWand() -- 杖の交換
  if not wandIsFine() then
    print("Swapping wand")
    while invoke(tr_wand, "transferItem", side_tr_wand, side_tr_wand_chest, 1, 1, 1) == 0 do
      os.sleep(1)
    end
    while invoke(tr_wand, "getSlotStackSize", side_tr_wand, 1) == 0 do
      os.sleep(1)
    end
    print("Completed swapping wand!")
  end
end

local function scanCenterItem() -- 中央台座のアイテム名を調べる
  local item = invoke(tr_cent, "getStackInSlot", side_tr_cent, 1)
  if item == nil then
    return nil
  else
    return item.label
  end
end

local function scanCenterItemNum()
  return invoke(tr_cent, "getSlotStackSize", side_tr_cent, 1)
end

local function itemOutput() -- 中央台座のアイテムをすべて搬出
  local item_num = scanCenterItemNum()
  print("output item num: " .. item_num)
  if item_num == 0 then
    print("Error: result item num is 0")
    return
  end

  for i = 1, item_num do
    invoke(tr_cent, "transferItem", side_tr_cent, side_tr_output, 1, 1, 1)
  end
end

local function remainingOutput() -- 周囲の台座に残ったアイテムをすべて搬出
  local center_item_num = scanCenterItemNum()
  if #controller.getItemsInNetwork() >= center_item_num + 1 then
    invoke(rs_expo, "setOutput", side_rs_expo, 15)
    print("Detected remaining items")
    while #controller.getItemsInNetwork() >= center_item_num + 1 do
      os.sleep(0.05)
    end
    invoke(rs_expo, "setOutput", side_rs_expo, 0)
    print("Exported remaining items")
  end
end

local function infusion()
  local original_item = scanCenterItem()
  if original_item == nil then
    return
  end

  print("Start infusion")

  while not wandIsFine() do
    swapWand()
  end

  invoke(rs_acce, "setOutput", side_rs_acce, 15)
  invoke(rs_wand, "setOutput", side_rs_wand, 15)

  -- Wait infusion
  local current_item = scanCenterItem()
  while original_item == current_item do
    os.sleep(0.05)
    current_item = scanCenterItem()
  end

  print("Result: " .. current_item)

  invoke(rs_acce, "setOutput", side_rs_acce, 0)
  invoke(rs_wand, "setOutput", side_rs_wand, 0)

  remainingOutput()
  itemOutput()

  print("Finished infusion")
  print("-------------------------")
end

local function init()
  invoke(rs_acce, "setOutput", side_rs_acce, 0)
  invoke(rs_wand, "setOutput", side_rs_wand, 0)
  invoke(rs_expo, "setOutput", side_rs_expo, 0)
end

-- main
print("Start infusion program")
init()
local start_infusion = false
while true do
  if start_infusion then
    infusion()
    -- Start infusion Immediately if it can
    os.sleep(0.05)
    if scanCenterItem() ~= nil then
      start_infusion = true
    else
      start_infusion = false
    end
  end

  if start_infusion == false then
    os.sleep(1)
    if scanCenterItem() ~= nil then
      start_infusion = true
    end
  end
end
