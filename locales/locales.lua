Locales = {
    ['fr'] = {
        ['press_gather'] = 'Appuyez sur ~INPUT_CONTEXT~ pour récolter.',
        ['press_process'] = 'Appuyez sur ~INPUT_CONTEXT~ pour traiter.',
        ['press_sell'] = 'Appuyez sur ~INPUT_CONTEXT~ pour vendre.',
        ['not_enough'] = "Vous n'avez pas assez d'éléments !",
        ['gather_zone'] = "Zone de Recolte",
        ['process_zone'] = "Zone de Traitement",
        ['sell_zone'] = "Zone de Vente",
        ['office'] = "Bureau "
    },
    ['en'] = {
        ['press_gather'] = 'Press ~INPUT_CONTEXT~ to gather.',
        ['press_traitement'] = 'Press ~INPUT_CONTEXT~ to process.',
        ['press_sell'] = 'Press ~INPUT_CONTEXT~ to sell.',
        ['not_enough'] = "You don't have enough items!",
        ['gather_zone'] = "Gathering zone",
        ['process_zone'] = "Processing zone",
        ['sell_zone'] = "Selling zone",
        ['office'] = "Office "
    }
}

function _U(str)
    local text = Locales[Config.Locale][str] or 'Translation missing: ' .. str
    text = string.gsub(text, "~INPUT_CONTEXT~", GetControlInstructionalButton(0, 38, true))
    return text
end