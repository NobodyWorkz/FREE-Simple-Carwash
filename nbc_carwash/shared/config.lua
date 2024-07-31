Config = {}

Config.Price = 100 -- Preis für die Waschanlage

Config.CarWash = {

	-- Text
    blipName = 'NBC - Waschanlage',
    washText = "Drücke ~r~E~s~ um das Fahrzeug zu waschen!", -- Text ohne Preis
    washTextWithPrice = "Drücke ~r~E~s~ um das Fahrzeug für ~g~$%d~s~ zu waschen!", -- Text mit Preis
    washCompletionMessage = "Dein Fahrzeug ist nun wieder sauber!",
    notEnoughMoneyMessage = "Du hast nicht genug Geld für die Autowäsche.",
    paidMessage = "Du hast ~g~$%d ~s~für die Autowäsche bezahlt.",
	
	-- Progressbar
    progress = {
        label = 'wird gewaschen..', -- Text unter der Progressbar
        duration = 2500, -- DONT CHANGE! 
        position = 'bottom' -- DONT CHANGE! 
    },
	
	-- Positionen der Waschanlagen
    positions = {
        {coord = vector3(24.4675, -1391.8799, 29.3333), rot = 270.0, size = vec3(5, 11, 6), debug = false},
        {coord = vector3(-700.0496, -933.8840, 19.0139), rot = 360.0, size = vec3(5, 11, 6), debug = false},
		{coord = vector3(2524.3776, 4194.7988, 39.9563), rot = 360.0, size = vec3(5, 11, 6), debug = false}
    },
	
	-- Einstellungen für den Marker
	marker = {
		type = 1,  -- Marker-Typ
		color = {r = 8, g = 91, b = 163, a = 200},  -- Marker-Farbe
		scale = vector3(1.0, 0.5, 0.2)  -- Marker-Größe
    }
}
