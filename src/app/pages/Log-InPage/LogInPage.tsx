"use client";

import { useState, useEffect } from "react";
import { Wallet, AlertCircle } from "lucide-react";
import { connect, disconnect } from "starknetkit";

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
	const [walletName, setWalletName] = useState("");

	// Check for existing session on component mount
	useEffect(() => {
		const checkExistingSession = async () => {
			try {
				// Check localStorage for remembered session
				const savedSession = localStorage.getItem("starknetSession");
				if (savedSession) {
					const session = JSON.parse(savedSession);
					setUsername(session.username || "");
					setRememberMe(true);

					// Try to reconnect to wallet
					const reconnect = await connect({
						modalMode: "neverAsk",
						webWalletUrl: "https://web.argent.xyz", // Optional: default Argent web wallet URL
						dappName: "Social Sphere",
					});

					if (reconnect && reconnect.wallet && reconnect.connectorData?.account) {
						// Check if the reconnected address matches the saved one
						if (reconnect.connectorData?.account === session.walletAddress) {
							setWalletAddress(reconnect.connectorData?.account);
							setWalletName(reconnect.wallet.name || "Starknet Wallet");
							setIsWalletConnected(true);
						}
					}
				} else {
					// Check sessionStorage for current session
					const tempSession = sessionStorage.getItem("starknetSession");
					if (tempSession) {
						const session = JSON.parse(tempSession);
						setUsername(session.username || "");

						// Try to reconnect to wallet
						const reconnect = await connect({
							modalMode: "neverAsk",
							webWalletUrl: "https://web.argent.xyz", // Optional
							dappName: "Your App Name",
						});

						if (reconnect && reconnect.wallet && reconnect.connectorData?.account) {
							// Check if the reconnected address matches the saved one
							if (reconnect.connectorData.account === session.walletAddress) {
								setWalletAddress(reconnect.connectorData.account);
								setWalletName(reconnect.wallet.name || "Starknet Wallet");
								setIsWalletConnected(true);
							}
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
			// Connect to wallet using StarknetKit
			const connection = await connect({
				modalMode: "alwaysAsk", // Options: "neverAsk" | "alwaysAsk" | "onlyIfNotConnected"
				webWalletUrl: "https://web.argent.xyz", // Optional: default Argent web wallet URL
				dappName: "Social Sphere",
			});

			if (!connection || !connection.wallet || !connection.connectorData?.account) {
				setError("No wallet connection established");
				return;
			}
			console.log(connection);

			// Get the wallet address and name
			const walletAddress = connection.connectorData?.account;
			const walletName = connection.wallet.name || "Starknet Wallet";

			setWalletAddress(walletAddress);
			setWalletName(walletName);
			setIsWalletConnected(true);

			// Save the username for display purposes
			setDisplayUsername(username);

			// Save session data
			saveSession(username, walletAddress);
		} catch (err) {
			console.error("Error connecting wallet:", err);
			setError(err.message || "Failed to connect wallet");
		} finally {
			setIsConnecting(false);
		}
	};

	// Disconnect wallet
	const handleDisconnect = async () => {
		try {
			await disconnect({ clearLastWallet: true });

			setWalletAddress("");
			setWalletName("");
			setIsWalletConnected(false);
			localStorage.removeItem("starknetSession");
			sessionStorage.removeItem("starknetSession");
		} catch (err) {
			console.error("Error disconnecting wallet:", err);
		}
	};

	// Save session based on rememberMe preference
	const saveSession = (username: string, walletAddress: string) => {
		const sessionData = { username, walletAddress };

		if (rememberMe) {
			localStorage.setItem("starknetSession", JSON.stringify(sessionData));
		}
		sessionStorage.setItem("starknetSession", JSON.stringify(sessionData));
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

					{/* Connect/Disconnect button */}
					{!isWalletConnected ? (
						<button
							onClick={handleWalletConnect}
							disabled={isConnecting}
							className={`w-full max-w-[403px] h-[50px] flex items-center justify-center gap-5 sm:gap-3 bg-[#4151FF] text-white font-semibold rounded-[20px] shadow-md hover:bg-[#3240CC] transition ${isConnecting ? "opacity-70 cursor-not-allowed" : ""}`}>
							<Wallet
								color="white"
								size={32}
							/>
							<p className="font-medium text-[18px] sm:text-[20px] leading-[24.2px]">{isConnecting ? "Connecting..." : "Connect Wallet"}</p>
						</button>
					) : (
						<button
							onClick={handleDisconnect}
							className="w-full max-w-[403px] h-[50px] flex items-center justify-center gap-5 sm:gap-3 bg-red-500 text-white font-semibold rounded-[20px] shadow-md hover:bg-red-600 transition">
							<Wallet
								color="white"
								size={32}
							/>
							<p className="font-medium text-[18px] sm:text-[20px] leading-[24.2px]">Disconnect Wallet</p>
						</button>
					)}

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
