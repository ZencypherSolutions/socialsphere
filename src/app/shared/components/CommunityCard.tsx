export default function CommunityCard() {
  return (
    <div className="w-full max-w-3xl p-8">
      <div className="relative w-full bg-[#EEEEEE] rounded-[32px] p-8">
        <div className="flex justify-between items-start">
          <div className="space-y-3">
            <h2 className="text-5xl font-normal text-black">CommunityDAO</h2>
            <p className="text-3xl text-black">Members: xxx</p>
          </div>
          <div className="px-6 py-3 bg-[#387478] text-white rounded-full">
            <span className="text-xl">Gaming</span>
          </div>
        </div>
        <div className="mt-10">
          <p className="text-xl text-black">Created: xx days ago</p>
        </div>
      </div>
    </div>
  );
}
