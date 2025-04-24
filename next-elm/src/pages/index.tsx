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
      <Script src="/elm.js" strategy="beforeInteractive" />
      <div id="elm-root" style={{ minHeight: '500px' }} />
    </>
  );
}
