import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        foreground: "var(--foreground)",
        primary: "#4ECCA3",
        background: "#EEEEEE",
        "text-dark": "#232931",
        "text-medium": "#393E46",
        "text-light": "#E36C59",
        hover: "#2C5154",
      },
    },
  },
  plugins: [],
} satisfies Config;
