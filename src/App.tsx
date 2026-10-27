import React, { useState } from 'react';
import { Crown, Sparkles, Gamepad2, Users, Shield, Mic, MicOff, Download, Radio, Trophy, Gift, LogOut } from 'lucide-react';
import { VoicUser, Seat, UserRole, SvipLevel, GlobalWinTickerItem, CpRelationship } from './types/voic';
import { GlobalWinTicker } from './components/RoyalRoom/GlobalWinTicker';
import { SystemRoomsBar, SystemRoomType } from './components/RoyalRoom/SystemRoomsBar';
import { CinemaScreen } from './components/RoyalRoom/CinemaScreen';
import { SeatActionModal } from './components/RoyalRoom/SeatActionModal';
import { SvipEntryOverlay } from './components/RoyalRoom/SvipEntryOverlay';
import { CpModal } from './components/RoyalRoom/CpModal';
import { RoleManagementModal } from './components/Admin/RoleManagementModal';
import { OfficialGamesModal, OfficialGameId } from './components/Games/OfficialGamesModal';
import { SVIP_TIERS } from './utils/svipConfig';

export const App: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<VoicUser>({
    id: '1',
    name: 'سلطان العرب 👑',
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    role: 'super_admin',
    svip: 9,
    coins: 150000,
    isMuted: false,
    isSpeaking: true,
  });

  const [currentRoom, setCurrentRoom] = useState<SystemRoomType>('main_room');
  const [activeTab, setActiveTab] = useState<'normal' | 'cinema'>('normal');
  const [selectedSeat, setSelectedSeat] = useState<Seat | null>(null);
  const [isRoleModalOpen, setIsRoleModalOpen] = useState(false);
  const [isOfficialGamesOpen, setIsOfficialGamesOpen] = useState(false);
  const [selectedOfficialGame, setSelectedOfficialGame] = useState<OfficialGameId>('slot_tiger');
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
        coins: 150000,
        isMuted: false,
        isSpeaking: true,
      } : index === 1 ? {
        id: '2',
        name: 'مدير المجلس 🛡️',
        avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        role: 'manager',
        svip: 6,
        coins: 80000,
        isMuted: false,
      } : index === 2 ? {
        id: '3',
        name: 'الأميرة نور 🌸',
        avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        role: 'supervisor',
        svip: 5,
        coins: 50000,
        isMuted: false,
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

  const throneSeat = seats[0];
  const vipSeats = seats.slice(1, 6);
  const guestSeats = seats.slice(6, 30);

  return (
    <div className="min-h-screen bg-slate-950 text-white flex flex-col font-sans select-none" dir="rtl">
      {/* Top Winning Ticker */}
      <GlobalWinTicker recentWins={recentWins} onSimulateWin={() => {}} />

      {/* Main Luxury Header */}
      <header className="px-4 py-3 bg-slate-900/90 border-b border-amber-500/20 backdrop-blur-md flex items-center justify-between sticky top-0 z-40">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-amber-600 via-yellow-400 to-amber-500 p-0.5 shadow-lg shadow-amber-500/20">
            <div className="w-full h-full bg-slate-950 rounded-[14px] flex items-center justify-center">
              <Crown className="w-5 h-5 text-amber-400 animate-pulse" />
            </div>
          </div>
          <div>
            <h1 className="font-black text-base tracking-wide bg-gradient-to-r from-amber-200 via-yellow-400 to-amber-500 bg-clip-text text-transparent">
              مجلس Sultan Voic الملكي 👑
            </h1>
            <div className="flex items-center gap-2 text-[11px] text-amber-300/80 font-medium">
              <span className="w-2 h-2 rounded-full bg-emerald-400 inline-block animate-ping" />
              <span>LiveKit WebRTC • 30 مقعداً نشطاً • متصل بـ Supabase</span>
            </div>
          </div>
        </div>

        {/* Action Pills */}
        <div className="flex items-center gap-2">
          {/* Real-time Coins Capsule */}
          <div
            onClick={() => setCurrentUser((u) => ({ ...u, coins: u.coins + 5000 }))}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-gradient-to-r from-amber-500/10 to-yellow-500/20 border border-amber-500/40 rounded-2xl cursor-pointer hover:bg-amber-500/20 transition-all"
            title="انقر لإضافة مكافأة كوينز"
          >
            <span className="text-sm">🪙</span>
            <span className="text-xs font-mono font-black text-amber-300">
              {currentUser.coins.toLocaleString()}
            </span>
            <span className="text-[10px] text-emerald-400 font-bold">+</span>
          </div>

          {/* Direct APK Download Button */}
          <a
            href="/sultan_voice_release.apk"
            download="sultan_voice_release.apk"
            className="flex items-center gap-1.5 px-3 py-1.5 bg-gradient-to-r from-amber-500 via-yellow-400 to-amber-600 hover:opacity-90 text-slate-950 text-xs font-black rounded-xl shadow-lg shadow-amber-500/20 transition-all active:scale-95"
          >
            <Download className="w-3.5 h-3.5" />
            <span>تحميل الـ APK الجاهز (86.7 MB) 📱</span>
          </a>

          {/* Download clean ZIP button */}
          <a
            href="/sultan_voic_app.zip"
            download
            className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-gradient-to-r from-emerald-600 to-teal-500 hover:from-emerald-500 hover:to-teal-400 text-white text-xs font-bold rounded-xl shadow-md transition-all active:scale-95"
          >
            <Download className="w-3.5 h-3.5" />
            <span>كود المشروع (ZIP)</span>
          </a>

          {/* Admin panel */}
          <button
            onClick={() => setIsRoleModalOpen(true)}
            className="px-2.5 py-1.5 bg-purple-500/20 border border-purple-500/40 text-purple-300 rounded-xl text-xs font-bold hover:bg-purple-500/30 transition-all flex items-center gap-1"
          >
            <Shield className="w-3.5 h-3.5" />
            <span>لوحة الإدارة</span>
          </button>
        </div>
      </header>

      {/* System Rooms Tabs */}
      <SystemRoomsBar
        currentRoom={currentRoom}
        onSelectRoom={setCurrentRoom}
        isSupervisorOrAdmin={currentUser.role === 'super_admin' || currentUser.role === 'admin'}
      />

      {/* Mode Switcher: 30 Seats vs Cinema & CP */}
      <div className="max-w-4xl mx-auto w-full px-4 pt-2 flex items-center justify-between">
        <div className="flex bg-slate-900 border border-slate-800 rounded-2xl p-1 gap-1 text-xs font-bold">
          <button
            onClick={() => setActiveTab('normal')}
            className={`px-3 py-1.5 rounded-xl transition-all flex items-center gap-1.5 ${
              activeTab === 'normal'
                ? 'bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-950 font-black shadow-md shadow-amber-500/20'
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
                ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white font-black shadow-md shadow-purple-500/20'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Radio className="w-3.5 h-3.5" />
            <span>السينما وعرش CP ❤️</span>
          </button>
        </div>

        {/* User VIP Badge */}
        <div className="flex items-center gap-2">
          <button
            onClick={() => triggerTestEntry(currentUser.svip)}
            className={`text-xs px-2.5 py-1 rounded-xl font-black transition-transform hover:scale-105 active:scale-95 ${SVIP_TIERS[currentUser.svip]?.badgeBg || ''}`}
          >
            👑 SVIP {currentUser.svip}
          </button>
        </div>
      </div>

      {/* Main Screen Content */}
      <main className="flex-1 max-w-4xl mx-auto w-full p-4 flex flex-col justify-between">
        {activeTab === 'cinema' ? (
          <CinemaScreen
            cinemaSeats={seats.slice(0, 10)}
            onSelectSeat={(seat) => setSelectedSeat(seat)}
            cpRelationship={cpRel}
            onOpenCpModal={() => setIsCpModalOpen(true)}
          />
        ) : (
          <div className="flex flex-col gap-4">
            {/* 1. Throne Section (#1) */}
            <div className="w-full bg-gradient-to-b from-amber-950/40 via-slate-900/80 to-slate-950 border-2 border-amber-500/50 rounded-3xl p-4 flex flex-col items-center justify-center shadow-xl shadow-amber-500/10 relative overflow-hidden">
              <div className="absolute top-2 right-4 px-2.5 py-0.5 rounded-full bg-amber-500/20 border border-amber-500/40 text-[10px] text-amber-300 font-bold flex items-center gap-1">
                <Crown className="w-3 h-3 text-amber-400" />
                <span>عرش المالك الإمبراطوري #1</span>
              </div>

              <div
                onClick={() => setSelectedSeat(throneSeat)}
                className="cursor-pointer flex flex-col items-center mt-2 group"
              >
                <div className="relative">
                  <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-amber-400 via-yellow-300 to-amber-600 p-1 shadow-lg shadow-amber-500/30 group-hover:scale-105 transition-transform">
                    <img
                      src={throneSeat.user?.avatar || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150'}
                      alt="Throne Owner"
                      className="w-full h-full rounded-full object-cover border-2 border-slate-950"
                    />
                  </div>
                  <div className="absolute -bottom-1 -right-1 bg-amber-500 text-slate-950 text-[10px] font-black px-1.5 py-0.5 rounded-full shadow">
                    👑 مالك
                  </div>
                </div>
                <span className="font-black text-sm text-amber-200 mt-2">
                  {throneSeat.user?.name || 'المالك'}
                </span>
                <span className="text-[10px] text-emerald-400 font-mono">مايك المالك الرئيسي</span>
              </div>
            </div>

            {/* 2. VIP Row (#2 to #6) */}
            <div className="bg-slate-900/60 border border-purple-500/30 rounded-2xl p-3">
              <div className="flex items-center gap-1.5 text-xs text-purple-300 font-bold mb-2">
                <Sparkles className="w-3.5 h-3.5 text-purple-400" />
                <span>مقاعد النواب ومجلس الإدارة (#2 - #6)</span>
              </div>
              <div className="grid grid-cols-5 gap-2">
                {vipSeats.map((seat) => (
                  <div
                    key={seat.index}
                    onClick={() => setSelectedSeat(seat)}
                    className={`aspect-square rounded-2xl border p-2 flex flex-col items-center justify-center cursor-pointer transition-all hover:scale-105 active:scale-95 ${
                      seat.user
                        ? 'bg-gradient-to-b from-purple-950/50 to-slate-900 border-purple-500/50 shadow-md'
                        : 'bg-slate-900/50 border-slate-800 hover:border-purple-500/30'
                    }`}
                  >
                    {seat.user ? (
                      <>
                        <img
                          src={seat.user.avatar}
                          alt={seat.user.name}
                          className="w-9 h-9 rounded-full border-2 border-purple-400 object-cover"
                        />
                        <span className="text-[10px] font-bold text-purple-200 mt-1 truncate max-w-full">
                          {seat.user.name}
                        </span>
                        <span className="text-[8px] text-purple-300 font-mono">#{seat.index + 1}</span>
                      </>
                    ) : (
                      <>
                        <div className="w-8 h-8 rounded-full bg-slate-800 border border-purple-500/30 flex items-center justify-center text-xs font-bold text-slate-400">
                          {seat.index + 1}
                        </div>
                        <span className="text-[9px] text-slate-500 mt-1">شاغر</span>
                      </>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* 3. Guest Grid (#7 to #30) */}
            <div className="bg-slate-900/40 border border-slate-800 rounded-2xl p-3">
              <div className="flex items-center gap-1.5 text-xs text-slate-400 font-bold mb-2">
                <Users className="w-3.5 h-3.5 text-amber-400" />
                <span>مقاعد الضيوف الملكية (#7 - #30)</span>
              </div>
              <div className="grid grid-cols-6 gap-2">
                {guestSeats.map((seat) => (
                  <div
                    key={seat.index}
                    onClick={() => setSelectedSeat(seat)}
                    className={`aspect-square rounded-2xl border p-1.5 flex flex-col items-center justify-center cursor-pointer transition-all hover:scale-105 active:scale-95 ${
                      seat.user
                        ? 'bg-gradient-to-b from-slate-800 to-slate-900 border-amber-500/40'
                        : 'bg-slate-900/40 border-slate-800/80 hover:border-slate-700'
                    }`}
                  >
                    {seat.user ? (
                      <>
                        <img
                          src={seat.user.avatar}
                          alt={seat.user.name}
                          className="w-8 h-8 rounded-full border border-amber-400 object-cover"
                        />
                        <span className="text-[9px] font-bold text-slate-200 mt-0.5 truncate max-w-full">
                          {seat.user.name}
                        </span>
                      </>
                    ) : (
                      <>
                        <div className="w-7 h-7 rounded-full bg-slate-800/60 border border-slate-700/60 flex items-center justify-center text-[11px] font-bold text-slate-500">
                          {seat.index + 1}
                        </div>
                        <span className="text-[8px] text-slate-500 mt-0.5">متاح</span>
                      </>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Bottom Floating Control Dock */}
      <footer className="sticky bottom-0 bg-slate-900/95 border-t border-amber-500/20 backdrop-blur-md px-4 py-3 flex items-center justify-between z-40">
        <div className="flex items-center gap-2">
          {/* Mic Button */}
          <button
            onClick={() => setCurrentUser((u) => ({ ...u, isMuted: !u.isMuted }))}
            className={`w-11 h-11 rounded-2xl flex items-center justify-center transition-all ${
              currentUser.isMuted
                ? 'bg-red-500/20 border border-red-500/40 text-red-400'
                : 'bg-emerald-500/20 border border-emerald-500/40 text-emerald-400 shadow-md shadow-emerald-500/10'
            }`}
            title="كتم / تشغيل المايك"
          >
            {currentUser.isMuted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5 animate-pulse" />}
          </button>

          {/* SVIP Entrance Demo Button */}
          <button
            onClick={() => triggerTestEntry(currentUser.svip)}
            className="px-3 py-2 bg-gradient-to-r from-amber-500/20 to-yellow-500/20 border border-amber-500/40 text-amber-300 rounded-xl text-xs font-bold flex items-center gap-1.5 hover:bg-amber-500/30 transition-all"
          >
            <Sparkles className="w-4 h-4 text-amber-400" />
            <span>دخول SVIP 9</span>
          </button>
        </div>

        {/* 7 Official Games Launcher Button */}
        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsOfficialGamesOpen(true)}
            className="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-amber-500 via-yellow-400 to-amber-600 text-slate-950 font-black text-xs rounded-xl shadow-lg shadow-amber-500/20 hover:opacity-95 transition-all active:scale-95"
          >
            <Trophy className="w-4 h-4" />
            <span>صالة الألعاب (7 ألعاب) 🐯</span>
          </button>

          <button
            onClick={() => setIsCpModalOpen(true)}
            className="w-10 h-10 rounded-2xl bg-rose-500/20 border border-rose-500/40 text-rose-300 flex items-center justify-center hover:bg-rose-500/30 transition-all"
            title="عرش الحب CP"
          >
            ❤️
          </button>
        </div>
      </footer>

      {/* Seat Actions Modal */}
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

      {/* Role Management Modal */}
      <RoleManagementModal
        isOpen={isRoleModalOpen}
        onClose={() => setIsRoleModalOpen(false)}
        currentUser={currentUser}
        onChangeUserRole={(role: UserRole) => setCurrentUser((u) => ({ ...u, role }))}
        onChangeUserSvip={(svip: SvipLevel) => setCurrentUser((u) => ({ ...u, svip }))}
        onSwitchUserId={(newId: string) => setCurrentUser((u) => ({ ...u, id: newId }))}
      />

      {/* 7 Official Games Modal */}
      <OfficialGamesModal
        isOpen={isOfficialGamesOpen}
        onClose={() => setIsOfficialGamesOpen(false)}
        userCoins={currentUser.coins}
        initialGame={selectedOfficialGame}
        setUserCoins={(newCoins) => {
          if (typeof newCoins === 'function') {
            setCurrentUser((u) => ({ ...u, coins: newCoins(u.coins) }));
          } else {
            setCurrentUser((u) => ({ ...u, coins: newCoins }));
          }
        }}
      />

      {/* CP Relationship Modal */}
      <CpModal
        isOpen={isCpModalOpen}
        onClose={() => setIsCpModalOpen(false)}
        cpRelationship={cpRel}
        onSendLoveGift={() => {}}
        onTriggerCpWelcome={() => {}}
      />

      {/* SVIP Entrance Animation Overlay */}
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
