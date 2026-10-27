import React from 'react';
import { X, Mic, MicOff, Lock, Unlock, LogIn, LogOut, Gift, UserX } from 'lucide-react';
import { Seat, VoicUser } from '../../types/voic';

interface SeatActionModalProps {
  seat: Seat | null;
  currentUser: VoicUser;
  onClose: () => void;
  onTakeSeat: (index: number) => void;
  onLeaveSeat: (index: number) => void;
  onToggleMute: (index: number) => void;
  onToggleLock: (index: number) => void;
  onKickSeat: (index: number) => void;
  onOpenGiftToSeat: (seat: Seat) => void;
}

export const SeatActionModal: React.FC<SeatActionModalProps> = ({
  seat,
  currentUser,
  onClose,
  onTakeSeat,
  onLeaveSeat,
  onToggleMute,
  onToggleLock,
  onKickSeat,
  onOpenGiftToSeat,
}) => {
  if (!seat) return null;

  const isOccupied = !!seat.user;
  const isMe = seat.user?.id === currentUser.id;
  const isAdmin = currentUser.role !== 'user';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <h3 className="text-white font-bold text-sm">
            إدارة المقعد #{seat.index + 1} {seat.index === 0 ? '👑 (العرش)' : ''}
          </h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-4 flex flex-col gap-2">
          {!isOccupied ? (
            <button
              onClick={() => {
                onTakeSeat(seat.index);
                onClose();
              }}
              className="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-amber-500 to-amber-600 text-slate-950 font-bold text-xs flex items-center justify-center gap-2"
            >
              <LogIn className="w-4 h-4" />
              <span>الصعود على المقعد</span>
            </button>
          ) : isMe ? (
            <button
              onClick={() => {
                onLeaveSeat(seat.index);
                onClose();
              }}
              className="w-full py-2.5 px-4 rounded-xl bg-red-600/80 hover:bg-red-600 text-white font-bold text-xs flex items-center justify-center gap-2"
            >
              <LogOut className="w-4 h-4" />
              <span>النزول من المقعد</span>
            </button>
          ) : (
            <button
              onClick={() => {
                onOpenGiftToSeat(seat);
              }}
              className="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-pink-500 to-rose-600 text-white font-bold text-xs flex items-center justify-center gap-2"
            >
              <Gift className="w-4 h-4" />
              <span>إرسال هدية للمستخدم</span>
            </button>
          )}

          {isAdmin && (
            <>
              <button
                onClick={() => {
                  onToggleMute(seat.index);
                  onClose();
                }}
                className="w-full py-2 px-4 rounded-xl bg-slate-800 text-slate-200 hover:text-white text-xs font-bold flex items-center justify-center gap-2"
              >
                {seat.isMuted ? <Mic className="w-4 h-4 text-emerald-400" /> : <MicOff className="w-4 h-4 text-red-400" />}
                <span>{seat.isMuted ? 'إلغاء كتم المقعد' : 'كتم مايك المقعد'}</span>
              </button>

              <button
                onClick={() => {
                  onToggleLock(seat.index);
                  onClose();
                }}
                className="w-full py-2 px-4 rounded-xl bg-slate-800 text-slate-200 hover:text-white text-xs font-bold flex items-center justify-center gap-2"
              >
                {seat.isLocked ? <Unlock className="w-4 h-4 text-amber-400" /> : <Lock className="w-4 h-4 text-amber-400" />}
                <span>{seat.isLocked ? 'فتح قفل المقعد' : 'قفل المقعد'}</span>
              </button>

              {isOccupied && !isMe && (
                <button
                  onClick={() => {
                    onKickSeat(seat.index);
                    onClose();
                  }}
                  className="w-full py-2 px-4 rounded-xl bg-red-950 border border-red-500/40 text-red-300 hover:text-white text-xs font-bold flex items-center justify-center gap-2"
                >
                  <UserX className="w-4 h-4" />
                  <span>إنزال العضو من المقعد</span>
                </button>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
};
