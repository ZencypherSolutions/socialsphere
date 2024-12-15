"use client"

import { Button } from "@/components/ui/button"
import { Globe2, Users } from 'lucide-react'

interface CommunityBannerProps {
  name?: string;
  memberCount?: number;
  onMoreInfo?: () => void;
}

export function CommunityBanner({
  name = "Art Community",
  memberCount = 0,
  onMoreInfo = () => {}
}: CommunityBannerProps) {
  return (
    <div className="w-full bg-[#EEEEEE] sticky top-0 z-10 p-4">
      <div className="relative">
        {/* Main banner container with special shape */}
        <div className="bg-[#387479] rounded-[30px] relative pl-[180px] pr-6 py-4 min-h-[90px] flex items-start justify-between w-[98%]">
          {/* Perfect circular icon container */}
          <div className="absolute left-[78px] top-1/2 -translate-y-1/2 h-[90px] w-[90px]">
            <div className="bg-[#232931] w-full h-full rounded-full flex items-center justify-center">
              <Globe2 className="h-6 w-6 text-white" />
            </div>
          </div>

          {/* Content container */}
          <div className="flex flex-1 items-start justify-between mt-8">
            {/* Title and buttons */}
            <div className="flex flex-col">
              <h1 className="text-2xl font-semibold text-white">{name}</h1>
              <Button 
                variant="ghost" 
                size="sm" 
                onClick={onMoreInfo}
                className="text-white hover:text-white hover:bg-[#2C5154]/20 rounded-full px-2 py-1 h-6 text-sm w-fit"
              >
                More info
              </Button>
            </div>

            {/* Member count */}
            <div className="flex items-center gap-1 bg-[#232931] px-4 py-1.5 mt-6 rounded-full">
              <Users className="h-4 w-4 text-white" />
              <span className="text-sm text-white">{memberCount} members</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default CommunityBanner;