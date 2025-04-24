// src/pages/index.tsx
import { useEffect } from 'react'
import Script from 'next/script'
import products from '../../public/data/products.json'   // adjust path if needed

import sliderStyles from '../styles/Slider.module.scss';
import slideStyles  from '../styles/Slide.module.scss';

type Color = {
  name: string
  outerUrl: string
  innerUrl: string
  isNew: boolean
}

type Product = {
  title: string
  price: number
  description: string
  features: string[]
  isNew: boolean
  isSet: boolean
  setImageUrl?: string
  setValue?: number
  colors?: Color[]
}

export const getStaticProps = async () => ({
  props: {
    products: products as Product[]
  }
})

export default function Home({ products }: { products: Product[] }) {
  useEffect(() => {
    if (typeof window !== 'undefined' && (window as any).Elm?.Main) {
      ;(window as any).Elm.Main.init({
        node: document.getElementById('elm-root')!,
        flags: products
      })
    }
  }, [products])

  return (
    <>
      {/* Make sure elm.js was output to public/elm.js by your build script */}
      <Script src="/elm.js" strategy="beforeInteractive" />
     
      <div className={sliderStyles.sliderRoot}>
        {/* 🔥 wrap the slides for badge, swatch, etc. */}
        <div className={slideStyles.slideRoot}>
          <div id="elm-root" style={{ minHeight: '500px' }} />
        </div>
      </div>
    </>
  )
}
