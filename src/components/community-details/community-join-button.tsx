import React from 'react';

export default function CommunityJoinButton() {
  return (
    <div className="flex items-center">
      <button 
        type="button" 
        className="bg-[#E87B5C] text-white px-12 py-3 rounded-full hover:bg-[#d16a4d] transition-all text-lg shadow-[0_8px_25px_rgb(232,123,92,0.4)] hover:shadow-[0_8px_30px_rgb(232,123,92,0.6)] hover:-translate-y-1"
      >
        Join
      </button>
    </div>
  );
} 