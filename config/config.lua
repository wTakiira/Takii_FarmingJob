Config = {}

Config.Locale = 'fr' -- Changer pour 'en' ou autre pour la traduction

-- Config.Target = false -- true = utilise ox_target, false = touche E

Config.Jobs = {
    ['vitapharma'] = {
        jobLabel = 'VitaPharma',
        itemRecolte = 'herbe_rare',
        itemTraitement = 'serum_vital',
        prixVente = 80,
        Recolte = {
            vector3(617.55395507812, 6501.4287109375, 29.453231811523),
            vector3(624.28735351562, 6481.7534179688, 30.698589324951),
            vector3(653.51849365234, 6479.7172851562, 30.519912719727),
            vector3(675.76525878906, 6459.203125, 31.15588760376),
            vector3(646.97906494141, 6458.2094726562, 30.838819503784),
            vector3(657.35681152344, 6492.404296875, 29.272426605225)
        },
        Traitement = vector3(441.29525756836, 6458.2734375, 28.748794555664),
        Vente = vector3(750.52545166016, 6459.84375, 31.267671585083),
        Bureau = vector3(417.16439819336, 6520.6079101562, 27.712482452393),
        grades = {
            --Laisser "boss" dans le name Pour le boss/patron
            {grade = 0, name = 'boss', label = 'Patron', salary = 25, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'employee', label = 'Chercheur', salary = 15, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'trainee', label = 'Testeur', salary = 10, skin_male = '{}', skin_female = '{}'}
        },
        Color = 24
    },
    ['emerauderie'] = {
        jobLabel = 'Émerauderie',
        itemRecolte = 'green_garnet',
        itemTraitement = 'emerald_crystal',
        prixVente = 90,
        Recolte = {
            vector3(2918.1879882812, 2795.3356933594, 41.23596572876),
            vector3(2931.8588867188, 2778.234375, 39.638893127441),
            vector3(2955.1374511719, 2769.7473144531, 38.897228240967),
            vector3(2952.25, 2796.4118652344, 40.917369842529),
            vector3(2986.1259765625, 2814.1828613281, 45.0456199646),
            vector3(2975.93359375, 2793.7626953125, 40.816635131836)
        },
        Traitement = vector3(3021.2036132812, 2949.2858886719, 66.283508300781),
        Vente = vector3(2944.2331542969, 2742.7416992188, 43.383167266846),
        Bureau = vector3(2831.7336425781, 2799.5510253906, 57.530693054199),
        grades = {
            {grade = 0, name = 'boss', label = 'Grand Maître', salary = 25, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'employee', label = 'Tailleur d’Émeraude', salary = 15, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'trainee', label = 'Chercheur de Veines', salary = 10, skin_male = '{}', skin_female = '{}'}
        },
        Color = 25 
    },
    ['junglejuice'] = {
        jobLabel = 'Jungle Juice',
        itemRecolte = 'fruit_exotique',
        itemTraitement = 'jus_exotique',
        prixVente = 60,
        Recolte = {
            vector3(5349.6708984375, -5205.0693359375, 30.873620986938), 
            vector3(5339.2954101562, -5188.1840820312, 31.209104537964),
            vector3(5364.5737304688, -5179.8325195312, 30.056083679199),
            vector3(5353.04296875, -5161.880859375, 28.994323730469),  
            vector3(5329.357421875, -5164.4702148438, 27.373447418213),
            vector3(5343.4497070312, -5173.8237304688, 29.325666427612),
        },
        Traitement = vector3(5327.5546875, -5265.431640625, 33.162719726562),
        Vente = vector3(5260.7836914062, -5255.703125, 25.40514755249),
        Bureau = vector3(5404.9194335938, -5171.9291992188, 31.450870513916),
        grades = {
            {grade = 0, name = 'boss', label = 'Boss Tropical', salary = 25, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'mixer', label = 'Mixologue', salary = 15, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'cueilleur', label = 'Cueilleur', salary = 10, skin_male = '{}', skin_female = '{}'}
        },
        Color = 46
    },
    ['winemaker'] = {
        jobLabel = 'Vigneron',
        itemRecolte = 'cervenehrozno',
        itemTraitement = 'cervenaflasa',
        prixVente = 70,
        Recolte = {
            vector3(-1892.2630615234, 2247.5378417969, 79.791488647461),
            vector3(-1885.2938232422, 2249.8662109375, 80.565353393555),
            vector3(-1880.8044433594, 2245.7661132812, 83.31901550293),
            vector3(-1900.4421386719, 2263.1162109375, 71.090675354004),
            vector3(-1891.2221679688, 2242.9599609375, 82.001930236816),
            vector3(-1883.1295166016, 2241.185546875, 84.780899047852)
        },
        Traitement = vector3(-1928.7921142578, 2059.7016601562, 140.83699035645),
        Vente = vector3(-1929.8935546875, 1778.8549804688, 173.16558837891),
        Bureau = vector3(-1876.0469970703, 2061.08984375, 145.57369995117),
        grades = {
            {grade = 0, name = 'boss', label = 'Chef de Mine', salary = 30, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'tailleur', label = 'Tailleur de Cristaux', salary = 20, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'mineur', label = 'Mineur', salary = 12, skin_male = '{}', skin_female = '{}'}
        },
        Color = 61
    },
    -- ['selmarinus'] = {
    --     jobLabel = 'Sel Marinus',
    --     itemRecolte = 'sel_brut',
    --     itemTraitement = 'sel_traite',
    --     prixVente = 80,
    --     Recolte = {
    --         vector3(1524.5137939453, 3910.5270996094, 31.022630691528),
    --         vector3(1583.1916503906, 3890.9255371094, 31.089782714844),
    --         vector3(1583.0323486328, 3845.8823242188, 31.089359283447),
    --         vector3(1582.8843994141, 3911.6206054688, 30.864990234375),
    --         vector3(1565.7940673828, 3837.6528320312, 30.945777893066),
    --         vector3(1522.435546875, 3924.1984863281, 30.98267364502)
    --     },
    --     Traitement = vector3(1447.5296630859, 3754.55859375, 31.998582839966),
    --     Vente = vector3(911.15686035156, 3644.0490722656, 32.676258087158),
    --     Bureau = vector3(1529.8167724609, 3778.0786132812, 34.511341094971),
    --     grades = {
    --         {grade = 0, name = 'boss', label = 'Maître Saunier', salary = 25, skin_male = '{}', skin_female = '{}'},
    --         {grade = 1, name = 'raffineur', label = 'Raffineur', salary = 15, skin_male = '{}', skin_female = '{}'},
    --         {grade = 2, name = 'ramasseur', label = 'Ramasseur', salary = 10, skin_male = '{}', skin_female = '{}'}
    --     },
    --     Color = 0
    -- },
    ['perlanostra'] = {
        jobLabel = 'Perla Nostra',
        itemRecolte = 'coquillage_perle',
        itemTraitement = 'perle_polie',
        prixVente = 100,
        Recolte = {
            vector3(-2224.3002929688, -441.37646484375, 1.1078805923462),
            vector3(-2217.5068359375, -425.9143371582, 4.0740637779236),
            vector3(-2218.9548339844, -404.67541503906, 7.9692792892456),
            vector3(-2233.2492675781, -417.34024047852, 3.7647454738617),
            vector3(-2240.6635742188, -430.69653320312, 1.8091315031052),
            vector3(-2245.1447753906, -417.26165771484, 3.3753733634949)
        },
        Traitement = vector3(-2134.5539550781, -393.71762084961, 13.187870979309),
        Vente = vector3(-2230.8542480469, -364.27279663086, 13.316324234009),
        Bureau = vector3(-2189.6918945312, -400.09307861328, 13.269594192505),
        grades = {
            {grade = 0, name = 'boss', label = 'Don Perla', salary = 30, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'tailleur', label = 'Polisseur', salary = 18, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'plongeur', label = 'Plongeur', salary = 12, skin_male = '{}', skin_female = '{}'}
        },
        Color = 32
    },
    ['lordorient'] = {
        jobLabel = "L'Or d'Orient",
        itemRecolte = 'crocus_zaffra',
        itemTraitement = 'filament_oriental',
        prixVente = 120,
        Recolte = {
            vector3(1869.6317138672, 4843.4365234375, 44.540153503418),
            vector3(1860.4416503906, 4825.5024414062, 44.872959136963),
            vector3(1852.1085205078, 4797.5615234375, 43.598724365234),
            vector3(1866.9167480469, 4785.0791015625, 42.733860015869),
            vector3(1886.1955566406, 4790.220703125, 44.347118377686),
            vector3(1889.7873535156, 4813.724609375, 45.44917678833)
        },
        Traitement = vector3(2015.92578125, 4984.3193359375, 41.319957733154),
        Vente = vector3(1901.5491943359, 4924.158203125, 48.830024719238),
        Bureau = vector3(1929.9532470703, 4635.31640625, 40.463779449463),
        grades = {
            {grade = 0, name = 'boss', label = 'Maître Safranier', salary = 28, skin_male = '{}', skin_female = '{}'},
            {grade = 1, name = 'secheur', label = 'Séchage', salary = 17, skin_male = '{}', skin_female = '{}'},
            {grade = 2, name = 'cueilleur', label = 'Cueilleur', salary = 12, skin_male = '{}', skin_female = '{}'}
        },
        Color = 59
    },
}