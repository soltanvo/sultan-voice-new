import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/room/models/gift.dart';

class GiftException implements Exception {
  final String message;
  const GiftException(this.message);

  @override
  String toString() => message;
}

class GiftService {
  final SupabaseClient _client;

  const GiftService(this._client);

  Future<List<Gift>> fetchGifts() async {
    final rows = await _client
        .from('gifts')
        .select('id, name, price_coins, icon_key')
        .order('price_coins');
    return rows.map(Gift.fromMap).toList();
  }

  Future<int> fetchCoins(String userId) async {
    final row = await _client.from('profiles').select('coins').eq('id', userId).maybeSingle();
    final coins = row?['coins'];
    if (coins is! int) throw const GiftException('تعذر قراءة رصيدك حالياً');
    return coins;
  }

  Future<int> sendGift({
    required String roomId,
    required int seatIndex,
    required Gift gift,
  }) async {
    try {
      final balance = await _client.rpc('send_gift', params: {
        'p_room_id': roomId,
        'p_seat_index': seatIndex,
        'p_gift_id': gift.id,
      });
      if (balance is! int) throw const GiftException('تعذر إتمام إرسال الهدية');
      return balance;
    } on PostgrestException catch (e) {
      throw GiftException(_mapError(e.message));
    }
  }

  String _mapError(String message) {
    if (message.contains('insufficient_coins')) return 'رصيدك غير كافٍ لإرسال هذه الهدية';
    if (message.contains('seat_empty')) return 'هذا المايك فارغ، لا يمكن إرسال الهدية له';
    if (message.contains('self_gift')) return 'لا يمكنك إرسال هدية لنفسك';
    if (message.contains('gift_not_found')) return 'هذه الهدية لم تعد متاحة';
    return 'تعذر إرسال الهدية، حاول مجدداً';
  }
}
