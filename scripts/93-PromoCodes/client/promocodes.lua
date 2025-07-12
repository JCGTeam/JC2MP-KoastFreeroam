class 'PromoCodes'

function PromoCodes:__init()
    self.globalPromocodes = {}
    self.invitationsPromocodes = {}

    Network:Subscribe("GlobalPromocodes", self, self.GlobalPromocodes)
    Network:Subscribe("InvitationsPromocodes", self, self.InvitationsPromocodes)

    Events:Subscribe("ApplyPromocode", self, self.ApplyPromocode)
    Events:Subscribe("ModuleUnload", function() Events:Fire("PromocodeSkipped") end)
end

function PromoCodes:GlobalPromocodes(args)
    self.globalPromocodes = args
end

function PromoCodes:InvitationsPromocodes(args)
    self.invitationsPromocodes = args
end

function PromoCodes:ApplyPromocode(args)
    local promoCodeFound = false

    if args.type then
        if args.type == 0 then
            for i, row in ipairs(self.globalPromocodes) do
                if args.name == row[2].name then
                    promoCodeFound = true

                    Network:Send("GlobalPromocodeUses", {row = row})
                    Events:Fire("PromocodeFound")
                    break
                end
            end

            if not promoCodeFound then
                Events:Fire("PromocodeNotFound")
            end
        elseif args.type == 1 then
            for i, row in ipairs(self.invitationsPromocodes) do
                if args.name == row[2].name then
                    promoCodeFound = true

                    Network:Send("InvitationPromocodeUses", {row = row})
                    Events:Fire("PromocodeFound")
                    break
                end
            end

            if not promoCodeFound then
                Events:Fire("PromocodeNotFound")
            end
        end
    else
        error("Type is not specified")
    end

    if not promoCodeFound then
        Events:Fire("PromocodeFailed")
    end
end

local promocodes = PromoCodes()