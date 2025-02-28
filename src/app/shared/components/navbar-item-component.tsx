    import React from 'react';

    interface NavbarItemProps {
    text: string;
    route: () => void;
    }

    const NavbarItem: React.FC<NavbarItemProps> = ({ text, route }) => {
    const handleClick = () => {
        if (route) {
        route();
        }
    };

    return (
        <button
        onClick={handleClick}
        className="bg-[#E36C59] text-white font-bold text-lg rounded-full px-6 py-2 shadow-lg hover:bg-[#D9564D] transition-all"
        >
        {text}
        </button>
    );
    };

    export default NavbarItem;
