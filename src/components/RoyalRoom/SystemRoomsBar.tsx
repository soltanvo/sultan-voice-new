import React from 'react';
import { Shield, Headphones, Film, Crown } from 'lucide-react';

export type SystemRoomType = 'main_room' | 'admin_room' | 'support_room';

interface SystemRoomsBarProps {
  currentRoom: SystemRoomType;
  onSelectRoom: (room: SystemRoomType) => void;
  isSupervisorOrAdmin: boolean;
}

export const SystemRoomsBar: React.FC<SystemRoomsBarProps> = ({
  currentRoom,
  onSelectRoom,
  isSupervisorOrAdmin,
}) => {
  return (
    <div className="w-full max-w-4xl mx-auto px-3 py-1 flex items-center justify-center gap-2 text-xs">
      <button
        onClick={() => onSelectRoom('main_room')}
        className={`px-3 py-1.5 rounded-xl font-bold flex items-center gap-1.5 transition-all ${
          currentRoom === 'main_room'
            ? 'bg-gradient-to-r from-amber-500 to-amber-600 text-slate-950 shadow-md shadow-amber-500/20'
            : 'bg-slate-900/80 text-white/70 hover:text-white border border-slate-800'
        }`}
      >
        <Crown className="w-3.5 h-3.5" />
        <span>المجلس الملكي 👑</span>
      </button>

      <button
        onClick={() => onSelectRoom('admin_room')}
        className={`px-3 py-1.5 rounded-xl font-bold flex items-center gap-1.5 transition-all ${
          currentRoom === 'admin_room'
            ? 'bg-gradient-to-r from-cyan-500 to-blue-600 text-white shadow-md shadow-cyan-500/20'
            : 'bg-slate-900/80 text-white/70 hover:text-white border border-slate-800'
        }`}
      >
        <Shield className="w-3.5 h-3.5 text-cyan-400" />
        <span>روم الإدارة 3D 🛡️</span>
      </button>

      <button
        onClick={() => onSelectRoom('support_room')}
        className={`px-3 py-1.5 rounded-xl font-bold flex items-center gap-1.5 transition-all ${
          currentRoom === 'support_room'
            ? 'bg-gradient-to-r from-emerald-500 to-teal-600 text-white shadow-md shadow-emerald-500/20'
            : 'bg-slate-900/80 text-white/70 hover:text-white border border-slate-800'
        }`}
      >
        <Headphones className="w-3.5 h-3.5 text-emerald-400" />
        <span>خدمة العملاء VIP 🎧</span>
      </button>
    </div>
  );
};
