"use client";

import { SidebarProvider } from "@/app/shared/components/sidebar";
import { SocialSphereSidebar } from "@/app/shared/components/social-sphere-sidebar";
import { SidebarTrigger } from "@/app/shared/components/sidebar";

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
