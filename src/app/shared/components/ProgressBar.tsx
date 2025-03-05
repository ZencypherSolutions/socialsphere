"use client";

import * as React from "react";

interface ProgressBarProps {
  step: number;
  totalSteps: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({ step, totalSteps }) => {
  const progressPercentage = (step / totalSteps) * 100;

  return (
    <div className="bg-secondary text-secondary-foreground rounded-lg shadow-md p-6 max-w-2xl mx-auto">
      <div className="flex justify-between items-start mb-4">
        <div className="font-semibold text-[#f7f7f7]">
          Create your DAO
        </div>
        <div className="font-semibold text-[#f7f7f7]">
          Step {step} of {totalSteps}
        </div>
      </div>

      <div className="relative w-full bg-[#f7f7f7] rounded-full py-0.5 px-1 mb-4">
        <div
          className="bg-primary h-3 rounded-full"
          style={{ width: `${progressPercentage}%` }}
        ></div>
      </div>

      <h2 className="text-2xl font-bold text-[#f7f7f7] mb-2">Define membership</h2>
      <p className="text-[#f7f7f7] text-sm">Decide the type of voting your DAO uses. You can change these settings with a vote.</p>
    </div>
  );
};

export default ProgressBar;
