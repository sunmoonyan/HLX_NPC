
if SERVER then
    


HLXNPC  = 
{

["example_1"] = {
    ["startdialogue"] = 1, -- The starting dialogue ID is 1

    ["dialogue"] = {
        [1] = { -- Dialogue ID 1
            ["text"] = "Hello how are you", -- The sentence spoken by the NPC
            ["args"] = {}, -- Custom arguments that can be injected into the text
            ["condition"] = function(ply) return true end, -- Condition to display this dialogue

            ["buttons"] = {
                [1] = { -- Button 1
                    ["text"] = "No.", -- Text displayed on the button
                    ["args"] = {}, -- Custom arguments for the button text
                    ["condition"] = function(ply) return true end, -- Condition to show this button
                    ["callback"] = function(ply) end, -- Function executed when the player selects this button
                    ["closedialogue"] = true, -- Whether to close the dialogue after selecting this button
                },

                [2] = { -- Button 2
                    ["text"] = "Yes.", -- Text displayed on the button
                    ["args"] = {}, -- Custom arguments for the button text
                    ["condition"] = function(ply) return true end, -- Condition to show this button
                    ["callback"] = function(ply) end, -- Function executed when the player selects this button
                    ["closedialogue"] = true, -- Whether to close the dialogue after selecting this button
                },
            }
        },
    }
},

["example_2"] = {
    ["startdialogue"] = 1,

    ["dialogue"] = {
        [1] = {
            ["text"] = "Hello what is your name?",
            ["args"] = {},
            ["condition"] = function(ply) return true end,

            ["buttons"] = {
                [1] = {
                    ["text"] = "I don't know.",
                    ["args"] = {},
                    ["condition"] = function(ply) return true end,
                    ["callback"] = function(ply) end,
                    ["closedialogue"] = true,
                },

                [2] = {
                    ["text"] = "My name is %s.",
                    ["args"] = {function(ply) return ply:GetName() end}, -- This argument provides the player's name to the text
                    ["condition"] = function(ply) return true end,
                    ["callback"] = function(ply) ply:InteractNPC("example_2", 2) end, -- Triggers the second dialogue when selected
                    ["closedialogue"] = false,
                },
            }
        },

        [2] = {
            ["text"] = "Nice to meet you %s.",
            ["args"] = {function(ply) return ply:GetName() end},
            ["condition"] = function(ply) return true end,

            ["buttons"] = {
                [1] = {
                    ["text"] = "Thanks.",
                    ["args"] = {},
                    ["condition"] = function(ply) return true end,
                    ["callback"] = function(ply) end,
                    ["closedialogue"] = true,
                },
            }
        },
    }
},


}

end
