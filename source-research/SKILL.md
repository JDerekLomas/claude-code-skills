---
name: source-research
description: Search and cite primary sources from Source Library. Use when asked what historical authors wrote, to find quotes from old texts, investigate alchemical or philosophical works, or cite translated Latin/German sources.
---

# Source Research

Search the Source Library collection of translated historical texts and retrieve quotes with citations.

## Collection Overview

116 books with translations, including:
- Ficino's Letters (841pp) & Complete Works (701pp)
- Agrippa's Occult Philosophy (626pp)
- Khunrath's Amphitheater of Eternal Wisdom (638pp)
- Reuchlin's Wonder-Working Word (527pp)
- Bruno's Latin Works (426pp)
- Drebbel's Two Treatises (69pp)
- Conring on Hermetic Medicine (433pp)

Many of these authors appear in the [Ficino Network visualization](/ficino_network_v2.html).

## When to Use

- "What did Ficino/Drebbel/Agrippa write about..."
- "Find quotes about quintessence/soul/alchemy"
- "What do historical sources say about..."
- "Cite primary sources for..."
- Questions about Renaissance philosophy, Hermeticism, occult philosophy

## When NOT to Use

- General historical questions (use web search instead)
- Post-1700 texts (collection focuses on Renaissance/Early Modern)
- Authors not in the collection (check /api/books first)
- Modern scholarship or secondary sources

## API Endpoints

### List All Books

```bash
curl -s "https://sourcelibrary-v2.vercel.app/api/books"
```

Returns all books with metadata including `pages_count` (translation coverage).

### Search

```bash
curl -s "https://sourcelibrary-v2.vercel.app/api/search?q=QUERY"
```

Options:
- `q=QUERY` — Search term (required)
- `language=Latin` — Filter by language
- `limit=10` — Results per page (default 10)
- `offset=0` — Pagination offset

Example:
```bash
curl -s "https://sourcelibrary-v2.vercel.app/api/search?q=quintessence&limit=5"
```

### Get Quote with Citation

```bash
curl -s "https://sourcelibrary-v2.vercel.app/api/books/BOOK_ID/quote?page=N"
```

Returns:
- `quote.translation` — English translation
- `quote.original` — Original Latin/German text
- `citation.inline` — e.g., "(Drebbel 1628, p. 57)"
- `citation.footnote` — Full footnote citation
- `citation.chicago` — Chicago style
- `citation.bibtex` — BibTeX format
- `citation.doi_url` — DOI link if available

### Get Book Metadata

```bash
curl -s "https://sourcelibrary-v2.vercel.app/api/books/BOOK_ID"
```

## Workflow

1. **Search** for the topic to find relevant pages
2. **Note** book IDs and page numbers from search results
3. **Get quotes** from specific pages for full text + citation
4. **Present** findings with inline citations

## Example Session

```bash
# 1. Search for quintessence
curl -s "https://sourcelibrary-v2.vercel.app/api/search?q=quintessence&limit=3"

# Response shows: book_id "6836f8ee811c8ab472a49e36", page 45

# 2. Get the full quote with citation
curl -s "https://sourcelibrary-v2.vercel.app/api/books/6836f8ee811c8ab472a49e36/quote?page=45"
```

## Citing in Responses

Use the `citation.inline` format in text:

> "The Quintessence is an eternal, immutable, incombustible thing, like the invincible heaven, perfect in all the elements." (Drebbel 1628, p. 45)

For academic use, provide the full footnote citation from `citation.footnote`.

## Handling Missing Data

- If a page returns 404, the book may not be fully translated yet
- Check `pages_count` in book metadata to see translation coverage
- Some books are in "draft" status and may have incomplete translations
- If DOI is available (`has_doi: true`), the translation is published and citable

## Key Authors in Collection

| Author | Work | Pages |
|--------|------|-------|
| Marsilio Ficino | Letters & Complete Works | 1542 |
| Heinrich Khunrath | Amphitheater of Eternal Wisdom | 638 |
| Cornelius Agrippa | Occult Philosophy | 626 |
| Johannes Reuchlin | Wonder-Working Word | 527 |
| Giordano Bruno | Latin Works | 426 |
| Hermann Conring | On Hermetic Medicine | 433 |
| Cornelius Drebbel | Two Treatises | 69 |
