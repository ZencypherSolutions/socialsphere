"use client";
import React, { useState } from "react";
import Image from "next/image";
import { motion, AnimatePresence } from "framer-motion";
import { intro1, intro2, intro3 } from "../../public";

const steps = [
	{
		title: "Get started",
		description:
			"Join your favorite communities right away and manage them effortlessly using a clear, intuitive dashboard.",
		image: intro1,
	},
	{
		title: "Create Your DAO",
		description:
			"Create a community of like-minded individuals and manage resources effectively with a fair, transparent voting system.",
		image: intro2,
	},
	{
		title: "Make Friends",
		description:
			"Actively interact with your communities, make new friends, and build influence to bring your vision to life.",
		image: intro3,
	},
];

const variants = {
	enter: (direction: number) => ({
		x: direction > 0 ? 1000 : -1000,
		opacity: 0
	}),
	center: {
		zIndex: 1,
		x: 0,
		opacity: 1
	},
	exit: (direction: number) => ({
		zIndex: 0,
		x: direction < 0 ? 1000 : -1000,
		opacity: 0
	})
};

const swipeConfidenceThreshold = 10000;
const swipePower = (offset: number, velocity: number) => {
	return Math.abs(offset) * velocity;
};

const IntroductionModal = ({ onOpen = false }: { onOpen?: boolean }) => {
	const [step, setStep] = useState(0);
	const [isOpen, setIsOpen] = useState(onOpen);
	const [[page, direction], setPage] = useState([0, 0]);

	const handleNext = () => {
		if (step < steps.length - 1) {
			setStep(step + 1);
			setPage([page + 1, 1]);
		} else {
			setIsOpen(false);
		}
	};

	const handleBack = () => {
		if (step > 0) {
			setStep(step - 1);
			setPage([page - 1, -1]);
		}
	};

	const handleClose = () => {
		setIsOpen(false);
	};

	if (!isOpen) return null;

	return (
		<motion.div
			initial={{ opacity: 0 }}
			animate={{ opacity: 1 }}
			exit={{ opacity: 0 }}
			className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 p-4"
		>
			<motion.div
				initial={{ scale: 0.9, opacity: 0 }}
				animate={{ scale: 1, opacity: 1 }}
				transition={{ type: "spring", duration: 0.5 }}
				className="relative flex flex-col gap-[20px] md:gap-[40px] justify-between p-[20px] md:p-[40px] rounded-xl shadow-lg w-full max-w-[568px] min-h-[500px] md:h-[630px] text-center"
				style={{
					background:
						"linear-gradient(180deg, #999999 0%, #93DEFF 0.01%, #DCF0FA 34.5%, #FFFFFF 66%)",
				}}
			>
				<motion.button
					whileHover={{ scale: 1.1 }}
					whileTap={{ scale: 0.9 }}
					className="absolute flex justify-center items-center w-[30px] h-[30px] md:w-[37px] md:h-[37px] top-[20px] right-[20px] md:top-[36px] md:right-[36px] text-[24px] md:text-[28px] rounded-full bg-white text-[#7D7D7D] font-semibold"
					onClick={handleClose}
				>
					x
				</motion.button>
				<div className="flex items-center justify-center mt-[20px] md:mt-0">
					<div className="relative flex flex-col justify-center items-center w-[200px] md:w-[250px] h-[230px] md:h-[290px]">
						<AnimatePresence initial={false} custom={direction}>
							<motion.div
								key={page}
								custom={direction}
								variants={variants}
								initial="enter"
								animate="center"
								exit="exit"
								transition={{
									x: { type: "spring", stiffness: 300, damping: 30 },
									opacity: { duration: 0.2 }
								}}
								drag="x"
								dragConstraints={{ left: 0, right: 0 }}
								dragElastic={1}
								onDragEnd={(e, { offset, velocity }) => {
									const swipe = swipePower(offset.x, velocity.x);

									if (swipe < -swipeConfidenceThreshold) {
										handleNext();
									} else if (swipe > swipeConfidenceThreshold) {
										handleBack();
									}
								}}
								className="absolute w-full h-full"
							>
								<Image
									src={steps[step].image}
									alt={steps[step].title}
									className="object-contain w-[200px] md:w-[250px] absolute bottom-0"
									priority
								/>
							</motion.div>
						</AnimatePresence>
						<motion.h2
							initial={{ y: 20, opacity: 0 }}
							animate={{ y: 0, opacity: 1 }}
							transition={{ delay: 0.2 }}
							className="text-base md:text-lg font-semibold bg-[#4151FF] text-white p-2 md:p-3 px-4 md:px-8 rounded-[10px] absolute bottom-[-40px] md:bottom-[-50px] whitespace-nowrap"
						>
							{steps[step].title}
						</motion.h2>
					</div>
				</div>

				<motion.div
					initial={{ y: 20, opacity: 0 }}
					animate={{ y: 0, opacity: 1 }}
					transition={{ delay: 0.3 }}
					className="flex flex-col justify-center items-center mt-[24px]"
				>
					<motion.p
						key={step}
						initial={{ opacity: 0 }}
						animate={{ opacity: 1 }}
						transition={{ duration: 0.3 }}
						className="text-gray-600 text-[14px] md:text-[15px] max-w-[300px] md:max-w-[403px] text-center dark:text-gray-300 mb-[20px] md:mb-[30px]"
					>
						{steps[step].description}
					</motion.p>
					<div className="flex justify-center space-x-1">
						{steps.map((_, index) => (
							<motion.span
								key={index}
								initial={false}
								animate={{
									scale: index === step ? 1.2 : 1,
									backgroundColor: index === step ? "#2563eb" : "#d1d5db"
								}}
								transition={{ duration: 0.2 }}
								className={`h-1.5 md:h-2 w-1.5 md:w-2 rounded-full`}
							></motion.span>
						))}
					</div>
				</motion.div>
				<div className="flex gap-[10px] md:gap-[14px] justify-between mt-auto">
					<motion.button
						whileHover={{ scale: 1.02 }}
						whileTap={{ scale: 0.98 }}
						className="w-full px-4 h-[40px] md:h-[50px] bg-white dark:bg-gray-700 rounded-md border border-[#7D7D7D] text-[16px] md:text-[18px]"
						onClick={handleBack}
						disabled={step === 0}
					>
						Back
					</motion.button>
					<motion.button
						whileHover={{ scale: 1.02 }}
						whileTap={{ scale: 0.98 }}
						className="w-full px-4 h-[40px] md:h-[50px] bg-blue-600 text-white rounded-md text-[16px] md:text-[18px]"
						onClick={handleNext}
					>
						{step === steps.length - 1 ? "Finish" : "Continue"}
					</motion.button>
				</div>
			</motion.div>
		</motion.div>
	);
};

export default IntroductionModal;
