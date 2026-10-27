export type UserRole = 'super_admin' | 'admin' | 'manager' | 'supervisor' | 'user' | 'member';

export type SvipLevel = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9;

export interface VoicUser {
  id: string;
  name: string;
  avatar: string;
  role: UserRole;
  svip: SvipLevel;
  coins: number;
  isMuted?: boolean;
  isSpeaking?: boolean;
}

export interface Seat {
  index: number;
  user: VoicUser | null;
  isLocked: boolean;
  isMuted: boolean;
}

export interface CpPartner {
  name: string;
  avatar: string;
  id?: string;
  svip?: SvipLevel;
}

export interface CpRelationship {
  partner1: CpPartner;
  partner2: CpPartner;
  level: number;
  points: number;
  title: string;
}

export interface GlobalWinTickerItem {
  id: string;
  winnerName: string;
  giftName: string;
  coinsWon: number;
  multiplier: number;
  timestamp: number;
}

export interface Agency {
  id: string;
  name: string;
  ownerId: string;
  supervisorIds: string[];
  memberIds: string[];
  membersCount: number;
  totalEarnings: number;
}
