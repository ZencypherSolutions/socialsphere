import React from 'react';
import type { CommunityDetailsProps } from '@/types/community';

export default function CommunityVotes({ community }: CommunityDetailsProps) {
  return (
    <div className="bg-[#387478] rounded-lg p-6 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-shadow">
      <h3 className="text-2xl font-semibold text-white mb-4">
        Some highlighted votes
      </h3>
      <div className="space-y-4">
        {[1, 2].map((_, index) => (
          <div
            // biome-ignore lint/suspicious/noArrayIndexKey: <explanation>
            key={index}
            className="bg-[#323643] rounded-lg p-4 shadow-[0_4px_20px_rgb(0,0,0,0.15)] hover:shadow-[0_4px_20px_rgb(0,0,0,0.25)] hover:-translate-y-0.5 transition-all"
          >
            <h4 className="text-white text-lg mb-2">
              What type of art is this?
            </h4>
            <div className="flex items-center gap-2 mb-2">
              <span className="bg-[#4F46E5] text-white px-4 py-1 rounded-full text-sm shadow-[0_2px_10px_rgb(79,70,229,0.3)] hover:shadow-[0_2px_15px_rgb(79,70,229,0.4)] hover:-translate-y-0.5 transition-all">
                Painting
              </span>
            </div>
            <div className="flex gap-4 text-gray-400 text-sm">
              <span>xx votes</span>
              <span>xx comments</span>
            </div>
          </div>
        ))}
      </div>

      <button 
        type="button" 
        className="mt-6 w-full bg-[#2C5154] text-white py-2 rounded-full hover:bg-[#151f1e] transition-all shadow-[0_4px_15px_rgb(0,0,0,0.2)] hover:shadow-[0_4px_20px_rgb(0,0,0,0.3)] hover:-translate-y-0.5"
      >
        Join our Discord
      </button>
    </div>
  );
}