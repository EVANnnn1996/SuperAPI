-- Localization
local locale = GetLocale()
if locale == "zhCN" then
	SuperAPI_L = {
		no_superwow = "未检测到 SuperWoW",
		loaded = "|cffffcc00SuperAPI|cffffaaaa 已加载。右键点击小地图图标以打开设置。",

		macro_char_limit = "%d/511 字符使用中",
		option_tooltip_party_chat_bubbles = "在角色头顶的对话气泡中显示密语、小队、团队和战场的聊天文字。",
		party_chat_bubbles_text = "显示密语和小队聊天气泡",

		autoloot_options = {
			"始终开启",
			"始终关闭",
			"Shift 切换为开启",
			"Shift 切换为关闭",
		},
		selection_circle_style = {
			"默认 - 不完整光环",
			"完整光环（需下载贴图）",
			"带朝向箭头的完整光环（需下载贴图）",
			"沿朝向的经典不完整光环",
		},

		autoloot_name = "自动拾取（请查看提示）",
		autoloot_desc = "设置自动拾取的行为。如果同时启用了 Vanilla Tweaks 的快速拾取，所有选项的效果将会反转（始终开启实际为始终关闭，Shift 切换为开启实际为 Shift 切换为关闭，以此类推）。",

		clickthrough_name = "穿透尸体点击",
		clickthrough_desc = "允许你穿透上层尸体，直接拾取下方的尸体。",

		fov_name = "视野范围（需要重载界面）",
		fov_desc = "调整游戏的视野范围（FoV），修改后需要重载界面才会生效。",

		selectioncircle_name = "选择光环样式",
		selectioncircle_desc = "调整选中目标时的光环样式。",

		backgroundsound_name = "后台声音",
		backgroundsound_desc = "允许游戏在窗口位于后台时继续播放声音。",

		uncappedsounds_name = "解除声音上限",
		uncappedsounds_desc = "解除同时播放声音的硬编码上限，让更多声音可以同时播放。启用后会将 SoundSoftwareChannels 和 SoundMaxHardwareChannels 都设置为 64。如果出现异常崩溃，请关闭此选项。",

		lootsparkle_name = "拾取光效",
		lootsparkle_desc = "切换可拾取宝箱上的闪光特效。",

		fubar_name = "FuBar - SuperAPI",
	}
else
	SuperAPI_L = {
		no_superwow = "No SuperWoW detected",
		loaded = "|cffffcc00SuperAPI|cffffaaaa Loaded.  Check the minimap icon for options.",

		macro_char_limit = "%d/511 Characters Used",
		option_tooltip_party_chat_bubbles = "Shows whisper, party, raid, and battleground chat text in speech bubbles above characters' heads.",
		party_chat_bubbles_text = "Show Whisper and Group Chat Bubbles",

		autoloot_options = {
			"Always on",
			"Always off",
			"Shift to toggle on",
			"Shift to toggle off",
		},
		selection_circle_style = {
			"Default - incomplete circle",
			"Full circle (must download texture)",
			"Full circle with arrow for facing direction (must download texture)",
			"Classic incomplete circle oriented in facing direction",
		},

		autoloot_name = "Autoloot (Read tooltip)",
		autoloot_desc = "Specifies autoloot behavior.  If using Vanilla Tweaks quickloot all of these will be reversed (always on will actually be always off, Shift to toggle on will be Shift to toggle off etc).",

		clickthrough_name = "Clickthrough corpses",
		clickthrough_desc = "Allows you to click through corpses to loot corpses underneath them.",

		fov_name = "Field of view (Requires reload)",
		fov_desc = "Changes the field of view of the game.  Requires reload to take effect.",

		selectioncircle_name = "Selection circle style",
		selectioncircle_desc = "Changes the style of the selection circle.",

		backgroundsound_name = "Background sound",
		backgroundsound_desc = "Allows game sound to play even when the window is in the background.",

		uncappedsounds_name = "Uncapped sounds",
		uncappedsounds_desc = "Allows more game sounds to play at the same time by removing hardcoded limit.  This will also set SoundSoftwareChannels and SoundMaxHardwareChannels to 64.  If you experience any weird crashes you may want to turn this off.",

		lootsparkle_name = "Loot Sparkle",
		lootsparkle_desc = "Toggle loot sparkle effect on lootable treasure.",

		fubar_name = "FuBar - SuperAPI",
	}
end

-- No superwow, no superapi
if not SUPERWOW_VERSION then
	DEFAULT_CHAT_FRAME:AddMessage(SuperAPI_L.no_superwow);
	-- this version of SuperAPI is made for SuperWoW 1.2
	-- can somebody make this warning better?
	return
end

SUPERAPI_ContainerItemsTable = {}

SuperAPI = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDebug-2.0", "AceModuleCore-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1")
SuperAPI:RegisterDB("SuperAPIDB")
SuperAPI.frame = CreateFrame("Frame", "SuperAPI", UIParent)

function SuperAPI:OnEnable()
	-- Let macro frame allow 511 characters
	MacroFrame_LoadUI();
	MacroFrameText:SetMaxLetters(511);
	MACROFRAME_CHAR_LIMIT = SuperAPI_L.macro_char_limit;

	-- Change chat bubbles options name
	OPTION_TOOLTIP_PARTY_CHAT_BUBBLES = SuperAPI_L.option_tooltip_party_chat_bubbles;
	PARTY_CHAT_BUBBLES_TEXT = SuperAPI_L.party_chat_bubbles_text;

	SuperAPI.SetItemRefOriginal = SetItemRef
	SuperAPI.SpellButton_OnClickOriginal = SpellButton_OnClick
	SuperAPI.SetItemButtonCountOriginal = SetItemButtonCount
	SuperAPI.SetActionOriginal = GameTooltip.SetAction
	SuperAPI.UnitFrame_OnEnterOriginal = UnitFrame_OnEnter
	SuperAPI.UnitFrame_OnLeaveOriginal = UnitFrame_OnLeave
	SuperAPI.CombatText_AddMessageOriginal = CombatText_AddMessage

	-- activate hooks
	SetItemRef = SuperAPI.SetItemRef
	SpellButton_OnClick = SuperAPI.SpellButton_OnClick
	SetItemButtonCount = SuperAPI.SetItemButtonCount
	GameTooltip.SetAction = SuperAPI.SetAction
	UnitFrame_OnEnter = SuperAPI.UnitFrame_OnEnter
	UnitFrame_OnLeave = SuperAPI.UnitFrame_OnLeave
	CombatText_AddMessage = SuperAPI.CombatText_AddMessage
	

	-- SuperAPI.frame:RegisterEvent("BAG_UPDATE")
	-- SuperAPI.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
	SuperAPI.frame:SetScript("OnEvent", SuperAPI.OnEvent)

	-- this chatcommand is empty. It is essential for showing tooltips of macros
	-- the format for showing a tooltip on a macro is EXACTLY this: /tooltip spell:spellid and then skip line
	SLASH_MACROTOOLTIP1 = "/tooltip"
	SlashCmdList["MACROTOOLTIP"] = function(cmd)
	end
	DEFAULT_CHAT_FRAME:AddMessage(SuperAPI_L.loaded)
end

function SuperAPI:OnEvent()
	if (event == "BAG_UPDATE_COOLDOWN" or event == "BAG_UPDATE") then
		SUPERAPI_ContainerItemsTable = {}
		for ibag = 0, 4 do
			for islot = 1, GetContainerNumSlots(ibag) do
				local bagitemlink = GetContainerItemLink(ibag, islot)
				if bagitemlink then
					local _, _, bagitemID = strfind(bagitemlink, "item:(%d+)")
					bagitemID = tonumber(bagitemID)
					SUPERAPI_ContainerItemsTable[bagitemID] = { bag = ibag; slot = islot }
				end
			end
		end
	end
end

-- HOOKS --
-- Global function to get a spell link from its exact id
SuperAPI.GetSpellLink = function(id)
	local spellname = SpellInfo(id)
	local link = "\124cffffffff\124Henchant:" .. id .. "\124h[" .. spellname .. "]\124h\124r"
	return link
end

-- reformat "Enchant" itemlinks to better supported "Spell" itemlinks
SuperAPI.SetItemRef = function(link, text, button)
	link = gsub(link, "spell:", "enchant:")
	SuperAPI.SetItemRefOriginal(link, text, button)
end

-- hooking spellbook frame to get a spell link on shift clicking a spell's button with chatframe open
SuperAPI.SpellButton_OnClick = function(drag)
	if ((not drag) and IsShiftKeyDown() and ChatFrameEditBox:IsVisible() and (not MacroFrame or not MacroFrame:IsVisible())) then
		local bookId = SpellBook_GetSpellID(this:GetID());
		local _, _, spellID = GetSpellName(bookId, SpellBookFrame.bookType)
		local link = SuperAPI.GetSpellLink(spellID)
		ChatFrameEditBox:Insert(link)
	else
		SuperAPI.SpellButton_OnClickOriginal(drag)
	end
end

-- hooking bags item button frames to show uses count
SuperAPI.SetItemButtonCount = function(button, count)
	if not button or not count then
		return SuperAPI.SetItemButtonCountOriginal(button, count)
	end
	if (count < 0) then
		if (count < -999) then
			count = "*";
		end
		getglobal(button:GetName() .. "Count"):SetText(-count);
		getglobal(button:GetName() .. "Count"):Show();
		getglobal(button:GetName() .. "Count"):SetFontObject(NumberFontNormalYellow);
	else
		getglobal(button:GetName() .. "Count"):SetFontObject(NumberFontNormal);
		SuperAPI.SetItemButtonCountOriginal(button, count)
	end
end

-- hooking actionbutton tooltip to show item tooltip on macros
SuperAPI.SetAction = function(this, buttonID)
	--local name, actiontype, macroID = GetActionText(buttonID)
	--if actiontype == "MACRO" then
	--	local _,_, body = GetMacroInfo(macroID)
	--	local _,_, itemID = strfind(body, "^/tooltip item:(%d+)")
	--	if itemID then
	--		itemID = tonumber(itemID)
	--		iteminfo = SUPERAPI_ContainerItemsTable[itemID]
	--		if iteminfo then
	--			return this:SetBagItem(iteminfo.bag, iteminfo.slot)
	--		end
	--	end
	--end
	--
	return SuperAPI.SetActionOriginal(this, buttonID)
end

-- Add Mouseover casting to default blizzard unitframes and all unitframe addons that use the same function
SuperAPI.UnitFrame_OnEnter = function()
	SuperAPI.UnitFrame_OnEnterOriginal()
	SetMouseoverUnit(this.unit)
end

SuperAPI.UnitFrame_OnLeave = function()
	SuperAPI.UnitFrame_OnLeaveOriginal()
	SetMouseoverUnit()
end

-- Fix scrolling combat text healer name
SuperAPI.CombatText_AddMessage = function(message, scrollFunction, r, g, b, displayType, isStaggered)
	local newMessage = gsub(message, "(%s%[)(0x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x)(%])", function(bracket1, hex, bracket2)
		if UnitIsUnit(hex, "player") then return nil
		else return " ["..UnitName(hex).."]" end
	end)
	return SuperAPI.CombatText_AddMessageOriginal(newMessage, scrollFunction, r, g, b, displayType, isStaggered)
end
