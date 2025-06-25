import Dashboard from "@/app/shared/components/dasboard";
import { Community } from "@/app/core/models/community";
import { useState } from 'react';
import CommunityBanner from "../shared/components/community-banner";
import CommunityDetailsModal from "../shared/components/community-details/community-modals";
import { SidebarProvider } from "../shared/components/sidebar";
import { SocialSphereSidebar } from "../shared/components/social-sphere-sidebar";

export default function ArtCommunityPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  
  const exampleCommunity: Community = {
    name: 'Art Community',
    description: 'This is an example community for demonstration purposes.',
    visibility: 'Public',
    createdAt: 'February 27, 2025',
    membersCount: 1250,
    highlightedVotes: [
      {
        question: 'Should we organize a virtual meetup?',
        type: 'Poll',
        votes: 45,
        comments: 12
      },
      {
        question: 'Proposal to add new community features',
        type: 'Proposal',   
        votes: 89,
        comments: 24
      }
    ]
  };

  return (
    <div className="h-screen bg-[#F5F5F5]">
      <SidebarProvider>
        <div className="flex h-full">
          <SocialSphereSidebar />
          <div className="flex-1 p-2 bg-[#F5F5F5]">
            <div className="w-full h-full">
              <CommunityBanner 
                name="Art Community"
                memberCount={`${exampleCommunity.membersCount} members`}
                onMoreInfo={() => setIsModalOpen(true)}
              />
            </div>
          </div>
          
          <CommunityDetailsModal
            isOpen={isModalOpen}
            onClose={() => setIsModalOpen(false)}
            community={exampleCommunity}
          />
        </div>
      </SidebarProvider>
    </div>
  );
}