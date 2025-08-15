util.AddNetworkString("ix_npc_send")
util.AddNetworkString("ix_npc_callback")
util.AddNetworkString("ix_npc_focus")

local player = FindMetaTable("Player")


   hook.Add("PlayerInitialSpawn", "HLXNPC_InitDialogueVar", function(ply)
      ply.hlxnpc_var = {}
   end)


   function player:IsNearNPC(npc)
      for i,v in ipairs(ents.FindInBox(self:GetPos()-Vector(100,100,100), self:GetPos()+Vector(100,100,100))) do
         if v:GetClass() == "ix_npc" then 
            if v:GetNpc() == npc then
               return true
            end
         end
      end
   end

   function player:InteractNPC(npc,dialogue)
      if dialogue then
      self:SendNPCDialogue(dialogue,npc,campos,camang)
      else
         if isfunction(HLXNPC[npc]["startdialogue"]) then
         self:SendNPCDialogue(HLXNPC[npc]["startdialogue"](self),npc,campos,camang)      
         else
         self:SendNPCDialogue(HLXNPC[npc]["startdialogue"],npc,campos,camang)   
         end
      end
   end

   function player:SendNPCDialogue(dialogue,npc)
     local FDialogue = ""
     local FArgs = {}
     local FArgsButton = {}
     local FButton = {}

     if HLXNPC[npc]["dialogue"][dialogue]["condition"](self) then else return end

     for i,v in ipairs(HLXNPC[npc]["dialogue"][dialogue]["args"]) do

        if isfunction(v) then
        FArgs[i] = v(self)
        else
        FArgs[i] = v
        end
     end
     
     for i,v in ipairs(HLXNPC[npc]["dialogue"][dialogue]["buttons"]) do
        if isfunction(v["condition"]) then
          if  v["condition"](self) then  
            FArgsButton[i] = {}

            for n,m in ipairs(v["args"]) do
               FArgsButton[i][n] = {}
               if isfunction(m) then
              FArgsButton[i][n] = m(self)
              else
              FArgsButton[i][n] = m
              end
            end
   
          FButton[i] = {string.format(v["text"], unpack( FArgsButton[i] ) ), v["closedialogue"] }
          end
        end

     end

     FDialogue = string.format(HLXNPC[npc]["dialogue"][dialogue]["text"], unpack( FArgs ) )  

     net.Start("ix_npc_send") --Nom
     net.WriteString(npc) --npc
     net.WriteInt(dialogue, 6)
     net.WriteString(FDialogue) --Dialogue
     net.WriteTable(FButton) --Buttons
     net.Send(self)

   end


   net.Receive("ix_npc_callback", function(len,ply) 
   local npc = net.ReadString()
   local dialogue = net.ReadInt(6)
   local button = net.ReadInt(4)

   if ply:IsNearNPC(npc) && HLXNPC[npc]["dialogue"][dialogue]["buttons"][button]["condition"](ply) then
   
     HLXNPC[npc]["dialogue"][dialogue]["buttons"][button]["callback"](ply)

   end

   end)

