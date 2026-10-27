import React, { useState } from 'react';
import { X, Play } from 'lucide-react';

interface TigerSlotModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
  onBigWin: (amount: number, mult: number) => void;
}

export const TigerSlotModal: React.FC<TigerSlotModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  setUserCoins,
  onBigWin,
}) => {
  const [bet] = useState(200);
  const [spinning, setSpinning] = useState(false);

  if (!isOpen) return null;

  const spin = () => {
    if (userCoins < bet) return;
    setUserCoins((prev) => prev - bet);
    setSpinning(true);

    setTimeout(() => {
      setSpinning(false);
      const mult = [2, 5, 10, 50][Math.floor(Math.random() * 4)];
      const won = bet * mult;
      setUserCoins((prev) => prev + won);
      onBigWin(won, mult);
    }, 900);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-gradient-to-b from-orange-950 via-slate-900 to-black border border-orange-500/40 rounded-2xl p-5 shadow-2xl text-center">
        <div className="flex items-center justify-between pb-3 border-b border-orange-500/30">
          <h3 className="text-white font-bold text-sm">تايغر سلوت (Fortune Tiger) 🐯</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-6">
          <span className={`text-6xl block mb-2 ${spinning ? 'animate-bounce' : ''}`}>🐯🍊</span>
          <p className="text-xs text-amber-300">نمر الحظ يزأر بمضاعفات تصل إلى x50!</p>
        </div>

        <button
          onClick={spin}
          disabled={spinning || userCoins < bet}
          className="w-full py-3 bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-400 text-slate-950 font-black rounded-xl shadow-lg flex items-center justify-center gap-2"
        >
          <Play className="w-4 h-4 fill-current" />
          <span>{spinning ? 'تدوير...' : 'تدوير نمر الحظ (200 كوين)'}</span>
        </button>
      </div>
    </div>
  );
};
