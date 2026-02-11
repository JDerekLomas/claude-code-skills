# Vercel Deployment Skill

## The Problem
After `npx vercel --prod`, the production domain may still point to an old deployment.

## Solution
Always alias after deploying:

```bash
npx vercel --prod
npx vercel alias <new-deployment-url> <your-domain>.vercel.app
```

## How to Find the New Deployment URL
It's printed after `npx vercel --prod` completes, or run:
```bash
npx vercel ls | head -5
```

## Example
```bash
npx vercel --prod
# Output: Production: https://myapp-abc123-team.vercel.app

npx vercel alias myapp-abc123-team.vercel.app myapp.vercel.app
```
