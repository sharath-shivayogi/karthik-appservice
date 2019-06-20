$VMResourceGroup = "test-vmcreate2"
$Location = "East US"
$VNetName = "myVnet"
#$VNetResourceGroup = "myVnet"
$SubnetName = "mySubnet"
$PublicIpName = "test-piP1"
$NICCardName = "testvmhdos"
$VMName = "Drazilevm1"
$VMSize = "Standard_B2s"
$Credential = Get-Credential
$PublisherName ="MicrosoftWindowsServer"
$Offer = "WindowsServer"
$Skus= "2012-R2-Datacenter"
$Version = "latest"
$storageaccountname = "drazilestore"
$Tags = @{Name = "Business Unit"; Value = "Test"}

Login-AzureRmAccount

$Sub = Get-AzureRmSubscription | Out-GridView -PassThru

Select-AzureRmSubscription -Subscription $Sub.Id

    If(!(Get-AzureRmResourceGroup -Name $VMResourceGroup -Location $Location -ErrorAction SilentlyContinue)){
                                                                                                            
                             Write-Host (Get-Date) "Resource Group does not exist. It is now being created... `n" -ForegroundColor Yellow
                                                                                                            
                             New-AzureRmResourceGroup -Name $VMResourceGroup -Location $Location 
                                                                                                            
                             Write-Host (Get-Date) "New Resource Group Action Completed. `n" -ForegroundColor Yellow
                                                                                                            
                                                                                                            }
    $VNet = Get-AzureRmVirtualNetwork | where Name -eq $VNetName
    $SubnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet -ErrorAction SilentlyContinue
    $PublicIP = New-AzureRmPublicIpAddress -Name $PublicIpName -ResourceGroupName $VMResourceGroup -Location $Location -AllocationMethod Static -Tag $Tags -Force
    $Interface = New-AzureRmNetworkInterface -Name $NICCardName -ResourceGroupName $VMResourceGroup -Location $Location -SubnetId $SubnetConfig.ID -PublicIpAddressId $PublicIP.Id -Tag $Tags -Force
    
    Write-Host (Get-Date) "Preparing Initial Compute Configuration for Virtual Machine. Please wait... `n" -ForegroundColor Yellow
    $VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -Tags $Tags
    $VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $PublisherName -Offer $Offer -Skus $Skus -Version $Version
    $VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
    $VirtualMachine = Set-AzureRmVMOSDisk -Name "$VMName.vhd" -VM $VirtualMachine -CreateOption FromImage
    New-AzureRmVM -ResourceGroupName $VMResourceGroup -Location $Location -VM $VirtualMachine -Tag $Tags

    write-host(get-date) "The VM is created Sucessfully and its Running "$VM.name""

   $settings = @{"domainId"="sonata-software.com"; "customerId"="7395ceeb-350d-4179-88c7-b841e87d8bef"; "clientId"="7395ceeb-350d-4179-88c7-b841e87d8bef"; "forceReboot"="yes"};
    $protectedSettings = @{"customerSecretKey"="123456"; "clientSecretKey"="Client Secret Key"};
    Set-AzureRmVMExtension -VMName $vm.Name -ResourceGroupName $vm.ResourceGroupName -Location $vm.Location -Publisher Symantec.CloudWorkloadProtection -ExtensionName SCWPAgentForWindows -ExtensionType SCWPAgentForWindows -Version 1.9 -Settings $settings -ProtectedSettings $protectedSettings -DisableAutoUpgradeMinorVersion 

        
        