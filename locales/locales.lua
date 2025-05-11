Locales = {
    ['fr'] = {
        ['press_gather'] = 'Appuyez sur [E] pour récolter.',
        ['press_process'] = 'Appuyez sur [E] pour traiter.',
        ['press_sell'] = 'Appuyez sur [E] pour vendre.',
        ['not_enough'] = "Vous n'avez pas assez d'éléments !",
        ['gather_zone'] = "Zone de Recolte",
        ['process_zone'] = "Zone de Traitement",
        ['sell_zone'] = "Zone de Vente",
        ['office'] = "Bureau ",
        ['inprogress_gather'] = 'Récolte en cours...',
        ['inprogress_process'] = 'Traitement en cours...',
        ['inprogress_sell'] = 'Vente en cours...'
    },
    ['en'] = {
        ['press_gather'] = 'Press [E] to gather.',
        ['press_traitement'] = 'Press [E] to process.',
        ['press_sell'] = 'Press [E] to sell.',
        ['not_enough'] = "You don't have enough items!",
        ['gather_zone'] = "Gathering zone",
        ['process_zone'] = "Processing zone",
        ['sell_zone'] = "Selling zone",
        ['office'] = "Office ",
        ['inprogress_gather'] = 'Gathering in progress...',
        ['inprogress_process'] = 'Processing in progress...',
        ['inprogress_sell'] = 'Selling in progress...'
    }
}

function _U(str)
    local text = Locales[Config.Locale][str] or 'Translation missing: ' .. str
    text = string.gsub(text, "[E]", GetControlInstructionalButton(0, 38, true))
    return text
end