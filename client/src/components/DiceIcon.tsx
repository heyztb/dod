interface DiceIconProps {
  size?: number;
}

export function DiceIcon({ size = 80 }: DiceIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="-51.2 -51.2 614.40 614.40"
      xmlns="http://www.w3.org/2000/svg"
      fill="#000000"
      transform="rotate(0)"
    >
      <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
      <g
        id="SVGRepo_tracerCarrier"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke="#CCCCCC"
        stroke-width="2.048"
      ></g>
      <g id="SVGRepo_iconCarrier">
        <path
          fill="none"
          stroke="#000000"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="5.632"
          d="M448,341.37V170.61A32,32,0,0,0,432.11,143l-152-88.46a47.94,47.94,0,0,0-48.24,0L79.89,143A32,32,0,0,0,64,170.61V341.37A32,32,0,0,0,79.89,369l152,88.46a48,48,0,0,0,48.24,0l152-88.46A32,32,0,0,0,448,341.37Z"
        ></path>
        <polyline
          fill="none"
          stroke="#000000"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="5.632"
          points="69 153.99 256 263.99 443 153.99"
        ></polyline>
        <line
          fill="none"
          stroke="#000000"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="5.632"
          x1="256"
          y1="463.99"
          x2="256"
          y2="263.99"
        ></line>
        <ellipse cx="256" cy="152" rx="24" ry="16"></ellipse>
        <ellipse cx="208" cy="296" rx="16" ry="24"></ellipse>
        <ellipse cx="112" cy="328" rx="16" ry="24"></ellipse>
        <ellipse cx="304" cy="296" rx="16" ry="24"></ellipse>
        <ellipse cx="400" cy="240" rx="16" ry="24"></ellipse>
        <ellipse cx="304" cy="384" rx="16" ry="24"></ellipse>
        <ellipse cx="400" cy="328" rx="16" ry="24"></ellipse>
      </g>
    </svg>
  );
}
