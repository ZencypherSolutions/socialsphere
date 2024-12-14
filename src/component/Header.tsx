// components/Header.js
import React from "react";

const Header = () => {
  return (
    <header className="flex flex-wrap justify-between items-center px-6 py-4  shadow-sm">
      <div className="flex items-center space-x-3">
        <img src="/Logo.svg" alt="Logo" className="bg-[#EEEEEE]" />
        <h1 className="text-xl font-bold text-[#000000] hover:text-[#232931]">
          SocialSphere
        </h1>
      </div>
      <nav className="space-x-4  mt-4 md:mt-0 text-[20px] leading-[28px]">
        <a href="#" className="text-[#000000] hover:text-[#232931]">
          About us
        </a>
        <a href="#" className="text-[#000000] hover:text-gray-600">
          Services
        </a>
        <a href="#" className="text-[#000000] hover:text-[#232931]">
          Use Cases
        </a>
        <a href="#" className="text-[#000000]hover:text-[#232931]">
          Forum
        </a>
      </nav>
      <button className="bg-[#E36C59] hover:bg-[#e37e6f] text-white px-4 py-2 rounded-[20px] mt-4 md:mt-0 w-[157px] h-[48px]   gap-0  opacity-1 shadow-md leading-[27px]">
        Launch Dapp
      </button>
    </header>
  );
};

export default Header;
