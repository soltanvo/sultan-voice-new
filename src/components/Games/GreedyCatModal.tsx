import React, { useState } from 'react';
import { X, Play } from 'lucide-react';

interface GreedyCatModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
}

export const GreedyCatModal: React.FC<GreedyCatModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  setUserCoins,
}) => {
  const [catState, setCatState] = useState<'idle' | 'happy' | 'angry'>('idle');
  const [bet] = useState(300);

  if (!isOpen) return null;

  const feedCat = () => {
    if (userCoins < bet) return;
    setUserCoins((prev) => prev - bet);

    const win = Math.random() > 0.5;
    if (win) {
      setCatState('happy');
      setUserCoins((prev) => prev + bet * 3);
    } else {
      setCatState('angry');
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl text-center">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <h3 className="text-white font-bold text-sm">القط الجشع (Greedy Cat) 🐱</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-6">
          <span className="text-7xl block mb-2">
            {catState === 'happy' ? '😻' : catState === 'angry' ? '😾' : '🐱'}
          </span>
          <p className="text-xs text-white/70">
            {catState === 'happy' ? 'القط سعيد وكافأك بـ 900 كوين!' : catState === 'angry' ? 'القط ابتلع الكوينز وغضب!' : 'أطعم القط كوينز للحصول على مكافآت مضاعفة!'}
          </p>
        </div>

        <button
          onClick={feedCat}
          disabled={userCoins < bet}
          className="w-full py-3 bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-400 text-slate-950 font-black rounded-xl shadow-lg flex items-center justify-center gap-2"
        >
          <Play className="w-4 h-4 fill-current" />
          <span>إطعام القط (300 كوين)</span>
        </button>
      </div>
    </div>
  );
};
