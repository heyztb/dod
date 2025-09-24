export type ApiResponse = {
  message: string;
  success: boolean;
};

export type MeResponse = {
  fid: number;
  primaryAddress?: string;
};

export type FarcasterNotificationDetails = {
  url: string;
  token: string;
};
