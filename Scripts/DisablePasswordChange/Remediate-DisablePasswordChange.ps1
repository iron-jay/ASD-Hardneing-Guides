# Generated from chrispro.tech
$RegistryItems = @(
	@{
		Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
		Name = 'DisablePasswordChange'
		Action = 'create'
		Type = 'DWord'
		Value = 1
	}
)

foreach ($Item in $RegistryItems) {
	try {
		if ($Item.Action -eq 'delete') {
			if (Test-Path -LiteralPath $Item.Path) {
				$Property = Get-ItemProperty -LiteralPath $Item.Path -Name $Item.Name -ErrorAction SilentlyContinue
				$ValueExists = $null -ne $Property -and ($Property.PSObject.Properties.Name -contains $Item.Name)

				if ($ValueExists) {
					Remove-ItemProperty -LiteralPath $Item.Path -Name $Item.Name -ErrorAction Stop
				}
			}
			continue
		}

		if (-not (Test-Path -LiteralPath $Item.Path)) {
			if ($Item.Action -eq 'create') {
				New-Item -Path $Item.Path -Force -ErrorAction Stop | Out-Null
			}
			else {
				throw "Registry path does not exist: $($Item.Path)"
			}
		}

		New-ItemProperty `
			-LiteralPath $Item.Path `
			-Name $Item.Name `
			-PropertyType $Item.Type `
			-Value $Item.Value `
			-Force `
			-ErrorAction Stop `
			| Out-Null
	}
	catch {
		Write-Output "Failed to remediate registry value $($Item.Path)\$($Item.Name)"
		Write-Output "Exception: $($_.Exception.Message)"
		exit 1
	}
}

Write-Output 'Registry remediation completed successfully.'
exit 0
