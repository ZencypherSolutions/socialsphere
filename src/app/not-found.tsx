"use client"

import { useRouter } from "next/navigation"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { ArrowLeft } from "lucide-react"
import { motion } from "framer-motion"

export default function NotFound() {
  const router = useRouter()

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-gray-50 p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="w-full flex flex-items-center max-w-[700px] min-h-[450px] bg-white rounded-[32px] p-10 shadow-lg"
      >
        <div className="flex flex-col md:flex-row items-center justify-center gap-10">
          <div className="md:w-[50%] flex justify-center">
            <motion.div
              initial={{ scale: 1.5 }}
              animate={{ scale: 2 }}
              transition={{
                duration: 0.5,
                ease: "easeOut",
              }}
              className="flex justify-center w-full"
            >
              <motion.div
                animate={{
                  y: [0, -10, 0],
                }}
                transition={{
                  repeat: Infinity,
                  duration: 3,
                  ease: "easeInOut",
                }}
              >
                <Image
                  src="/404.png"
                  alt="404 illustration"
                  width={400}
                  height={400}
                  className="object-cover object-center"
                  priority
                />
              </motion.div>
            </motion.div>
          </div>
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="md:w-1/2 text-left"
          >
            <motion.h1
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.2, delay: 0.3 }}
              className="text-6xl mb-3 cursor-default transition-all duration-300 hover:scale-105 hover:text-[#4461F2]"
            >
              Oops!
            </motion.h1>
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.2, delay: 0.3 }}
              className="text-gray-500 text-lg mb-6 max-w-[250px] cursor-default transition-all duration-300 hover:translate-x-1"
            >
              We couldn't find the page you were looking for
            </motion.p>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.4, delay: 0.9 }}
              className="flex justify-start"
            >
              {/* Fixed Button Component */}
              <motion.div
                whileHover={{
                  scale: 1.05,
                  boxShadow: "0px 5px 15px rgba(68, 97, 242, 0.3)",
                }}
                whileTap={{ scale: 0.95 }}
                transition={{ type: "spring", stiffness: 400, damping: 17 }}
                className="relative overflow-hidden rounded-full"
              >
                <motion.div
                  className="absolute inset-0 bg-white opacity-0"
                  initial={{ x: "-100%" }}
                  whileHover={{
                    x: "100%",
                    opacity: 0.1,
                    transition: { duration: 0.5 },
                  }}
                />

                <Button
                  onClick={() => router.back()}
                  className="bg-[#4461F2] hover:bg-[#3451E2] text-white px-3 py-3 rounded-full inline-flex items-center gap-2"
                >
                  <span className="flex items-center">
                    <ArrowLeft className="w-5 h-5 font-bold transition-transform duration-300 group-hover:-translate-x-1" />
                  </span>
                  <span className="transition-all duration-300 group-hover:tracking-wider">
                    Go back
                  </span>
                </Button>
              </motion.div>
            </motion.div>
          </motion.div>
        </div>
      </motion.div>
    </div>
  );
}
