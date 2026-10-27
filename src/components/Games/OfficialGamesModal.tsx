import React, { useState } from 'react';
import { X, Trophy, Sparkles, Coins, Play } from 'lucide-react';

export type OfficialGameId =
  | 'slot_tiger'
  | 'fortune_dragon'
  | 'greedy_box'
  | 'gates_of_olympus'
  | 'luck_77'
  | 'mahjong_ways_2'
  | 'queen_of_bounty'
  | 'fortune_tiger'
  | 'yummy';

interface OfficialGamesModalProps {
  isOpen: boolean;
  onClose: () => void;
  userCoins: number;
  initialGame?: OfficialGameId;
  setUserCoins: (coins: number | ((prev: number) => number)) => void;
}

const OFFICIAL_GAMES_LIST = [
  { id: 'slot_tiger', title: 'تايغر سلوت (Slot Tiger)', icon: '🐯', color: 'from-amber-600 to-orange-700', desc: 'نمر الحظ الصيني مع أظرف الذهب ومضاعفات حتى x50' },
  { id: 'fortune_dragon', title: 'كنوز التنين (Fortune Dragon)', icon: '🐉', color: 'from-red-600 to-amber-700', desc: 'تنين الشرق الأسطوري وحبات اللؤلؤ الإمبراطورية حتى x100' },
  { id: 'greedy_box', title: 'صندوق الجشع (Greedy Box)', icon: '🎁', color: 'from-purple-600 to-pink-700', desc: 'صناديق الكنوز الأسطورية مع جوائز الحظ المضاعفة' },
  { id: 'gates_of_olympus', title: 'زيوس الأولمب (Gates of Olympus)', icon: '⚡', color: 'from-blue-600 to-indigo-800', desc: 'صواعق زيوس الخارقة مع كؤوس ومجوهرات الأولمب حتى x250' },
  { id: 'luck_77', title: 'حظ 777 (Luck 77)', icon: '🎰', color: 'from-yellow-500 to-amber-700', desc: 'ماكينة السلوت الكلاسيكية مع الجاكبوت الملكي' },
  { id: 'mahjong_ways_2', title: 'ماجونغ وايز 2 (Mahjong Ways)', icon: '🀄', color: 'from-emerald-600 to-teal-800', desc: 'أحجار الماجونغ الإمبراطورية الذهبية مع تحويل الرموز' },
  { id: 'queen_of_bounty', title: 'ملكة المكافآت (Queen of Bounty)', icon: '🏴‍☠️', color: 'from-amber-700 to-yellow-800', desc: 'كنوز القراصنة الملكية مع بكرات متتالية ومضاعفات x60' },
  { id: 'fortune_tiger', title: 'النمر الذهبي (Fortune Tiger)', icon: '🐅', color: 'from-amber-500 to-yellow-600', desc: 'ضربات النمر الذهبي ومضاعفات الجاكبوت الإمبراطوري' },
  { id: 'yummy', title: 'يامي بونانزا (Yummy Sweet)', icon: '🍬', color: 'from-pink-500 to-rose-600', desc: 'حلوى الحظ ومضاعفات الفواكه السحرية اللذيذة' },
];

export const OfficialGamesModal: React.FC<OfficialGamesModalProps> = ({
  isOpen,
  onClose,
  userCoins,
  initialGame = 'slot_tiger',
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
      const isWin = Math.random() > 0.35;
      if (isWin) {
        const mult = [2, 3, 5, 10, 25][Math.floor(Math.random() * 5)];
        const won = bet * mult;
        setUserCoins((prev) => prev + won);
        setLastWin(won);
      }
    }, 850);
  };

  const activeGameInfo = OFFICIAL_GAMES_LIST.find((g) => g.id === selectedGame) || OFFICIAL_GAMES_LIST[0];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-in fade-in duration-200" dir="rtl">
      <div className="w-full max-w-lg bg-slate-900 border border-amber-500/40 rounded-3xl p-5 shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center">
              <Trophy className="w-4 h-4 text-amber-400" />
            </div>
            <div>
              <h3 className="text-white font-black text-sm">صالة ألعاب Sultan Voic الرسمية 👑</h3>
              <p className="text-[11px] text-amber-300 font-mono">
                الرصيد: {userCoins.toLocaleString()} كوين 🪙
              </p>
            </div>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white p-1 rounded-lg">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Game Horizontal Tabs */}
        <div className="flex gap-2 overflow-x-auto py-3 my-2 no-scrollbar">
          {OFFICIAL_GAMES_LIST.map((g) => (
            <button
              key={g.id}
              onClick={() => {
                setSelectedGame(g.id as OfficialGameId);
                setLastWin(null);
              }}
              className={`px-3 py-2 rounded-2xl text-xs font-bold whitespace-nowrap shrink-0 transition-all flex items-center gap-1.5 ${
                selectedGame === g.id
                  ? 'bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-950 font-black shadow-lg shadow-amber-500/20 scale-105'
                  : 'bg-slate-800/80 text-slate-300 hover:text-white border border-slate-700/60'
              }`}
            >
              <span className="text-sm">{g.icon}</span>
              <span>{g.title.split(' ')[0]}</span>
            </button>
          ))}
        </div>

        {/* Game Arena */}
        <div className={`my-3 bg-gradient-to-b ${activeGameInfo.color} to-slate-950 p-6 rounded-2xl border border-amber-500/40 text-center shadow-inner relative overflow-hidden`}>
          <div className="absolute inset-0 bg-black/40 pointer-events-none" />
          <div className="relative z-10">
            <span className={`text-6xl mb-2 inline-block transition-transform duration-300 ${spinning ? 'scale-125 rotate-12 animate-pulse' : 'hover:scale-110'}`}>
              {activeGameInfo.icon}
            </span>
            <h4 className="text-white font-black text-lg">{activeGameInfo.title}</h4>
            <p className="text-xs text-white/80 mt-1 max-w-sm mx-auto">{activeGameInfo.desc}</p>

            {lastWin !== null && (
              <div className="mt-4 p-2.5 bg-emerald-500/20 border border-emerald-500/50 rounded-2xl text-emerald-300 font-black text-sm animate-bounce shadow-lg">
                🎉 فوز ملكي أسطوري! +{lastWin.toLocaleString()} كوين 🪙
              </div>
            )}
          </div>
        </div>

        {/* Controls */}
        <div className="flex items-center justify-between pt-3 border-t border-slate-800">
          <div className="flex items-center gap-1.5">
            <span className="text-xs text-slate-400 font-bold ml-1">الرهان:</span>
            {[200, 500, 1000, 5000].map((b) => (
              <button
                key={b}
                onClick={() => setBet(b)}
                className={`px-2.5 py-1.5 rounded-xl text-xs font-mono font-bold transition-all ${
                  bet === b
                    ? 'bg-amber-400 text-slate-950 shadow-md font-black'
                    : 'bg-slate-800 text-slate-300 hover:text-white'
                }`}
              >
                {b}
              </button>
            ))}
          </div>

          <button
            onClick={handleSpin}
            disabled={spinning || userCoins < bet}
            className="px-6 py-2.5 bg-gradient-to-r from-amber-500 via-yellow-400 to-amber-600 hover:opacity-95 text-slate-950 font-black text-xs rounded-xl shadow-lg shadow-amber-500/20 flex items-center gap-2 disabled:opacity-50 transition-all active:scale-95"
          >
            <Play className="w-4 h-4 fill-current" />
            <span>{spinning ? 'جاري اللعب...' : `تدوير (${bet} كوين)`}</span>
          </button>
        </div>
      </div>
    </div>
  );
};
