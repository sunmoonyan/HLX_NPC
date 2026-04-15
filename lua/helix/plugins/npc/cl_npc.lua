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
                    LocalPlayer():SetNoDraw(false)
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
        Focus_View(ent:LocalToWorld(Vector(25+ent:GetCamOffsetX(), 10+ent:GetCamOffsetY(), 65+ent:GetCamOffsetZ())),ent:LocalToWorldAngles(Angle(10, 170, 0)),false)

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

local hlxEditorData = {}
local function notifyEditor(text)
    LocalPlayer():Notify(text)
end

local function buildNPCLua(definition)
    local lines = {}
    lines[#lines + 1] = "HLXNPC[" .. string.format("%q", definition.npcID) .. "] = {"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "    startdialog = function(ply, ent)"
    lines[#lines + 1] = "        return 1"
    lines[#lines + 1] = "    end,"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "    dialogs = {"
    lines[#lines + 1] = ""

    for dialogIndex, dialog in ipairs(definition.dialogs or {}) do
        lines[#lines + 1] = "        [" .. dialogIndex .. "] = {"
        lines[#lines + 1] = "            [\"Text\"] = " .. string.format("%q", dialog.text or "") .. ","
        lines[#lines + 1] = "            [\"Args\"] = function(ply, ent)"
        lines[#lines + 1] = "                return {}"
        lines[#lines + 1] = "            end,"
        lines[#lines + 1] = "            [\"Condition\"] = function(ply, ent)"
        lines[#lines + 1] = "                return true"
        lines[#lines + 1] = "            end,"
        lines[#lines + 1] = "            [\"Answers\"] = {"

        for answerIndex, answer in ipairs(dialog.answers or {}) do
            lines[#lines + 1] = "                [" .. answerIndex .. "] = {"
            lines[#lines + 1] = "                    [\"Condition\"] = function(ply, ent)"
            lines[#lines + 1] = "                        return true"
            lines[#lines + 1] = "                    end,"
            lines[#lines + 1] = "                    [\"Text\"] = " .. string.format("%q", answer.text or "") .. ","
            lines[#lines + 1] = "                    [\"Args\"] = function(ply, ent)"
            lines[#lines + 1] = "                        return {}"
            lines[#lines + 1] = "                    end,"
            lines[#lines + 1] = "                    [\"CallBack\"] = function(ply, ent)"

            if tobool(answer.close) or tonumber(answer.targetDialog or 0) < 1 then
                lines[#lines + 1] = "                        ply:CloseNPCDialog()"
            else
                lines[#lines + 1] = "                        ply:OpenNPCDialog(ent, " .. math.floor(tonumber(answer.targetDialog) or 0) .. ")"
            end

            lines[#lines + 1] = "                    end,"
            lines[#lines + 1] = "                },"
        end

        lines[#lines + 1] = "            },"
        lines[#lines + 1] = "        },"
        lines[#lines + 1] = ""
    end

    lines[#lines + 1] = "    },"
    lines[#lines + 1] = "}"

    return table.concat(lines, "\n")
end

local function cloneDefinition(definition)
    local cloned = {
        npcID = tostring(definition.npcID or ""),
        dialogs = {}
    }

    for _, dialog in ipairs(definition.dialogs or {}) do
        local newDialog = {
            text = tostring(dialog.text or ""),
            answers = {}
        }

        for _, answer in ipairs(dialog.answers or {}) do
            newDialog.answers[#newDialog.answers + 1] = {
                text = tostring(answer.text or ""),
                close = tobool(answer.close),
                targetDialog = tonumber(answer.targetDialog) or 0
            }
        end

        cloned.dialogs[#cloned.dialogs + 1] = newDialog
    end

    return cloned
end


local function openNPCEditor(existingData)
    local frame = vgui.Create("DFrame")
    frame:SetSize(840, 680)
    frame:Center()
    frame:SetTitle("NPC Editor")
    frame:MakePopup()

    local top = vgui.Create("DPanel", frame)
    top:Dock(TOP)
    top:SetTall(74)

    local idLabel = vgui.Create("DLabel", top)
    idLabel:SetPos(10, 10)
    idLabel:SetText("NPC ID")
    idLabel:SizeToContents()

    local idEntry = vgui.Create("DTextEntry", top)
    idEntry:SetPos(10, 30)
    idEntry:SetSize(330, 26)
    idEntry:SetPlaceholderText("example: bartender_custom")

    local addDialogButton = vgui.Create("DButton", top)
    addDialogButton:SetPos(360, 30)
    addDialogButton:SetSize(140, 26)
    addDialogButton:SetText("Add dialog")


    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    local bottom = vgui.Create("DPanel", frame)
    bottom:Dock(BOTTOM)
    bottom:SetTall(38)

    local saveButton = vgui.Create("DButton", bottom)
    saveButton:Dock(LEFT)
    saveButton:SetWide(250)
    saveButton:SetText("Save")

    local copyButton = vgui.Create("DButton", bottom)
    copyButton:Dock(RIGHT)
    copyButton:SetWide(220)
    copyButton:SetText("Copy Lua table")

    local dialogRows = {}

    local function addAnswerRow(answersPanel, dialogData, answerData)
        local row = vgui.Create("DPanel", answersPanel)
        row:Dock(TOP)
        row:SetTall(56)
        row:DockMargin(0, 0, 0, 6)

        local answerText = vgui.Create("DTextEntry", row)
        answerText:SetPos(0, 0)
        answerText:SetSize(360, 24)
        answerText:SetText(answerData.text or "")
        answerText:SetPlaceholderText("Answer text")

        local targetDialog = vgui.Create("DNumberWang", row)
        targetDialog:SetPos(370, 0)
        targetDialog:SetSize(70, 24)
        targetDialog:SetMinMax(0, 999)
        targetDialog:SetValue(tonumber(answerData.targetDialog) or 0)

        local targetLabel = vgui.Create("DLabel", row)
        targetLabel:SetPos(446, 4)
        targetLabel:SetText("target")
        targetLabel:SizeToContents()

        local closeCheck = vgui.Create("DCheckBoxLabel", row)
        closeCheck:SetPos(520, 4)
        closeCheck:SetText("close dialog")
        closeCheck:SetValue(tobool(answerData.close) and 1 or 0)
        closeCheck:SizeToContents()

        local remove = vgui.Create("DButton", row)
        remove:SetPos(660, 0)
        remove:SetSize(80, 24)
        remove:SetText("Remove")

        local entry = {
            panel = row,
            getData = function()
                return {
                    text = answerText:GetValue(),
                    close = closeCheck:GetChecked(),
                    targetDialog = math.floor(tonumber(targetDialog:GetValue()) or 0)
                }
            end
        }

        table.insert(dialogData.answerRows, entry)

        remove.DoClick = function()
            for index, answerRow in ipairs(dialogData.answerRows) do
                if answerRow == entry then
                    table.remove(dialogData.answerRows, index)
                    break
                end
            end
            if IsValid(row) then row:Remove() end
        end
    end

    local function addDialog(dialogData)
        local wrapper = vgui.Create("DCollapsibleCategory", scroll)
        wrapper:Dock(TOP)
        wrapper:DockMargin(0, 0, 0, 8)
        wrapper:SetLabel("Dialog")
        wrapper:SetExpanded(true)
        wrapper.Paint = function(self, w, h)
        end

        wrapper.Header:SetTextColor(Color(255, 255, 255))
        wrapper.Header.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, ix.config.Get("color")) -- ta couleur ici
        end

        local content = vgui.Create("DPanel", wrapper)
        content:SetTall(210)
        content.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(25, 25, 25, 240))
        end

        wrapper:SetContents(content)

        local text = vgui.Create("DTextEntry", content)
        text:SetPos(8, 8)
        text:SetSize(770, 60)
        text:SetMultiline(true)
        text:SetText(dialogData.text or "")
        text:SetPlaceholderText("Dialog text")

        local answersPanel = vgui.Create("DScrollPanel", content)
        answersPanel:SetPos(8, 74)
        answersPanel:SetSize(770, 100)

        local addAnswer = vgui.Create("DButton", content)
        addAnswer:SetPos(8, 178)
        addAnswer:SetSize(120, 24)
        addAnswer:SetText("Add answer")

        local removeDialog = vgui.Create("DButton", content)
        removeDialog:SetPos(138, 178)
        removeDialog:SetSize(140, 24)
        removeDialog:SetText("Remove dialog")

        local entry = {
            panel = wrapper,
            textEntry = text,
            answerRows = {}
        }
        table.insert(dialogRows, entry)

        addAnswer.DoClick = function()
            addAnswerRow(answersPanel, entry, {})
        end

        removeDialog.DoClick = function()
            for index, dialogRow in ipairs(dialogRows) do
                if dialogRow == entry then
                    table.remove(dialogRows, index)
                    break
                end
            end
            if IsValid(wrapper) then wrapper:Remove() end
        end

        for _, answer in ipairs(dialogData.answers or {}) do
            addAnswerRow(answersPanel, entry, answer)
        end
    end

    local function collectDefinition()
        local definition = {
            npcID = string.Trim(idEntry:GetValue() or ""),
            dialogs = {}
        }

        for _, dialogRow in ipairs(dialogRows) do
            local text = string.Trim(dialogRow.textEntry:GetValue() or "")
            if text ~= "" then
                local dialog = {
                    text = text,
                    answers = {}
                }

                for _, answerRow in ipairs(dialogRow.answerRows) do
                    local answerData = answerRow.getData()
                    answerData.text = string.Trim(answerData.text or "")
                    if answerData.text ~= "" then
                        dialog.answers[#dialog.answers + 1] = answerData
                    end
                end

                definition.dialogs[#definition.dialogs + 1] = dialog
            end
        end

        return definition
    end

    saveButton.DoClick = function()
        local definition = collectDefinition()
        if definition.npcID == "" then
            notifyEditor("NPC ID is required.")
            return
        end

        if #definition.dialogs < 1 then
            notifyEditor("At least one dialog is required.")
            return
        end

        net.Start("ix_npc_editor_save")
        net.WriteTable(definition)
        net.SendToServer()
    end

    copyButton.DoClick = function()
        local definition = collectDefinition()
        if definition.npcID == "" then
            notifyEditor("NPC ID is required.")
            return
        end

        if #definition.dialogs < 1 then
            notifyEditor("At least one dialog is required.")
            return
        end

        SetClipboardText(buildNPCLua(definition))
        notifyEditor("NPC Lua table copied.")
    end

    if existingData and existingData.npcID then
        idEntry:SetText(existingData.npcID)
        for _, dialog in ipairs(existingData.dialogs or {}) do
            addDialog(dialog)
        end
    else
        addDialog({ text = "", answers = {} })
    end

    addDialogButton.DoClick = function()
        addDialog({ text = "", answers = {} })
    end
end

net.Receive("ix_npc_editor_open", function()
    hlxEditorData = net.ReadTable() or {}
    openNPCEditor()
end)

net.Receive("ix_npc_editor_sync", function()
    hlxEditorData = net.ReadTable() or {}
end)

local function openDialogBrowser(entries)
    local frame = vgui.Create("DFrame")
    frame:SetSize(780, 520)
    frame:Center()
    frame:SetTitle("NPC Dialog Browser")
    frame:MakePopup()

    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:AddColumn("NPC ID")
    list:AddColumn("Source")

    local lookup = {}
    for _, item in ipairs(entries or {}) do
        local dialogCount = #(item.definition and item.definition.dialogs or {})
        local row = list:AddLine(item.npcID or "", item.source or "unknown", tostring(dialogCount))
        lookup[row:GetID()] = item
    end

    local function getSelectedItem()
        local selected = list:GetSelectedLine()
        if not selected then return nil end
        local row = list:GetLine(selected)
        if not row then return nil end
        return lookup[row:GetID()]
    end

    local actions = vgui.Create("DPanel", frame)
    actions:Dock(BOTTOM)
    actions:SetTall(72)

    local deleteButton = vgui.Create("DButton", actions)
    deleteButton:SetPos(8, 8)
    deleteButton:SetSize(180, 26)
    deleteButton:SetText("Delete")

    local editButton = vgui.Create("DButton", actions)
    editButton:SetPos(196, 8)
    editButton:SetSize(180, 26)
    editButton:SetText("Edit dialog")

    local createFromButton = vgui.Create("DButton", actions)
    createFromButton:SetPos(384, 8)
    createFromButton:SetSize(190, 26)
    createFromButton:SetText("Create new from selected")

    local copyButton = vgui.Create("DButton", actions)
    copyButton:SetPos(582, 8)
    copyButton:SetSize(190, 26)
    copyButton:SetText("Copy dialog")

    local function refreshActionState()
        local item = getSelectedItem()
        local inGame = item and item.source == "in-game"
        deleteButton:SetEnabled(inGame or false)
        editButton:SetEnabled(inGame or false)
        createFromButton:SetEnabled(item ~= nil)
        copyButton:SetEnabled(item ~= nil)
    end

    list.OnRowSelected = refreshActionState
    refreshActionState()

    deleteButton.DoClick = function()
        local item = getSelectedItem()
        if not item or item.source ~= "in-game" then return end

        net.Start("ix_npc_editor_delete")
        net.WriteString(item.npcID or "")
        net.SendToServer()
        frame:Close()
    end

    editButton.DoClick = function()
        local item = getSelectedItem()
        if not item or item.source ~= "in-game" then return end

        openNPCEditor(cloneDefinition(item.definition or {}))
        frame:Close()
    end

    createFromButton.DoClick = function()
        local item = getSelectedItem()
        if not item then return end

        local definition = cloneDefinition(item.definition or {})
        local baseID = string.Trim(tostring(item.npcID or ""))
        if baseID == "" then
            baseID = "new_npc"
        end
        definition.npcID = baseID .. "_copy"
        openNPCEditor(definition)
        frame:Close()
    end

    copyButton.DoClick = function()
        local item = getSelectedItem()
        if not item then return end

        local definition = cloneDefinition(item.definition or {})
        definition.npcID = tostring(item.npcID or definition.npcID or "npc_class")
        SetClipboardText(buildNPCLua(definition))
        notifyEditor("Dialog copied as Lua table.")
    end
end

net.Receive("ix_npc_dialog_browser_open", function()
    local entries = net.ReadTable() or {}
    openDialogBrowser(entries)
end)

