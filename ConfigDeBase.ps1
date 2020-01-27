Function Write-log {
        <#
        .SYNOPSIS
        Cette fonction permet d'afficher un statut d'exécution du script.
        .DESCRIPTION
        Cette fonction permet d'écrire un message au sein d'un fichier log, ainsi qu'à l'écran.
        .PARAMETER message
           Spécifie le message à afficher.
        .PARAMETER Chemin
           Spécifie le chemin du fichier log a utiliser.
        .parameter Type
         Possibilite de choix entre OK et ECHEC.
            OK --> [OK]>
            ECHEC  --> [ECHEC]>
            RIEN --> [--]>
        .parameter Action
         Possibilité de choix entre Update, Create, Get, Test, Export.
            UPDATE --> [UPDATE]>
            CREATE --> [CREATE]>
            GET --> [GET]>
            EXPORT --> [EXPORT]>
            TEST --> [TEST]>
            RIEN --> [--]>
        .PARAMETER Erreur
            Spécifie l'erreur à écrire dans le fichier log.
        .EXAMPLE
           write-log -message "Fin d'execution du script." -type "OK" -action UPDATE
        .EXAMPLE
            write-log -message "une erreur s'est produite." -type ECHEC -Erreur "$($_.exception.message)"  -action UPDATE
         #>

    [Cmdletbinding()]
    Param(
        [Parameter(mandatory=$true,position=0)]$message,
        [Parameter(mandatory=$false,position=2)]$chemin = "c:\temp\config_vm.log",
        [Parameter(mandatory=$false,position=1)][ValidateSet("OK","ECHEC")]$type,
        [Parameter(mandatory=$false,position=1)]$Erreur,
        [Parameter(mandatory=$false,position=1)][ValidateSet("Green","Red","Yellow","White","Magenta")]$Colortext ="White"


    )
    
    #Definition du type
        switch ($type){
            ("OK"){$status  = "[OK]>"}
            ("ECHEC"){$status = "[ECHEC]>"}
            Default {$status  = "[--]>"}
        }

   
   #Creation du message
        if (!(Test-Path c:\temp)) {md C:\temp | Out-Null} 

        $Timestamp = get-date  -Format yyyyMMdd-HH:mm:ss
        $MessageComplet = $timestamp + $status  + $TypeAction + $message + $Erreur
    #Affichage du message sur l'ecran
        write-host $messagecomplet -ForegroundColor $Colortext
        write-verbose "Ecriture du message suivant : $($Message) au sein du fichier $($chemin)"
    #Ecriture du message dans le fichier log.
        $messagecomplet| out-file -FilePath $chemin -Append -Encoding unicode

}

try{
    $interface = Get-NetConnectionProfile
    $index = $interface.InterfaceIndex
    Set-NetConnectionProfile -InterfaceIndex $index -NetworkCategory Private
   #Set-NetConnectionProfile  -NetworkCategory Private
   }
Catch{
   	
   }

#Paramétrage de la zone de temp de l'horloge
    
Try{
    Set-NetFirewallProfile -All -Enabled False
    Write-log -message "La désactivation du firewall a été réalisé avec succés" -type OK -Colortext Green
}
catch [System.Net.WebException], [System.Exception] {
    Write-log -message "ERREUR.... une erreur s'est produite lors de la désactivation du firewall." -type ECHEC -Erreur "$($_.exception.message) // $($_.ErrorDetails.Message)" -Colortext Red
}
	
Try{
    winrm quickconfig -quiet
    Write-log -message "L'activation de WinRm a été réalisé avec succés" -type OK -Colortext Green
}
catch [System.Net.WebException], [System.Exception] {
    Write-log -message "ERREUR.... une erreur s'est produite lors de l'activation de WinRm." -type ECHEC -Erreur "$($_.exception.message) // $($_.ErrorDetails.Message)" -Colortext Red
}

Try{
    	set-item wsman:\localhost\Client\TrustedHosts -value * -Force
    Write-log -message "Le paramétrage de WSMAN a été réalisé avec succés" -type OK -Colortext Green
}
catch [System.Net.WebException], [System.Exception] {
    Write-log -message "ERREUR.... une erreur s'est produite lors du paramétrage de WSMAN." -type ECHEC -Erreur "$($_.exception.message) // $($_.ErrorDetails.Message)" -Colortext Red
}
