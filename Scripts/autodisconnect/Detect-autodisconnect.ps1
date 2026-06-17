# Generated from chrispro.tech
$RegistryItems = @(
	@{
		Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters'
		Name = 'autodisconnect'
		Action = 'create'
		Type = 'DWord'
		Expected = 15
	}
)

$Failures = @()

function ConvertTo-ComparableRegistryValue {
	param(
		$Value,
		[string]$Type
	)

	if ($Type -eq 'Binary') {
		return (($Value | ForEach-Object { '{0:X2}' -f [byte]$_ }) -join ',')
	}

	if ($Type -eq 'MultiString') {
		return (($Value | ForEach-Object { [string]$_ }) -join [char]31)
	}

	if ($Type -eq 'ExpandString') {
		return [System.Environment]::ExpandEnvironmentVariables([string]$Value)
	}

	return [string]$Value
}

foreach ($Item in $RegistryItems) {
	if (-not (Test-Path -LiteralPath $Item.Path)) {
		if ($Item.Action -eq 'delete') { continue }
		$Failures += [pscustomobject]@{
			Path = $Item.Path
			Name = $Item.Name
			Reason = 'Registry path does not exist'
			Expected = $Item.Expected
			Actual = '<missing path>'
		}
		continue
	}

	$Property = Get-ItemProperty -LiteralPath $Item.Path -Name $Item.Name -ErrorAction SilentlyContinue
	$ValueExists = $null -ne $Property -and ($Property.PSObject.Properties.Name -contains $Item.Name)

	if ($Item.Action -eq 'delete') {
		if ($ValueExists) {
			$Failures += [pscustomobject]@{
				Path = $Item.Path
				Name = $Item.Name
				Reason = 'Registry value should be deleted'
				Expected = '<deleted>'
				Actual = $Property.($Item.Name)
			}
		}
		continue
	}

	if (-not $ValueExists) {
		$Failures += [pscustomobject]@{
			Path = $Item.Path
			Name = $Item.Name
			Reason = 'Registry value does not exist'
			Expected = $Item.Expected
			Actual = '<missing value>'
		}
		continue
	}

	$Actual = $Property.($Item.Name)
	$ComparableActual = ConvertTo-ComparableRegistryValue -Value $Actual -Type $Item.Type
	$ComparableExpected = ConvertTo-ComparableRegistryValue -Value $Item.Expected -Type $Item.Type
	if ($ComparableActual -ne $ComparableExpected) {
		$Failures += [pscustomobject]@{
			Path = $Item.Path
			Name = $Item.Name
			Reason = 'Registry value does not match expected value'
			Expected = $Item.Expected
			Actual = $ComparableActual
		}
	}
}

if ($Failures.Count -gt 0) {
	Write-Output "Registry remediation detection failed. $($Failures.Count) item(s) require remediation."
	foreach ($Failure in $Failures) {
		Write-Output "Path: $($Failure.Path)"
		Write-Output "Name: $($Failure.Name)"
		Write-Output "Reason: $($Failure.Reason)"
		Write-Output "Expected: $($Failure.Expected)"
		Write-Output "Actual: $($Failure.Actual)"
		Write-Output '---'
	}
	exit 1
}

Write-Output 'Registry remediation detection passed. All registry values match the expected configuration.'
exit 0
