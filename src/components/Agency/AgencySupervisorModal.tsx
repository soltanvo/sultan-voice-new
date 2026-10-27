import React from 'react';
import { X, Users, ShieldCheck, UserPlus } from 'lucide-react';
import { VoicUser, Agency } from '../../types/voic';

interface AgencySupervisorModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentUser: VoicUser;
  agency: Agency;
  onDelegateSupervisor: (targetUserId: string) => void;
  onBindMember: (targetUserId: string) => void;
}

export const AgencySupervisorModal: React.FC<AgencySupervisorModalProps> = ({
  isOpen,
  onClose,
  currentUser,
  agency,
  onDelegateSupervisor,
  onBindMember,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-amber-500/40 rounded-2xl p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <div className="flex items-center gap-2">
            <Users className="w-5 h-5 text-amber-400" />
            <h3 className="text-white font-bold text-sm">إدارة وكالة السلطان الرسمية</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-4 space-y-3">
          <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/60">
            <div className="text-xs text-amber-400 font-bold">{agency.name}</div>
            <div className="text-[11px] text-white/70 mt-1">كود الوكالة: {agency.id} • الأعضاء: {agency.membersCount}</div>
          </div>


          <button
            onClick={() => {
              onDelegateSupervisor('2');
              onClose();
            }}
            className="w-full py-2.5 px-3 rounded-xl bg-gradient-to-r from-cyan-500 to-blue-600 text-white font-bold text-xs flex items-center justify-center gap-2"
          >
            <ShieldCheck className="w-4 h-4" />
            <span>تفويض مشرف وكالة جديد 🛡️</span>
          </button>

          <button
            onClick={() => {
              onBindMember('3');
              onClose();
            }}
            className="w-full py-2.5 px-3 rounded-xl bg-slate-800 border border-slate-700 text-white font-bold text-xs flex items-center justify-center gap-2 hover:bg-slate-700"
          >
            <UserPlus className="w-4 h-4 text-emerald-400" />
            <span>ربط عضو بالوكالة ⚡</span>
          </button>
        </div>
      </div>
    </div>
  );
};
