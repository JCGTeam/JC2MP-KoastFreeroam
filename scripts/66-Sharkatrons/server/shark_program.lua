updatesPerSecond = 20 -- defines how often the server updates the shark positions
targetDistance = 2 -- the distance (in meter) a shark has to reach a waypoint, to select the next one

defaultHeight = 198
model = "sharkatron.3000.eez/go701-a.lod"
collision = "sharkatron.3000.eez/go701_lod1-a_col.pfx"

--

aquarium = Aquarium()

aquarium:NewShark("original_easteregg.txt")