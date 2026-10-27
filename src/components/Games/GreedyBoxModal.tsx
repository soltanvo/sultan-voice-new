import React, { useState } from 'react';
import { X, Play } from 'lucide-react';

interface GreedyBoxModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
  onBigWin: (amount: number, mult: number) => void;
}

export const GreedyBoxModal: React.FC<GreedyBoxModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  setUserCoins,
  onBigWin,
}) => {
  const [bet] = useState(500);
  const [opening, setOpening] = useState(false);

  if (!isOpen) return null;

  const openBox = () => {
    if (userCoins < bet) return;
    setUserCoins((prev) => prev - bet);
    setOpening(true);

    setTimeout(() => {
      setOpening(false);
      const mult = [2, 5, 10, 30][Math.floor(Math.random() * 4)];
      const won = bet * mult;
      setUserCoins((prev) => prev + won);
      onBigWin(won, mult);
    }, 900);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl text-center">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <h3 className="text-white font-bold text-sm">جريدي بوكس (Greedy Box) 🎁</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-6">
          <span className={`text-6xl block mb-2 ${opening ? 'animate-bounce' : ''}`}>🎁✨</span>
          <p className="text-xs text-white/70">افتح الصندوق السري واحصل على جوائز كوينز فورية!</p>
        </div>

        <button
          onClick={openBox}
          disabled={opening || userCoins < bet}
          className="w-full py-3 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 text-slate-950 font-black rounded-xl shadow-lg flex items-center justify-center gap-2"
        >
          <Play className="w-4 h-4 fill-current" />
          <span>{opening ? 'فتح الصندوق...' : 'فتح الصندوق (500 كوين)'}</span>
        </button>
      </div>
    </div>
  );
};
