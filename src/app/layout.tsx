import "@/app/globals.css";
import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { SocialSphereSidebar } from "@/components/social-sphere-sidebar";
import { Navbar } from '@/components/Navbar';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <Navbar />
        <SidebarProvider>
          <div className="content-wrapper">
            <div className="flex min-h-screen">
              <SocialSphereSidebar />
              <main className="flex-1 p-4 md:p-6 lg:p-8">
                <SidebarTrigger />
                {children}
              </main>
            </div>
          </div>
        </SidebarProvider>
      </body>
    </html>
  );
}
