import Image from 'next/image';
import logo from './components/ui/logo.png';

export function Navbar() {
  return (
    <nav className="bg-[#EEEEEE] fixed top-0 w-full h-20 flex items-center justify-between shadow-md px-10">
      <div className="flex items-center space-x-4">
        <div className="w-30 h-30 flex items-center justify-center">
          <Image src={logo.src} alt="Logo" width={70} height={70} />
        </div>
      </div>

      <ul className="flex space-x-6 text-[#232931] text-base font-medium">
        <li className="hover:text-#232931 ">About us</li>
        <li className="hover:text-#232931 ">Services</li>
        <li className="hover:text-#232931 ">Use Cases</li>
        <li className="hover:text-#232931 ">Forum</li>
      </ul>

      <div>
        <button
          style={{
            boxShadow: '4px 6px 10px rgba(0, 0, 0, 0.50)',
          }}
          className="bg-[#E36C59] text-white px-6 py-3 rounded-full shadow-md"
        >
          Launch Dapp
        </button>
      </div>
    </nav>
  );
}
