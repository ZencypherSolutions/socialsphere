// pages/index.js
import Header from "@/component/Header";
import Head from "next/head";
import LandingPage from "./pages/LandingPage/LandingPage";
import LogInPage from "./pages/Log-InPage/LoginPage";
import { PostComponent } from "@/components/post-form";

const votesData = [
  {
    question: "What type of art is this?",
    category: "Painting",
    votes: 12,
  },
  {
    question: "What type of art is this?",
    category: "Painting",
    votes: 12,
  },
  {
    question: "What type of art is this?",
    category: "Painting",
    votes: 12,
  },
  {
    question: "What type of art is this?",
    category: "Painting",
    votes: 12,
  },
];

export default function Home() {
  return (
    <>
      <div>
        {votesData.map((vote, index) => (
          <PostComponent key={index} data={vote} />
        ))}
      </div>
    </>
  );
}
