require "class"

local Widget = require "widgets/widget"

local Image = require "widgets/image"
local FoodRecipePopup = require "widgets/foodrecipepopup"
local ResolveInventoryItemAssets = require "utils/resolveinventoryitemassets"

local FoodItem = Class(Widget, function(self, owner, foodcrafting, recipe, hasPopup)
  Widget._ctor(self, "FoodItem")
  self.owner = owner
  self.foodcrafting = foodcrafting
  self.recipe = recipe
  self.slot = nil
  self.hasPopup = hasPopup

  self.prefab = self.recipe.name
  self:DefineAssetData()
  self.tile = self:AddChild(Image(self.atlas, self.item_tex))

  if self.hasPopup then
    self.recipepopup = self:AddChild(FoodRecipePopup(self.owner, self.recipe))
    self.recipepopup:SetPosition(-24,-8,0)
    self.recipepopup:Hide()
    local s = 1.60
    self.recipepopup:SetScale(s,s,s)
  end
end)

function FoodItem:DefineAssetData()
  self.item_tex = self.prefab..'.tex'
  self.atlas = GetInventoryItemAtlas(self.item_tex)
  self.localized_name = STRINGS.NAMES[string.upper(self.prefab)] or self.prefab
  -- No idea about this issue: 
  --    https://forums.kleientertainment.com/forums/topic/145440-the-atlas-resolved-by-getinventoryitematlas-cannot-be-tested-by-thesimatlascontains
  -- if not self.atlas or not TheSim:AtlasContains(self.atlas, self.item_tex) then
  --   print("Craft pot ~ AssetData: failed to resolve[" .. self.prefab .. "]" .. self.localized_name .. " tex:" .. (self.item_tex or "nil") .. " atlas:" .. (self.atlas or "nil"))
  -- end
end

function FoodItem:SetSlot(slot)
  self.slot = slot
end

function FoodItem:ShowPopup(cookerIngs)
  if self.hasPopup then
    self.recipepopup:Update(cookerIngs)
    self.recipepopup:Show()
  end
end

function FoodItem:HidePopup()
  if self.hasPopup then
    self.recipepopup:Hide()
  end
end

function FoodItem:OnGainFocus()
  FoodItem._base.OnGainFocus(self)
  if self.slot and self.slot.slot_idx then
    self.foodcrafting:FoodFocus(self.slot.slot_idx)
  end
end

function FoodItem:Refresh()
  local recipe = self.recipe
  local unlocked = recipe.unlocked
  local reqsmatch = recipe.reqsmatch
  local readytocook = recipe.readytocook

  if (readytocook or reqsmatch ) and unlocked then
    self.tile:SetTint(1,1,1,1)
  else
    self.tile:SetTint(0,0,0,1)
  end
end


return FoodItem
