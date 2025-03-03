import { XMarkIcon } from '@heroicons/react/24/outline';
import { Dialog } from '@headlessui/react';
import CommunityAvatar from '@/components/community-details/community-avatar';
import type { ModalProps } from '@/types/community';

interface CommunityHeaderProps extends ModalProps {
  communityName: string;
}

export default function CommunityHeader({
  communityName,
  onClose,
}: CommunityHeaderProps) {
  return (
    <div className="flex justify-between items-start mb-6">
      <div className="flex items-center gap-4">
        <CommunityAvatar />
        <Dialog.Title className="text-2xl font-semibold text-white">
          {communityName}
        </Dialog.Title>
      </div>
      <div className="flex items-start gap-12">
        <span className="text-white text-sm mt-6">
          Edit community / DAO description
        </span>
        <button
          type="button"
          className="text-white hover:text-gray-200 -mt-2 -mr-1"
          onClick={onClose}
        >
          <span className="text-2xl">X</span>
        </button>
      </div>
    </div>
  );
}