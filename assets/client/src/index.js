import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { ChakraProvider, ColorModeScript, extendTheme } from '@chakra-ui/react'
import "@fontsource/cantata-one"
import "@fontsource/damion"
import "@fontsource/raleway"
import "@fontsource/fira-code"
import "@fontsource/assistant"

const colors = {
  brand: {
    900: '#1a365d',
    800: '#153e75',
    700: '#2a69ac',
  }
}

// Font to consider: Gilroy, look @fontsource.org
const fonts = {
  heading: `Assistant, serif`,
  body: `Assistant, sans-serif`
}

const theme = extendTheme({ colors, fonts })

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <ChakraProvider theme={theme}>
      <App />
    </ChakraProvider>
  </React.StrictMode>
);