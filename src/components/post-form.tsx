"use client";
import { Button } from "@/components/ui/button";
import {
  ChevronDown,
  ChevronUp,
  MessageSquare,
  Send,
  Share,
} from "lucide-react";
import React, { useState } from "react";

type PostData = {
  category: string;
  question: string;
  votes: number;
};

interface Comment {
  id: string;
  text: string;
  username: string;
  timestamp: Date;
}

interface PostDataProp {
  data: PostData;
}

export const PostComponent: React.FC<PostDataProp> = ({ data }) => {
  const [likes, setLikes] = useState(0);
  const [dislikes, setDislikes] = useState(0);
  const [userReaction, setUserReaction] = useState<"like" | "dislike" | null>(
    null
  );
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState("");
  const [showComments, setShowComments] = useState(false);

  const handleReaction = (type: "like" | "dislike") => {
    if (userReaction === type) {
      setUserReaction(null);
      if (type === "like") setLikes((prev) => prev - 1);
      else setDislikes((prev) => prev - 1);
    } else {
      if (userReaction) {
        if (userReaction === "like") setLikes((prev) => prev - 1);
        else setDislikes((prev) => prev - 1);
      }
      setUserReaction(type);
      if (type === "like") setLikes((prev) => prev + 1);
      else setDislikes((prev) => prev + 1);
    }
  };

  const handleComment = () => {
    if (newComment.trim()) {
      const comment: Comment = {
        id: Date.now().toString(),
        text: newComment,
        username: "Default User",
        timestamp: new Date(),
      };
      setComments((prev) => [comment, ...prev]);
      setNewComment("");
    }
  };

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: "Check out this post",
          text: data.question,
          url: window.location.href,
        });
      } catch (err) {
        console.log("Error sharing:", err);
      }
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-4 sm:p-6 bg-[#2C5154] rounded-xl shadow-lg">
      <div className="flex items-center mb-4 sm:mb-6 bg-[#387478] rounded-3xl p-2">
        <img
          src="https://www.shutterstock.com/image-vector/user-profile-icon-vector-avatar-600nw-2247726673.jpg"
          alt="User Avatar"
          className="w-10 h-10 sm:w-12 sm:h-12 rounded-full object-cover border-2 border-[#4ECCA3]"
        />
        <div className="ml-4 w-full">
          <div className="flex items-center w-full justify-between">
            <h2 className="text-[#EEEE] font-bold text-xs sm:text-sm">
              Default User Name
            </h2>
            <span className="text-[#EEEE] text-xs sm:text-sm me-2">member</span>
          </div>
        </div>
      </div>
      <div className="mb-4">
        <span className="inline-block bg-[#E36C59] text-white px-2 sm:px-3 py-1 rounded-full text-xs sm:text-sm font-semibold">
          {data.category}
        </span>
      </div>
      <div className="rounded-lg mb-5 flex flex-col sm:flex-row justify-between gap-2">
        <p className="text-[#EEEE] text-xs sm:text-sm">{data.question}</p>
        <p className="text-[#EEEE] text-xs sm:text-sm">{data.votes} Votes</p>
      </div>

      {/* Comment Section */}
      <div className="space-y-4">
        {/* Comment Input */}
        <div className="flex flex-col gap-2">
          <textarea
            className="text-white w-full h-32 sm:h-64 rounded-lg shadow-md p-4 resize-none bg-[#387478] focus:outline-none focus:border-[#4ECCA3]"
            placeholder="Add a comment..."
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
          />
          <Button
            onClick={handleComment}
            className="bg-[#4ECCA3] hover:bg-[#45b38f]"
          >
            <Send className="h-4 w-4" />
          </Button>
        </div>

        {/* Comments List */}
        <div className="space-y-3">
          {comments.map((comment) => (
            <div key={comment.id} className="bg-[#387478] p-3 rounded-lg">
              <div className="flex justify-between items-center mb-2">
                <span className="text-white text-sm font-semibold">
                  {comment.username}
                </span>
                <span className="text-gray-400 text-xs">
                  {comment.timestamp.toLocaleDateString()}
                </span>
              </div>
              <p className="text-white text-sm">{comment.text}</p>
            </div>
          ))}
        </div>
      </div>
      <div className="flex items-center gap-4 my-4 w-full">
        <div className="flex items-center gap-2 px-3 rounded-2xl bg-gray-400">
          <Button
            variant="link"
            size="sm"
            onClick={() => handleReaction("like")}
            className={`flex items-center gap-2 hover:no-underline p-0 ${
              userReaction === "like" ? "text-green-400" : "text-white"
            }`}
          >
            <ChevronUp size={16} />
            {/* {likes > 0 && <span>{likes}</span>} */}
          </Button>

          <Button
            variant="link"
            size="sm"
            onClick={() => handleReaction("dislike")}
            className={`flex items-center gap-2 hover:no-underline p-0 ${
              userReaction === "dislike" ? "text-red-400" : "text-white"
            }`}
          >
            <ChevronDown size={16} />
            {/* {dislikes > 0 && <span>{dislikes}</span>} */}
          </Button>
        </div>

        <Button
          variant="link"
          size="sm"
          onClick={() => setShowComments(!showComments)}
          className="text-white flex items-center gap-2 px-3 rounded-2xl bg-gray-400 hover:no-underline"
        >
          <MessageSquare size={16} />
          <span>{comments.length}</span>
        </Button>

        <Button
          variant="link"
          size="sm"
          onClick={handleShare}
          className="text-white hover:no-underline block ml-auto"
        >
          <Share className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
};
