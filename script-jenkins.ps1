#!/usr/bin/pwsh

# dependencias con PSDepend
Invoke-PSDepend -Path ./Dependencias -Force -ErrorAction Stop | Out-Null

if ($Error.count -eq 0) { 
    Write-Output "Gestionadas todas las dependencias con éxito"
} else {
    Throw "Error ocurrido al ejecutar PSDepend: `n $($Error[0].Exception)"
}
        
# tests con Pester
Invoke-Pester -Output None -ErrorAction Stop | Out-Null

# sabemos que, si todo sale bien, $Error.count debería valer 6 tras los tests de Pester, porque imprime al menos 6 líneas de texto cuando es invocado, más los posibles errores
if ($Error.count -eq 6) {
    Write-Output "Superados todos los Tests de Pester"
} else {
    Throw "Error ocurrido durante los tests de Pester: `n $($Error[0].Exception)"
}

# tests con PSScriptAnalyzer
$PropiedadesScriptAnalyzer=@()
get-content ./Reglas-ScriptAnalyzer/* | 
    where { -not ($_ -match '^#') } | 
    ForEach-Object { $PropiedadesScriptAnalyzer += $_ }

$TestsScriptAnalyzer=Invoke-ScriptAnalyzer -Path ./Gestionar-Datos.ps1 -IncludeRule $PropiedadesScriptAnalyzer

if (($TestsScriptAnalyzer | measure).count -gt 0) {
    Throw "Ha habido $(($TestsScriptAnalyzer | measure).count) errores de PSScriptAnalyzer.$($TestsScriptAnalyzer | select Line,RuleName,Message,Severity)"
} else {
    Write-Output "Se han superado los tests de PSScriptAnalyzer."
}