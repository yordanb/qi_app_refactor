import "package:qi_app_refact/models/ss_filter_params.dart";
import "config.dart";

class Endpoint {
  // Base URLs
  static final String base = AppConfig.apiBase;
  static final String api = AppConfig.apiUrl;

  // ─── Auth ──────────────────────────────────────────────────────────────
  static final String login = "$base/api/v1/auth/login";
  static final String checkAndroidId = "$base/api/v1/auth/id-cek";

  // ─── KPI ───────────────────────────────────────────────────────────────
  static String kpiAll = "$api/all-kpi";
  //static String barChartData = '$api/bar_chart_data?nrp=$nrp';

  // ─── FCM ───────────────────────────────────────────────────────────────
  static String saveToken(String nrp) => "$api/fcm/save_token?nrp=$nrp";
  static String getToken(String nrp) => "$api/fcm/get_token?nrp=$nrp";

  // ─── User ──────────────────────────────────────────────────────────────
  static final String register = "$base/auth/register";
  static String getProfile(String nrp) => "$api/user/profile?nrp=$nrp";

  // ─── Suggestion System (SS) ─────────────────────────────────────────────
  static String ss(SSFilterParams params) {
    final kategori = params.kategori;
    final subKategori = params.subKategori;
    final opsi = params.opsiTambahan;

    if (subKategori == "plt2") {
      return "$api/ss-staff-plt2";
    } else if (subKategori == "zero") {
      return "$api/ss-zero-mech-crew/$opsi";
    } else if (subKategori == "<5") {
      return "$api/ss-mech-5/$opsi";
    } else {
      return "$api/ss-$kategori/$subKategori";
    }
  }
}
