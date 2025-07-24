import Header from "@/app/shared/components/Header";
import Head from "next/head";
import Image from "next/image";
import React from "react";
import { FaArrowRight } from "react-icons/fa";

const LandingPage = () => {
  return (
    <>
      <Head>
        <title>SocialSphere</title>
        <meta
          name="description"
          content="Empowering communities through decentralization"
        />
      </Head>

      <main className="bg-[#EEEEEE] min-h-screen font-sans">
        {/* Navbar */}
        <Header />

        {/* Hero Section */}
        <section className="text-center py-16 px-6 bg-[#EEEEEE]">
          <div className="flex justify-center">
            <div className="w-full max-w-[700px]">
              <div className="text-4xl md:text-5xl font-bold text-[#232931] font-space leading-[50px]">
                Empowering
              </div>

              <h1 className="text-4xl md:text-5xl font-bold font-space bg-primary px-[20px] text-white py-[10px] rounded-[30px] justify-self-end leading-[50px] shadow-md">
                Communities
              </h1>
              <div className="text-4xl md:text-5xl font-bold text-[#232931] font-space mr-20 right-8 px-[15px] py-[5px] leading-[50px]">
                Through
              </div>
              <div className="text-4xl md:text-5xl font-bold font-space justify-self-end leading-[50px]">
                Decentralization
              </div>
            </div>
          </div>
          <p className="mt-4 text-sm md:text-base leading-[24px] text-center">
            Are you new here?
          </p>
          <button className="bg-primary w-[213.34px] h-[48px] hover:bg-primary/90 text-white px-4 md:px-6 py-2 md:py-3 mt-6 rounded-[10px] leading-[18px]">
            Get started
          </button>
        </section>

        {/* Features */}
        <section className="flex flex-col md:flex-row gap-6 px-6 py-12 md:px-10 justify-center">
          {[
            {
              text: "Seamless DAO templates with voting and secure fund management for communities.",
              image: "/Frame 11.svg",
              id: 1,
            },
            {
              text: "Empower groups with roles, proposal boards, and financial tools for clear governance.",
              image: "/governance-tools.svg",
              id: 2,
            },
            {
              text: "Simplify decisions and funds with stablecoins, multi-sig wallets, and user-friendly tools.",
              image: "/simplify.png",
              id: 3,
            },
          ].map((feature, index) => (
            <div
              key={index}
              className="bg-muted text-white p-4 md:p-6 rounded-[45px] shadow-xl items-center w-full max-w-[399px] min-h-[180px] md:h-[213px] px-4 md:px-[60px] py-6 md:py-[70px] flex flex-col md:flex-row justify-between gap-4 md:gap-5"
            >
              <p className="flex-1 text-[16px] md:text-[18px] font-space leading-[20px] md:leading-[22.98px] text-center md:text-left">
                {feature.text}
              </p>
              <Image
                src={feature.image}
                alt={`Feature ${index + 1}`}
                width={feature.id === 1 ? 94 : feature.id === 2 ? 70 : 90}
                height={feature.id === 1 ? 63 : feature.id === 2 ? 71 : 73}
                className={`object-contain filter brightness-0 invert flex-shrink-0 ${
                  feature.id === 1
                    ? "w-[60px] h-[40px] md:w-[94.4px] md:h-[63.49px]"
                    : feature.id === 2
                    ? "w-[50px] h-[50px] md:w-[70px] md:h-[71px]"
                    : "w-[60px] h-[48px] md:w-[90.44px] md:h-[72.96px]"
                }`}
              />
            </div>
          ))}
        </section>

        {/* about us  */}
        <section className="py-16 px-6 bg-secondary text-secondary-foreground">
          <h3 className="text-6xl sm:text-8xl md:text-[115px] font-bold mb-6 font-space leading-tight md:leading-[144px] text-center">
            About
          </h3>
          <p className="text-sm md:text-base max-w-[618.87px] text-center font-inter font-[400] text-[26px] leading-[36px] mx-auto">
            Team of product and brand designers that are really passionate about
            blockchain technology and good design. We are not just UI freaks! We
            advocate users for better product experience and common sense.
          </p>
          <p className="flex items-center justify-center leading-[39px] text-[18px] font-inter font-[400]">
            More About us
            <FaArrowRight size={24} color="gray" className="ml-2" />
          </p>
        </section>

        {/* Roadmap */}
        <section className="text-center py-16 px-6 bg-[#EEEEEE]">
          <h3 className="text-[40px] md:text-[40px] font-bold mb-6 font-space leading-[50px]">
            Roadmap
          </h3>
          <p className="mb-8 max-w-[882px] mx-auto font-space font-[400], text-[22px] text-[#232931] text-center leading-[28.07px]">
            Our roadmap outlines a clear path to enhance SocialSphere, focusing
            on user-friendly features, global accessibility, and community
            growth. Together, we&apos;ll revolutionize how communities
            collaborate, govern, and thrive.
          </p>

          <div className="relative max-w-4xl mx-auto">
            {[
              {
                quarter: "Q1",
                quarterImage: "/white_star.png",
                text: "Q1: Launch MVP and onboard users.",
                id: 1,
                image: "/line 5.svg",
              },
              {
                quarter: "Q2",
                quarterImage: "/color_star.png",
                text: "Q2: Add features and enhance accessibility.",
                id: 2,
                image: "/line 6.svg",
              },
              {
                quarter: "Q3",
                quarterImage: "/color_star.png",
                text: "Q3: Grow partnerships and user engagement.",
                id: 3,
                image: "/line 7.svg",
              },
              {
                quarter: "Q4",
                quarterImage: "/color_star.png",
                text: "Q4: Optimize tools and expand capabilities.",
                id: 4,
                image: "/line 8.svg",
              },
              {
                quarter: "Q5",
                quarterImage: "/color_star.png",
                text: "Q5: Scale globally and integrate feedback.",
                id: 5,
                image: "/line 9.svg",
              },
              {
                quarter: "Q6",
                quarterImage: "/white_star.png",
                text: "Q6: Innovate advanced features for communities.",
                id: 6,
              },
            ].map((step, index) => (
              <div
                key={index}
                className={`flex flex-col md:flex-row items-center ${
                  index % 2 === 0 ? "md:justify-start" : "md:justify-end"
                } relative mb-12`}
              >
                {/* Curved SVG Line - Hidden on mobile and tablet */}
                {index < 5 && (
                  <div
                    className={`hidden lg:block absolute w-full h-20 ${
                      index % 2 === 0 ? "right-0" : "left-0"
                    }`}
                    style={{
                      top: "2.5rem",
                      zIndex: -1,
                    }}
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="804"
                      height="38"
                      viewBox="0 0 804 38"
                      fill="none"
                    >
                      <path
                        d="M800.977 37.5C800.992 0.409045 3.36389 37.8406 3.37969 0.74898"
                        stroke="#393E46"
                        strokeWidth="5"
                      />
                    </svg>
                  </div>
                )}

                {/* Step Quarter */}
                <div
                  className={`w-[200px] md:w-[258px] h-[80px] md:h-[120px] rounded-[20px] md:rounded-[30px] flex items-center justify-center text-white text-lg font-bold shadow-xl mb-4 md:mb-0 ${
                    step.id === 1 || step.id === 6
                      ? "bg-primary"
                      : "bg-[#FFFFFF]"
                  }`}
                >
                  <Image
                    src={step.quarterImage}
                    alt={`Quarter ${step.quarter}`}
                    width={step.id === 1 ? 90 : 70}
                    height={step.id === 1 ? 90 : 71}
                    className={`object-contain ${
                      step.id === 1
                        ? "max-w-[60px] max-h-[60px] md:max-w-[90px] md:max-h-[90px]"
                        : "max-w-[50px] max-h-[50px] md:max-w-[70px] md:max-h-[71px]"
                    }`}
                  />
                </div>

                {/* Hidden line image on mobile and tablet */}
                {step.image && (
                  <Image
                    src={step.image}
                    alt={`Feature ${index + 1}`}
                    width={798}
                    height={38}
                    className={`hidden lg:block absolute bottom-[-40px] px-[10%] max-w-[798.44px] ${
                      step.id === 6 ? "hidden" : ""
                    }`}
                  />
                )}

                {/* Step Description */}
                <div
                  className={`p-4 w-full md:w-[480px] text-center md:text-left ${
                    index % 2 === 0
                      ? "md:ml-6"
                      : "md:mr-6 lg:absolute lg:left-[25%]"
                  }`}
                >
                  <p className="text-sm md:text-base font-space text-[#232931] font-[700] leading-relaxed md:leading-[50px]">
                    {step.text}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </section>
      </main>
    </>
  );
};

export default LandingPage;
