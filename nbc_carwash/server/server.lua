RegisterServerEvent('nbw_carwash:checkWash')
AddEventHandler('nbw_carwash:checkWash', function()
    local player <const> = source

    TriggerClientEvent('nbw_carwash:startWash', player)
end)
