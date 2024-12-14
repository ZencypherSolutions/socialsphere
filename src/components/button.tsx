"use client";
import React, { forwardRef, ButtonHTMLAttributes } from "react";
import { Slot } from "@radix-ui/react-slot";

const buttonVariants = {
  variant: {
    default: "bg-text-dark text-white hover:opacity-70",
    destructive: "bg-red-500 text-white hover:bg-red-500/90",
    outline:
      "border border-blue-500 bg-white hover:bg-gray-100 hover:text-blue-800",
    secondary:
      "bg-transparent text-gray-900 font-medium border border-blue-500 hover:bg-gray-100/80",
    tertiary:
      "bg-gradient-to-r from-blue-100 to-blue-100 text-black font-medium border border-blue-500 hover:opacity-90",
    ghost: "hover:bg-gray-100 hover:text-gray-900",
    link: "text-gray-900 underline-offset-4 hover:underline",
  },
  size: {
    default: "h-12 px-4 py-2 rounded-lg",
    md: "h-11 px-4 py-2",
    sm: "h-9 rounded-md px-3",
    lg: "h-14 rounded-xl px-8",
    icon: "h-10 w-10",
  },
};

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: keyof typeof buttonVariants.variant;
  size?: keyof typeof buttonVariants.size;
  className?: string;
  asChild?: boolean;
}

const cn = (...classes: (string | undefined)[]) => {
  return classes.filter(Boolean).join(" ");
};

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    { className = "", variant = "default", size = "sm", asChild, ...props },
    ref
  ) => {
    const combinedClassName = cn(
      "inline-flex items-center justify-center whitespace-nowrap rounded-md text-base font-medium",
      "ring-offset-white transition-colors focus-visible:outline-none focus-visible:ring-2",
      "focus-visible:ring-blue-500 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
      buttonVariants.variant[variant],
      buttonVariants.size[size],
      className
    );

    const Comp = asChild ? Slot : "button";
    return <Comp ref={ref} className={combinedClassName} {...props} />;
  }
);

Button.displayName = "Button";

export default Button;
