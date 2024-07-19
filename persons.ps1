try {

    $config = $configuration | ConvertFrom-Json
    $pathList = @($config.jsonNL,$config.jsonMY,$config.jsonSG)

    $isahPersons = [System.Collections.ArrayList]@()
    foreach ($path in $pathList) {
        $jsonContent = Get-Content -Path $path
        $records = $jsonContent | ConvertFrom-Json
        [void]$isahPersons.Add($records)
        Write-Information "Found [$($records.persons.count)] persons in source file [$path]"    
    }
    Write-Information "Processing [$($isahPersons.persons.count)] persons"

    # Add sequence attribute to contracts
    $isahPersons.Persons.Contracts | Add-Member -MemberType NoteProperty -Name "Sequence" -Value $null -Force
    $isahPersons.Persons.Contracts | Add-Member -MemberType NoteProperty -Name "Team" -Value $null -Force

    # add contracts, externalId and displayName properties to persons
    foreach ($isahPerson in $isahPersons.Persons) {
        
        # Include employeeId in displayname
        $isahPerson.DisplayName = "$($isahPerson.DisplayName) ($($isahPerson.ExternalId))"

        # Create list to hold the person's contracts
        $contractList = [System.Collections.ArrayList]@()
    
        foreach ($isahContract in $isahPerson.Contracts) {
            #Make a copy of the contract object so we can manipulate it without affecting the other contract objects
            $rbacAttributeNameList = @("RBAC1","RBAC2","RBAC3")

            # loop through all properties in rbac object
            $i = 1
            foreach ($rbacAttribute in $rbacAttributeNameList) {
                
                $contract = $isahContract.PSObject.Copy()

                foreach ($rbacAttributeToDelete in $rbacAttributeNameList) {
                    $contract.psobject.properties.remove($rbacAttributeToDelete)
                }
                
                if (-not [string]::IsNullOrEmpty($isahContract.$rbacAttribute.ID)) {                
                    $contract.ExternalId = "$($isahPerson.externalId)_$i"
                    $contract.Team = [PsCustomObject]@{
                            id = $($isahContract.$rbacAttribute.ID)
                            name = $($isahContract.$rbacAttribute.Name)
                        }

                    $contract.StartDate = $isahContract.$rbacAttribute.StartDate

                    # EndDate of role cannot be later than the actual enddate of the contract
                    if (-not [string]::IsNullOrEmpty($isahContract.EndDate) -and ([string]::IsNullOrEmpty($isahContract.$rbacAttribute.EndDate) -or [DateTime]$isahContract.$rbacAttribute.EndDate -gt [DateTime]$isahContract.EndDate)) {
                        Write-Warning "Changed the role [$($isahContract.$rbacAttribute.ID)] enddate for person [$($isahPerson.externalId)] to [$($isahContract.EndDate)] as the role enddate [$($isahContract.$rbacAttribute.EndDate)] superseeds the conract enddate [$($isahContract.EndDate)]"
                        $contract.EndDate = $isahContract.EndDate       
                    } else {
                        $contract.EndDate = $isahContract.$rbacAttribute.EndDate
                    }
                    
                    $contract.Sequence = $($i)
                    
                    [void]$contractList.Add($contract);
                }
                $i++            
            }
            
            # If no roles have been assigned at all, add the original contract to the system
            if ($contractList.Count -eq 0) {
                Write-Warning "No role found for person [$($isahPerson.externalId)]. Skipping role logic to define contract"
                $isahContract.ExternalId = "$($isahPerson.externalId)_0"
                $isahContract.Sequence = '1'
            
                [void]$contractList.Add($isahContract);
            }
        }
            
        # Assign contracts to person
        $isahPerson.Contracts = $contractList

        # Output one person to HelloID
        Write-Output ($isahPerson | ConvertTo-Json -Depth 10)
    }
} catch {
    $ex = $PSItem
    $verboseErrorMessage = $ex.Exception.Message  
    $auditErrorMessage = $ex.Exception.Message
    
    Write-Warning "Error occurred for person [$($isahPerson.ExternalId)]. Error at Line [$($ex.InvocationInfo.ScriptLineNumber)]: $($ex.InvocationInfo.Line). Error: $($VerboseErrorMessage)"
    
    throw "Could not enhance and export person objects to HelloID. Error Message: $($auditErrorMessage)"
}