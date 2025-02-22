import React from "react";
import CommunityBanner from "./community-banner";
import { SocialSphereSidebar } from "./social-sphere-sidebar";
import HighlightedVoteCarousel from "./highlighted-votes-carousel";
import { PostComponent } from "./post-form";
import { SidebarProvider } from "@/components/ui/sidebar"; // Asegúrate de que esta es la ruta correcta

const Dashboard: React.FC = () => {
  return (
    <SidebarProvider>
      <div className="flex h-screen bg-gray-200">
        {/* Sidebar */}
        <div className="w-1/4">
          <SocialSphereSidebar />
        </div>

        {/* Main Content */}
        <div className="flex-1 flex flex-col bg-white rounded-2xl shadow-lg p-6 min-h-screen overflow-y-auto">
          {/* Navbar */}
          <CommunityBanner />

          {/* Highlighted Votes */}
          <div className="p-6">
            <h2 className="text-lg font-semibold">Highlighted votes</h2>
            <HighlightedVoteCarousel />
          </div>

          {/* Post Section con Scroll si hay muchos elementos */}
          <div className="flex-1 overflow-y-auto space-y-6 p-6">
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
            {/* Agrega más PostComponent si es necesario */}
          </div>
        </div>
      </div>
    </SidebarProvider>
  );
};

export default Dashboard;
