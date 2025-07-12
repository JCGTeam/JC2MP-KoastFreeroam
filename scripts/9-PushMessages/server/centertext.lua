class 'CenterText'

function CenterText:__init()
    Events:Subscribe("CastCenterText", self, self.CastCenterText)
end

function CenterText:CastCenterText(args)
    Network:Send(args.target, "CastCenterText", {text = args.text, time = args.time, color = args.color})
end

local centertext = CenterText()