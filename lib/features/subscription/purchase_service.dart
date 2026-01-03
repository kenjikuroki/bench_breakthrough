
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; // Add to pubspec first
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/app_config.dart';
import '../settings/settings_provider.dart';

part 'purchase_service.g.dart';

@Riverpod(keepAlive: true)
class PurchaseService extends _$PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product ID (Replace with your actual ID)
  static const String _premiumProductId = 'app.bench_breakthrough.premium_unlock'; 

  @override
  Future<void> build() async {
    // 課金無効モード（テスト用）なら何もしない
    if (!AppConfig.isBillingEnabled) {
      debugPrint('[PurchaseService] Billing is DISABLED. Mock mode.');
      return;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[PurchaseService] Store is not available');
      return;
    }

    // 購買ストリームの監視開始
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseData,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('[PurchaseService] Error: $error');
      },
    );
    
    // 復元処理（起動時にチェック）は行わない
    // await _iap.restorePurchases();
  }

  /// 課金開始
  Future<void> buyPremium() async {
    // 課金無効モードなら即座にプレミアム付与（デバッグ用）
    if (!AppConfig.isBillingEnabled) {
      debugPrint('[PurchaseService] Mock purchase successful.');
      await ref.read(isPremiumProvider.notifier).setPremium(true);
      return;
    }

    final available = await _iap.isAvailable();
    if (!available) return;

    final response = await _iap.queryProductDetails({_premiumProductId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[PurchaseService] Product not found: ${_premiumProductId}');
      // エラー処理が必要ならここで
    }
    
    if (response.productDetails.isEmpty) return;

    final productDetails = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[PurchaseService] Buy error: $e');
    }
  }

  /// 購買データ更新時の処理
  Future<void> _onPurchaseData(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 保留中
        debugPrint('[PurchaseService] Purchase pending...');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('[PurchaseService] Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          // 成功 or 復元
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
             // プレミアム権限付与
             await ref.read(isPremiumProvider.notifier).setPremium(true);
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // ここでレシート検証サーバーに問い合わせるのが本来のベストプラクティス
    // 今回は簡易的に true を返す (クライアント完結)
    return true;
  }
  
  /// 復元ボタン用
  Future<void> restore() async {
     if (!AppConfig.isBillingEnabled) {
       // デバッグモードでの復元？まあオンにするだけでいいか
       await ref.read(isPremiumProvider.notifier).setPremium(true);
       return;
     }
     await _iap.restorePurchases();
  }
}
