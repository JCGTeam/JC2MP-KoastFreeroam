class 'Mapping'

function Mapping:__init()
	Events:Subscribe( "ModuleLoad", self, self.CreateStaticObjects )
	Events:Subscribe( "ModuleUnload", self, self.DestroyStaticObjects )

	self.objects = {
		{
			position = Vector3( 12772.375976563, 1378.9853515625, 6049.072265625 ),
			angle = Angle( 0.0073636039160192, 0.045337688177824, 0.20024675130844, 0.97866827249527 ),
			model = "17x48.nl/go666-a.lod",
			collision = "17x48.nl/go666_lod1-a_col.pfx"
		},
		{
			position = Vector3( 12774.028320313, 1379.1522216797, 6067.2001953125 ),
			angle = Angle( 0.0073636039160192, 0.045337688177824, 0.20024675130844, 0.97866827249527 ),
			model = "17x48.nl/go666-a.lod",
			collision = "17x48.nl/go666_lod1-a_col.pfx"
		},
		{
			position = Vector3( 15053.65625, 2087.8701171875, 5845.6416015625 ),
			angle = Angle( 0, 0.044913966208696, 0, 0.99899083375931 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 14768.958984375, 2087.8498535156, 5871.3208007813 ),
			angle = Angle( 0, 0.044913966208696, 0, 0.99899083375931 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 14529.494140625,2038.7054443359,5893.6396484375 ),
			angle = Angle( 0.0073636039160192,0.045337688177824,0.20024675130844,0.97866827249527 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 14267.790039063,1926.4476318359,5918.1645507813 ),
			angle = Angle( 0.0073636039160192,0.045337688177824,0.20024675130844,0.97866827249527 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 14006.322265625,1814.2984619141,5942.701171875 ),
			angle = Angle( 0.0073636039160192,0.045337688177824,0.20024675130844,0.97866827249527 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 13744.618164063,1702.0406494141,5967.2260742188 ),
			angle = Angle( 0.0073636039160192,0.045337688177824,0.20024675130844,0.97866827249527 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 13482.999023438,1589.8735351563,5991.7387695313 ),
			angle = Angle( 0.0073636039160192,0.045337688177824,0.20024675130844,0.97866827249527 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 13221.689453125,1477.8264160156,6016.2080078125 ),
			angle = Angle( 0.0073636039160192,0.045337688177824,0.20024675130844,0.97866827249527 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 12960.0703125,1365.6593017578,6040.720703125 ),
			angle = Angle( 0.0073636039160192,0.045337688177824,0.20024675130844,0.97866827249527 ),
			model = "17x25.nl/gb028-a.lod",
			collision = "17x25.nl/gb028_lod1-a_col.pfx"
		},
		{
			position = Vector3( 16275, 212.5, -7800 ),
			angle = Angle.Zero,
			model = "km04.submarine.eez/key014_02-a.lod",
			collision = "km07.submarine.eez/key014_02_lod1-a_col.pfx"
		},
		{
			position = Vector3( 16275, 212.5, -7800 ),
			angle = Angle.Zero,
			model = "km04.submarine.eez/key014_02-a.lod",
			collision = "km07.submarine.eez/key014_02_lod1-a_col.pfx"
		},
		{
			position = Vector3( 16275, 212.5, -7800 ),
			angle = Angle.Zero,
			model = "km04.submarine.eez/key014_02-interior.lod",
			collision = ""
		}
	}
end

function Mapping:CreateStaticObjects( args )
	for _, obj in ipairs(self.objects) do
		local objArgs = {}
		objArgs.position  = obj.position
		objArgs.angle     = obj.angle
		objArgs.model     = obj.model
		objArgs.collision = obj.collision
		obj.object = StaticObject.Create(objArgs)
	end
end

function Mapping:DestroyStaticObjects()
	for _, obj in ipairs(self.objects) do
		obj.object:Remove()
	end
end

mapping = Mapping()