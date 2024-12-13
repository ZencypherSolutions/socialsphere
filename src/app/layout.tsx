import "@/app/globals.css"
import { SidebarProvider } from "@/components/ui/sidebar"
import { SocialSphereSidebar } from "@/components/social-sphere-sidebar"

export const metadata = {
  title: 'Social Sphere',
  description: 'A social platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <SidebarProvider>
          <div className="flex min-h-screen">
            <SocialSphereSidebar />
            <main className="flex-1 p-4 md:p-6 lg:p-8">{children}</main>
          </div>
        </SidebarProvider>
      </body>
    </html>
  )
}

