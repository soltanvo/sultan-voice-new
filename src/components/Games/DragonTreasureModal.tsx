import React, { useState } from 'react';
import { X, Play } from 'lucide-react';

interface DragonTreasureModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
  onJackpotWin: (amount: number, mult: number) => void;
}

export const DragonTreasureModal: React.FC<DragonTreasureModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  setUserCoins,
  onJackpotWin,
}) => {
  const [bet] = useState(1000);
  const [spinning, setSpinning] = useState(false);

  if (!isOpen) return null;

  const play = () => {
    if (userCoins < bet) return;
    setUserCoins((prev) => prev - bet);
    setSpinning(true);

    setTimeout(() => {
      setSpinning(false);
      const mult = [5, 10, 20, 50, 100][Math.floor(Math.random() * 5)];
      const won = bet * mult;
      setUserCoins((prev) => prev + won);
      onJackpotWin(won, mult);
    }, 1000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-gradient-to-b from-red-950 via-slate-900 to-black border border-red-500/40 rounded-2xl p-5 shadow-2xl text-center">
        <div className="flex items-center justify-between pb-3 border-b border-red-500/30">
          <h3 className="text-white font-bold text-sm">كنوز التنين (Dragon Treasure) 🐉</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-6">
          <span className={`text-6xl block mb-2 ${spinning ? 'animate-bounce' : ''}`}>🐉🔥</span>
          <p className="text-xs text-amber-300">كنوز التنين الأسطوري مع مضاعفات تصل إلى x100!</p>
        </div>

        <button
          onClick={play}
          disabled={spinning || userCoins < bet}
          className="w-full py-3 bg-gradient-to-r from-red-600 to-amber-500 hover:from-red-500 text-white font-black rounded-xl shadow-lg flex items-center justify-center gap-2"
        >
          <Play className="w-4 h-4 fill-current" />
          <span>{spinning ? 'فتح الكنز...' : 'فتح كنز التنين (1,000 كوين)'}</span>
        </button>
      </div>
    </div>
  );
};
