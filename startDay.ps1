
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
$haveChanges = git status --porcelain
# if (($haveChanges = git status --porcelain | Where-Object { $_ -match '^\?\?'}) -or (git status --porcelain | Where-Object { $_ -match '[\s\S]+'})) {
if ($haveChanges -match '^\?\?' -or $haveChanges -match '[\s\S]+') {
    if ($haveChanges -like '*UU*') {
        Write-Host "`nHay conflictos por arreglar, solucionalos y haz commit" -BackgroundColor Red -ForegroundColor Black
        exit
    }
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
if (!$haveCommits) { Write-Output "No hay commits pendientes de subir." }
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
$mergeResult = git merge $mainBrach
if ($mergeResult -like '*Automatic merge failed; fix conflicts*') {
    Write-Output $mergeResult
    Write-Host "`nHay conflictos por arreglar, solucionalos y haz commit" -BackgroundColor Red -ForegroundColor Black
}
elseif ($mergeResult -like '*Already up to date.*') {
    Write-Output $mergeResult
    Write-Host "`nNo hay cambios que fusionar " -BackgroundColor Green -ForegroundColor Black
}
else {
    Write-Output $mergeResult
    $decisionPush = $Host.UI.PromptForChoice("Quieres enviar(push) los cambios", "Continuar?", @('&Yes'; '&No'), 1)
    if (($decisionPush) -eq 0) {
        git push
    }
}
Write-Host $("-" * 50)
Set-Location -Path $currentPath
Read-Host('Enter para salir') 







