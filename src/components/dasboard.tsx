import React from "react";
import CommunityBanner from "./community-banner";
import { SocialSphereSidebar } from "./social-sphere-sidebar";
import HighlightedVoteCarousel from "./highlighted-votes-carousel";
import { PostComponent } from "./post-form";
import { SidebarProvider } from "@/components/ui/sidebar"; 

const Dashboard: React.FC = () => {
  return (
    <SidebarProvider>
      <div className="flex w-full h-screen bg-gray-200">

        <div className="w-1/5 min-w-[250px] lg:w-1/6">
          <SocialSphereSidebar />
        </div>

        <div className="flex-1 flex flex-col bg-white rounded-2xl shadow-lg p-6 min-h-screen overflow-y-auto w-full">
          <CommunityBanner />

          <div className="p-6 w-full max-w-6xl mx-auto">
            <HighlightedVoteCarousel />
          </div>

          <div className="flex-1 overflow-y-auto space-y-6 p-6 max-w-5xl w-full mx-auto">
            <PostComponent
              data={{
                category: "Art",
                question: "What do you think about this type of art?",
                votes: 123,
              }}
            />
            <PostComponent
              data={{
                category: "Sports",
                question: "What do you think about this sport?",
                votes: 123,
              }}
            />
          </div>
        </div>
      </div>
    </SidebarProvider>
  );
};

export default Dashboard;
