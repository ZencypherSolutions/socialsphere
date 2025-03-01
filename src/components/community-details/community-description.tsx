import React from 'react';
import type { CommunityDetailsProps } from '@/types/community';

export default function CommunityDescription({ community }: CommunityDetailsProps) {
  return (
    <div className="bg-[#387478] rounded-lg p-6 flex flex-col h-full shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-shadow">
      <div>
        <h3 className="text-2xl font-semibold text-white mb-4 text-center">
          Description
        </h3>
        <p className="text-white text-center text-lg">
          Enter a description of the community/DAO here
        </p>
      </div>

      <div className="mt-auto space-y-6">
        <div className="flex justify-between items-center">
          <span className="text-white text-base">Visibility</span>
          <span className="text-white text-base">Public</span>
        </div>
        <div className="flex justify-between items-center">
          <span className="text-white text-base">Date</span>
          <span className="text-white text-base">Created on Dec 12, 2024</span>
        </div>
        <div className="flex justify-between items-center">
          <span className="text-white text-base">Members joined</span>
          <span className="text-white text-base">xx members</span>
        </div>
      </div>
    </div>
  );
}