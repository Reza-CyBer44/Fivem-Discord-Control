RegisterNetEvent("discordc:kill")

AddEventHandler("discordc:kill", function()
   
   SetEntityHealth(PlayerPedId(), 0)
   
end)