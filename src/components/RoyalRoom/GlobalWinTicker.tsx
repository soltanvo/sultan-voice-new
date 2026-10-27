import React from 'react';
import { Flame, Sparkles } from 'lucide-react';
import { GlobalWinTickerItem } from '../../types/voic';

interface GlobalWinTickerProps {
  recentWins: GlobalWinTickerItem[];
  onSimulateWin: () => void;
}

export const GlobalWinTicker: React.FC<GlobalWinTickerProps> = ({ recentWins }) => {
  if (!recentWins || recentWins.length === 0) return null;
  const currentWin = recentWins[0];

  return (
    <div className="w-full max-w-4xl mx-auto px-2 py-1">
      <div className="bg-gradient-to-r from-red-950/80 via-slate-900/90 to-amber-950/80 border border-amber-500/40 rounded-full px-4 py-1.5 flex items-center justify-between text-xs text-white shadow-lg backdrop-blur-sm">
        <div className="flex items-center gap-2 overflow-hidden">
          <Flame className="w-4 h-4 text-orange-500 animate-pulse shrink-0" />
          <span className="font-bold text-amber-300 shrink-0">فوز أسطوري:</span>
          <span className="text-white font-medium truncate">
            تهانينا للملك <strong className="text-amber-400 font-bold">{currentWin.winnerName}</strong> بالفوز بـ{' '}
            <strong className="text-emerald-400 font-mono font-black">{currentWin.coinsWon.toLocaleString()}</strong> كوين في لعبة{' '}
            {currentWin.giftName} (مضاعف x{currentWin.multiplier})! 🎉
          </span>
        </div>
        <div className="shrink-0 flex items-center gap-1 text-[11px] text-amber-400 font-mono">
          <Sparkles className="w-3.5 h-3.5" />
          <span>{currentWin.timestamp}</span>
        </div>
      </div>
    </div>
  );
};
