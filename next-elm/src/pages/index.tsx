import { useEffect } from 'react'
import Script from 'next/script'

export default function Home() {
  useEffect(() => {
    // once elm.js has been loaded, window.Elm.Main is available
    if (typeof window !== 'undefined') {
      const Elm = (window as any).Elm
      if (Elm?.Main) {
        Elm.Main.init({ node: document.getElementById('elm-root')! })
      }
    }
    
  }, [])

  return (
    <>
      {/* ensure elm.js is in public/elm.js */}
      <Script src="/elm.js" strategy="beforeInteractive" />
      <div id="elm-root" style={{ minHeight: '200px' }} />
    </>
  )
}
