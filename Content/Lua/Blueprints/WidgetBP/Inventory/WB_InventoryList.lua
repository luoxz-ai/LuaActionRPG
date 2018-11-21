local m = {}

-- parent UObject
local Super = Super

-- global functions
local LoadClass = LoadClass
local CreateDelegate = CreateDelegate
local CreateLatentAction = CreateLatentAction

-- C++ library
local GameplayStatics = LoadClass('GameplayStatics')
local KismetSystemLibrary = LoadClass('KismetSystemLibrary')
local BlueluaLibrary = LoadClass('BlueluaLibrary')
local WidgetBlueprintLibrary = LoadClass('WidgetBlueprintLibrary')

-- Common
local Common = require 'Lua.Blueprints.Common'

function m:Construct()
    self:SetupItemsList()
    Super:PlayAnimation(Super.SwipeInAnimation, 0, 1, Common.EUMGSequencePlayMode.Forward, 1)

    Super.Background.OnMouseButtonDownEvent:Add(
        function()
            Super:CloseList()
            return WidgetBlueprintLibrary:Handled()
        end)

    Super.ClearSlotButton.OnClicked:Add(self, self.OnClearSlotButtonClicked)
end

function m:SetupItemsList()
    self:AddInventoryItemsToList()
    self:AddStoreItemsToList()
    Super.ListTypeLabel:SetText(Super.ItemType.Name)
end

function m:AddInventoryItemsToList()
    local WBInventoryItemClass = LoadClass('/Game/Blueprints/WidgetBP/Inventory/WB_InventoryItem.WB_InventoryItem_C')
    local OriginalDefaultItemClass = WBInventoryItemClass.ItemClass
    local OriginalDefaultOwningList = WBInventoryItemClass.OwningList

    local PlayerController = GameplayStatics:GetPlayerController(Super, 0)
    local Items = PlayerController:GetInventoryItems(nil, Super.ItemType)
    for _, Item in ipairs(Items) do
        WBInventoryItemClass.ItemClass = Item
        WBInventoryItemClass.OwningList = Super
        local InventoryItem = WidgetBlueprintLibrary:Create(Super, WBInventoryItemClass, nil)
        Super.ItemsBox:AddChild(InventoryItem)
    end

    WBInventoryItemClass.ItemClass = OriginalDefaultItemClass
    WBInventoryItemClass.OwningList = OriginalDefaultOwningList
end

function m:AddStoreItemsToList()
    local GameInstance = GameplayStatics:GetGameInstance(Super):ToLuaObject()
    if not GameInstance then
        return
    end

    local PlayerController = GameplayStatics:GetPlayerController(Super, 0)
    local WBPurchaseItemClass = LoadClass('/Game/Blueprints/WidgetBP/Inventory/WB_PurchaseItem.WB_PurchaseItem_C')
    local OriginalDefaultItemClass = WBPurchaseItemClass.ItemClass
    local OriginalDefaultOwningList = WBPurchaseItemClass.OwningList

    local Items = GameInstance:GetStoreItems(Super.ItemType)
    for _, Item in ipairs(Items) do
        if PlayerController:GetInventoryItemCount(Item) <= 0 then
            WBPurchaseItemClass.ItemClass = Item
            WBPurchaseItemClass.OwningList = Super
            local PurchaseItem = WidgetBlueprintLibrary:Create(Super, WBPurchaseItemClass, nil)
            Super.ItemsBox:AddChild(PurchaseItem)
        end
    end

    WBPurchaseItemClass.ItemClass = OriginalDefaultItemClass
    WBPurchaseItemClass.OwningList = OriginalDefaultOwningList
end

function m:OnClearSlotButtonClicked()
    local PlayerController = GameplayStatics:GetPlayerController(Super, 0)
    PlayerController:SetSlottedItem(Super.EquipmentButton.EquipSlot, nil)
    Super:CloseList()
end

return m