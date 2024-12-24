// pages/index.js
import Header from "@/component/Header";
import Head from "next/head";
import LandingPage from "./pages/LandingPage/LandingPage";

export default function Home() {
  return (
    <>
      <div>
        <LandingPage/>
     </div>
    </>
  );
}
