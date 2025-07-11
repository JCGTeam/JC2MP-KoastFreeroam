class 'Logo'

function Logo:__init()
    self.logo_txt = "Koast Freeroam! [Open Source]"
    self.logo_clr = Color(255, 255, 255, 30)

    Events:Subscribe("Render", self, self.Render)

    local build = LocalPlayer:GetValue("KoastBuild")
    if build then
        print("KMod ( Version: " .. build .. " ) loaded.")
    else
        print("KMod loaded.")
    end
end

function Logo:Render()
    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    Render:DrawText(Vector2(20, Render.Height - Render:GetTextHeight(self.logo_txt) - 15), self.logo_txt, self.logo_clr)
end

local logo = Logo()
