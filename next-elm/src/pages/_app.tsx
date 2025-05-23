import '../styles/globals.css';
import '../styles/slider.css';      // your slider module (with .slider-container styles)
import '../styles/slide.css'; 
import type { AppProps } from "next/app";

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}