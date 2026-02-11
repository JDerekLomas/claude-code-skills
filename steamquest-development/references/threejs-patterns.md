# Three.js Interactive Patterns

## Basic Setup Template

```tsx
import React, { useState, useEffect, useCallback, useRef } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

interface Props {
  interaction: { type: string; ariaLabel?: string };
}

const MyInteractive: React.FC<Props> = ({ interaction }) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const sceneRef = useRef<THREE.Scene | null>(null);
  const rendererRef = useRef<THREE.WebGLRenderer | null>(null);
  const cameraRef = useRef<THREE.PerspectiveCamera | null>(null);
  const controlsRef = useRef<OrbitControls | null>(null);

  // Initialize Three.js scene
  const initThree = useCallback(() => {
    if (!containerRef.current) return;

    // Scene
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x87ceeb);
    sceneRef.current = scene;

    // Camera
    const width = containerRef.current.clientWidth;
    const height = containerRef.current.clientHeight;
    const camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 500);
    camera.position.set(0, 15, 40);
    cameraRef.current = camera;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.shadowMap.enabled = true;
    containerRef.current.appendChild(renderer.domElement);
    rendererRef.current = renderer;

    // Lighting
    const ambient = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambient);

    const directional = new THREE.DirectionalLight(0xffffff, 1);
    directional.position.set(30, 60, 40);
    directional.castShadow = true;
    scene.add(directional);

    // Controls
    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.target.set(0, 10, 0);
    controlsRef.current = controls;
  }, []);

  // Cleanup
  useEffect(() => {
    initThree();
    return () => {
      if (rendererRef.current && containerRef.current) {
        const dom = rendererRef.current.domElement;
        if (containerRef.current.contains(dom)) {
          containerRef.current.removeChild(dom);
        }
        rendererRef.current.dispose();
      }
    };
  }, [initThree]);

  // Animation loop
  useEffect(() => {
    let animationId: number;
    const animate = () => {
      animationId = requestAnimationFrame(animate);
      controlsRef.current?.update();
      if (sceneRef.current && cameraRef.current && rendererRef.current) {
        rendererRef.current.render(sceneRef.current, cameraRef.current);
      }
    };
    animate();
    return () => cancelAnimationFrame(animationId);
  }, []);

  // Handle resize
  useEffect(() => {
    const handleResize = () => {
      if (!containerRef.current || !cameraRef.current || !rendererRef.current) return;
      const w = containerRef.current.clientWidth;
      const h = containerRef.current.clientHeight;
      cameraRef.current.aspect = w / h;
      cameraRef.current.updateProjectionMatrix();
      rendererRef.current.setSize(w, h);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return (
    <div className="w-full h-full flex flex-col">
      <div
        ref={containerRef}
        className="flex-1 rounded-t-lg overflow-hidden"
        style={{ minHeight: '280px' }}
        aria-label={interaction.ariaLabel}
        role="img"
      />
      <div className="bg-white/95 rounded-b-lg p-3 shadow-lg">
        {/* Controls go here */}
      </div>
    </div>
  );
};

export default MyInteractive;
```

## Common Geometries

### Cylinder (Tree Trunk)
```typescript
const geometry = new THREE.CylinderGeometry(
  radiusTop,    // top radius
  radiusBottom, // bottom radius
  height,       // height
  16            // radial segments
);
```

### Cone (Conifer Tree)
```typescript
const geometry = new THREE.ConeGeometry(
  radius,  // base radius
  height,  // height
  16       // radial segments
);
```

### Sphere (Foliage)
```typescript
const geometry = new THREE.SphereGeometry(
  radius,  // radius
  32,      // width segments
  16       // height segments
);
```

### Ground Plane
```typescript
const geometry = new THREE.CircleGeometry(100, 64);
const material = new THREE.MeshStandardMaterial({
  color: 0x4a7c31,
  roughness: 0.9,
  side: THREE.DoubleSide,
});
const ground = new THREE.Mesh(geometry, material);
ground.rotation.x = -Math.PI / 2;
ground.receiveShadow = true;
```

## Materials

### Standard Material (Most Common)
```typescript
const material = new THREE.MeshStandardMaterial({
  color: 0x8B4513,    // brown
  roughness: 0.8,     // 0-1, higher = less shiny
  metalness: 0.1,     // 0-1, higher = more metallic
});
```

### Common Colors
```typescript
// Nature
const bark = 0x5d4037;      // brown bark
const leaves = 0x2e7d32;    // green foliage
const grass = 0x4a7c31;     // ground green
const sky = 0x87ceeb;       // sky blue

// UI Accents
const emerald = 0x10b981;   // emerald green
const amber = 0xf59e0b;     // amber yellow
```

## Lighting Setup

### Standard Outdoor Scene
```typescript
// Ambient (base lighting)
const ambient = new THREE.AmbientLight(0xffffff, 0.5);
scene.add(ambient);

// Main directional (sun)
const sun = new THREE.DirectionalLight(0xffffff, 1.2);
sun.position.set(30, 60, 40);
sun.castShadow = true;
sun.shadow.mapSize.width = 2048;
sun.shadow.mapSize.height = 2048;
sun.shadow.camera.near = 0.5;
sun.shadow.camera.far = 150;
sun.shadow.camera.left = -50;
sun.shadow.camera.right = 50;
sun.shadow.camera.top = 50;
sun.shadow.camera.bottom = -50;
scene.add(sun);

// Fill light (soften shadows)
const fill = new THREE.DirectionalLight(0xffeedd, 0.3);
fill.position.set(-20, 30, -30);
scene.add(fill);
```

## Camera & Controls

### Orbit Controls Setup
```typescript
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.05;
controls.target.set(0, 12, 0);        // Look at point
controls.maxPolarAngle = Math.PI / 2 - 0.05;  // Don't go below ground
controls.minDistance = 15;
controls.maxDistance = 100;
```

### Camera Positioning
```typescript
// Position relative to object
camera.position.set(0, height * 0.4, height * 1.5);
controls.target.set(0, height * 0.4, 0);
```

## Updating Objects

### Clear and Rebuild
```typescript
const updateGeometry = useCallback(() => {
  if (!groupRef.current) return;

  // Clear existing
  while (groupRef.current.children.length > 0) {
    const child = groupRef.current.children[0];
    if (child instanceof THREE.Mesh) {
      child.geometry?.dispose();
      if (child.material instanceof THREE.Material) {
        child.material.dispose();
      }
    }
    groupRef.current.remove(child);
  }

  // Rebuild...
}, [dependencies]);
```

### Trigger Update on State Change
```typescript
useEffect(() => {
  updateGeometry();
}, [updateGeometry]);  // updateGeometry has dependencies in useCallback
```

## Layout Pattern

Fit interactive without scrolling:

```tsx
return (
  <div className="w-full h-full flex flex-col">
    {/* 3D view - takes remaining space */}
    <div
      ref={containerRef}
      className="flex-1 rounded-t-lg overflow-hidden"
      style={{ minHeight: '280px' }}
    />

    {/* Controls - fixed height at bottom */}
    <div className="bg-white/95 rounded-b-lg p-3 shadow-lg">
      <div className="grid grid-cols-2 gap-x-4 gap-y-2">
        {/* Slider controls */}
        <div>
          <label className="flex justify-between text-xs font-medium text-gray-700">
            <span>Parameter</span>
            <span className="font-mono text-emerald-700">{value} unit</span>
          </label>
          <input
            type="range"
            min="0"
            max="100"
            value={value}
            onChange={(e) => setValue(parseInt(e.target.value))}
            className="w-full h-1.5 bg-gray-200 rounded-lg cursor-pointer"
          />
        </div>
      </div>
    </div>
  </div>
);
```

## Performance Tips

1. **Limit pixel ratio**: `Math.min(window.devicePixelRatio, 2)`
2. **Dispose geometries/materials** when removing objects
3. **Use instancing** for many identical objects
4. **Limit shadow map size** based on needs
5. **Use simpler geometries** (fewer segments) when possible
