// pages/index.js
import Header from "@/app/shared/components/Header";
import Head from "next/head";
import LandingPage from "./landing/pages/LandingPage/LandingPage";
import LogInPage from "./auth/pages/Log-InPage/LogInPage";
import { PostComponent } from "@/app/shared/components/post-form";
import DashboardLayout from "./communityDashboard/components/Layout/DashboardLayout";

export default function Home() {
  return (
    <>
      <div>
          <LandingPage />
      </div>
    </>
  );
}
