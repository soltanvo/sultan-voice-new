import React from 'react';
import { Crown, Sparkles, X } from 'lucide-react';
import { VoicUser, SvipLevel } from '../../types/voic';

interface SvipEntryOverlayProps {
  currentEntry: {
    userName: string;
    avatar: string;
    level: SvipLevel;
    role?: string;
    isThroneAscension?: boolean;
  } | null;
  onDismiss: () => void;
  onTriggerTestEntry: (level: SvipLevel) => void;
  showSelectorModal: boolean;
  setShowSelectorModal: (show: boolean) => void;
}


export const SvipEntryOverlay: React.FC<SvipEntryOverlayProps> = ({
  currentEntry,
  onDismiss,
  onTriggerTestEntry,
  showSelectorModal,
  setShowSelectorModal,
}) => {
  return (
    <>
      {/* Active Entrance Banner */}
      {currentEntry && (
        <div className="fixed top-20 inset-x-0 z-50 flex justify-center pointer-events-none px-4 animate-in slide-in-from-top duration-500">
          <div className="bg-gradient-to-r from-red-600 via-amber-500 to-yellow-400 p-1 rounded-2xl shadow-2xl shadow-amber-500/50">
            <div className="bg-slate-950/90 rounded-xl px-6 py-3 flex items-center gap-3 backdrop-blur-md">
              <span className="text-3xl animate-bounce">
                {currentEntry.level === 9 ? '🔥' : currentEntry.level >= 7 ? '👑' : '🏎️'}
              </span>
              <div>
                <div className="text-xs text-amber-300 font-bold">دخول ملكي فاخر!</div>
                <div className="text-sm font-black text-white flex items-center gap-1.5">
                  <span>{currentEntry.userName}</span>
                  <span className="px-2 py-0.5 rounded-full bg-amber-500 text-slate-950 text-[10px]">
                    SVIP{currentEntry.level}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Selector Modal */}
      {showSelectorModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
          <div className="w-full max-w-sm bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl">
            <div className="flex items-center justify-between pb-3 border-b border-slate-800">
              <h3 className="text-white font-bold text-sm flex items-center gap-2">
                <Crown className="w-4 h-4 text-amber-400" />
                <span>اختبار دخلات SVIP الملكية</span>
              </h3>
              <button onClick={() => setShowSelectorModal(false)} className="text-slate-400 hover:text-white">
                <X className="w-5 h-5" />
              </button>
            </div>
            <div className="grid grid-cols-3 gap-2 my-4">
              {([1, 2, 3, 4, 5, 6, 7, 8, 9] as SvipLevel[]).map((lvl) => (
                <button
                  key={lvl}
                  onClick={() => {
                    onTriggerTestEntry(lvl);
                    setShowSelectorModal(false);
                  }}
                  className="p-2 rounded-xl bg-slate-800 hover:bg-amber-500/20 hover:border-amber-400 border border-slate-700 text-xs font-bold text-white transition-all"
                >
                  SVIP {lvl} 👑
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </>
  );
};
