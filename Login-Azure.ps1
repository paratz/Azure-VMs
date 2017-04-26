#SubscriptionName                 SubscriptionId                      
#----------------                 --------------                      
#Visual Studio Enterprise         xxxxxxxxxe-f464-45d8-adeb-c7a0e8c678f6
#Visual Studio Ultimate with MSDN xxxxxxxx-c5a1-4bee-8f4a-5ccaeccc0787

Login-AzureRmAccount

#Iniciar Sesión en Portal Clásico
Add-AzureAccount

#Listar todas las subscripciones existentes
Get-AzureSubscription

#Seleccionar la subscripción donde se trabajará (reemplazar el subscriptionID obtenido del comando anterior)
Select-AzureSubscription -SubscriptionId cfcb919c-c5a1-4bee-8f4a-5ccaeccc0787
Select-AzureRmSubscription -SubscriptionId cfcb919c-c5a1-4bee-8f4a-5ccaeccc0787