try {
    $config = $configuration | ConvertFrom-Json
    $pathList = @($config.jsonNL, $config.jsonMY, $config.jsonSG)

    $isahPersons = [System.Collections.ArrayList]@()
    foreach ($path in $pathList) {
        $jsonContent = Get-Content -Path $path
        $records = $jsonContent | ConvertFrom-Json
        [void]$isahPersons.Add($records)
    }

    $isahDepartmentList = $isahPersons.Persons.Contracts | Where-Object { $_.Department.ExternalId -ne "" } | Select-Object Department, Manager
    $departmentList = [System.Collections.ArrayList]@()

    foreach ($isahDepartment in $isahDepartmentList) {
        $department = [PscustomObject]@{
            ExternalId        = $isahDepartment.Department.ExternalId
            DisplayName       = $isahDepartment.Department.DisplayName
            ParentExternalId  = $null
            ManagerExternalId = $null
        }

        [void]$departmentList.Add($department)
    }

    $departmentListGrouped = $departmentList | Group-Object ExternalId | Sort-Object #-AsHashtable
    foreach ($department in $departmentListGrouped) {
        Write-Output $department.Group[0] | Get-Unique | ConvertTo-Json
    }
}
catch {
    $ex = $PSItem
    $verboseErrorMessage = $ex.Exception.Message
    $auditErrorMessage = $ex.Exception.Message

    Write-Warning "Error occurred for department [$($isahDepartment.Department.ExternalId)]. Error at Line [$($ex.InvocationInfo.ScriptLineNumber)]: $($ex.InvocationInfo.Line). Error: $($VerboseErrorMessage)"

    throw "Could not enhance and export person objects to HelloID. Error Message: $($auditErrorMessage)"
}