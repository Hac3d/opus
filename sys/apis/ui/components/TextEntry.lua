local class = require('class')
local entry = require('entry')
local UI    = require('ui')
local Util  = require('util')

local colors = _G.colors
local _rep   = string.rep

UI.TextEntry = class(UI.Window)
UI.TextEntry.defaults = {
	UIElement = 'TextEntry',
	value = '',
	shadowText = '',
	focused = false,
	textColor = colors.white,
	shadowTextColor = colors.gray,
	backgroundColor = colors.black, -- colors.lightGray,
	backgroundFocusColor = colors.black, --lightGray,
	height = 1,
	limit = 6,
	accelerators = {
		[ 'control-c' ] = 'copy',
	}
}
function UI.TextEntry:postInit()
	self.value = tostring(self.value)
	self.entry = entry({ limit = self.limit, offset = 2 })
end

function UI.TextEntry:layout()
	UI.Window.layout(self)
	self.entry.width = self.width - 2
end

function UI.TextEntry:setValue(value)
	self.value = value
	self.entry:unmark()
	self.entry.value = tostring(value)
	self.entry:updateScroll()
end

function UI.TextEntry:setPosition(pos)
	self.entry.pos = pos
	self.entry.value = tostring(self.value)
	self.entry:updateScroll()
end

function UI.TextEntry:draw()
	local bg = self.backgroundColor
	local tc = self.textColor
	if self.focused then
		bg = self.backgroundFocusColor
	end

	local text = tostring(self.value)
	if #text > 0 then
		if self.entry.scroll > 0 then
			text = text:sub(1 + self.entry.scroll)
		end
		if self.mask then
			text = _rep('*', #text)
		end
	else
		tc = self.shadowTextColor
		text = self.shadowText
	end

	self:write(1, 1, ' ' .. Util.widthify(text, self.width - 2) .. ' ', bg, tc)

	if self.entry.mark.active then
		local tx = math.max(self.entry.mark.x - self.entry.scroll, 0)
		local tex = self.entry.mark.ex - self.entry.scroll

		if tex > self.width - 2 then -- unsure about this
			tex = self.width - 2 - tx
		end

		if tx ~= tex then
			self:write(tx + 2, 1, text:sub(tx + 1, tex), colors.gray, tc)
		end
	end
	if self.focused then
		self:setCursorPos(self.entry.pos - self.entry.scroll + 2, 1)
	end
end

function UI.TextEntry:reset()
	self.entry:reset()
	self.value = ''
	self:draw()
	self:updateCursor()
end

function UI.TextEntry:updateCursor()
	self:setCursorPos(self.entry.pos - self.entry.scroll + 2, 1)
end

function UI.TextEntry:focus()
	self:draw()
	if self.focused then
		self:setCursorBlink(true)
	else
		self:setCursorBlink(false)
	end
end

function UI.TextEntry:eventHandler(event)
	local text = self.value
	self.entry.value = tostring(text)
	if event.ie and self.entry:process(event.ie) then
		if self.entry.textChanged then
			self.value = self.entry.value
			self:draw()
			if text ~= self.value then
				self:emit({ type = 'text_change', text = self.value, element = self })
			end
		elseif self.entry.posChanged then
			self:updateCursor()
		end
		return true
	end

	return false
end
