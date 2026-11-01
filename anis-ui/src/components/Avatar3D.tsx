import { useRef, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { MeshDistortMaterial, Sparkles, OrbitControls } from '@react-three/drei';
import * as THREE from 'three';

type AvatarState = 'idle' | 'listening' | 'thinking' | 'speaking' | 'error';
interface Avatar3DProps { state: AvatarState; }

function HolographicOrb({ state }: Avatar3DProps) {
  const meshRef = useRef<THREE.Mesh>(null);
  const { distort, speed, color } = useMemo(() => {
    switch (state) {
      case 'listening': return { distort: 0.6, speed: 4, color: '#00f0ff' };
      case 'thinking': return { distort: 0.8, speed: 6, color: '#a855f7' };
      case 'speaking': return { distort: 0.4, speed: 3, color: '#00f0ff' };
      case 'error': return { distort: 0.2, speed: 1, color: '#ef4444' };
      default: return { distort: 0.2, speed: 1.5, color: '#0051ff' };
    }
  }, [state]);

  useFrame((s) => {
    if (meshRef.current) {
      meshRef.current.position.y = Math.sin(s.clock.elapsedTime * 0.5) * 0.1;
      meshRef.current.rotation.y += 0.005;
    }
  });

  return (
    <mesh ref={meshRef} scale={2.2}>
      <sphereGeometry args={[1, 64, 64]} />
      <MeshDistortMaterial color={color} envMapIntensity={1} clearcoat={1} clearcoatRoughness={0.1} metalness={0.8} distort={distort} speed={speed} roughness={0.2} />
      <Sparkles count={150} scale={4} size={2} speed={0.4} opacity={0.6} color={color} />
    </mesh>
  );
}

export default function Avatar3D({ state }: Avatar3DProps) {
  return (
    <div className="absolute inset-0 z-0">
      <Canvas camera={{ position: [0, 0, 6], fov: 45 }}>
        <ambientLight intensity={0.5} />
        <pointLight position={[10, 10, 10]} intensity={1.5} color="#00f0ff" />
        <HolographicOrb state={state} />
        <OrbitControls enableZoom={false} enablePan={false} />
      </Canvas>
      <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_center,transparent_0%,#0a0a0f_90%)]" />
    </div>
  );
}
