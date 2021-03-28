return {
PlaceObj('ModItemCode', {
	'name', "AddEntities",
	'FileName', "Code/AddEntities.lua",
}),
PlaceObj('ModItemCode', {
	'name', "BoostedVistaDeposit",
	'FileName', "Code/BoostedVistaDeposit.lua",
}),
PlaceObj('ModItemCode', {
	'comment', "Spawn New Deposits, base mod code",
	'FileName', "Code/Script.lua",
}),
PlaceObj('ModItemCode', {
	'name', "TriboEffectDeposit",
	'FileName', "Code/TriboEffectDeposit.lua",
}),
PlaceObj('ModItemCode', {
	'name', "RD_Override_ConstructionStatus",
	'FileName', "Code/RD_Override_ConstructionStatus.lua",
}),
PlaceObj('ModItemCode', {
	'name', "Anomalies",
	'FileName', "Code/Anomalies.lua",
}),
PlaceObj('ModItemCode', {
	'name', "RandomPerSector",
	'FileName', "Code/RandomPerSector.lua",
}),
PlaceObj('ModItemXTemplate', {
	__content = function ()  end,
	__copy_group = "Infopanel",
	__is_kind_of = "ipEffectDeposit",
	comment = "Non-Conditional copy of ipEffectDeposit",
	group = "Infopanel",
	id = "ipEffectDeposit_RD",
	PlaceObj('XTemplateTemplate', {
		'comment', "ipEffectDeposit without conditions",
		'__template', "Infopanel",
		'Id', "ipEffectDeposit_RD",
		'Title', T(416836394594, --[[ModItemXTemplate ipEffectDeposit_RD Title]] "<DisplayName>"),
		'Description', T(856133410830, --[[ModItemXTemplate ipEffectDeposit_RD Description]] "<ipDescription>"),
	}, {
		PlaceObj('XTemplateTemplate', {
			'comment', "ipEffectDeposit Section",
			'__template', "InfopanelSection",
			'RolloverTranslate', false,
			'RolloverText', "Various new effects can come from being near these locations",
			'RolloverTitle', "Tip",
			'Title', "New Effects",
			'Icon', "UI/Icons/Sections/deposit.tga",
		}, {
			PlaceObj('XTemplateTemplate', {
				'comment', "Set by code ingame xx:GetInfoPanelDetails",
				'__template', "InfopanelText",
				'Text', T(--[[ModItemXTemplate ipEffectDeposit_RD Text]] "<InfopanelDetails>"),
			}),
			}),
		PlaceObj('XTemplateTemplate', {
			'comment', "ipTWZ copy from SkiRich- kindof",
			'__template', "InfopanelSection",
			'RolloverText', T(562655489367, --[[ModItemXTemplate ipEffectDeposit_RD RolloverText]] "Control when to display the Zone.\n<em>On</em><right>Show if selected<left>\n<em>Locked</em><right>Always Show<left>\n<em>Off</em><right>Always Hide<left>"),
			'RolloverTitle', "Options Help",
			'RolloverHint', T(307096774514, --[[ModItemXTemplate ipEffectDeposit_RD RolloverHint]] "<center><left_click> Toggle zone options."),
			'OnContextUpdate', function (self, context, ...)
				if context.ipTWZState == "On" then
					self:SetIcon(context.ipTWZIcon)
				elseif context.ipTWZState == "Locked" then
					self:SetIcon(context.ipTWZIcon)
				elseif context.ipTWZState == "Off" then
					self:SetIcon(context.ipTWZIcon)
				end
			end,
			'Title', T(672405560937, --[[ModItemXTemplate ipEffectDeposit_RD Title]] "Show Field Zone [<em><ipTWZState></em>]"),
			'Icon', 'CurrentModPath .. "UI/RD_WZ_On.png"',
		}, {
			PlaceObj('XTemplateFunc', {
				'name', "OnMouseButtonDown(self, pos, button)",
				'parent', function (parent, context)
					return parent.parent
				end,
				'func', function (self, pos, button)
					local building = self.context
					if button == "L" then
						PlayFX("DomeAcceptColonistsChanged", "start", building)
						-- put your stuff here
						building:infopanel_TWZ()
						ObjModified(building)
					end
					--print("clicked on")
				end,
			}),
			}),
		PlaceObj('XTemplateTemplate', {
			'__template', "sectionCheats",
		}),
		}),
}),
}
