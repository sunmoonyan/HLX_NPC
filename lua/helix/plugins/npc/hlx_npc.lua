------------ MINIMUM TEMPLATE -------------

HLXNPC["template"] = {

    startdialog = function(ply,ent)
        return 1
    end,

    onTakeDamage = function(ent)

    end,

    dialogs = {

        [1] = {
            ["Text"] = [[]],
            ["Args"] = function(ply, ent)
                return {}
            end,
            ["Condition"] = function(ply, ent)
                return true
            end,            
            ["Answers"] = {

                [1] = {
                    ["Condition"] = function(ply, ent)
                        return true
                    end,
                    ["Text"] = "",
                    ["Args"] = function(ply, ent)
                        return {}
                    end,
                    ["CallBack"] = function(ply, ent)
                        ply:CloseNPCDialog()
                    end,
                },

            },

        },


    },

}

--------------------------------------

HLXNPC["gun_dealer"] = {

    startdialog = function(ply,ent)
        return 1
    end,

    onTakeDamage = function(ent)

    end,

    dialogs = {

        [1] = {
            ["Text"] = [[Hey %s , my name is %s, would you like to buy a gun]],
            ["Args"] = function(ply, ent)
                return {ply:GetCharacter():GetName(),ent:GetDisplayName()}
            end,
            ["Condition"] = function(ply, ent)
                return true
            end,            
            ["Answers"] = {

                [1] = {
                    ["Condition"] = function(ply, ent)
                        return true
                    end,
                    ["Text"] = "No",
                    ["Args"] = function(ply, ent)
                        return {}
                    end,
                    ["CallBack"] = function(ply, ent)
                        ply:CloseNPCDialog()
                    end,
                },

                [2] = {
                    ["Condition"] = function(ply, ent)
                        return true
                    end,
                    ["Text"] = "Yes [500$]",
                    ["Args"] = function(ply, ent)
                        return {}
                    end,
                    ["CallBack"] = function(ply, ent)
                        ply:CloseNPCDialog()
                        ply:GetCharacter():SetMoney(ply:GetCharacter():GetMoney()-500)
                        ply:Give("weapon_357")
                    end,
                },

            },

        },


    },

}

---------------------------

HLXNPC["grocery"] = {

    startdialog = function(ply,ent)
        return 1
    end,

    onTakeDamage = function(ent)
        ent:PlayNPCAnimation("idle_all_cower",5)
        ent:EmitSound("ambient/voices/m_scream1.wav")
    end,

    dialogs = {

        [1] = {
            ["Text"] = [[Hey %s , my name is %s, what do you want]],
            ["Args"] = function(ply, ent)
                return {ply:GetCharacter():GetName(),ent:GetDisplayName()}
            end,
            ["Condition"] = function(ply, ent)
                return true
            end,            
            ["Answers"] = {

                [1] = {
                    ["Condition"] = function(ply, ent)
                        return true
                    end,
                    ["Text"] = "Nothing",
                    ["Args"] = function(ply, ent)
                        return {}
                    end,
                    ["CallBack"] = function(ply, ent)
                        ply:CloseNPCDialog()
                    end,
                },

                [2] = {
                    ["Condition"] = function(ply, ent)
                        return ply:IsAdmin()
                    end,
                    ["Text"] = "Sell",
                    ["Args"] = function(ply, ent)
                        return {}
                    end,
                    ["CallBack"] = function(ply, ent)
                        ply:CloseNPCDialog()
                    end,
                },

                [3] = {
                    ["Condition"] = function(ply, ent)
                        return true
                    end,
                    ["Text"] = "Buy",
                    ["Args"] = function(ply, ent)
                        return {}
                    end,
                    ["CallBack"] = function(ply, ent)
                        ply:OpenNPCDialog(ent,2)
                        ent:PlayNPCAnimation("gesture_disagree_original")
                        ent:EmitSound("vo/npc/male01/sorrydoc02.wav")
                    end,
                },
            },

        },

        [2] = {
            ["Text"] = [[Im sorry but i dont have anything to sell]],
            ["Args"] = function(ply, ent)
                return {}
            end,
            ["Condition"] = function(ply, ent)
                return true
            end,            
            ["Answers"] = {
                [1] = {
                    ["Condition"] = function(ply, ent)
                        return true
                    end,
                    ["Text"] = "Okay",
                    ["Args"] = function(ply, ent)
                        return {}
                    end,
                    ["CallBack"] = function(ply, ent)
                        ply:CloseNPCDialog()
                        ent:PlayNPCAnimation("gesture_item_throw")
                        ent:EmitSound("vo/coast/barn/male01/lite_rockets01.wav")
                    end,
                },

            },

        },

    },

}

