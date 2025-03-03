import { Dialog, Transition } from '@headlessui/react'
import { Fragment } from 'react'
import type { Community } from '@/types/community'
import CommunityHeader from './community-header'
import CommunityDescription from './community-description'
import CommunityVotes from './community-votes'
import CommunityJoinButton from './community-join-button'

interface CommunityDetailsModalProps {
  isOpen: boolean
  onClose: () => void
  community: Community
}

export default function CommunityDetailsModal({
  isOpen,
  onClose,
  community,
}: CommunityDetailsModalProps) {
  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black/25" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel className="w-full max-w-4xl transform overflow-hidden rounded-2xl bg-[#2C5154] p-6 shadow-xl transition-all">
                <CommunityHeader communityName={community.name} onClose={onClose} isOpen={false} />

                <div className="grid grid-cols-[1fr_auto_1fr] gap-6">
                  <CommunityDescription community={community} />
                  <CommunityJoinButton />
                  <CommunityVotes community={community} />
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
}