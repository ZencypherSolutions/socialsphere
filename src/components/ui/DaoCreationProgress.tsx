"use client"

import * as React from "react"

interface DaoCreationProgressProps {
  step: number;
  totalSteps: number;
  title: string;
  description: string;
}

const DaoCreationProgress: React.FC<DaoCreationProgressProps> = ({
  step,
  totalSteps,
  title,
  description,
}) => {

  const progressPercentage = (step / totalSteps) * 100;

  return (
    <div className="bg-secondary text-secondary-foreground rounded-lg shadow-md p-6 max-w-2xl mx-auto">

      <div className="flex justify-between items-start">
      <div className="font-semibold text-white">
        Create your DAO
      </div>
      <div className="font-semibold text-white">
          Step {step} of {totalSteps}
      </div>
      </div>

      <div className="relative w-full bg-white rounded-full py-0.5 px-1">
        <div
          className="bg-primary h-3 rounded-full"
          style={{ width: `${progressPercentage}%` }}
        ></div>
      </div>

      <h2 className="text-2xl font-bold text-white mb-2">{title}</h2>
      <p className="text-white text-sm">{description}</p>
    </div>
  );
};

export default DaoCreationProgress;
