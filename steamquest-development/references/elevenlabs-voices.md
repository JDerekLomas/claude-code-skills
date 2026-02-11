# ElevenLabs Voice Reference

## Recommended Voices by Character Type

### Young Female Characters
- **Jessica** `cgSgspJ2msm6clMCkdW9` - Playful, bright, warm (American)
- **Sarah** `EXAVITQu4vr4xnSDxMaL` - Mature, reassuring, confident (American)

### Professional Female Characters
- **Matilda** `XrExE9yKIg1WjnnlVkGX` - Knowledgeable, professional (American)
- **Alice** `Xb7hH8MSUJpSbSDYk0k2` - Clear, engaging educator (British)

### Young Male Characters
- **Liam** `TX3LPaxmHKxFdv7VOQHJ` - Energetic, confident (American)
- **Will** `bIHbv24MWmeRgasZH58o` - Relaxed optimist (American)

### Professional Male Characters
- **Brian** `nPczCjzI2devNBz1zQrb` - Deep, resonant, comforting (American)
- **Eric** `cjVigY5qzO86Huf0OWal` - Smooth, trustworthy (American)
- **Roger** `CwhRBWXzGAHq8TQ4Fs17` - Laid-back, casual, resonant (American)

### Narrator/Authority
- **George** `JBFqnCBsd6RMkjVDRZzb` - Warm, captivating storyteller (British)
- **Bill** `pqHfZKP75CvOlQylNhV4` - Wise, mature, balanced (American)

## API Configuration

### Model Selection
- **eleven_turbo_v2_5** - Fast, good quality (recommended)
- **eleven_multilingual_v2** - Multiple languages
- **eleven_monolingual_v1** - English only, legacy

### Voice Settings

```json
{
  "stability": 0.5,        // 0-1, higher = more consistent
  "similarity_boost": 0.75, // 0-1, higher = closer to original
  "style": 0.3,            // 0-1, higher = more expressive
  "use_speaker_boost": true // Enhanced clarity
}
```

### Character Type Presets

**Curious Student:**
```json
{ "stability": 0.4, "similarity_boost": 0.75, "style": 0.4 }
```

**Knowledgeable Mentor:**
```json
{ "stability": 0.6, "similarity_boost": 0.8, "style": 0.25 }
```

**Energetic Narrator:**
```json
{ "stability": 0.35, "similarity_boost": 0.7, "style": 0.5 }
```

## Text Formatting for Natural Speech

### Adding Pauses

| Method | Effect | Example |
|--------|--------|---------|
| `...` | Natural pause, slight hesitation | "Wait... that makes sense!" |
| `—` → `...` | Convert em-dash to ellipsis | "years—time" → "years... time" |
| `.` | Full stop, breath | "Okay. Let me try." |
| `,` | Brief pause | "First, measure the trunk." |

### Emphasis

| Method | Effect |
|--------|--------|
| ALL CAPS | Strong emphasis |
| *italics* | Slight emphasis (strip in TTS) |

### Things to Strip

Remove before TTS:
- HTML tags (`<strong>`, `<em>`, `<div>`)
- Image embeds
- Math symbols (convert: π → "pi", ² → " squared")
- Special characters

### strip_html Function

```python
def strip_html(text):
    # Remove div blocks (images)
    text = re.sub(r"<div[^>]*>.*?</div>", "", text, flags=re.DOTALL)
    # Remove HTML tags
    text = re.sub(r'<[^>]+>', '', text)
    # Convert em-dashes to pauses
    text = text.replace('\u2014', '...').replace('\u2013', '...')
    # Convert math symbols
    text = text.replace('\u03c0', 'pi')
    text = text.replace('\u00b2', ' squared')
    text = text.replace('\u00b3', ' cubed')
    text = text.replace('\u2153', 'one third')
    return text.strip()
```

## Sound Effects Generation

ElevenLabs sound-generation API:

```bash
curl -X POST "https://api.elevenlabs.io/v1/sound-generation" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "gentle forest ambiance with birds chirping",
    "duration_seconds": 30
  }' --output bgmusic.mp3
```

## Listing Voices

```bash
curl -s "https://api.elevenlabs.io/v1/voices" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" | \
  python3 -c "
import json,sys
data=json.load(sys.stdin)
for v in data['voices']:
    labels = v.get('labels', {})
    print(f\"{v['voice_id']}: {v['name']} - {labels.get('gender', '?')}, {labels.get('age', '?')}, {labels.get('accent', '?')}\")
"
```
