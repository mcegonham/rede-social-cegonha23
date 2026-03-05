# Configurações de Codificação para evitar caracteres estranhos
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Iniciar-Sombra {
    param (
        [string]$urlAlvo,
        [int]$maxDepth = 6
    )

    $visitados = New-Object System.Collections.Generic.HashSet[string]
    $arquivoLog = "shadow_dump_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
    
    Write-Host "`n[!] INICIANDO VARREDURA PROFUNDA (NÍVEL $maxDepth)" -ForegroundColor Cyan
    Write-Host "[!] ALVO: $urlAlvo" -ForegroundColor White
    Write-Host "[!] LOG: $arquivoLog" -ForegroundColor Gray
    Write-Host "---------------------------------------------------"

    $fila = New-Object System.Collections.Generic.Queue[PSCustomObject]
    $fila.Enqueue(@{url=$urlAlvo; depth=0})

    while ($fila.Count -gt 0) {
        $item = $fila.Dequeue()
        $url = $item.url
        $depth = $item.depth

        if ($depth -le $maxDepth -and -not $visitados.Contains($url)) {
            try {
                $visitados.Add($url) | Out-Null
                
                # Interface Visual no Terminal
                Write-Host "[Nivel $depth][Capturado] " -NoNewline -ForegroundColor DarkGray
                Write-Host $url -ForegroundColor Green
                
                # Salva no arquivo em tempo real
                $url | Out-File -FilePath $arquivoLog -Append

                # Requisição simulando Navegador Real
                $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
                
                # Extração de links (apenas HTTP/HTTPS)
                $links = $resp.Links.Href | Where-Object { $_ -match "^https?://" } | Select-Object -Unique

                foreach ($l in $links) {
                    $fila.Enqueue(@{url=$l; depth=$($depth + 1)})
                }

                # Delay humano para evitar Ban do Server
                Start-Sleep -Milliseconds 150

            } catch {
                Write-Host "[!] FALHA: $url" -ForegroundColor Red
            }
        }
    }
    Write-Host "`n[OK] VARREDURA CONCLUÍDA. Total de links: $($visitados.Count)" -ForegroundColor Yellow
}

# --- MENU LOOP PRINCIPAL ---
do {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Magenta
    Write-Host "      SYSTEM SHADOW CRAWLER V4.0          " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Magenta
    Write-Host " [1] Iniciar Nova Sombra (Profundidade 6) "
    Write-Host " [2] Sair do Sistema                      "
    Write-Host "------------------------------------------"
    
    $opcao = Read-Host "Escolha uma opção"

    if ($opcao -eq "1") {
        $alvo = Read-Host "`nInsira o Link Alvo (Pai)"
        if ($alvo -like "http*") {
            Iniciar-Sombra -urlAlvo $alvo
            Read-Host "`nPressione ENTER para voltar ao Menu..."
        } else {
            Write-Host "Erro: Link inválido! Use http:// ou https://" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }

} while ($opcao -ne "2")

Write-Host "Desligando Sombra..." -ForegroundColor Gray
Start-Sleep -Seconds 1