"use client"

import { useRouter } from "next/navigation"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { ArrowLeft } from "lucide-react"

export default function NotFound() {
  const router = useRouter()

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-gray-50 p-4">
      <div className="w-full flex flex-items-center max-w-[700px] min-h-[450px] bg-white rounded-[32px] p-10 shadow-lg">
        <div className="flex flex-col md:flex-row items-center justify-center gap-10">
          <div className="md:w-1/2">
            <div className="relative w-[280px] h-[280px] mx-auto">
              <Image src="/404.png" alt="404 illustration" fill className="object-contain" priority />
            </div>
          </div>

          <div className="md:w-1/2 text-left">
            <h1 className="text-6xl  mb-3">Oops!</h1>
            <p className="text-gray-500 text-lg mb-6 max-w-[250px]">We couldn't find the page you were looking for</p>
            
            <div className="flex justify-start">
              <Button
                onClick={() => router.back()}
                className="bg-[#4461F2] hover:bg-[#3451E2] text-white px-3 py-3 rounded-full inline-flex items-center gap-2"
              >
                <ArrowLeft className="w-5 h-5 font-bold" />
                Go back
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

