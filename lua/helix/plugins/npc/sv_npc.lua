util.AddNetworkString("ix_npc_open")
util.AddNetworkString("ix_npc_close")
util.AddNetworkString("ix_npc_callback")
util.AddNetworkString("ix_npc_editor_open")
util.AddNetworkString("ix_npc_editor_sync")
util.AddNetworkString("ix_npc_editor_save")
util.AddNetworkString("ix_npc_editor_delete")
util.AddNetworkString("ix_npc_dialog_browser_open")

local PLUGIN = PLUGIN

local player = FindMetaTable("Player")

local CUSTOM_NPC_KEY = "hlx_npc_custom"

local function normalizeEditorData(data)
   if not istable(data) then return nil end

   local npcID = string.Trim(tostring(data.npcID or ""))
   if npcID == "" then return nil end

   local dialogs = {}
   local rawDialogs = istable(data.dialogs) and data.dialogs or {}

   for index, rawDialog in ipairs(rawDialogs) do
      local text = string.Trim(tostring(rawDialog.text or ""))
      if text ~= "" then
         local dialog = {
            text = text,
            answers = {}
         }

         local rawAnswers = istable(rawDialog.answers) and rawDialog.answers or {}
         for _, rawAnswer in ipairs(rawAnswers) do
            local answerText = string.Trim(tostring(rawAnswer.text or ""))
            if answerText ~= "" then
               local close = tobool(rawAnswer.close)
               local targetDialog = tonumber(rawAnswer.targetDialog) or 0

               dialog.answers[#dialog.answers + 1] = {
                  text = answerText,
                  close = close,
                  targetDialog = targetDialog
               }
            end
         end

         dialogs[#dialogs + 1] = dialog
      end
   end

   if #dialogs < 1 then return nil end

   return {
      npcID = npcID,
      dialogs = dialogs
   }
end

local function editorDataToRuntime(definition)
   local runtimeDialogs = {}

   for dialogIndex, dialog in ipairs(definition.dialogs) do
      local runtimeAnswers = {}

      for answerIndex, answer in ipairs(dialog.answers) do
         local shouldClose = tobool(answer.close)
         local targetDialog = tonumber(answer.targetDialog) or 0

         runtimeAnswers[answerIndex] = {
            ["Condition"] = function(ply, ent)
               return true
            end,
            ["Text"] = answer.text,
            ["Args"] = function(ply, ent)
               return {}
            end,
            ["CallBack"] = function(ply, ent)
               if shouldClose or targetDialog < 1 then
                  ply:CloseNPCDialog()
                  return
               end

               local npctable = HLXNPC[ent:GetNpc()]
               if not npctable or not npctable.dialogs[targetDialog] then
                  ply:CloseNPCDialog()
                  return
               end

               ply:OpenNPCDialog(ent, targetDialog)
            end
         }
      end

      runtimeDialogs[dialogIndex] = {
         ["Text"] = dialog.text,
         ["Args"] = function(ply, ent)
            return {}
         end,
         ["Condition"] = function(ply, ent)
            return true
         end,
         ["Answers"] = runtimeAnswers
      }
   end

   return {
      startdialog = function(ply, ent)
         return 1
      end,
      onTakeDamage = function(ent)
      end,
      dialogs = runtimeDialogs
   }
end

function PLUGIN:RegisterCustomNPC(definition)
   local normalized = normalizeEditorData(definition)
   if not normalized then return false end

   HLXNPC[normalized.npcID] = editorDataToRuntime(normalized)

   self.customNPCData = self.customNPCData or {}
   self.customNPCData[normalized.npcID] = normalized
   return true
end

function PLUGIN:LoadCustomNPCData()
   self.customNPCData = ix.data.Get(CUSTOM_NPC_KEY, {}, true, true) or {}

   for _, definition in pairs(self.customNPCData) do
      self:RegisterCustomNPC(definition)
   end
end

function PLUGIN:SaveCustomNPCData()
   ix.data.Set(CUSTOM_NPC_KEY, self.customNPCData or {}, true, true)
end

local function sendEditorSync()
   net.Start("ix_npc_editor_sync")
   net.WriteTable(PLUGIN.customNPCData or {})
   net.Broadcast()
end

function serializeRuntimeNPC(npcID, npcTable)
   local definition = {
      npcID = npcID,
      dialogs = {}
   }

   local dialogs = (istable(npcTable) and istable(npcTable.dialogs)) and npcTable.dialogs or {}
   for dialogIndex, dialog in pairs(dialogs) do
      if isnumber(dialogIndex) and istable(dialog) then
         local dialogRow = {
            index = dialogIndex,
            text = tostring(dialog.Text or ""),
            answers = {}
         }

         for answerIndex, answer in pairs(dialog.Answers or {}) do
            if isnumber(answerIndex) and istable(answer) then
               dialogRow.answers[#dialogRow.answers + 1] = {
                  text = tostring(answer.Text or ""),
                  close = true,
                  targetDialog = 0
               }
            end
         end

         definition.dialogs[#definition.dialogs + 1] = dialogRow
      end
   end

   table.sort(definition.dialogs, function(a, b) return (a.index or 0) < (b.index or 0) end)
   for _, dialogRow in ipairs(definition.dialogs) do
      dialogRow.index = nil
   end

   return definition
end

function buildDialogBrowserData()
   local data = {}
   local custom = PLUGIN.customNPCData or {}

   for npcID, definition in pairs(custom) do
      data[#data + 1] = {
         npcID = npcID,
         source = "in-game",
         definition = definition
      }
   end

   for npcID, npcTable in pairs(HLXNPC or {}) do
      if not custom[npcID] then
         data[#data + 1] = {
            npcID = npcID,
            source = "code",
            definition = serializeRuntimeNPC(npcID, npcTable)
         }
      end
   end

   table.sort(data, function(a, b)
      return tostring(a.npcID) < tostring(b.npcID)
   end)

   return data
end



function player:InteractNPC(ent)

   if !ent:IsNearPlayer(self) then return end

   local npcid = ent:GetNpc()
   local npctable = HLXNPC[npcid] or nil 

   if npctable == nil then return end

   local startdialog = npctable["startdialog"](self,ent)
   if startdialog == nil then return end

   self:OpenNPCDialog(ent,startdialog) 

end


function player:OpenNPCDialog(ent,dialogID)

   local name = ent:GetDisplayName()

   local npcid = ent:GetNpc()
   local npctable = HLXNPC[npcid] or nil 
   local dialog = npctable["dialogs"][dialogID]

   if (!dialog["Condition"](self,ent)) then return end

   local text = dialog["Text"]
   local textargs = dialog["Args"](self,ent)
   local formatedText = ""

   formatedText = string.format(text,unpack( textargs ))  

   local answers = dialog["Answers"]
   local formatedAnswers = {}

   for i,v in ipairs(answers) do
      if v["Condition"](self,ent) then 
      formatedAnswers[i] = string.format(v["Text"],unpack(v["Args"](self,ent)))  
      end
   end

   net.Start("ix_npc_open")
   net.WriteString(name)
   net.WriteInt(dialogID, 9)
   net.WriteString(formatedText)
   net.WriteTable(formatedAnswers)
   net.WriteEntity(ent)
   net.Send(self)

end

function player:CloseNPCDialog()
   net.Start("ix_npc_close")
   net.Send(self)
end

net.Receive("ix_npc_callback", function(len,ply) 
   local ent = net.ReadEntity()
   local dialogID = net.ReadInt(9)
   local answersID = net.ReadInt(5)

   local dialog = HLXNPC[ent:GetNpc()]["dialogs"][dialogID]
   local answer = dialog["Answers"][answersID]

   if ent:IsNearPlayer(ply) && dialog["Condition"](ply,ent) && answer["Condition"](ply,ent) then 
      answer["CallBack"](ply,ent)
   else
      ply:CloseNPCDialog()
   end
end)

net.Receive("ix_npc_editor_save", function(_, ply)
   if not ply:IsAdmin() then return end

   local definition = net.ReadTable()
   local ok = PLUGIN:RegisterCustomNPC(definition)

   if not ok then
      ply:Notify("Invalid NPC data.")
      return
   end

   PLUGIN:SaveCustomNPCData()
   sendEditorSync()
   ply:Notify("NPC saved in HLXNPC and persisted.")
end)

net.Receive("ix_npc_editor_delete", function(_, ply)
   if not ply:IsAdmin() then return end

   local npcID = string.Trim(net.ReadString() or "")
   if npcID == "" then return end

   PLUGIN.customNPCData = PLUGIN.customNPCData or {}
   if not PLUGIN.customNPCData[npcID] then
      ply:Notify("NPC not found in editor data.")
      return
   end

   PLUGIN.customNPCData[npcID] = nil
   HLXNPC[npcID] = nil
   PLUGIN:SaveCustomNPCData()

   for _, ent in ipairs(ents.FindByClass("ix_npc")) do
      if ent:GetNpc() == npcID then
         ent:Remove()
      end
   end

   sendEditorSync()
   ply:Notify("Editor NPC deleted.")
end)

