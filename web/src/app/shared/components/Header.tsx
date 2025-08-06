"use client";
import React, { useState } from "react";
import { HiMenu, HiX } from "react-icons/hi";

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  return (
    <header className="relative bg-[#EEEEEE]">
      <div className="max-w-7xl mx-auto flex justify-between items-center px-4 sm:px-6 py-4">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 sm:w-10 sm:h-10 bg-black rounded-full flex items-center justify-center">
            <div className="text-white text-xs sm:text-sm font-bold">SS</div>
          </div>
          <h1 className="text-lg sm:text-xl font-bold text-[#000000]">
            SocialSphere
          </h1>
        </div>

        {/* Desktop Navigation - Centered */}
        <nav className="hidden md:flex gap-8 text-[16px] text-gray-600 absolute left-1/2 transform -translate-x-1/2">
          <a href="#" className="hover:text-[#232931]">
            About us
          </a>
          <a href="#" className="hover:text-[#232931]">
            Services
          </a>
          <a href="#" className="hover:text-[#232931]">
            Use Cases
          </a>
          <a href="#" className="hover:text-[#232931]">
            Forum
          </a>
        </nav>

        {/* Desktop Launch Button */}
        <button className="hidden md:block bg-[#4F46E5] hover:bg-[#4338CA] text-white px-6 py-2 rounded-full text-sm font-medium">
          Launch Dapp
        </button>

        {/* Mobile Hamburger Menu */}
        <button
          onClick={toggleMenu}
          className="md:hidden p-2 text-gray-600 hover:text-[#232931] focus:outline-none"
          aria-label="Toggle menu"
        >
          {isMenuOpen ? <HiX size={24} /> : <HiMenu size={24} />}
        </button>
      </div>

      {/* Mobile Menu */}
      {isMenuOpen && (
        <div className="md:hidden absolute top-full left-0 right-0 bg-[#EEEEEE] border-t border-gray-200 shadow-lg z-50">
          <nav className="flex flex-col px-4 py-4 space-y-4">
            <a href="#" className="text-gray-600 hover:text-[#232931] py-2">
              About us
            </a>
            <a href="#" className="text-gray-600 hover:text-[#232931] py-2">
              Services
            </a>
            <a href="#" className="text-gray-600 hover:text-[#232931] py-2">
              Use Cases
            </a>
            <a href="#" className="text-gray-600 hover:text-[#232931] py-2">
              Forum
            </a>
            <button className="bg-[#4F46E5] hover:bg-[#4338CA] text-white px-6 py-2 rounded-full text-sm font-medium mt-4 self-start">
              Launch Dapp
            </button>
          </nav>
        </div>
      )}
    </header>
  );
};

export default Header;
