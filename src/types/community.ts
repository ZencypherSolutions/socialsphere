export interface Community {
  name: string;
  description: string;
  visibility: 'Public' | 'Private';
  createdAt: string;
  membersCount: number;
  highlightedVotes: Array<{
    question: string;
    type: string;
    votes: number;
    comments: number;
  }>;
}

export interface CommunityDetailsProps {
  community: Community;
}

export interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
} 