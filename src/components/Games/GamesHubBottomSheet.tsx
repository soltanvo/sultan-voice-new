import React from 'react';
import { X, Gamepad2, Sparkles, Coins } from 'lucide-react';

interface GamesHubBottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  onOpenTigerSlot: () => void;
  onOpenDragonTreasure: () => void;
  onOpenGreedyBox: () => void;
  onOpenOfficialSuite: (gameId?: string) => void;
  userCoins: number;
}

export const GamesHubBottomSheet: React.FC<GamesHubBottomSheetProps> = ({
  isOpen,
  onClose,
  onOpenTigerSlot,
  onOpenDragonTreasure,
  onOpenGreedyBox,
  onOpenOfficialSuite,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-lg bg-slate-900 border-t-2 border-amber-500/40 rounded-t-3xl p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <div className="flex items-center gap-2">
            <Gamepad2 className="w-5 h-5 text-amber-400" />
            <h3 className="text-white font-bold text-sm">مركز ألعاب السلطان الملكية</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="grid grid-cols-3 gap-2.5 my-4">
          <button
            onClick={() => {
              onClose();
              onOpenTigerSlot();
            }}
            className="p-3 rounded-2xl bg-gradient-to-b from-orange-500/20 to-slate-800 border border-orange-500/40 flex flex-col items-center hover:scale-105 transition-transform"
          >
            <span className="text-3xl mb-1">🐯</span>
            <span className="text-xs font-bold text-white">تايغر سلوت</span>
          </button>

          <button
            onClick={() => {
              onClose();
              onOpenDragonTreasure();
            }}
            className="p-3 rounded-2xl bg-gradient-to-b from-red-500/20 to-slate-800 border border-red-500/40 flex flex-col items-center hover:scale-105 transition-transform"
          >
            <span className="text-3xl mb-1">🐉</span>
            <span className="text-xs font-bold text-white">كنوز التنين</span>
          </button>

          <button
            onClick={() => {
              onClose();
              onOpenGreedyBox();
            }}
            className="p-3 rounded-2xl bg-gradient-to-b from-amber-500/20 to-slate-800 border border-amber-500/40 flex flex-col items-center hover:scale-105 transition-transform"
          >
            <span className="text-3xl mb-1">🎁</span>
            <span className="text-xs font-bold text-white">جريدي بوكس</span>
          </button>

          <button
            onClick={() => {
              onClose();
              onOpenOfficialSuite('queen_of_bounty');
            }}
            className="p-3 rounded-2xl bg-slate-800 border border-slate-700 flex flex-col items-center hover:scale-105 transition-transform col-span-3 text-center"
          >
            <span className="text-xs font-bold text-amber-300">فتح بقية الألعاب الرسمية الخمس (ملكة القراصنة، ماجونغ، زوس) ⚡</span>
          </button>
        </div>
      </div>
    </div>
  );
};
