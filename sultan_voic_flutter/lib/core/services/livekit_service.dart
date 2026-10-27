import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveKitService extends ChangeNotifier {
  Room? _room;
  bool _isConnected = false;
  bool _isMicMuted = false;
  final Map<int, String> _seatUserMap = {}; // رقم المقعد -> معرف المستخدم
  final Set<String> _speakingParticipants = {};

  Room? get room => _room;
  bool get isConnected => _isConnected;
  bool get isMicMuted => _isMicMuted;
  Set<String> get speakingParticipants => _speakingParticipants;

  /// الاتصال بالغرفة باستخدام رمز LiveKit (Token 200)
  Future<bool> connectToRoyalRoom({
    required String liveKitUrl,
    required String token200,
  }) async {
    try {
      // التحقق من صلاحية الميكروفون
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('[Voic LiveKit] لم يتم منح صلاحية الميكروفون');
        return false;
      }

      final roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultAudioPublishOptions: const AudioPublishOptions(
          name: 'voic_audio_track',
          dtx: true,
        ),
      );

      _room = Room(roomOptions: roomOptions);

      // الاستماع لأحداث الغرفة والمتحدثين
      _room!.addListener(_onRoomEvent);

      await _room!.connect(liveKitUrl, token200);
      _isConnected = true;
      notifyListeners();
      debugPrint('[Voic LiveKit] تم الاتصال بنجاح بالغرفة الملكية (Token 200)');
      return true;
    } catch (e) {
      debugPrint('[Voic LiveKit Error]: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  void _onRoomEvent() {
    if (_room == null) return;
    
    // رصد المتحدثين النشطين
    _speakingParticipants.clear();
    for (final p in _room!.remoteParticipants.values) {
      if (p.isSpeaking) {
        _speakingParticipants.add(p.identity);
      }
    }
    if (_room!.localParticipant?.isSpeaking ?? false) {
      _speakingParticipants.add(_room!.localParticipant!.identity);
    }
    notifyListeners();
  }

  /// تبديل كتم/تشغيل المايك الخاص بك
  Future<void> toggleMicrophone() async {
    if (_room?.localParticipant == null) return;
    _isMicMuted = !_isMicMuted;
    await _room!.localParticipant!.setMicrophoneEnabled(!_isMicMuted);
    notifyListeners();
  }

  /// فصل الاتصال
  Future<void> disconnect() async {
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
    _isConnected = false;
    notifyListeners();
  }
}
