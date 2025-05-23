
import React from "react";

const Header = () => {
  return (
    <header className="flex flex-wrap justify-between items-center px-6 py-4  shadow-sm">
      <div className="flex items-center space-x-3">
        <img src="logo.svg" alt="Logo" className="bg-[#EEEEEE]" />
        <h1 className="text-xl font-bold text-[#000000] hover:text-[#232931]">
          SocialSphere
        </h1>
      </div>
      <nav className="flex gap-6 mt-4 md:mt-0 text-[20px] leading-[28px]">
        <a href="#" className="text-[#000000] hover:text-[#232931]">
          About us
        </a>
        <a href="#" className="text-[#000000] hover:text-gray-600">
          Services
        </a>
        <a href="#" className="text-[#000000] hover:text-[#232931]">
          Use Cases
        </a>
        <a href="#" className="text-[#000000] hover:text-[#232931]">
          Forum
        </a>
      </nav>

      <button className="bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-[30px] mt-4 md:mt-0 w-[157px] h-[48px] gap-0 opacity-1 shadow-lg leading-[27px]">
        Launch Dapp
      </button>
    </header>
  );
};

export default Header;
