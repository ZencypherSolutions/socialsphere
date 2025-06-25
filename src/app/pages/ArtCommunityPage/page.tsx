'use client';

import { useState } from 'react';
import CommunityDetailsModal from '@/components/community-details/community-modals';
import { Button } from '@/components/ui/button';
import type { Community } from '@/types/community';

export default function ArtCommunityPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  
  // Example community data - in a real app, this would likely come from an API
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
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold mb-8">Community Details</h1>
      
      <Button onClick={() => setIsModalOpen(true)}>
        View Community Details
      </Button>
      
      <CommunityDetailsModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        community={exampleCommunity}
      />
    </div>
  );
}