include("shared.lua")


    ENT.PopulateEntityInfo = true

    function ENT:OnPopulateEntityInfo(container)
        local name = container:AddRow("name")
        name:SetImportant()
        name:SetText(self:GetDisplayName())
        name:SizeToContents()

        local descriptionText = self:GetDescription()

        if (descriptionText != "") then
            local description = container:AddRow("description")
            description:SetText(self:GetDescription())
            description:SizeToContents()
        end
    end


 