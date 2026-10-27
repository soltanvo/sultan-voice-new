import React from 'react';
import { X, Heart, Sparkles, Crown } from 'lucide-react';
import { CpRelationship } from '../../types/voic';

interface CpModalProps {
  isOpen: boolean;
  onClose: () => void;
  cpRelationship?: CpRelationship | null;
  onSendLoveGift: (points: number) => void;
  onTriggerCpWelcome: () => void;
}

export const CpModal: React.FC<CpModalProps> = ({
  isOpen,
  onClose,
  cpRelationship,
  onSendLoveGift,
  onTriggerCpWelcome,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-gradient-to-b from-rose-950/90 via-slate-900 to-slate-950 border border-rose-500/40 rounded-2xl p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-3 border-b border-rose-500/20">
          <div className="flex items-center gap-2">
            <Heart className="w-5 h-5 text-rose-500 fill-current animate-pulse" />
            <h3 className="text-white font-bold text-sm">علاقة الشريك الروحي (CP)</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-4 text-center space-y-3">
          <div className="flex items-center justify-center gap-4">
            <div className="flex flex-col items-center">
              <img
                src={cpRelationship?.partner1.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'}
                className="w-14 h-14 rounded-full border-2 border-rose-500 object-cover shadow-lg"
                alt="Partner 1"
              />
              <span className="text-xs font-bold text-white mt-1">{cpRelationship?.partner1.name || 'سلطان'}</span>
            </div>
            <Heart className="w-8 h-8 text-rose-500 fill-current animate-bounce" />
            <div className="flex flex-col items-center">
              <img
                src={cpRelationship?.partner2.avatar || 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'}
                className="w-14 h-14 rounded-full border-2 border-rose-500 object-cover shadow-lg"
                alt="Partner 2"
              />
              <span className="text-xs font-bold text-white mt-1">{cpRelationship?.partner2.name || 'أميرة'}</span>
            </div>
          </div>

          <div className="bg-rose-950/40 border border-rose-500/30 p-2.5 rounded-xl">
            <div className="text-xs text-rose-300 font-bold">مستوى رابطة العشق: المستوى {cpRelationship?.level || 9} 👑</div>
            <div className="text-[11px] text-white/70">نقاط المحبة: {cpRelationship?.points.toLocaleString() || '1,500,000'} نقطة</div>
          </div>

          <div className="flex gap-2">
            <button
              onClick={() => {
                onSendLoveGift(5000);
                onClose();
              }}
              className="flex-1 py-2 rounded-xl bg-gradient-to-r from-rose-500 to-pink-600 text-white font-bold text-xs shadow-md"
            >
              إرسال هدية محبة 💖
            </button>

            <button
              onClick={() => {
                onTriggerCpWelcome();
                onClose();
              }}
              className="flex-1 py-2 rounded-xl bg-slate-800 text-rose-300 border border-rose-500/30 hover:bg-slate-700 font-bold text-xs"
            >
              تشغيل دخلة الـ CP
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
