import React, { useState } from 'react';
import { X, Play, Coins } from 'lucide-react';

interface SlotMachineModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
}

export const SlotMachineModal: React.FC<SlotMachineModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  setUserCoins,
}) => {
  const [reels, setReels] = useState(['7️⃣', '7️⃣', '7️⃣']);
  const [spinning, setSpinning] = useState(false);
  const [bet] = useState(200);

  if (!isOpen) return null;

  const spin = () => {
    if (userCoins < bet) return;
    setUserCoins((prev) => prev - bet);
    setSpinning(true);

    setTimeout(() => {
      const symbols = ['7️⃣', '💎', '👑', '🍒', '🔔', '🪙'];
      const r1 = symbols[Math.floor(Math.random() * symbols.length)];
      const r2 = symbols[Math.floor(Math.random() * symbols.length)];
      const r3 = symbols[Math.floor(Math.random() * symbols.length)];
      setReels([r1, r2, r3]);
      setSpinning(false);

      if (r1 === r2 && r2 === r3) {
        setUserCoins((prev) => prev + bet * 20);
      }
    }, 800);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl text-center">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <h3 className="text-white font-bold text-sm">ماكينة سلوت الحظ 777 🎰</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-6 flex justify-center gap-3">
          {reels.map((s, idx) => (
            <div key={idx} className="w-20 h-24 bg-slate-950 border-2 border-amber-400 rounded-xl flex items-center justify-center text-4xl shadow-inner">
              <span className={spinning ? 'animate-bounce' : ''}>{s}</span>
            </div>
          ))}
        </div>

        <button
          onClick={spin}
          disabled={spinning || userCoins < bet}
          className="w-full py-3 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 text-slate-950 font-black rounded-xl shadow-lg flex items-center justify-center gap-2"
        >
          <Play className="w-4 h-4 fill-current" />
          <span>{spinning ? 'تدوير...' : `تدوير (200 كوين)`}</span>
        </button>
      </div>
    </div>
  );
};
