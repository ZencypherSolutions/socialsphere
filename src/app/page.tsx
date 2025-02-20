// pages/index.js
import Header from "@/component/Header";
import Head from "next/head";
import LandingPage from "./pages/LandingPage/LandingPage";
import LoginPage from "./pages/LoginPage/LoginPage";

export default function Home() {
  return (
    <>
      <div>
        {/* <LandingPage/> */}
        <LoginPage/>
     </div>
    </>
  );
}
