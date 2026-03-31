import 'package:qi_app_refact/models/ss_filter_params.dart';
import 'config.dart';

class Endpoint {
  // Base URLs
  static const String base = Config.apiBase;
  static const String api = Config.apiUrl;

  // ─── Auth ──────────────────────────────────────────────────────────────
  static const String login = '$base/auth/login';
  static const String checkAndroidId = '$base/auth/id-cek';

  // ─── KPI ───────────────────────────────────────────────────────────────
  static String kpiAll = '$api/all-kpi';
  //static String barChartData = '$api/bar_chart_data?nrp=$nrp';

  // ─── FCM ───────────────────────────────────────────────────────────────
  static String saveToken(String nrp) => '$api/fcm/save_token?nrp=$nrp';
  static String getToken(String nrp) => '$api/fcm/get_token?nrp=$nrp';

  // ─── User ──────────────────────────────────────────────────────────────
  static const String register = '$base/auth/register';
  static String getProfile(String nrp) => '$api/user/profile?nrp=$nrp';

  // ─── Suggestion System (SS) ─────────────────────────────────────────────
  static String ss(SSFilterParams params) {
    final kategori = params.kategori;
    final subKategori = params.subKategori;
    final opsi = params.opsiTambahan;

    if (subKategori == 'plt2') {
      return "$api/ss-staff-plt2";
    } else if (subKategori == 'zero') {
      return "$api/ss-zero-mech-crew/$opsi";
    } else if (subKategori == '<5') {
      return "$api/ss-mech-5/$opsi";
    } else {
      return "$api/ss-$kategori/$subKategori";
    }
  }
}
