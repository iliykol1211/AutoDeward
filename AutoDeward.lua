local SexAutoDeward = {}
local KostyaUtils = require("KostyaUtils/Utils")
SexAutoDeward.optionEnable = Menu.AddOption({"Utility"}, "AutoDeward", "")

local trigertime = 0
function SexAutoDeward.OnUpdate()
    if not Menu.IsEnabled(SexAutoDeward.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    if not Engine.IsInGame() or not myHero then return end
    if trigertime > GameRules.GetGameTime() then return end
    if Entity.IsAlive(myHero) then
        for i = 0,5 do
            local item = NPC.GetItemByIndex(myHero, i)
            if item and Abilities.Contains(item) and Ability.IsItem(item) and KostyaUtils.CanUseItem(myHero, item) then
                if Ability.GetTargetType(item) & Enum.TargetType.DOTA_UNIT_TARGET_TREE ~= 0 then
                    local rangetoward = Ability.GetLevelSpecialValueForFloat(item, "cast_range_ward")
                    if not rangetoward or rangetoward == 0 then
                        rangetoward = 450
                    end
                    local npcs = NPCs.InRadius(Entity.GetAbsOrigin(myHero), rangetoward, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_BOTH)
                    if npcs then
                        for _,npc in pairs(npcs) do
                            if npc and Entity.IsAlive(npc) and not Entity.IsDormant(npc) and not Entity.IsSameTeam(npc, myHero) and NPC.GetUnitName(npc) then
                                if (NPC.GetUnitName(npc) == "npc_dota_sentry_wards" or NPC.GetUnitName(npc) == "npc_dota_observer_wards" ) then
                                    Ability.CastTarget(item, npc)
                                    trigertime = GameRules.GetGameTime() + 0.5
                                end
                            end
                        end
                    end
                    SexAutoDeward.FindTree(item)
                end
            end
        end
    end
end

function SexAutoDeward.FindTree(item)
    local rangetotree = Ability.GetCastRange(item)
    local myHero = Heroes.GetLocal()
    for _,npc in pairs(NPCs.GetAll()) do
        if npc and Entity.IsAlive(npc) and not Entity.IsSameTeam(npc, myHero) and NPC.IsEntityInRange(myHero, npc, rangetotree) and NPC.GetUnitName(npc) then
            if NPC.GetUnitName(npc) == "npc_dota_treant_eyes" and NPC.IsEntityInRange(npc, myHero, rangetotree) then
                local gettrees = Trees.InRadius(Entity.GetAbsOrigin(npc), 10, true)
                for _,tree in pairs(gettrees) do
                    if tree and Trees.Contains(tree) and Tree.IsActive(tree) then
                        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET_TREE, Tree.GetIndex(tree), Vector(0, 0, 0), item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero, false, true)
                        trigertime = GameRules.GetGameTime() + 0.5
                    end
                end
            end
        end
    end
end

return SexAutoDeward