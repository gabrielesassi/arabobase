# Genera 28 file MP3 per le lettere arabe tramite Google Translate TTS.
# Usa solo componenti Windows integrati (Invoke-WebRequest).
# Esecuzione: powershell -ExecutionPolicy Bypass -File .\generate_audio.ps1

$ErrorActionPreference = "Stop"

$outDir = Join-Path $PSScriptRoot "audio"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

# Suono della lettera (non il nome): lettera + fatha per CV breve ("ba").
# Codepoint: 0x064E = fatha, 0x0627 = alif, 0x0622 = alif con madda ("aa")
$letters = @(
    @{ id = "alif";  cp = @(0x0622) },                   # aa
    @{ id = "ba";    cp = @(0x0628, 0x064E) },           # ba
    @{ id = "ta";    cp = @(0x062A, 0x064E) },           # ta
    @{ id = "tha";   cp = @(0x062B, 0x064E) },           # tha
    @{ id = "jim";   cp = @(0x062C, 0x064E) },           # ja
    @{ id = "hha";   cp = @(0x062D, 0x064E) },           # Ha (enfatica)
    @{ id = "kha";   cp = @(0x062E, 0x064E) },           # kha
    @{ id = "dal";   cp = @(0x062F, 0x064E) },           # da
    @{ id = "dhal";  cp = @(0x0630, 0x064E) },           # dha
    @{ id = "ra";    cp = @(0x0631, 0x064E) },           # ra
    @{ id = "zay";   cp = @(0x0632, 0x064E) },           # za
    @{ id = "sin";   cp = @(0x0633, 0x064E) },           # sa
    @{ id = "shin";  cp = @(0x0634, 0x064E) },           # sha
    @{ id = "sad";   cp = @(0x0635, 0x064E) },           # Sa (enfatica)
    @{ id = "dad";   cp = @(0x0636, 0x064E) },           # Da (enfatica)
    @{ id = "taa";   cp = @(0x0637, 0x064E) },           # Ta (enfatica)
    @{ id = "zaa";   cp = @(0x0638, 0x064E) },           # Za (enfatica)
    @{ id = "ayn";   cp = @(0x0639, 0x064E) },           # 'a
    @{ id = "ghayn"; cp = @(0x063A, 0x064E) },           # gha
    @{ id = "fa";    cp = @(0x0641, 0x064E) },           # fa
    @{ id = "qaf";   cp = @(0x0642, 0x064E) },           # qa
    @{ id = "kaf";   cp = @(0x0643, 0x064E) },           # ka
    @{ id = "lam";   cp = @(0x0644, 0x064E) },           # la
    @{ id = "mim";   cp = @(0x0645, 0x064E) },           # ma
    @{ id = "nun";   cp = @(0x0646, 0x064E) },           # na
    @{ id = "ha";    cp = @(0x0647, 0x064E) },           # ha (soft)
    @{ id = "waw";   cp = @(0x0648, 0x064E) },           # wa
    @{ id = "ya";    cp = @(0x064A, 0x064E) }            # ya
)

$total = $letters.Count
$done  = 0
$ok    = 0
$fail  = 0

foreach ($letter in $letters) {
    $done++
    $text = [string]::new([char[]]$letter.cp)
    $out  = Join-Path $outDir "$($letter.id).mp3"

    if (Test-Path $out) {
        Write-Host ("[{0,2}/{1}] {2,-6}  gia esistente, salto" -f $done, $total, $letter.id)
        $ok++
        continue
    }

    $encoded = [uri]::EscapeDataString($text)
    $url = "https://translate.google.com/translate_tts?ie=UTF-8&q=$encoded&tl=ar&client=tw-ob"

    try {
        Invoke-WebRequest `
            -Uri $url `
            -OutFile $out `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36" `
            -ErrorAction Stop | Out-Null

        Write-Host ("[{0,2}/{1}] {2,-6}  OK  ({3})" -f $done, $total, $letter.id, $text)
        $ok++
        Start-Sleep -Milliseconds 600
    } catch {
        Write-Warning ("[{0,2}/{1}] {2,-6}  errore: {3}" -f $done, $total, $letter.id, $_.Exception.Message)
        $fail++
    }
}

Write-Host ""
Write-Host ("Completato. OK: {0}  Falliti: {1}  Cartella: {2}" -f $ok, $fail, $outDir)
