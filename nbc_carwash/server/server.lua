local ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('nbw_carwash:checkWash')
AddEventHandler('nbw_carwash:checkWash', function()
    local player <const> = source

    TriggerClientEvent('nbw_carwash:startWash', player)
end)

RegisterServerEvent('carwash:chargePlayer')
AddEventHandler('carwash:chargePlayer', function(price)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if xPlayer and xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('esx:showNotification', _source, string.format(Config.CarWash.paidMessage, price))
    else
        TriggerClientEvent('esx:showNotification', _source, Config.CarWash.notEnoughMoneyMessage)
    end
end)