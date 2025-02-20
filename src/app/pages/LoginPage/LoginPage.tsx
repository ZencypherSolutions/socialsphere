import React from "react";

const LoginPage = () => {
    return (
        
        <div className="flex items-center justify-center w-full h-[100vh] bg-[#EEEEEE] font-inter">
            <div className="flex flex-col gap-8 w-[350px] md:w-[480px] bg-[#FFFFFF] p-10 rounded-[40px] shadow-xl text-center">
                <div className="flex flex-col items-center justify-center gap-2">
                    <div className="text-[40px] font-semibold text-[#323643] [text-shadow:2px_2px_4px_rgba(0,0,0,0.2)]">Sign In</div>
                    <div className="w-[90%] font-medium text-sm text-[#323643]">
                        Please enter a username for your account and connect your wallet
                    </div>
                </div>

                <div className="flex flex-col items-center justify-center gap-4">
                    <input type="text" placeholder="Enter new username"
                        className="w-[90%] px-4 py-2 border-[1px] border-[#7D7D7D] rounded-[20px] text-[#7D7D7D] text-center focus:outline-none"/>

                    <button className="w-[90%] flex items-center justify-center gap-2 px-4 py-2 bg-[#4151FF] text-white font-semibold rounded-[20px]">
                        <img src="/connect-wallet.png" className="w-5 h-5"/>
                        Connect Wallet
                    </button>
                </div>
            </div>
        </div>
    );
};

export default LoginPage;
