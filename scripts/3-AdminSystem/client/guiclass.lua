class "GUI"

local sx, sy = Game:GetSetting ( 30 ), Game:GetSetting ( 31 )
local textBoxTypes =
	{
		[ "text" ] = TextBox,
		[ "numeric" ] = TextBoxNumeric,
		[ "multiline" ] = TextBoxMultiline,
		[ "password" ] = PasswordTextBox
	}
local protected = { }

function GUI:Window( title, pos, size )
	local window = Window.Create()
	window:SetTitle( title )
	window:SetPositionRel( pos )
	window:SetSizeRel( size )

	return window
end

function GUI:Button( text, pos, size, parent, id )
	local button = Button.Create()
	button:SetText( text )
	button:SetPositionRel( pos )
	button:SetSizeRel( size )
	if ( id ) then
		button:SetDataString ( "id", id )
		table.insert ( protected, button )
	end
	if ( parent ) then
		button:SetParent( parent )
	end

	return button
end

function GUI:Label( text, pos, size, parent )
	local label = Label.Create()
	label:SetText( text )
	label:SetPositionRel( pos )
	label:SetSizeRel( size )
	if ( parent ) then
		label:SetParent( parent )
	end

	return label
end

function GUI:SortedList( pos, size, parent, columns )
	local list = SortedList.Create()
	list:SetPositionRel( pos )
	list:SetSizeRel( size )
	if ( parent ) then
		list:SetParent( parent )
	end
	if ( type ( columns ) == "table" and #columns > 0 ) then
		for _, col in ipairs ( columns ) do
			if tonumber ( col.width ) then
				list:AddColumn ( tostring ( col.name ), tonumber ( col.width ) )
			else
				list:AddColumn ( tostring ( col.name ) )
			end
		end
	end

	return list
end

function GUI:TextBox( text, pos, size, type, parent )
	local func = textBoxTypes [ type ]
	if ( func ) then
		local textBox = func.Create()
		textBox:SetText( text )
		textBox:SetPositionRel( pos )
		textBox:SetSizeRel( size )
		if ( parent ) then
			textBox:SetParent( parent )
		end
		textBox:Subscribe( "Focus", self, self.Focus )
		textBox:Subscribe( "Blur", self, self.Blur )
		return textBox
	else
		return false
	end
end

function GUI:ComboBox( pos, size, parent, items )
	local menuItems = {}
	local comboBox = ComboBox.Create()
	comboBox:SetPositionRel( pos )
	comboBox:SetSizeRel( size )
	if ( parent ) then
		comboBox:SetParent( parent )
	end
	if ( type ( items ) == "table" and #items > 0 ) then
		for _, item in ipairs ( items ) do
			menuItems [ item ] = comboBox:AddItem ( item )
		end
	end

	return comboBox, menuItems
end

function GUI:ListBox( pos, size, parent, label )
	local list = ListBox.Create()
	list:SetPositionRel( pos )
	list:SetSizeRel( size )
	if ( parent ) then
		list:SetParent( parent )
	end
	if ( label ) then
		tLabel = Label.Create()
		if ( parent ) then
			tLabel:SetParent( parent )
		end
		tLabel:SetText( label )
		tLabel:SetPositionRel( Vector2 ( pos.x, pos.y - 0.031 ) )
		tLabel:SetSizeRel( size )
		tLabel:SetAlignment( 64 )
	end

	return list, tLabel
end

function GUI:CollapsibleList( pos, size, parent, categories )
	local cats = {}
	local list = CollapsibleList.Create()
	list:SetPositionRel( pos )
	list:SetSizeRel( size )
	if ( parent ) then
		list:SetParent ( parent )
	end
	if ( type ( categories ) == "table" and #categories > 0 ) then
		for _, cat in ipairs ( categories ) do
			table.insert ( cats, list:Add ( tostring ( cat ) ) )
		end
	end

	return list, cats
end

function GUI:ScrollControl( pos, size, parent )
	local scroll = ScrollControl.Create()
	scroll:SetPositionRel( pos )
	scroll:SetSizeRel( size )
	if ( parent ) then
		scroll:SetParent( parent )
	end

	return scroll
end

function GUI:TabControl( tabs, pos, size, parent )
	local addedTabs = {}
	local tabControl = TabControl.Create()
	tabControl:SetPositionRel( pos )
	tabControl:SetSizeRel( size )
	if ( parent ) then
		tabControl:SetParent( parent )
	end
	if ( tabs and #tabs > 0 ) then
		for _, tab in ipairs ( tabs ) do
			local tabName = tab:lower()
			addedTabs [ tabName ] = { }
			addedTabs [ tabName ].base = BaseWindow.Create()
			addedTabs [ tabName ].base:SetPositionRel( pos )
			addedTabs [ tabName ].base:SetSizeRel( size )
			if ( parent ) then
				addedTabs [ tabName ].base:SetParent( parent )
			end
			addedTabs [ tabName ].page = tabControl:AddPage ( tab, addedTabs [ tabName ].base )
			addedTabs [ tabName ].page:SetDataString ( "id", "general.tab_".. tab:lower() )
			table.insert ( protected, addedTabs [ tabName ].page )
		end
	end

	return tabControl, addedTabs
end

function GUI:ColorPicker( isHSV, pos, size, parent )
	local func = ( isHSV and HSVColorPicker or ColorPicker )
	local picker = func.Create()
	picker:SetPositionRel( pos )
	picker:SetSizeRel( size )
	if ( parent ) then
		picker:SetParent( parent )
	end

	return picker
end

function GUI:CheckBox( text, pos, size, parent )
	if ( text == "" or not text ) then
		checkbox = CheckBox.Create()
	else
		checkbox = LabeledCheckBox.Create()
		checkbox:GetLabel():SetText( text )
	end
	checkbox:SetPositionRel( pos )
	checkbox:SetSizeRel( size )
	if ( parent ) then
		checkbox:SetParent( parent )
	end

	return checkbox
end

function GUI:RadioButtonController( options, pos, size, parent )
	local button = RadioButtonController.Create()
	button:SetPositionRel( pos )
	button:SetSizeRel( size )
	if ( parent ) then
		button:SetParent( parent )
	end

	for _, option in ipairs ( options ) do
		button:AddOption( option )
	end

	return button
end

function GUI:RadioButton( text, pos, size, parent )
	if ( text == "" or not text ) then
		button = RadioButton.Create()
	else
		button = LabeledRadioButton.Create()
		button:GetLabel():SetText( text )
	end
	button:SetPositionRel( pos )
	button:SetSizeRel( size )
	if ( parent ) then
		button:SetParent( parent )
	end

	return button
end

function GUI:Tree( pos, size, parent )
	local tree = Tree.Create()
	tree:SetPositionRel( pos )
	tree:SetSizeRel( size )
	if ( parent ) then
		tree:SetParent( parent )
	end

	return tree
end

function GUI:Center( guiElement )
	local size = guiElement:GetSizeRel()
	local width, height = table.unpack ( tostring ( size ):split ( "," ) )
	local size = Vector2( ( ( sx / sx ) / 2 - width / 2 ), ( ( sy / sy ) / 2 - height / 2 ) )
	guiElement:SetPositionRel( size )
end

function GUI:GetAllProtected()
	return protected
end

function GUI:Focus()
	Input:SetEnabled( false )
end

function GUI:Blur()
	Input:SetEnabled( true )
end