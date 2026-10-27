export interface SvipTierInfo {
  level: number;
  name: string;
  badgeBg: string;
  icon: string;
}

export const SVIP_TIERS: Record<number, SvipTierInfo> = {
  0: { level: 0, name: 'عضو عادي', badgeBg: 'bg-slate-700 text-white', icon: '👤' },
  1: { level: 1, name: 'SVIP 1 - برونزي', badgeBg: 'bg-gradient-to-r from-amber-700 to-amber-900 text-amber-200', icon: '🥉' },
  2: { level: 2, name: 'SVIP 2 - فضي', badgeBg: 'bg-gradient-to-r from-slate-400 to-slate-600 text-white', icon: '🥈' },
  3: { level: 3, name: 'SVIP 3 - ذهبي', badgeBg: 'bg-gradient-to-r from-amber-500 to-yellow-600 text-slate-950', icon: '🥇' },
  4: { level: 4, name: 'SVIP 4 - بلاتينيوم', badgeBg: 'bg-gradient-to-r from-cyan-500 to-blue-600 text-white', icon: '💎' },
  5: { level: 5, name: 'SVIP 5 - ياقوت', badgeBg: 'bg-gradient-to-r from-rose-500 to-red-700 text-white', icon: '💠' },
  6: { level: 6, name: 'SVIP 6 - زمرد', badgeBg: 'bg-gradient-to-r from-emerald-500 to-teal-700 text-white', icon: '❇️' },
  7: { level: 7, name: 'SVIP 7 - إمبراطوري', badgeBg: 'bg-gradient-to-r from-purple-600 to-amber-500 text-yellow-200', icon: '👑' },
  8: { level: 8, name: 'SVIP 8 - أسطوري', badgeBg: 'bg-gradient-to-r from-orange-500 via-amber-400 to-red-600 text-white', icon: '🦅' },
  9: { level: 9, name: 'SVIP 9 - سلطان الكون', badgeBg: 'bg-gradient-to-r from-red-600 via-amber-500 to-yellow-300 text-slate-950 font-black', icon: '🔥' },
};
