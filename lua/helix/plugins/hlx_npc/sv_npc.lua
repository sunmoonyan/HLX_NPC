util.AddNetworkString("ix_npc_open")
util.AddNetworkString("ix_npc_close")
util.AddNetworkString("ix_npc_callback")


local player = FindMetaTable("Player")

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

