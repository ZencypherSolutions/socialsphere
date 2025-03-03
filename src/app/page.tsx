// pages/index.js
"use client"
import Header from "@/component/Header";
import Head from "next/head";
import LandingPage from "./pages/LandingPage/LandingPage";
import LogInPage from "./pages/Log-InPage/LogInPage";
import IntroductionModal from "@/components/introduction-modal";
import { useState } from "react";

export default function Home() {
  const [isOpen, setIsOpen] = useState(true)
	return (
		<>
			<div>
				<IntroductionModal onOpen={isOpen} />
			</div>
		</>
	);
}
