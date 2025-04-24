// src/pages/index.tsx
import { useEffect } from 'react';
import Script       from 'next/script';
import products     from '../../public/data/products.json';


export default function Home() {
  useEffect(() => {
    (window as any).Elm.Main.init({
      node: document.getElementById('elm-root')!,
      flags: products
    });
  }, []);

  return (
    <>
      <h1>It's dangerous to go alone! Take this:</h1>
      <Script src="/elm.js" strategy="beforeInteractive" />
      <div id="elm-root" style={{ minHeight: '500px' }} />
    </>
  );
}
