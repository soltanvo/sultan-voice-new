import React, { useState } from 'react';
import { Crown, Sparkles, Gamepad2, Users, Shield, Mic, MicOff, Download, Radio, Music } from 'lucide-react';
import { VoicUser, Seat, UserRole, SvipLevel, GlobalWinTickerItem, CpRelationship } from './types/voic';
import { GlobalWinTicker } from './components/RoyalRoom/GlobalWinTicker';
import { SystemRoomsBar, SystemRoomType } from './components/RoyalRoom/SystemRoomsBar';
import { CinemaScreen } from './components/RoyalRoom/CinemaScreen';
import { SeatActionModal } from './components/RoyalRoom/SeatActionModal';
import { SvipEntryOverlay } from './components/RoyalRoom/SvipEntryOverlay';
import { CpModal } from './components/RoyalRoom/CpModal';
import { RoleManagementModal } from './components/Admin/RoleManagementModal';
import { GamesHubBottomSheet } from './components/Games/GamesHubBottomSheet';
import { SVIP_TIERS } from './utils/svipConfig';

export const App: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<VoicUser>({
    id: '1',
    name: 'سلطان العرب 👑',
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    role: 'super_admin',
    svip: 9,
    coins: 1500000,
    isMuted: false,
    isSpeaking: true,
  });

  const [currentRoom, setCurrentRoom] = useState<SystemRoomType>('main_room');
  const [activeTab, setActiveTab] = useState<'normal' | 'cinema'>('normal');
  const [selectedSeat, setSelectedSeat] = useState<Seat | null>(null);
  const [isRoleModalOpen, setIsRoleModalOpen] = useState(false);
  const [isGamesHubOpen, setIsGamesHubOpen] = useState(false);
  const [isCpModalOpen, setIsCpModalOpen] = useState(false);
  const [svipSelectorOpen, setSvipSelectorOpen] = useState(false);
  const [currentEntry, setCurrentEntry] = useState<{
    userName: string;
    avatar: string;
    level: SvipLevel;
    role?: string;
  } | null>(null);

  // Initialize 30 seats
  const [seats, setSeats] = useState<Seat[]>(() => {
    return Array.from({ length: 30 }, (_, index) => ({
      index,
      user: index === 0 ? {
        id: '1',
        name: 'سلطان العرب 👑',
        avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        role: 'super_admin',
        svip: 9,
        coins: 1500000,
        isMuted: false,
        isSpeaking: true,
      } : null,
      isLocked: false,
      isMuted: false,
    }));
  });

  const [recentWins] = useState<GlobalWinTickerItem[]>([
    {
      id: '1',
      winnerName: 'سلطان العرب',
      giftName: 'تايغر سلوت 🐯',
      coinsWon: 500000,
      multiplier: 50,
      timestamp: Date.now(),
    },
  ]);

  const [cpRel] = useState<CpRelationship>({
    partner1: {
      id: currentUser.id,
      name: currentUser.name,
      avatar: currentUser.avatar,
      svip: currentUser.svip,
    },
    partner2: {
      id: '2',
      name: 'الأميرة نور 🌸',
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      svip: 5,
    },
    level: 9,
    points: 99999,
    title: 'عرش الحب الملكي ❤️',
  });

  const handleTakeSeat = (index: number) => {
    setSeats((prev) =>
      prev.map((s) => (s.index === index ? { ...s, user: currentUser } : s))
    );
    setSelectedSeat(null);
  };

  const handleLeaveSeat = (index: number) => {
    setSeats((prev) =>
      prev.map((s) => (s.index === index ? { ...s, user: null } : s))
    );
    setSelectedSeat(null);
  };

  const handleToggleMute = (index: number) => {
    setSeats((prev) =>
      prev.map((s) => (s.index === index ? { ...s, isMuted: !s.isMuted } : s))
    );
  };

  const handleToggleLock = (index: number) => {
    setSeats((prev) =>
      prev.map((s) => (s.index === index ? { ...s, isLocked: !s.isLocked } : s))
    );
  };

  const handleKickSeat = (index: number) => {
    setSeats((prev) =>
      prev.map((s) => (s.index === index ? { ...s, user: null } : s))
    );
    setSelectedSeat(null);
  };

  const triggerTestEntry = (level: SvipLevel) => {
    setCurrentEntry({
      userName: currentUser.name,
      avatar: currentUser.avatar,
      level,
      role: currentUser.role,
    });
  };

  return (
    <div className="min-h-screen bg-slate-950 text-white flex flex-col font-sans select-none" dir="rtl">
      {/* Top Banner / Ticker */}
      <GlobalWinTicker recentWins={recentWins} onSimulateWin={() => {}} />

      {/* Header */}
      <header className="px-4 py-3 bg-slate-900/90 border-b border-amber-500/20 backdrop-blur-md flex items-center justify-between sticky top-0 z-40">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-amber-600 to-yellow-400 p-0.5 shadow-lg shadow-amber-500/20">
            <div className="w-full h-full bg-slate-950 rounded-[14px] flex items-center justify-center">
              <Crown className="w-5 h-5 text-amber-400" />
            </div>
          </div>
          <div>
            <h1 className="font-black text-base tracking-wide bg-gradient-to-r from-amber-200 via-yellow-400 to-amber-500 bg-clip-text text-transparent">
              Sultan Voic 👑
            </h1>
            <p className="text-[11px] text-amber-300/70 font-medium">الغرفة الملكية 30 مقعداً • LiveKit HD</p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="flex items-center gap-2">
          <a
            href="/sultan_voic_app.zip"
            download
            className="flex items-center gap-1.5 px-3 py-1.5 bg-gradient-to-r from-emerald-600 to-teal-500 hover:from-emerald-500 hover:to-teal-400 text-white text-xs font-bold rounded-xl shadow-md transition-all active:scale-95"
          >
            <Download className="w-3.5 h-3.5" />
            <span>تحميل الكود النظيف (ZIP)</span>
          </a>

          <button
            onClick={() => setIsRoleModalOpen(true)}
            className="px-2.5 py-1.5 bg-amber-500/20 border border-amber-500/40 text-amber-300 rounded-xl text-xs font-bold hover:bg-amber-500/30 transition-all flex items-center gap-1"
          >
            <Shield className="w-3.5 h-3.5" />
            <span>لوحة الأدمن</span>
          </button>
        </div>
      </header>

      {/* System Rooms Tabs */}
      <SystemRoomsBar
        currentRoom={currentRoom}
        onSelectRoom={setCurrentRoom}
        isSupervisorOrAdmin={currentUser.role === 'super_admin' || currentUser.role === 'admin'}
      />

      {/* Mode Switcher: 30 Seats vs Cinema */}
      <div className="max-w-4xl mx-auto w-full px-4 pt-2 flex items-center justify-between">
        <div className="flex bg-slate-900 border border-slate-800 rounded-2xl p-1 gap-1 text-xs font-bold">
          <button
            onClick={() => setActiveTab('normal')}
            className={`px-3 py-1.5 rounded-xl transition-all flex items-center gap-1.5 ${
              activeTab === 'normal'
                ? 'bg-amber-500 text-slate-950 shadow-md shadow-amber-500/20'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Users className="w-3.5 h-3.5" />
            <span>مجلس 30 مقعداً</span>
          </button>
          <button
            onClick={() => setActiveTab('cinema')}
            className={`px-3 py-1.5 rounded-xl transition-all flex items-center gap-1.5 ${
              activeTab === 'cinema'
                ? 'bg-amber-500 text-slate-950 shadow-md shadow-amber-500/20'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Radio className="w-3.5 h-3.5" />
            <span>وضع السينما و CP</span>
          </button>
        </div>

        {/* User Info Capsule */}
        <div className="flex items-center gap-2 bg-slate-900/80 border border-amber-500/30 rounded-2xl px-3 py-1.5">
          <span className={`text-[10px] px-2 py-0.5 rounded-lg font-black ${SVIP_TIERS[currentUser.svip]?.badgeBg || ''}`}>
            SVIP {currentUser.svip}
          </span>
          <span className="text-xs font-bold text-amber-300 font-mono">
            {currentUser.coins.toLocaleString()} كوين 🪙
          </span>
        </div>
      </div>

      {/* Main Body */}
      <main className="flex-1 max-w-4xl mx-auto w-full p-4 flex flex-col justify-between">
        {activeTab === 'cinema' ? (
          <CinemaScreen
            cinemaSeats={seats.slice(0, 10)}
            onSelectSeat={(seat) => setSelectedSeat(seat)}
            cpRelationship={cpRel}
            onOpenCpModal={() => setIsCpModalOpen(true)}
          />
        ) : (
          <div className="grid grid-cols-5 sm:grid-cols-6 gap-3 py-4">
            {seats.map((seat) => (
              <div
                key={seat.index}
                onClick={() => setSelectedSeat(seat)}
                className={`relative aspect-square rounded-2xl border flex flex-col items-center justify-center p-2 cursor-pointer transition-all hover:scale-105 active:scale-95 ${
                  seat.user
                    ? 'bg-gradient-to-b from-amber-950/40 to-slate-900/80 border-amber-500/50 shadow-lg shadow-amber-500/10'
                    : seat.isLocked
                    ? 'bg-slate-900/40 border-red-500/30 opacity-70'
                    : 'bg-slate-900/60 border-slate-800 hover:border-amber-500/40'
                }`}
              >
                {seat.user ? (
                  <>
                    <div className="relative">
                      <img
                        src={seat.user.avatar}
                        alt={seat.user.name}
                        className="w-10 h-10 sm:w-12 sm:h-12 rounded-full border-2 border-amber-400 object-cover"
                      />
                      {seat.user.isSpeaking && (
                        <div className="absolute inset-0 rounded-full border-2 border-emerald-400 animate-ping pointer-events-none" />
                      )}
                    </div>
                    <span className="text-[10px] font-bold text-amber-200 mt-1 truncate max-w-full">
                      {seat.user.name}
                    </span>
                    <span className="text-[9px] text-emerald-400 font-mono">مايك {seat.index + 1}</span>
                  </>
                ) : (
                  <>
                    <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-slate-800/80 border border-slate-700 flex items-center justify-center text-slate-400 font-bold text-xs">
                      {seat.isLocked ? '🔒' : seat.index + 1}
                    </div>
                    <span className="text-[10px] text-slate-400 mt-1">
                      {seat.isLocked ? 'مقفل' : 'فارغ'}
                    </span>
                  </>
                )}
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Bottom Bar: Action buttons & Games Hub */}
      <footer className="sticky bottom-0 bg-slate-900/95 border-t border-amber-500/20 backdrop-blur-md px-4 py-3 flex items-center justify-between z-40">
        <div className="flex items-center gap-2">
          <button
            onClick={() => setCurrentUser((u) => ({ ...u, isMuted: !u.isMuted }))}
            className={`w-11 h-11 rounded-2xl flex items-center justify-center transition-all ${
              currentUser.isMuted
                ? 'bg-red-500/20 border border-red-500/40 text-red-400'
                : 'bg-emerald-500/20 border border-emerald-500/40 text-emerald-400 animate-pulse'
            }`}
          >
            {currentUser.isMuted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
          </button>

          <button
            onClick={() => triggerTestEntry(currentUser.svip)}
            className="px-3 py-2 bg-gradient-to-r from-amber-500/20 to-yellow-500/20 border border-amber-500/40 text-amber-300 rounded-xl text-xs font-bold flex items-center gap-1.5 hover:bg-amber-500/30 transition-all"
          >
            <Sparkles className="w-4 h-4 text-amber-400" />
            <span>عرض دخول الـ SVIP</span>
          </button>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsGamesHubOpen(true)}
            className="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-purple-600 via-pink-600 to-amber-500 text-white font-black text-xs rounded-xl shadow-lg shadow-purple-500/20 hover:opacity-95 transition-all active:scale-95"
          >
            <Gamepad2 className="w-4 h-4" />
            <span>صالة الألعاب الملكية 🐯</span>
          </button>
        </div>
      </footer>

      {/* Modals */}
      <SeatActionModal
        seat={selectedSeat}
        currentUser={currentUser}
        onClose={() => setSelectedSeat(null)}
        onTakeSeat={handleTakeSeat}
        onLeaveSeat={handleLeaveSeat}
        onToggleMute={handleToggleMute}
        onToggleLock={handleToggleLock}
        onKickSeat={handleKickSeat}
        onOpenGiftToSeat={() => {}}
      />

      <RoleManagementModal
        isOpen={isRoleModalOpen}
        onClose={() => setIsRoleModalOpen(false)}
        currentUser={currentUser}
        onChangeUserRole={(role: UserRole) => setCurrentUser((u) => ({ ...u, role }))}
        onChangeUserSvip={(svip: SvipLevel) => setCurrentUser((u) => ({ ...u, svip }))}
        onSwitchUserId={(newId: string) => setCurrentUser((u) => ({ ...u, id: newId }))}
      />

      <GamesHubBottomSheet
        isOpen={isGamesHubOpen}
        onClose={() => setIsGamesHubOpen(false)}
        onOpenTigerSlot={() => {}}
        onOpenDragonTreasure={() => {}}
        onOpenGreedyBox={() => {}}
        onOpenOfficialSuite={() => {}}
        userCoins={currentUser.coins}
      />

      <CpModal
        isOpen={isCpModalOpen}
        onClose={() => setIsCpModalOpen(false)}
        cpRelationship={cpRel}
        onSendLoveGift={() => {}}
        onTriggerCpWelcome={() => {}}
      />

      <SvipEntryOverlay
        currentEntry={currentEntry}
        onDismiss={() => setCurrentEntry(null)}
        onTriggerTestEntry={triggerTestEntry}
        showSelectorModal={svipSelectorOpen}
        setShowSelectorModal={setSvipSelectorOpen}
      />
    </div>
  );
};

export default App;
