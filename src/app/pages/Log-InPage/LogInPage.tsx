"use client";

import { useState, useEffect } from "react";
import { Wallet, AlertCircle } from "lucide-react";
import { isConnected, requestAccess, getAddress } from "@stellar/freighter-api";

export default function LogInPage() {
	// User input states
	const [username, setUsername] = useState("");
	const [displayUsername, setDisplayUsername] = useState("");

	const [rememberMe, setRememberMe] = useState(false);

	// Wallet states
	const [walletAddress, setWalletAddress] = useState("");
	const [isConnecting, setIsConnecting] = useState(false);
	const [error, setError] = useState("");
	const [isWalletConnected, setIsWalletConnected] = useState(false);

	// Check for existing session on component mount
	useEffect(() => {
		const checkExistingSession = async () => {
			try {
				// First check if Freighter is connected
				const freighterConnected = await isConnected();
				if (!freighterConnected.isConnected) {
					return;
				}

				// Check localStorage for remembered session
				const savedSession = localStorage.getItem("stellarSession");
				if (savedSession) {
					const session = JSON.parse(savedSession);
					setUsername(session.username || "");
					setRememberMe(true);

					// Verify wallet address matches saved address
					const addressResult = await getAddress();
					if (addressResult.address && addressResult.address === session.walletAddress) {
						setWalletAddress(addressResult.address);
						setIsWalletConnected(true);
					}
				} else {
					// Check sessionStorage for current session
					const tempSession = sessionStorage.getItem("stellarSession");
					if (tempSession) {
						const session = JSON.parse(tempSession);
						setUsername(session.username || "");

						// Verify wallet address
						const addressResult = await getAddress();
						if (addressResult.address && addressResult.address === session.walletAddress) {
							setWalletAddress(addressResult.address);
							setIsWalletConnected(true);
						}
					}
				}
			} catch (err) {
				console.error("Error checking existing session:", err);
			}
		};

		checkExistingSession();
	}, []);

	// Handle wallet connection
	const handleWalletConnect = async () => {
		if (!username.trim()) {
			setError("Please enter a username before connecting your wallet");
			return;
		}

		setIsConnecting(true);
		setError("");

		try {
			// Check if Freighter is installed
			const isAppConnected = await isConnected();
			if (!isAppConnected.isConnected) {
				setError("Freighter wallet is not installed or unavailable");
				return;
			}

			// Request access to get the public key
			const accessObj = await requestAccess();
			if (accessObj.error) {
				setError(accessObj.error);
				return;
			}

			// Successfully connected
			const publicKey = accessObj.address;
			setWalletAddress(publicKey);
			setIsWalletConnected(true);

			// Save the username for display purposes
			setDisplayUsername(username);

			// Clear the input field
			setUsername("");

			// Save session data
			saveSession(username, publicKey);
		} catch (err) {
			console.error("Error connecting wallet:", err);
			setError(err.message || "Failed to connect wallet");
		} finally {
			setIsConnecting(false);
		}
	};

	// Save session based on rememberMe preference
	const saveSession = (username: string, walletAddress: string) => {
		const sessionData = { username, walletAddress };

		if (rememberMe) {
			localStorage.setItem("stellarSession", JSON.stringify(sessionData));
			sessionStorage.setItem("stellarSession", JSON.stringify(sessionData));
		}
	};

	return (
		<div className="flex items-center justify-center min-h-screen bg-[#EEEEEE] font-inter p-4">
			<div className="flex flex-col gap-6 w-full sm:w-[568px] bg-white p-6 sm:p-10 rounded-[30px] shadow-xl text-center">
				<div className="flex flex-col items-center justify-center gap-4 sm:gap-6">
					<h2 className="text-3xl sm:text-[40px] font-semibold text-[#323643] leading-tight [text-shadow:2px_2px_4px_rgba(0,0,0,0.3)]">Sign In</h2>

					<p className="font-medium text-sm sm:text-base text-[#323643] px-4 sm:px-10 leading-relaxed">Please enter a username for your account and connect your wallet</p>

					{/* Error message */}
					{error && (
						<div className="w-full max-w-[403px] p-3 bg-red-50 border border-red-200 text-red-700 rounded-[15px] text-sm flex items-start gap-2">
							<AlertCircle
								size={16}
								className="mt-0.5 flex-shrink-0"
							/>
							<span>{error}</span>
						</div>
					)}

					{/* Username input */}
					<input
						type="text"
						placeholder="Enter new username"
						value={username}
						onChange={(e) => setUsername(e.target.value)}
						className="w-full max-w-[403px] h-[50px] border border-[#7D7D7D] rounded-[20px] text-center text-lg sm:text-[20px] leading-[24.2px] px-4"
						disabled={isWalletConnected}
					/>

					{isWalletConnected && <div>{username}</div>}
					<button
						onClick={handleWalletConnect}
						disabled={isConnecting}
						className={`w-full max-w-[403px] h-[50px] flex items-center justify-center gap-5 sm:gap-3 bg-[#4151FF] text-white font-semibold rounded-[20px] shadow-md hover:bg-[#3240CC] transition ${isConnecting ? "opacity-70 cursor-not-allowed" : ""}`}>
						<Wallet
							color="white"
							size={32}
						/>

						<p className="font-medium text-[18px] sm:text-[20px] leading-[24.2px]">{isWalletConnected ? "Connected" : isConnecting ? "Connecting..." : "Connect Wallet"}</p>
					</button>

					{/* Remember me checkbox */}
					<div className="flex items-center w-full max-w-[403px] px-2">
						<input
							id="remember-me"
							type="checkbox"
							checked={rememberMe}
							onChange={(e) => setRememberMe(e.target.checked)}
							className="h-4 w-4 text-[#4151FF] border-gray-300 rounded"
						/>
						<label
							htmlFor="remember-me"
							className="ml-2 block text-sm text-[#323643]">
							Remember me
						</label>
					</div>
				</div>
			</div>
		</div>
	);
}
