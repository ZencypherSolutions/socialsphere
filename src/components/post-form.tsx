type PostData = {
    category: string;
    question: string;
    votes: number;
  };
  
  interface PostDataProp {
    data: PostData;
  }
  
  export const PostComponent: React.FC<PostDataProp> = ({ data }) => {
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
        <div className="mb-6">
          <textarea
            className="text-white w-full h-32 sm:h-64 rounded-lg shadow-md p-4 resize-none bg-[#387478] focus:outline-none focus:border-[#4ECCA3]"
            placeholder="Enter your text here..."
          ></textarea>
        </div>
      </div>
    );
  };
  