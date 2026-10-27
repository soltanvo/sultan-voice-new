import React from 'react';
import { X, ShieldAlert, Crown, User } from 'lucide-react';
import { VoicUser, UserRole, SvipLevel } from '../../types/voic';

interface RoleManagementModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentUser: VoicUser;
  onChangeUserRole: (role: UserRole) => void;
  onChangeUserSvip: (svip: SvipLevel) => void;
  onSwitchUserId: (newId: string) => void;
}

export const RoleManagementModal: React.FC<RoleManagementModalProps> = ({
  isOpen,
  onClose,
  currentUser,
  onChangeUserRole,
  onChangeUserSvip,
  onSwitchUserId,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-purple-500/40 rounded-2xl p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <div className="flex items-center gap-2">
            <ShieldAlert className="w-5 h-5 text-purple-400" />
            <h3 className="text-white font-bold text-sm">مصفوفة الصلاحيات والرتب</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-4 space-y-3">
          <div>
            <label className="text-xs text-slate-400 block mb-1">الرتبة الإدارية:</label>
            <div className="grid grid-cols-2 gap-2">
              {(['super_admin', 'manager', 'supervisor', 'user'] as UserRole[]).map((r) => (
                <button
                  key={r}
                  onClick={() => onChangeUserRole(r)}
                  className={`py-1.5 px-2 rounded-lg text-xs font-bold ${
                    currentUser.role === r ? 'bg-purple-600 text-white' : 'bg-slate-800 text-slate-300'
                  }`}
                >
                  {r === 'super_admin' ? 'سوبر أدمن 👑' : r === 'manager' ? 'مدير 🛡️' : r === 'supervisor' ? 'مشرف ⚡' : 'مستخدم عادي'}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="text-xs text-slate-400 block mb-1">مستوى SVIP:</label>
            <div className="grid grid-cols-5 gap-1.5">
              {([0, 1, 3, 5, 7, 8, 9] as SvipLevel[]).map((lvl) => (
                <button
                  key={lvl}
                  onClick={() => onChangeUserSvip(lvl)}
                  className={`py-1 rounded-lg text-xs font-mono font-bold ${
                    currentUser.svip === lvl ? 'bg-amber-500 text-slate-950' : 'bg-slate-800 text-slate-300'
                  }`}
                >
                  {lvl === 0 ? '0' : `S${lvl}`}
                </button>
              ))}
            </div>
          </div>

          <div className="pt-2 border-t border-slate-800">
            <button
              onClick={() => onSwitchUserId(currentUser.id === '1' ? '999' : '1')}
              className="w-full py-2 bg-slate-800 hover:bg-slate-700 text-xs font-bold text-amber-300 rounded-xl"
            >
              تبديل هوية المستخدم: {currentUser.id === '1' ? 'ID: 1 (المالك)' : 'ID: 999 (عضو)'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
