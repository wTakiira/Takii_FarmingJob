Locales = {
    ['fr'] = {
        ['press_recolte'] = 'Appuyez sur ~INPUT_CONTEXT~ pour récolter.',
        ['press_traitement'] = 'Appuyez sur ~INPUT_CONTEXT~ pour traiter.',
        ['press_vente'] = 'Appuyez sur ~INPUT_CONTEXT~ pour vendre.',
        ['not_enough'] = "Vous n'avez pas assez d'éléments !"
    },
    ['en'] = {
        ['press_recolte'] = 'Press ~INPUT_CONTEXT~ to gather.',
        ['press_traitement'] = 'Press ~INPUT_CONTEXT~ to process.',
        ['press_vente'] = 'Press ~INPUT_CONTEXT~ to sell.',
        ['not_enough'] = "You don't have enough items!"
    }
}

function _U(str)
    return Locales[Config.Locale][str] or 'Translation missing: ' .. str
end