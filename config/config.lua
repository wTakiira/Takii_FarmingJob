Config = {}

Config.Locale = 'fr' -- Changer pour 'en' ou autre pour la traduction

Config.Jobs = {
    ['orpailleur'] = {
        jobLabel = 'Orpailleur',
        itemRecolte = 'pepites_or',
        itemTraitement = 'lingot_or',
        prixVente = 100,
        Recolte = {
            vector3(569.4502, 246.7754, 103.1509),
            vector3(572.0, 250.0, 103.0),
            vector3(565.0, 240.0, 103.0)
        },
        Traitement = vector3(601.7166, 244.2060, 102.902),
        Vente = vector3(615.5301, 260.4384, 103.0894),
        Bureau = vector3(594.4901, 258.3544, 103.3166),
        grades = {
            --Laisser ID 0 Pour le boss/patron
            {grade = 0, name = 'boss', label = 'Patron', salary = 1500, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'employee', label = 'Employé', salary = 1000, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'trainee', label = 'Recrue', salary = 500, skin_male = '{}', skin_female = '{}'}
        },
        Color = 5
    },
    ['diamantaire'] = {
        jobLabel = 'Diamantaire',
        itemRecolte = 'diamand_brut',
        itemTraitement = 'diamant_rafine',
        prixVente = 100,
        Recolte = {
            vector3(900.0, 2000.0, 30.0),
            vector3(905.0, 2010.0, 30.0),
            vector3(910.0, 2020.0, 30.0)
        },
        Traitement = vector3(900.0, 2050.0, 30.0),
        Vente = vector3(900.0, 2100.0, 30.0),
        Bureau = vector3(900.0, 2100.0, 30.0),
        grades = {
            {grade = 0, name = 'boss', label = 'Patron', salary = 1500, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'employee', label = 'Employé', salary = 1000, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'trainee', label = 'Recrue', salary = 500, skin_male = '{}', skin_female = '{}'}
        },
        Color = 15 
    }
}