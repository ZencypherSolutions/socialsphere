"use client";

import { SidebarProvider } from "@/components/ui/sidebar";
import { SocialSphereSidebar } from "@/components/social-sphere-sidebar";
import { SidebarTrigger } from "@/components/ui/sidebar";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <SidebarProvider>
      <div className="flex min-h-screen">
        <SocialSphereSidebar />
        <main className="flex-1 p-4 md:p-6 lg:p-8">
          <SidebarTrigger />
          {children}
        </main>
      </div>
    </SidebarProvider>
  );
}
