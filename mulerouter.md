# MuleRouter Skill

Generate AI images and videos using MuleRouter's unified API gateway.

## Description

Use this skill for AI image generation, video creation, and image editing via MuleRouter.

## IMPORTANT: Always Download Generated Assets

MuleRouter stores generated images/videos in **ephemeral storage** that will expire. After every successful generation:

1. **Always download the result immediately** using curl or wget
2. Save to the project's `public/images/` or `public/assets/` directory
3. Use a descriptive filename based on the prompt

### Download Workflow

After receiving a successful response with an image URL:

```bash
# Create directory if needed
mkdir -p ./public/images/generated

# Download with descriptive name
curl -o "./public/images/generated/[descriptive-name].png" "[image-url]"
```

### Example Complete Workflow

```bash
# 1. Generate image
RESPONSE=$(curl -s -X POST "https://api.mulerouter.ai/v1/images/generations" \
  -H "Authorization: Bearer $MULEROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "wan-txt2img", "prompt": "mountain sunset"}')

# 2. Extract URL from response
IMAGE_URL=$(echo $RESPONSE | jq -r '.data[0].url')

# 3. Download immediately
curl -o "./public/images/generated/mountain-sunset.png" "$IMAGE_URL"
```

**Never leave images only on MuleRouter's servers - they are temporary!**

## Available Models

**Image Generation (Wan Series)**
- Text-to-Image
- Image-to-Image transformation
- Inpainting (Nano Banana Pro)

**Video Generation**
- Text-to-Video (Wan 2.1-2.5)
- Image-to-Video animation

**Language Models (Qwen Series)**
- Qwen3 Max, Plus, Flash

## API Access

```bash
export MULEROUTER_API_KEY="your-api-key"
```

### Text-to-Image
```bash
curl -X POST "https://api.mulerouter.ai/v1/images/generations" \
  -H "Authorization: Bearer $MULEROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "wan-txt2img",
    "prompt": "A serene mountain lake at sunset, dramatic clouds, photorealistic",
    "negative_prompt": "blurry, low quality, distorted",
    "width": 1024,
    "height": 1024
  }'
```

## Prompt Structure

```
[Subject], [Setting/Context], [Style], [Lighting], [Quality Modifiers]
```

### Examples

**Landscape:**
`Mountain peak above clouds, golden hour light, dramatic shadows, 8k photorealistic`

**Product:**
`Minimalist watch on marble surface, soft studio lighting, commercial photography`

**Portrait:**
`Woman in red dress, urban rooftop, cinematic lighting, shallow depth of field`

**Abstract:**
`Flowing liquid metal shapes, iridescent colors, 3D render, octane, highly detailed`

## Quality Modifiers

- `8k`, `highly detailed`, `sharp focus`
- `photorealistic`, `cinematic`, `editorial`
- `studio lighting`, `golden hour`, `dramatic`

## Negative Prompts

```
blurry, low quality, distorted, watermark, text, oversaturated, artifacts
```

## Resources

- Playground: https://mulerouter.ai/playground
- Docs: https://docs.mulerouter.ai
