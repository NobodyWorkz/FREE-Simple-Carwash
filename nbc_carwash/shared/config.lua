Config = {}

Config.CarWash = {

	-- Preis für die Waschanlage
    price = 0,
	
	-- Text
    blipName = 'NBC - Waschanlage',
	washText = "Drücke ~r~E~s~ um das Fahrzeug zu waschen!",
    washCompletionMessage = "Dein Fahrzeug ist nun wieder sauber!",
	
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
		{coord = vector3(851.72, -2110.8, 30.58), rot = 360.0, size = vec3(5, 11, 6), debug = false},
        {coord = vector3(-516.00323486328, 7581.4624023438, 6.3631510734558), rot = 360.0, size = vec3(5, 11, 6), debug = false}
    },
	marker = {
		type = 1,  -- Marker-Typ
		color = {r = 8, g = 91, b = 163, a = 200},  -- Marker-Farbe
		scale = vector3(1.0, 0.5, 0.2)  -- Marker-Größe
    }
}