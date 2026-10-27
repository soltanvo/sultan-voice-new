import React, { useState } from 'react';
import { X, Trophy, Sparkles, Coins, Play } from 'lucide-react';

export type OfficialGameId = 'queen_of_bounty' | 'mahjong_ways_2' | 'luck_77' | 'gates_of_olympus' | 'fortune_dragon';

interface OfficialGamesModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  initialGame: OfficialGameId;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
}

const OFFICIAL_GAMES_LIST = [
  { id: 'queen_of_bounty', title: 'ملكة القراصنة (Queen of Bounty)', icon: '🏴‍☠️', desc: 'مغامرة القراصنة مع بكرات متتالية ومضاعفات x10' },
  { id: 'mahjong_ways_2', title: 'ماجونغ وايز 2 (Mahjong Ways)', icon: '🀄', desc: 'سلوت الماهجونغ الذهبي الأسطوري مع تحويل الرموز' },
  { id: 'luck_77', title: 'لاك 777 (Luck 77)', icon: '🎰', desc: 'ماكينة السلوت الكلاسيكية مع الجاكبوت الملكي' },
  { id: 'gates_of_olympus', title: 'بوابات أوليمبوس (Gates of Olympus)', icon: '⚡', desc: 'صواعق زوس الملكية مع مضاعفات نارية حتى x500' },
  { id: 'fortune_dragon', title: 'تنين الحظ (Fortune Dragon)', icon: '🐉', desc: 'كرة التنين المشتعلة مع ميزة الدوران الفائق' },
];

export const OfficialGamesModal: React.FC<OfficialGamesModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  initialGame,
  setUserCoins,
}) => {
  const [selectedGame, setSelectedGame] = useState<OfficialGameId>(initialGame);
  const [bet, setBet] = useState(500);
  const [spinning, setSpinning] = useState(false);
  const [lastWin, setLastWin] = useState<number | null>(null);

  if (!isOpen) return null;

  const handleSpin = () => {
    if (userCoins < bet) return;
    setUserCoins((prev) => prev - bet);
    setSpinning(true);
    setLastWin(null);

    setTimeout(() => {
      setSpinning(false);
      const isWin = Math.random() > 0.45;
      if (isWin) {
        const mult = [2, 3, 5, 10, 25][Math.floor(Math.random() * 5)];
        const won = bet * mult;
        setUserCoins((prev) => prev + won);
        setLastWin(won);
      }
    }, 1000);
  };

  const activeGameInfo = OFFICIAL_GAMES_LIST.find((g) => g.id === selectedGame) || OFFICIAL_GAMES_LIST[0];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-lg bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <div className="flex items-center gap-2">
            <Trophy className="w-5 h-5 text-amber-400" />
            <h3 className="text-white font-bold text-sm">حزمة الألعاب الرسمية الفاخرة</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Game Tabs */}
        <div className="flex gap-2 overflow-x-auto py-2 my-2 no-scrollbar">
          {OFFICIAL_GAMES_LIST.map((g) => (
            <button
              key={g.id}
              onClick={() => setSelectedGame(g.id as OfficialGameId)}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold whitespace-nowrap shrink-0 transition-all ${
                selectedGame === g.id
                  ? 'bg-amber-500 text-slate-950 shadow-md shadow-amber-500/20'
                  : 'bg-slate-800 text-slate-300 hover:text-white'
              }`}
            >
              {g.icon} {g.title.split(' ')[0]}
            </button>
          ))}
        </div>

        {/* Game Arena */}
        <div className="my-4 bg-gradient-to-b from-purple-950/40 to-slate-950 p-6 rounded-2xl border border-amber-500/30 text-center">
          <span className="text-6xl mb-2 inline-block animate-bounce">{activeGameInfo.icon}</span>
          <h4 className="text-white font-black text-base">{activeGameInfo.title}</h4>
          <p className="text-xs text-white/60 mt-1 max-w-xs mx-auto">{activeGameInfo.desc}</p>

          {lastWin !== null && (
            <div className="mt-4 p-2 bg-emerald-500/20 border border-emerald-500/40 rounded-xl text-emerald-300 font-black text-sm animate-pulse">
              🎉 مبروك! فزت بـ {lastWin.toLocaleString()} كوين!
            </div>
          )}
        </div>

        {/* Controls */}
        <div className="flex items-center justify-between pt-2">
          <div className="flex items-center gap-2">
            <span className="text-xs text-slate-400">الرهان:</span>
            {[200, 500, 1000].map((b) => (
              <button
                key={b}
                onClick={() => setBet(b)}
                className={`px-2.5 py-1 rounded-lg text-xs font-mono font-bold ${
                  bet === b ? 'bg-amber-500 text-slate-950' : 'bg-slate-800 text-slate-300'
                }`}
              >
                {b}
              </button>
            ))}
          </div>

          <button
            onClick={handleSpin}
            disabled={spinning || userCoins < bet}
            className="px-6 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 text-slate-950 font-black text-xs rounded-xl shadow-lg flex items-center gap-1.5 disabled:opacity-50"
          >
            <Play className="w-4 h-4 fill-current" />
            <span>{spinning ? 'جارِ الدوران...' : 'تدوير الرهان'}</span>
          </button>
        </div>
      </div>
    </div>
  );
};
