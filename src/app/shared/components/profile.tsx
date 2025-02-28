import React from "react";
import { Avatar, AvatarFallback, AvatarImage } from "@/app/shared/components/avatar";
import { Button } from "@/app/shared/components/button";
import { SidebarFooter } from "@/app/shared/components/sidebar";

const Profile = ({ username }: { username: string }) => {
  return (
    <>
      <SidebarFooter className="mt-auto border-t p-4">
        <Button
          variant="ghost"
          className="w-full justify-start gap-2 bg-primary text-white hover:bg-primary/90 hover:text-white rounded-full"
        >
          <Avatar className="h-6 w-6">
            <AvatarImage src="/placeholder.svg" />
            <AvatarFallback>
              <div className="relative w-full h-full flex items-center justify-center">
                <div className="absolute w-full h-full bg-white rounded-full"></div>
                <div className="absolute w-[80%] h-[80%] bg-muted rounded-full"></div>
                <div className="absolute top-[15%] w-[30%] h-[30%] bg-muted-foreground rounded-full"></div>
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