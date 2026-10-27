import React from 'react';
import { X, Lock, Download, AlertTriangle } from 'lucide-react';

interface ForcedUpdateModalProps {
  isOpen: boolean;
  onClose: () => void;
  isSimulatedLockActive: boolean;
  setIsSimulatedLockActive: (active: boolean) => void;
  onSelectAnimatedAvatar: (url: string) => void;
  onSelectAnimatedWallpaper?: (url: string) => void;
}


export const ForcedUpdateModal: React.FC<ForcedUpdateModalProps> = ({
  isOpen,
  onClose,
  isSimulatedLockActive,
  setIsSimulatedLockActive,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-gradient-to-b from-red-950 via-slate-900 to-black border-2 border-red-500/60 rounded-3xl p-6 shadow-2xl text-center">
        <div className="w-16 h-16 rounded-full bg-red-500/20 border-2 border-red-500 mx-auto flex items-center justify-center mb-4 animate-bounce">
          <AlertTriangle className="w-8 h-8 text-red-400" />
        </div>

        <h3 className="text-white font-black text-lg">تحديث إمبراطوري إجباري! 👑</h3>
        <p className="text-xs text-red-200/80 my-2">
          يتوفر إصدار جديد v2.0.0 يتضمن نظام الهدايا السينمائية والكرافتة السحرية. يجب التحديث للمتابعة.
        </p>

        <div className="my-4 space-y-2">
          <a
            href="/sultan_voic_flutter_github_ready.zip"
            download
            className="w-full py-3 bg-gradient-to-r from-red-600 via-amber-500 to-yellow-400 text-slate-950 font-black text-xs rounded-xl shadow-lg flex items-center justify-center gap-2"
          >
            <Download className="w-4 h-4" />
            <span>تحميل التحديث الجديد (APK / ZIP)</span>
          </a>

          <button
            onClick={() => {
              setIsSimulatedLockActive(false);
              onClose();
            }}
            className="w-full py-2 bg-slate-800 hover:bg-slate-700 text-white text-xs font-bold rounded-xl"
          >
            إغلاق شاشة التنبيه مؤقتاً
          </button>
        </div>
      </div>
    </div>
  );
};
