class 'Banner'

function Banner:__init()
	self.pos = Vector3( 1052.8500000000, 218.0000000000, -1897.4930000000 )
	self.angle = Angle( -2.919954, -0.000000, 0.000000 )

	self.distance = 1500

	self.defaultImage = Image.Create( AssetLocation.Resource, "NotFound" )

    self.model = self:CreateSprite( self.defaultImage )

	Network:Subscribe( "ChangeImage", self, self.ChangeImage )
	Events:Subscribe( "GameRenderOpaque", self, self.GameRenderOpaque )
end

function Banner:LoadImages()
	if self.images then return end

	self.images = {}

    for i = ImagesRange.Min, ImagesRange.Max do
        table.insert( self.images, Image.Create( AssetLocation.Resource, tostring( i ) ) )
    end
end

function Banner:ChangeImage( index )
	if Vector3.Distance( Camera:GetPosition(), self.pos ) >= self.distance then return end

	self:LoadImages()
    self.model:SetTexture( self.images and self.images[index] or self.defaultImage )
end


function Banner:GameRenderOpaque()
	if Vector3.Distance( Camera:GetPosition(), self.pos ) >= self.distance then return end

	local rotateAngle = Angle.Zero
	local t = Transform3()

	t:Translate( self.pos ):Rotate( self.angle )
	Render:SetTransform( t )

	local minDist = 500

	self.model:SetTextureAlpha( 255 - math.clamp( ( Vector3.Distance( Camera:GetPosition(), self.pos ) - minDist ) / ( self.distance - minDist ) * 255, 0, 255 ) )
	self.model:Draw()
end

function Banner:CreateSprite( image )
	local size = Vector2( 5, 3 )
	local uv1, uv2 = image:GetUV()

	local sprite = Model.Create({
		Vertex( Vector2( -size.x, size.y ), Vector2( uv1.x, uv1.y ) ),
		Vertex( Vector2( -size.x,-size.y ), Vector2( uv1.x, uv2.y ) ),
		Vertex( Vector2( size.x,-size.y ), Vector2( uv2.x, uv2.y ) ),
		Vertex( Vector2( size.x,-size.y ), Vector2( uv2.x, uv2.y ) ),
		Vertex( Vector2( size.x, size.y ), Vector2( uv2.x, uv1.y ) ),
		Vertex( Vector2( -size.x, size.y ), Vector2( uv1.x, uv1.y ) )
	})

	sprite:SetTexture( image )
	sprite:SetTopology( Topology.TriangleList )

	return sprite
end

banner = Banner()