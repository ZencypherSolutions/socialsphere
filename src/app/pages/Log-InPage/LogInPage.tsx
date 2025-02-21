import Image from 'next/image';

export default function LogInPage() {

    return (
        <div className="flex items-center h-screen justify-center bg-[#EEEEEE] font-inter">
            <div className="flex flex-col gap-8 w-[578px] h-[374px] bg-[#FFFFFF] p-10 rounded-[40px] shadow-xl text-center">
                <div className="flex flex-col items-center justify-center gap-6">
                    <h2 className="text-[40px] font-semibold text-[#323643] leading-[48.41px] [text-shadow:2px_2px_4px_rgba(0,0,0,0.3)]">Sign In</h2>
                    <p className="font-medium text-base text-[#323643] mx-10 leading-[19.36px]">
                        Please enter a username for your account and connect your wallet
                    </p>
                    <input
                        type="text"
                        placeholder="Enter new username"
                        className="w-[403px] h-[50px] border-[1px] border-[#7D7D7D] rounded-[20px] text-center text-[20px] leading-[24.2px]"
                    />
                    <button className="w-[403px] h-[50px] flex items-center justify-center gap-3 bg-[#4151FF] text-[#F7F7F7] font-semibold rounded-[20px]">
                        <Image
                            src="/walletIcon.svg"
                            alt="Wallet Icon"
                            width={36}
                            height={27}
                        />
                        <Image
                            src="/walletBroch.svg"
                            alt="Wallet Broch"
                            width={8.14}
                            height={4.1}
                            className="mt-1.5 mx-[-24px]"
                        />
                        <p className="font-medium text-[20px] leading-[24.2px] mx-5">Connect Wallet</p>
                    </button>
                </div>
            </div>
        </div>
    );
}