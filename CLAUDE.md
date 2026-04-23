# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Alfabeto Arabo — Sito di esercizio

Sito web statico per esercitarsi con le 28 lettere dell'alfabeto arabo.

## Obiettivo utente
- **Modalità "Guarda e pronuncia"**: mostra una lettera casuale, l'utente la pronuncia ad alta voce, poi rivela nome + audio per verificare.
- **Modalità "Ascolta e scrivi"**: riproduce il suono di una lettera casuale, l'utente la scrive su carta, poi rivela la lettera per verificare.

## Struttura file

```
.
├── index.html              # Pagina singola, tutto inline (CSS + JS)
├── generate_audio.ps1      # Script per (ri)generare gli MP3
├── audio/                  # 28 file MP3 (alif.mp3, ba.mp3, ..., ya.mp3)
└── CLAUDE.md               # Questo file
```

## Stack tecnico
- HTML + CSS + JavaScript vanilla, nessuna dipendenza, nessun build step.
- Single file (`index.html`) con CSS e JS inline.
- Responsive mobile-first, target touch ≥48px.

## Audio
- **Sorgente MP3**: Google Translate TTS (`translate.google.com/translate_tts`) con `tl=ar` e `client=tw-ob`. API non ufficiale — ok per uso personale, da valutare per uso pubblico/commerciale.
- **Testo passato al TTS**: lettera + fatha (es. `بَ`) per riprodurre il *suono* della lettera, non il nome. Per alif si usa `آ` (aa lunga). Scelta fatta per distinguere il suono ("ba") dal nome della lettera ("bāʾ") che confonde chi impara.
- **Naming file**: id ASCII lowercase (alif, ba, ta, tha, jim, hha, kha, dal, dhal, ra, zay, sin, shin, sad, dad, taa, zaa, ayn, ghayn, fa, qaf, kaf, lam, mim, nun, ha, waw, ya). `hha` = ح enfatica, `taa`/`zaa` = ط/ظ enfatiche, `ha` = ه.
- **Fallback**: se un MP3 manca/non carica, `index.html` usa Web Speech API (`SpeechSynthesisUtterance`, lang `ar-SA`).

## Rigenerare l'audio
```powershell
# Da questa cartella:
Remove-Item .\audio\*.mp3 -Force   # opzionale, se vuoi forzare
powershell -ExecutionPolicy Bypass -File .\generate_audio.ps1
```
Lo script salta i file già esistenti. Pausa 600 ms tra le richieste.

Per cambiare il testo TTS (es. sillaba più lunga, vocale diversa), modifica l'array `$letters` in `generate_audio.ps1` — ogni voce è `@{ id = "..."; cp = @(codepoint1, codepoint2, ...) }`.

## Pubblicazione
Hosting statico: GitHub Pages, Netlify, Cloudflare Pages. Carica solo `index.html` e la cartella `audio/`. Lo script `.ps1` e questo `CLAUDE.md` non servono in produzione.

## Architettura JS (index.html)

Tutto il JS è in un unico `<script>` a fondo pagina. Non ci sono moduli né classi.

**`LETTERS`** — array di 28 oggetti `{ id, ar, name, speak }`:
- `id`: chiave ASCII usata anche come nome file MP3 (`audio/{id}.mp3`)
- `ar`: glifo Unicode da mostrare a schermo
- `name`: traslitterazione scientifica mostrata dopo il reveal
- `speak`: nome arabo della lettera passato al fallback TTS (`SpeechSynthesisUtterance`)

**`state`** — oggetto globale:
- `mode`: `"see"` | `"listen"`
- `current`: lettera attiva (oggetto di `LETTERS`) o `null`
- `recentlyShown`: buffer FIFO di 5 lettere per evitare ripetizioni immediate
- `revealed`: booleano che controlla cosa è visibile nella card

**Flusso di render**: ogni cambio di stato chiama `renderCurrent()` (aggiorna il glifo e il nome) e/o `renderControls()` (ricrea i bottoni, poiché variano per modo e stato). Non c'è framework reattivo — il DOM viene riscritto direttamente.

**Catena audio**: `speak(letter)` prova `audio/{id}.mp3`; se `error` o `.play()` rigetta, ricade su `speakWithTTS(letter)` che usa Web Speech API con `lang = "ar-SA"`.

## Decisioni prese in sessioni precedenti
- Scartato Web Speech API come sorgente primaria: qualità voci arabe inconsistente su Windows.
- Scartato Python (edge-tts, gTTS): utente non ha Python installato.
- Scelto PowerShell + Google Translate TTS: zero installazioni richieste su Windows.
- Scartato "lettera + fatha + alif" (CVV "baa"): troppo simile al nome della lettera ("bāʾ").

## Possibili evoluzioni future
- Sostituire MP3 con registrazioni di madrelingua (Wikimedia Commons, CC).
- Aggiungere vocali brevi (fatha/kasra/damma) e lunghe come modalità separata.
- Tracciare progresso/statistiche per lettera (localStorage).
- Modalità "scrittura a mano" con canvas + riconoscimento.
- PWA per uso offline.
