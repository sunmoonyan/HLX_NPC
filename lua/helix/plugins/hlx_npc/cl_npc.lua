surface.CreateFont( "CloseCaption_Normal:50", {
  font = "CloseCaption_Normal",
  extended = false,
  size = 50,
  weight = 500,
  italic = false,
} )

surface.CreateFont("ixMenuButtonBigLabelFont", {
    font = "Roboto Th",
    size = ScreenScale(15),
    extended = true,
    weight = 100
})

ix_npcui = false

net.Receive("ix_npc_open", function() 
    NPC_UI(net.ReadString(),net.ReadInt(9),net.ReadString(),net.ReadTable(),net.ReadEntity())
end)

net.Receive("ix_npc_close", function() 
    if IsValid(NpcMenu) then
        NpcMenu:AlphaTo(0, 0.2, 0, function()
            if IsValid(NpcMenu) then

                NpcMenu:Remove()
                ix_npcui = false
                timer.Stop("npc_smoothdesc")
                timer.Create("npc_force_close_focus", 0.75, 1, function() 
                    hook.Remove("CalcView", "npc_focus")
                end)

            end
        end)
    end
end)

local function Focus_View(campos,camang)

    npc_smoothpos = LocalPlayer():EyePos()
    npc_smoothang = LocalPlayer():GetAngles()

    npc_campos = campos
    npc_camang = camang

    LocalPlayer():SetNoDraw(true)

    hook.Add("CalcView", "npc_focus", function(ply, pos, angles, fov)
        local speed = 5 
        local t = math.Clamp(FrameTime() * speed, 0, 1)

        npc_smoothpos = LerpVector(t, npc_smoothpos, npc_campos)
        npc_smoothang = LerpAngle(t, npc_smoothang, npc_camang)

        if !IsValid(NpcMenu) then
            npc_campos = LocalPlayer():EyePos()
            npc_camang = LocalPlayer():GetAngles()
            if npc_smoothpos:DistToSqr(npc_campos) < 1 then
                hook.Remove("CalcView", "npc_focus")
                LocalPlayer():SetNoDraw(false)
            end
        end

        return {
            origin = npc_smoothpos,
            angles = npc_smoothang,
            fov = fov,
            drawviewer = true
        }
    end)

end


function NPC_UI(name,dialogID,text,answers,ent)
    local Xsize = ScrW()
    local Ysize = ScrH()
    local SchemaColor = ix.config.Get("color")

    local letter = 0
    local smoothtext = ""
    timer.Create("npc_smoothdesc", 0.008, string.len(text)+1, function()
        smoothtext = string.sub(text, 0, letter)
        letter = letter + 1
        if string.GetChar(text, letter) == "" then
        else
            LocalPlayer():EmitSound("ui/buttonrollover.wav", 25)
        end
    end)


    if !IsValid(NpcMenu) then

        NpcMenu = vgui.Create("DFrame")
        NpcMenu:SetPos(0, 0)
        NpcMenu:SetSize(Xsize, Ysize)
        NpcMenu:SetTitle("")
        NpcMenu:MakePopup()
        NpcMenu:SetDraggable(false)
        NpcMenu:ShowCloseButton(false)
        NpcMenu:SetAlpha(0)
        NpcMenu:AlphaTo(255, 0.3, 0)
        ix_npcui = true
        function NpcMenu:OnClose()
            ix_npcui = false
        end
        function NpcMenu:Paint(w, h)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawLine(w * 0.6, h * 0.1, w * 0.6, h * 0.9)
            surface.DrawLine(w * 0.6, h * 0.2, w * 0.9, h * 0.2)
                
            draw.DrawText(name, "CloseCaption_Normal:50", w * 0.61, h * 0.125, Color(255, 255, 225, 255), TEXT_ALIGN_LEFT)
            draw.DrawText(smoothtext, "Trebuchet18", w * 0.625, (h * (0.015) + h * 0.22), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
        end

        timer.Stop("npc_force_close_focus")
        Focus_View(ent:LocalToWorld(Vector(25, 10, 65)),ent:LocalToWorldAngles(Angle(10, 170, 0)),false)

    else

        for _, child in pairs(NpcMenu:GetChildren()) do
            if IsValid(child) and child.isAnswers then
                child:Remove()
            end
        end

        function NpcMenu:Paint(w, h)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawLine(w * 0.6, h * 0.1, w * 0.6, h * 0.9)
            surface.DrawLine(w * 0.6, h * 0.2, w * 0.9, h * 0.2)
                
            draw.DrawText(name, "CloseCaption_Normal:50", w * 0.61, h * 0.125, Color(255, 255, 225, 255), TEXT_ALIGN_LEFT)
            draw.DrawText(smoothtext, "Trebuchet18", w * 0.625, (h * (0.015) + h * 0.22), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

        end

    end

    local buttonSlot = 0
    local buttonWidth = Xsize * 0.3
    local buttonHeight = Ysize * 0.1
    local startY = Ysize * 0.8

    for i,v in pairs(answers) do

        local button = vgui.Create("DButton", NpcMenu)
        button:SetText("")
        button:SetPos(Xsize * 0.6, startY-buttonHeight*buttonSlot)
        button:SetSize(buttonWidth, buttonHeight)
        button.hoverFrac = 0
        button.isAnswers = true
        button.DoClick = function()
            net.Start("ix_npc_callback")
            net.WriteEntity(ent)
            net.WriteInt(dialogID, 9)
            net.WriteInt(i, 5)
            net.SendToServer()
        end

        function button:OnCursorEntered()
            LocalPlayer():EmitSound("Helix.Rollover")
        end

        function button:Paint(w, h)

            local target = self:IsHovered() and 1 or 0
            self.hoverFrac = Lerp(FrameTime() * 10, self.hoverFrac, target)

            local alpha = Lerp(self.hoverFrac, 0, 200)

            surface.SetDrawColor(SchemaColor.r, SchemaColor.g, SchemaColor.b, alpha)
            surface.SetMaterial(Material("vgui/gradient-l.png"))
            surface.DrawTexturedRect(0, 0, w, h)
            draw.DrawText(v, "ixMenuButtonBigLabelFont", w / 2, h * 0.3, Color(255, 255, 225, 255), TEXT_ALIGN_CENTER)
        end

        buttonSlot=buttonSlot+1

    end


end

