--
local langcf = "GERss"
local CFGVAR = langcf
LSP.Language = {}
LSP.Language.Langs = {
    ["ENG"] = {
        ["LSP.Load"] = "LSP: Language System Loaded",
    }, 
    ["GER"] = {
        ["LSP.Load"] = "LSP: Sprache System geladen",
    },
}  

function LSP:GetPhrase(phrase)
    return LSP.Language.Langs[CFGVAR][phrase]
end
