---
name: daily-sourcelibrary
description: Batch OCR and translation for Source Library using Gemini Batch API (50% cheaper). Process books from the roadmap queue.
---

# Source Library Batch Processing

Process historical Latin texts using Gemini Batch API for 50% cost savings.

## Current Status (2025-12-27)

**6 books complete:**
- Euclid (Elements) - 278 pages
- Plato (Complete Works) - 718 pages
- Ptolemy (Cosmographia) - 276 pages
- Boethius (Consolation of Philosophy) - 294 pages
- Plotinus (Enneads) - 544 pages
- Copernicus (De revolutionibus) - 422 pages

Results at: `~/translate/data/pipeline/results/`

## Quick Commands

```bash
cd ~/translate && source .venv/bin/activate && set -a && source .env && set +a
```

### Check batch job status on Gemini
```bash
python3 -c "
from pathlib import Path
import json
from google import genai
import os
client = genai.Client(api_key=os.environ['GEMINI_API_KEY'])

for f in sorted(Path('data/pipeline/batch_jobs').glob('batch_*.json'))[-10:]:
    if '_keys' in f.name: continue
    data = json.loads(f.read_text())
    gname = data.get('gemini_job_name')
    if gname:
        r = client.batches.get(name=gname)
        status = str(r.state).replace('JobState.JOB_STATE_', '')
        print(f\"{data['book_id'][:25]:<25} {data['job_type']:<8} {status}\")
"
```

### Check local results
```bash
python3 -c "
from pathlib import Path
for d in sorted(Path('data/pipeline/results').iterdir()):
    if d.is_dir():
        ocr = len(list(d.glob('ocr_*.md')))
        trans = len(list(d.glob('trans_*.md')))
        print(f'{d.name}: {ocr} OCR, {trans} Trans')
"
```

### Process next book from roadmap
```bash
python -m src.pipeline.daily_run
```

### Process specific book
```bash
python -m src.pipeline.daily_run --book <ia_identifier>
```

### Collect results from completed batch
```bash
python3 -c "
from google import genai
from pathlib import Path
import json, os
client = genai.Client(api_key=os.environ['GEMINI_API_KEY'])

job_id = 'batch_YYYYMMDD_HHMMSS'  # Replace with actual job ID
job_file = Path(f'data/pipeline/batch_jobs/{job_id}.json')
data = json.loads(job_file.read_text())
result = client.batches.get(name=data['gemini_job_name'])

keys_file = Path(f'data/pipeline/batch_jobs/{job_id}_keys.json')
keys = json.loads(keys_file.read_text())
results_dir = Path(f'data/pipeline/results/{data[\"book_id\"]}')
results_dir.mkdir(parents=True, exist_ok=True)

for i, resp in enumerate(result.dest.inlined_responses):
    if i < len(keys) and resp.response and resp.response.candidates:
        text = resp.response.candidates[0].content.parts[0].text
        (results_dir / f'{keys[i]}.md').write_text(text)
        print(f'Collected {keys[i]}')
"
```

## Roadmap Queue

Next books to process (from `data/roadmap.json`):
1. Ptolemy - Almagest (need non-encrypted source)
2. Apollonius - Conics
3. Ficino - Platonic Theology
4. Pico - Oration on Dignity of Man
5. Corpus Hermeticum
6. Kepler - Mysterium Cosmographicum
7. Galileo - Sidereus Nuncius

## Pipeline Architecture

```
Internet Archive  -->  PDF Download  -->  PNG Extraction
                                              |
                                              v
                       Split Detection (pages 10, 20, 25)
                                              |
                          Single pages?  -----+
                              |               |
                              v               v
                      OCR Batch Submit    Flag for manual split
                              |
                              v
                     Translation Batch
                              |
                              v
                      Collect Results
                              |
                              v
                    ~/translate/data/pipeline/results/
```

## Cost Savings

Gemini Batch API: **50% cheaper** than real-time
- No rate limits
- 1-24 hour turnaround
- Results retained ~30 days

## Troubleshooting

### Proxy errors
```bash
unset ALL_PROXY HTTP_PROXY HTTPS_PROXY
```

### Missing API key
```bash
set -a && source .env && set +a
```

### Large book (>1GB payload)
Split into multiple batches of ~180 pages each.
