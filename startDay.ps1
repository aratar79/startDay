
function applyCommit {

    param (
        [string]$branch
    )
    $messageCommit = Read-Host('Mensaje para el commit(CTRL+C para cancelar)') 
    Write-Host $("-" * 50)
    git commit -m $messageCommit
    Write-Host $("-" * 50)
    git push -u origin $branch.TrimStart()
    Write-Host $("-" * 50)
    return
}

[string]$mainBrach = "" # Here is the name of our main development branch
[string]$currentPath = (Get-Item .).FullName
[string]$repoPath = "" # Here is the path to our local repository
[bool]$haveCommits = $false
Set-Location -Path $repoPath

$currentBranch = (((git branch) | Select-String '\*') -replace '\*' , '').TrimStart()
if ($currentBranch -eq $mainBrach) {
    Write-Host "Estás en la rama principal, por favor ves a tu rama de desarollo para poder ejecutar el script" -BackgroundColor Red -ForegroundColor Black
    Read-Host('Enter para salir') 
    exit
}

Clear-Host

Write-Host "`n`n La rama PRINCIPAL configurada es: $mainBrach " -BackgroundColor Green -ForegroundColor Black
Write-Host "`n Tu rama actual es: $currentBranch " -BackgroundColor Yellow -ForegroundColor Black
$decisionContinue = $Host.UI.PromptForChoice("", "Continuar?", @('&Yes'; '&No'), 1)
if (($decisionContinue) -eq 1) {
    exit
}

Write-Output "Comprobando cambios en TU BRANCH...."
if (git status --porcelain | Where-Object { $_ -match '^\?\?'}) {
    Write-Output "Hay cambios por insertar:"
    Write-Host $("-" * 50)
    git status -s
    Write-Host $("-" * 50)
    git add -A
    Write-Host $("-" * 50)
    applyCommit -branch $currentBranch
}
else {
    Write-Output "No hay cambios por agregar, comprobando commits...."
    if (git status | Where-Object { $_ -match '^(.*?)(by\s[0-9]\scommit(s\b|\b))' }) {
        $haveCommits = $true
        $decisionContinue = $Host.UI.PromptForChoice("Falta hacer push de algunos commits", "Continuar?", @('&Yes'; '&No'), 1)
        if (($decisionContinue) -eq 0){
            git push -u origin $currentBranch
        }
        else {
            exit
        }
    }
    else {
        $haveCommits = $false
    }
}
if(!$haveCommits) {Write-Output "No hay commits pendientes de subir."}
Write-Output "continuamos...."
Write-Host $("-" * 50)
git checkout $mainBrach
Write-Host $("-" * 50)
$currentBranchAfterChange = (((git branch) | Select-String '\*') -replace '\*' , '').TrimStart()
Write-Output "Rama actual: $currentBranchAfterChange"
Write-Output "Descargando cambios del repositorio...."
Write-Host $("-" * 50)
git pull
Write-Host $("-" * 50)
git checkout $currentBranch
Write-Host $("-" * 50)
git merge $mainBrach
Write-Host $("-" * 50)
Set-Location -Path $currentPath
Read-Host('Enter para salir') 






