import { Badge } from "./ui/badge"
import { Card, CardContent, CardHeader } from "./ui/card"

interface HighlightedVoteProps {
  question: string
  category: string
  votes?: number
  comments?: number
}

export default function HighlightedVote({
  question,
  category,
  votes = 0,
  comments = 0
}: HighlightedVoteProps) {
  return (
    <Card className="max-w-sm border-none bg-[#2C5154] shadow-xl rounded-3xl">
      <CardHeader className="pb-2">
        <h2 className="text-3xl font-medium text-white">
          {question}
        </h2>
      </CardHeader>
      <CardContent className="space-y-12">
        <Badge
          variant="secondary"
          className="bg-[#E36C59] border-none font-normal px-3 hover:bg-[#E36C59] shadow-xl text-[#EEEEEE] text-lg rounded-full"
        >
          {category}
        </Badge>
        <div className="flex gap-8 text-xl text-[#EEEEEE]">
          <span>{votes} votes</span>
          <span>{comments} comments</span>
        </div>
      </CardContent>
    </Card>
  )
}
