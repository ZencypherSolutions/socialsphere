"use client";

import { useState, useEffect } from "react";
import HighlightedVote from "./highlighted-vote";

const HighlightedVotesCarousel = () => {
  const votesData = [
    { question: "What type of art is this?", category: "Painting", votes: 12, comments: 4 },
    { question: "What type of art is this?", category: "Painting", votes: 12, comments: 4 },
    { question: "What type of art is this?", category: "Painting", votes: 12, comments: 4 },
    { question: "What type of art is this?", category: "Painting", votes: 12, comments: 4 },
    
  ];

  const [currentIndex, setCurrentIndex] = useState(0);
  const [slidesToShow, setSlidesToShow] = useState(3);

  useEffect(() => {
    const updateSlidesToShow = () => {
      setSlidesToShow(window.innerWidth >= 768 ? 3 : 1);
    };

    updateSlidesToShow();
    window.addEventListener("resize", updateSlidesToShow);

    return () => window.removeEventListener("resize", updateSlidesToShow);
  }, []);

  const handleNext = () => {
    setCurrentIndex((prevIndex) =>
      prevIndex + 1 < votesData.length - slidesToShow + 1 ? prevIndex + 1 : 0
    );
  };

  const handlePrev = () => {
    setCurrentIndex((prevIndex) =>
      prevIndex - 1 >= 0 ? prevIndex - 1 : votesData.length - slidesToShow
    );
  };

  return (
    <div className="relative w-full mx-auto overflow-hidden">
      <h1 className="text-2xl font-bold text-center mb-6">Highlighted Votes</h1>

      <div
        className="flex transition-transform duration-500"
        style={{
          transform: `translateX(-${currentIndex * (100 / slidesToShow)}%)`,
          width: `${(votesData.length * 100) / slidesToShow}%`,
        }}
      >
        {votesData.map((vote, index) => (
          <div
            key={index}
            className="inline-flex gap-1"
            style={{
              width: `${100 / slidesToShow}%`,
              margin: "0 0.5rem",
            }}
          >
            <HighlightedVote
              question={vote.question}
              category={vote.category}
              votes={vote.votes}
              comments={vote.comments}
            />
          </div>
        ))}
      </div>

      {currentIndex > 0 && ( 
        <button
          onClick={handlePrev}
          className="absolute top-1/2 left-4 transform -translate-y-1/2 bg-white text-black p-2 rounded-full shadow-md z-10"
        >
          {"<"}
        </button>
      )}
      <button
        onClick={handleNext}
        className="absolute top-1/2 right-4 transform -translate-y-1/2 bg-white text-black p-2 rounded-full shadow-md z-10"
      >
        {">"}
      </button>
    </div>
  );
};

export default HighlightedVotesCarousel;
