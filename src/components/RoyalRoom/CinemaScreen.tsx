import React from 'react';
import { Film, Mic, MicOff, Crown, Heart } from 'lucide-react';
import { Seat, CpRelationship } from '../../types/voic';

interface CinemaScreenProps {
  cinemaSeats: Seat[];
  onSelectSeat: (seat: Seat) => void;
  cpRelationship?: CpRelationship | null;
  onOpenCpModal?: () => void;
}

export const CinemaScreen: React.FC<CinemaScreenProps> = ({
  cinemaSeats,
  onSelectSeat,
}) => {
  return (
    <div className="w-full flex flex-col items-center gap-4 py-2">
      {/* 3D Cinema Display Screen */}
      <div className="w-full max-w-2xl h-44 sm:h-56 bg-gradient-to-b from-slate-900 via-slate-950 to-black rounded-3xl border-2 border-amber-500/40 p-4 shadow-2xl relative overflow-hidden flex flex-col items-center justify-center text-center">
        <div className="absolute inset-0 bg-radial from-amber-500/10 to-transparent pointer-events-none" />
        <Film className="w-12 h-12 text-amber-400 mb-2 animate-pulse" />
        <h3 className="text-white font-black text-base sm:text-lg">سينما Sultan Voic الملكية 🎬</h3>
        <p className="text-xs text-amber-300/80 mt-1">بث مباشر سينمائي مع 10 مايكات ذهبية محيطية</p>
      </div>

      {/* 10 Cinema Mics Layout */}
      <div className="grid grid-cols-5 gap-3 w-full max-w-xl px-2">
        {cinemaSeats.slice(0, 10).map((seat) => (
          <div
            key={seat.index}
            onClick={() => onSelectSeat(seat)}
            className="flex flex-col items-center cursor-pointer group"
          >
            <div className={`w-12 h-12 rounded-full border-2 flex items-center justify-center transition-all ${
              seat.user
                ? 'border-amber-400 bg-slate-800 shadow-md shadow-amber-500/20'
                : 'border-slate-700 bg-slate-900/60 hover:border-slate-500'
            }`}>
              {seat.user ? (
                <img src={seat.user.avatar} alt={seat.user.name} className="w-full h-full rounded-full object-cover" />
              ) : (
                <Mic className="w-5 h-5 text-slate-500" />
              )}
            </div>
            <span className="text-[10px] text-white/80 font-bold mt-1 truncate max-w-[60px]">
              {seat.user ? seat.user.name : `مايك ${seat.index + 1}`}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};
