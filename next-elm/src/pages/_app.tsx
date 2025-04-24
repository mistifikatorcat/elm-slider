// src/pages/_app.tsx
import '../styles/globals.css';
import sliderStyles from '../styles/Slider.module.scss';
import slideStyles  from '../styles/Slide.module.scss';
import type { AppProps } from "next/app";

export default function App({ Component, pageProps }: AppProps) {
  return (
    // slider wrapper
    <div className={sliderStyles.root}>
      {/* slide-wrapper (so slide styles also apply anywhere inside this) */}
      <div className={slideStyles.wrapper}>
        <Component {...pageProps} />
      </div>
    </div>
  );
}