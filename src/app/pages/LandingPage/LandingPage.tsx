import Header from '@/component/Header';
import Head from "next/head";
import React from 'react'
import { BiArrowBack } from 'react-icons/bi';
import { FaArrowRight } from 'react-icons/fa';

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
            <div className=" w-[700px] ">
              <div className="text-4xl md:text-5xl font-bold text-[#232931] font-space leading-[50px]">
                Empowering
              </div>

              <h1 className="text-4xl md:text-5xl font-bold font-space bg-[#387478] px-[20px]  text-white py-[10px] rounded-[30px] justify-self-end leading-[50px] shadow-md">
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
          <button className="bg-[#E36C59] w-[213.34px] h-[48px]  hover:bg-[#e37e6f] text-white px-4 md:px-6 py-2 md:py-3 mt-6 rounded-[10px] leading-[18px]">
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
              className="bg-[#387478] text-white p-6 rounded-[45px] shadow-xl items-center w-full max-w-[399px] h-[213px] px-[60px] py-[70px] flex justify-between gap-5"
            >
              <p className="flex-1 text-[18px] md:text-base font-space leading-[22.98px]">
                {feature.text}
              </p>
              <img
                src={feature.image}
                alt={`Feature ${index + 1}`}
                className={`object-contain ${
                  feature.id === 1
                    ? "w-[94.4px] h-[63.49px]"
                    : feature.id === 2
                    ? "w-[70px] h-[71px]"
                    : "w-[90.44px] h-[72.96px]"
                }`}
              />
            </div>
          ))}
        </section>

        {/* about us  */}
        <section className="text-center py-16 px-6 bg-[#EEEEEE]">
          <h3 className="text-[115px] md:text-3xl font-bold mb-6 font-space leading-[144px]">
            About
          </h3>
          <p className=" text-sm md:text-base max-w-[618.87px] mx-auto text-left font-inter font-[400] text-[26px] leading-[36px]">
            Team of product and brand designers that are really passionate about
            blockchain technology and good design. We are not just UI freaks! We
            advocate users for better product experience and common sense.
          </p>
          <p className="flex items-center leading-[39px] text-[18px] text-[#232931] font-inter font-[400] ml-[27%]">
            More About us
            <FaArrowRight size={24} color="gray" className="ml-2" />
          </p>
        </section>

        {/* Roadmap */}
        <section className="text-center py-16 px-6 bg-[#EEEEEE]">
          <h3 className="text-[40px] md:text-[40px] font-bold mb-6 font-space leading-[50px]">
            Roadmap
          </h3>
          <p className="mb-8  max-w-[882px] mx-auto font-space font-[400], text-[22px] text-[#232931] text-center leading-[28.07px]">
            Our roadmap outlines a clear path to enhance SocialSphere, focusing
            on user-friendly features, global accessibility, and community
            growth. Together, we'll revolutionize how communities collaborate,
            govern, and thrive.
          </p>

          <div className="relative max-w-4xl mx-auto">
            {[
              {
                quarter: "Q1",
                quarterImage: "/q1.svg",
                text: "Q1: Launch MVP and onboard users.",
                id: 1,
                image: "/line 5.svg",
              },
              {
                quarter: "Q2",
                quarterImage: "/star 1.svg",

                text: "Q2: Add features and enhance accessibility.",
                id: 2,
                image: "/line 6.svg",
              },
              {
                quarter: "Q3",
                quarterImage: "/star 1.svg",

                text: "Q3: Grow partnerships and user engagement.",
                id: 3,
                image: "/line 7.svg",
              },
              {
                quarter: "Q4",
                quarterImage: "/star 1.svg",

                text: "Q4: Optimize tools and expand capabilities.",
                id: 4,
                image: "/line 8.svg",
              },
              {
                quarter: "Q5",
                quarterImage: "/star 1.svg",

                text: "Q5: Scale globally and integrate feedback.",
                id: 5,
                image: "/line 9.svg",
              },
              {
                quarter: "Q6",
                quarterImage: "/stars 2.svg",

                text: "Q6: Innovate advanced features for communities.",
                id: 6,
              },
            ].map((step, index) => (
              <div
                key={index}
                className={`flex items-center ${
                  index % 2 === 0 ? "justify-start" : "justify-end"
                } relative mb-12`}
              >
                {/* Curved SVG Line */}
                {index < 5 && (
                  <div
                    className={`absolute w-full h-20 ${
                      index % 2 === 0 ? "right-0" : "left-0"
                    } border border-red-500`}
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
                  className={`w-[258px] h-[120px] rounded-[30px] flex items-center justify-center text-white text-lg font-bold shadow-xl ${
                    step.id === 1 || step.id === 6
                      ? "bg-[#387478]"
                      : "bg-[#FFFFFF]"
                  }`}
                >
                  <img
                    src={step.quarterImage}
                    alt={`Quarter ${step.quarter}`}
                    className={`object-contain ${
                      step.id === 1
                        ? "max-w-[90px] max-h-[90px]"
                        : "max-w-[70px] max-h-[71px]"
                    }`}
                  />
                </div>
                <img
                  src={step.image}
                  alt={`Feature ${index + 1}`}
                  className={`absolute bottom-[-40px] px-[10%] max-w-[798.44px] ${
                    step.id === 6 ? "hidden" : ""
                  }`}
                />

                {/* Step Description */}
                <div
                  className={`p-4 w-[480px] md:w-[480px]   ${
                    index % 2 === 0
                      ? "ml-6 text-left"
                      : "mr-6 text-left  absolute left-[25%] "
                  }`}
                >
                  <p className="  text-sm md:text-base font-space text-[#232931] font-[700] text-22 leading-[50px]  ">
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
}

export default LandingPage