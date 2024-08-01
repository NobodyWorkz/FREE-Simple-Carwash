local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('carwash:check', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.Price
    if xPlayer.getMoney() < price then cb(false) return end
    xPlayser.removeMoney(price)
    cb(true)
end)