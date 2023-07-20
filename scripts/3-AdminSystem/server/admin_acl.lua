class "ACL"

function ACL:__init()
	json = require "JSON"

	self.groups = {}
	self.members = {}

	SQL:Execute ( "CREATE TABLE IF NOT EXISTS acl_groups ( name VARCHAR UNIQUE, creator VARCHAR, permissions VARCHAR, creationDate VARCHAR, tag VARCHAR, tagColour VARCHAR )" )
	SQL:Execute ( "CREATE TABLE IF NOT EXISTS acl_members ( groups VARCHAR, steamID VARCHAR )" )

	self:loadGroups()
	self:loadGroupMembers()
end

function ACL:loadGroups()
	local query = SQL:Query ( "SELECT * FROM acl_groups" )
	local result = query:Execute()
	if ( #result > 0 ) then
		for _, group in ipairs ( result ) do
			self.groups [ group.name ] =
				{
					creator = group.creator,
					permissions = json.decode ( group.permissions ),
					creationDate = group.creationDate,
					tag = group.tag,
					tagColour = json.decode ( group.tagColour )
				}
		end
	end
	print ( tostring ( #result ) .." ACL group(s) loaded!" )
end

function ACL:loadGroupMembers()
	local query = SQL:Query ( "SELECT * FROM acl_members" )
	local result = query:Execute ( )
	if ( #result > 0 ) then
		for _, member in ipairs ( result ) do
			self.members [ member.steamID ] = json.decode ( member.groups )
		end
	end
	print ( tostring ( #result ) .." ACL group member(s) loaded!" )
end

function ACL:createGroup( name, permissions, creator, tag, tagColour )
	if ( name and type ( permissions ) == "table" ) then
		if ( not self.groups [ name ] ) then
			local cmd = SQL:Command ( "INSERT INTO acl_groups ( name, creator, permissions, creationDate, tag, tagColour ) VALUES ( ?, ?, ?, ?, ?, ? )" )
			local theDate = os.date ( "%c" )
			cmd:Bind ( 1, tostring ( name ) )
			cmd:Bind ( 2, ( creator or "Сервер" ) )
			cmd:Bind ( 3, json.encode ( permissions ) )
			cmd:Bind ( 4, theDate )
			cmd:Bind ( 5, ( tag or "" ) )
			cmd:Bind ( 6, json.encode ( type ( tagColour ) == "table" and tagColour or {} ) )
			cmd:Execute()
			self.groups [ name ] =
				{
					creator = creator,
					permissions = permissions,
					creationDate = theDate,
					tag = ( tag or "" ),
					tagColour = tagColour
				}

			return true
		end
	else
		return false
	end
end

function ACL:destroyGroup( name )
	if ( name ) then
		if ( self.groups [ name ] ) then
			local cmd = SQL:Command ( "DELETE FROM acl_groups WHERE name = ( ? )" )
			cmd:Bind ( 1, name )
			cmd:Execute ( )
			local objects = self:groupListObjects ( name )
			if ( objects ) then
				for _, steamID in ipairs ( objects ) do
					self:groupRemoveObject ( name, steamID )
				end
			end
			self.groups [ name ] = nil

			return true
		else
			return false
		end
	else
		return false
	end
end

function ACL:updateGroupPermission( group, permission, value )
	if ( group and permission and ( value == true or value == false ) ) then
		if ( self.groups [ group ] ) then
			self.groups [ group ].permissions [ permission ] = value
			local cmd = SQL:Command ( "UPDATE acl_groups SET permissions = ? WHERE name = ?" )
			cmd:Bind ( 1, json.encode ( self.groups [ group ].permissions ) )
			cmd:Bind ( 2, group )
			cmd:Execute()

			return true
		else
			return false
		end
	else
		return false
	end
end

function ACL:groupListObjects( name )
	if ( name ) then
		if ( self.groups [ name ] ) then
			local objects = { }
			for steamID, groups in pairs ( self.members ) do
				for _, group in ipairs ( groups ) do
					if ( group == name ) then
						table.insert ( objects, steamID )
						break
					end
				end
			end

			return objects
		end
	else
		return false
	end
end

function ACL:groupList( all )
	local groups = {}
	if ( not all ) then
		for name, data in pairs ( self.groups ) do
			table.insert (
				groups,
				{
					name = name,
					creator = data.creator,
					permissions = data.permissions,
					creationDate = data.creationDate,
					objects = { }
				}
			)
			local index = #groups
			local query = SQL:Query ( "SELECT * FROM acl_members WHERE groups LIKE '%".. tostring ( name ) .."%'" )
			local result = query:Execute ( )
			if ( #result > 0 ) then
				for _, result in ipairs ( result ) do
					table.insert ( groups [ index ].objects, result.steamID )
				end
			end
		end
	else
		groups = self.groups
	end

	return groups
end

function ACL:getGroupTag( group )
	if ( group ) then
		if ( self.groups [ group ] ) then
			return ( self.groups [ group ].tag or "" )
		else
			return false
		end
	else
		return false
	end
end

function ACL:getGroupTagColour( group )
	if ( group ) then
		if ( self.groups [ group ] ) then
			return ( self.groups [ group ].tagColour or { 255, 255, 255 } )
		else
			return false
		end
	else
		return false
	end
end

function ACL:hasObjectPermissionTo( steamID, action )
	if ( steamID and action ) then
		if ( self.members [ steamID ] ) then
			local has = false
			for _, group in ipairs ( self.members [ steamID ] ) do
				local groupData = self.groups [ group ]
				if ( type ( groupData ) == "table" ) then
					if ( type ( groupData.permissions ) == "table" ) then
						if ( groupData.permissions [ action ] ) then
							has = true
							break
						end
					end
				end
			end

			return has
		else
			return false
		end
	else
		return false
	end
end

function ACL:isObjectInGroup( steamID, group )
	if ( steamID and group ) then
		if ( self.members [ steamID ] ) then
			local is = false
			for _, groupName in ipairs ( self.members [ steamID ] ) do
				if ( groupName == group ) then
					is = true
					break
				end
			end

			return is
		else
			return false
		end
	else
		return false
	end
end

function ACL:getObjectGroups( steamID )
	if ( steamID ) then
		if ( self.members [ steamID ] ) then
			return self.members [ steamID ]
		else
			return false
		end
	else
		return false
	end
end

function ACL:groupAddObject( group, steamID )
	if ( group and steamID ) then
		if ( self.groups [ group ] ) then
			if ( not self:isObjectInGroup ( steamID, group ) ) then
				if ( not self.members [ steamID ] ) then
					self.members [ steamID ] = { group }
					local cmd = SQL:Command ( "INSERT INTO acl_members ( groups, steamID ) VALUES ( ?, ? )" )
					cmd:Bind ( 1, json.encode ( self.members [ steamID ] ) )
					cmd:Bind ( 2, steamID )
					cmd:Execute()
				else
					table.insert ( self.members [ steamID ], group )
					local cmd = SQL:Command ( "UPDATE acl_members SET groups = ? WHERE steamID = ?" )
					cmd:Bind ( 1, json.encode ( self.members [ steamID ] ) )
					cmd:Bind ( 2, steamID )
					cmd:Execute()
				end

				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function ACL:groupRemoveObject( group, steamID )
	if ( group and steamID ) then
		if ( self.groups [ group ] ) then
			if ( self.members [ steamID ] ) then
				if ( #self.members [ steamID ] == 1 ) then
					self.members [ steamID ] = nil
					local cmd = SQL:Command ( "DELETE FROM acl_members WHERE steamID = ?" )
					cmd:Bind ( 1, steamID )
					cmd:Execute()
				else
					for index, groupName in ipairs ( self.members [ steamID ] ) do
						if ( groupName == group ) then
							table.remove ( self.members [ steamID ], index )
							break
						end
					end
					local cmd = SQL:Command ( "UPDATE acl_members SET groups = ? WHERE steamID = ?" )
					cmd:Bind ( 1, json.encode ( self.members [ steamID ] ) )
					cmd:Bind ( 2, steamID )
					cmd:Execute()
				end
			else
				return false
			end

			return true
		else
			return false
		end
	else
		return false
	end
end

ACL = ACL()