import React, { useState } from 'react';
import { X, Music2, Volume2, Mic, MicOff, Radio, Play, Pause } from 'lucide-react';

interface AudioMixerModalProps {
  isOpen: boolean;
  onClose: () => void;
  isMyMicMuted: boolean;
  onToggleMic: () => void;
  onBroadcastMixerStatus: (streaming: boolean, title: string) => void;
}

export const AudioMixerModal: React.FC<AudioMixerModalProps> = ({
  isOpen,
  onClose,
  isMyMicMuted,
  onToggleMic,
  onBroadcastMixerStatus,
}) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [trackTitle, setTrackTitle] = useState('شيلات وأغاني طرب ملكية');
  const [musicVolume, setMusicVolume] = useState(80);

  if (!isOpen) return null;

  const togglePlay = () => {
    const nextState = !isPlaying;
    setIsPlaying(nextState);
    onBroadcastMixerStatus(nextState, trackTitle);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-slate-900 border border-emerald-500/40 rounded-2xl p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <div className="flex items-center gap-2">
            <Music2 className="w-5 h-5 text-emerald-400" />
            <h3 className="text-white font-bold text-sm">ميكسر الصوت والموسيقى</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="my-4 space-y-4">
          <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/60">
            <div className="flex items-center justify-between text-xs mb-2">
              <span className="text-white font-bold">{trackTitle}</span>
              <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${isPlaying ? 'bg-emerald-500 text-slate-950 animate-pulse' : 'bg-slate-700 text-slate-400'}`}>
                {isPlaying ? 'بث مباشر نشط' : 'متوقف'}
              </span>
            </div>
            <button
              onClick={togglePlay}
              className={`w-full py-2 rounded-lg text-xs font-bold flex items-center justify-center gap-2 ${
                isPlaying ? 'bg-red-600 text-white' : 'bg-emerald-500 text-slate-950'
              }`}
            >
              {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
              <span>{isPlaying ? 'إيقاف البث الموسيقي' : 'بدء تشغيل الميكسر في الغرفة'}</span>
            </button>
          </div>

          <div>
            <div className="flex justify-between text-xs text-slate-400 mb-1">
              <span>مستوى صوت الموسيقى</span>
              <span>{musicVolume}%</span>
            </div>
            <input
              type="range"
              min="0"
              max="100"
              value={musicVolume}
              onChange={(e) => setMusicVolume(Number(e.target.value))}
              className="w-full accent-emerald-400"
            />
          </div>

          <div className="pt-2 border-t border-slate-800 flex items-center justify-between">
            <span className="text-xs text-slate-400">حالة مايكك الشخصي:</span>
            <button
              onClick={onToggleMic}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 ${
                isMyMicMuted ? 'bg-red-500/20 text-red-400 border border-red-500/30' : 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
              }`}
            >
              {isMyMicMuted ? <MicOff className="w-3.5 h-3.5" /> : <Mic className="w-3.5 h-3.5" />}
              <span>{isMyMicMuted ? 'مايكك مكتوم' : 'مايكك شغال'}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
