if CLIENT then

surface.CreateFont( "CloseCaption_Normal:50", {
  font = "CloseCaption_Normal", -- On Windows/macOS, use the font-name which is shown to you by your operating system Font Viewer. On Linux, use the file name
  extended = false,
  size = 50,
  weight = 500,
  italic = false,
} )


    npcui_smoothpos = Vector(0, 0, 0)
    npcui_smoothang = Angle(0, 0, 0)

    net.Receive("ix_npc_send", function() 
        if NpcMenu != nil && NpcMenu:IsValid() then
            NpcMenu:Remove() 
            IXNPC_UI(net.ReadString(),net.ReadInt(6),net.ReadString(),net.ReadTable(),false)
        else
            IXNPC_UI(net.ReadString(),net.ReadInt(6),net.ReadString(),net.ReadTable(),true)
        end
    end)

    net.Receive("ix_npc_focus", function()
        npcui_smoothpos = LocalPlayer():EyePos()
        npcui_smoothang = LocalPlayer():GetAngles()
        campos = net.ReadVector()
        camang = net.ReadAngle()
        LocalPlayer():SetNoDraw(true)
        hook.Add("CalcView", "npc_focus", function(ply, pos, angles, fov)
            npcui_smoothpos = LerpVector(0.01, npcui_smoothpos,campos)
            npcui_smoothang = LerpAngle(0.01, npcui_smoothang,camang)
            return {
                origin = npcui_smoothpos,
                angles = npcui_smoothang,
                fov = fov,
                drawviewer = true
            }
        end)
    end)

    function IXNPC_UI(name,dialogueindex,dialogue,buttons,intro)
        local Xsize = ScrW()
        local Ysize = ScrH()
        local lines = 0
        local letter = 0
        local smoothdesc = ""


        timer.Create("npcui_smoothdesc", 0.008, string.len(dialogue)+1, function()
            smoothdesc = string.sub(dialogue, 0, letter)
            letter = letter + 1
            if string.GetChar(dialogue, letter) == "" then
            else
                LocalPlayer():EmitSound("ui/buttonrollover.wav", 25)
            end
        end)

        NpcMenu = vgui.Create("DFrame")
        NpcMenu:SetPos(0, 0)
        NpcMenu:SetSize(Xsize, Ysize)
        NpcMenu:SetTitle("")
        NpcMenu:MakePopup()
        NpcMenu:SetDraggable(false)
        NpcMenu:ShowCloseButton(false)
        NpcMenu.exit = false
        NpcMenu.linecolor = 0


        function NpcMenu:Paint(w, h)

            if intro == true && self.exit == false then
                self.linecolor = Lerp(0.005, self.linecolor, 255)
            elseif self.exit == true then
                self.linecolor = Lerp(0.05, self.linecolor, 0)
            else
                self.linecolor = 255
            end

            surface.SetDrawColor(255, 255, 255, self.linecolor)
            surface.DrawLine(w * 0.6, h * 0.1, w * 0.6, h * 0.9)
            surface.DrawLine(w * 0.6, h * 0.2, w * 0.9, h * 0.2)
            
            draw.DrawText(name, "CloseCaption_Normal:50", w * 0.61, h * 0.125, Color(255, 255, 225, self.linecolor), TEXT_ALIGN_LEFT)


                draw.DrawText(smoothdesc, "Trebuchet18", w * 0.625, (h * (0.015) + h * 0.22), Color(255, 255, 255, self.linecolor), TEXT_ALIGN_LEFT)

        end
        
        local slot = 0

        for i,v in pairs(buttons) do
            local button = vgui.Create("DButton", NpcMenu)
            button:SetText("")
            local buttonWidth = Xsize * 0.3
            local buttonHeight = Ysize * 0.1
            local startY = Ysize * 0.8
            slot = slot + 1
            button.buttoncolor = ix.config.Get("color")
            button:SetPos(Xsize * 0.6, startY - (slot - 1) * buttonHeight)
            button:SetSize(buttonWidth, buttonHeight)
            button.colorAlpha = 0
            button.DoClick = function()
                LocalPlayer():EmitSound("Helix.Whoosh")

                net.Start("ix_npc_callback")
                net.WriteString(name)
                net.WriteInt(dialogueindex, 6)
                net.WriteInt(i, 4)
                net.SendToServer()

                if v[2] then
                  NpcMenu.exit = true

                  hook.Add("CalcView", "npc_focus", function(ply, pos, angles, fov)
                    npcui_smoothpos = LerpVector(0.01, npcui_smoothpos, LocalPlayer():EyePos())
                    npcui_smoothang = LerpAngle(0.01, npcui_smoothang, LocalPlayer():GetAngles())
                   return {
                     origin = npcui_smoothpos,
                      angles = npcui_smoothang,
                      fov = fov,
                      drawviewer = true
                    }
                  end)


                  timer.Create("ixnpc_close", 1, 1, function() 
                    NpcMenu:Remove()
                    hook.Remove("CalcView", "npc_focus")
                    LocalPlayer():SetNoDraw(false)
                  end)
                end

            end
            function button:OnCursorEntered()
                LocalPlayer():EmitSound("Helix.Rollover")
            end
            function button:Paint(w, h)
                if self:IsHovered() then
                    self.colorAlpha = Lerp(0.01, self.colorAlpha, 255)
                else
                    self.colorAlpha = Lerp(0.1, self.colorAlpha, 0)
                end
                if NpcMenu.exit == false then
                    surface.SetDrawColor(self.buttoncolor.r, self.buttoncolor.g, self.buttoncolor.b, self.colorAlpha)
                else
                    surface.SetDrawColor(self.buttoncolor.r, self.buttoncolor.g, self.buttoncolor.b, NpcMenu.linecolor)
                end
                if NpcMenu.exit then self:Remove() end
                surface.SetMaterial(Material("vgui/gradient-l.png"))
                surface.DrawTexturedRect(0, 0, w, h)
                draw.DrawText(v[1], "ixMenuButtonBigLabelFont", w / 2, h * 0.3, Color(255, 255, 225, NpcMenu.linecolor), TEXT_ALIGN_CENTER)
            end
        end


    end


end
