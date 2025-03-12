Config = {}

Config.Locale = 'fr' -- Changer pour 'en' ou autre pour la traduction

Config.Jobs = {
    ['orpailleur'] = {
        jobLabel = 'Orpailleur',
        itemRecolte = 'pepites_or',
        itemTraitement = 'lingot_or',
        prixVente = 100,
        Recolte = vector3(1000.0, 2000.0, 30.0),
        Traitement = vector3(1050.0, 2050.0, 30.0),
        Vente = vector3(1100.0, 2100.0, 30.0),
        Bureau = vector3(1100.0, 2100.0, 30.0),
    },
    ['diamantaire'] = {
        jobLabel = 'Diamantaire',
        itemRecolte = 'diamand_brut',
        itemTraitement = 'diamant_rafine',
        prixVente = 100,
        Recolte = vector3(900.0, 2000.0, 30.0),
        Traitement = vector3(900.0, 2050.0, 30.0),
        Vente = vector3(900.0, 2100.0, 30.0),
        Bureau = vector3(900.0, 2100.0, 30.0),
    }
}