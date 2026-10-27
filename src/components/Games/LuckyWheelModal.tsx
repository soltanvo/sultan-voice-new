import React, { useState } from 'react';
import { X, Play, RotateCw } from 'lucide-react';

interface LuckyWheelModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
  onWinSvip: () => void;
}

export const LuckyWheelModal: React.FC<LuckyWheelModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  setUserCoins,
  onWinSvip,
}) => {
  const [spinning, setSpinning] = useState(false);
  const [bet] = useState(500);

  if (!isOpen) return null;

  const spin = () => {
    if (userCoins < bet) return;
    setUserCoins((prev) => prev - bet);
    setSpinning(true);

    setTimeout(() => {
      setSpinning(false);
      const prizes = [1000, 2000, 5000, 10000];
      const win = prizes[Math.floor(Math.random() * prizes.length)];
      setUserCoins((prev) => prev + win);
      if (Math.random() > 0.8) onWinSvip();
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl text-center">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <h3 className="text-white font-bold text-sm">عجلة الحظ الملكية 🎡</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-6 flex justify-center">
          <div className={`w-36 h-36 rounded-full border-4 border-amber-400 bg-radial from-amber-500/30 to-purple-900/60 flex items-center justify-center shadow-xl ${spinning ? 'animate-spin' : ''}`}>
            <span className="text-5xl">🎡</span>
          </div>
        </div>

        <button
          onClick={spin}
          disabled={spinning || userCoins < bet}
          className="w-full py-3 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 text-slate-950 font-black rounded-xl shadow-lg flex items-center justify-center gap-2"
        >
          <RotateCw className="w-4 h-4" />
          <span>{spinning ? 'تدوير العجلة...' : 'تدوير (500 كوين)'}</span>
        </button>
      </div>
    </div>
  );
};
