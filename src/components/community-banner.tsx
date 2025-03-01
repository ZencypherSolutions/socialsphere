"use client"

import { useRouter } from "next/navigation"

interface CommunityBannerProps {
  name?: string
  memberCount?: string
  onMoreInfo?: () => void
}

export default function CommunityBanner({
  name = "Art Community",
  memberCount = "xx members",
  onMoreInfo,
}: CommunityBannerProps) {
  const router = useRouter()

  const handleClick = () => {
    if (onMoreInfo) {
      onMoreInfo()
    } else {
      router.push("/community-details")
    }
  }

  return (
    <div className="relative w-full">
      <div className="bg-[#2C5154] rounded-[40px] h-[160px] relative flex items-center w-[1200px]">
        <div className="absolute -bottom-16 left-16">
          <div className="w-[180px] h-[180px] bg-[#393E46] rounded-full flex items-center justify-center">
            <div className="w-[60px] h-[60px] bg-[#D9D9D9] rounded-full absolute top-11 right-11" />
          </div>
        </div>

        <div className="ml-72 flex items-center w-full pr-32">
          <div className="flex flex-col gap-2">
            <h1 className="text-5xl font-normal text-white">{name}</h1>
            <span 
              className="text-white/80 text-xl cursor-pointer w-fit
                        transition-all duration-300
                        hover:text-white hover:drop-shadow-[0_0_8px_rgba(255,255,255,0.5)]" 
              onClick={handleClick}
              onKeyDown={(e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                  handleClick();
                }
              }}
              tabIndex={0}
              // biome-ignore lint/a11y/useSemanticElements: <explanation>
              role="button"
            >
              More info
            </span>
          </div>
        </div>

        <span className="absolute bottom-6 right-8 text-white text-xl">{memberCount}</span>
      </div>
    </div>
  )
}