import React from "react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { SidebarFooter } from "@/components/ui/sidebar";
import { Gem, GemIcon } from "lucide-react";

const Profile = ({ username }: { username: string }) => {
  return (
    <>
      <SidebarFooter className="mt-auto border-t p-4">
        <Button
          variant="ghost"
          className="w-full justify-start gap-2 bg-[#2c5154] text-white hover:bg-[#3d4f59] hover:text-white rounded-full"
        >
          <Avatar className="h-6 w-6">
            <AvatarImage src="/placeholder.svg" />
            <AvatarFallback>
              <div className="relative w-full h-full flex items-center justify-center">
                <div className="absolute w-full h-full bg-white rounded-full"></div>
                <div className="absolute w-[80%] h-[80%] bg-[#E36C59] rounded-full"></div>
                <div className="absolute top-[15%] w-[30%] h-[30%] bg-[#232931] rounded-full"></div>
              </div>
            </AvatarFallback>
          </Avatar>
          <span>{username}</span>
        </Button>
      </SidebarFooter>
    </>
  );
};

export default Profile;