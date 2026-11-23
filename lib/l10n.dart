import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interface language: Indonesian ('id', the default) or English ('en').
/// Screens write their text in English and pass it through [tr]; [_id] holds the Indonesian.
class AppLanguage {
  static String code = 'id';

  static bool get indonesian => code == 'id';
}

/// Translates [en] into the current language. `{name}` blanks are filled from [args].
String tr(String en, [Map<String, Object> args = const {}]) {
  var text = AppLanguage.indonesian ? (_id[en] ?? en) : en;
  args.forEach((key, value) => text = text.replaceAll('{$key}', '$value'));
  return text;
}

const _monthsId = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
const _monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _daysId = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// "28 Oktober 2026" / "28 October 2026"
String longDate(DateTime date) => '${date.day} ${(AppLanguage.indonesian ? _monthsId : _monthsEn)[date.month - 1]} ${date.year}';

/// "Selasa, 24 Nov" / "Tuesday, 24 Nov"
String weekdayDate(DateTime date) => '${(AppLanguage.indonesian ? _daysId : _daysEn)[date.weekday - 1]}, ${date.day} ${shortMonth(date.month)}';

/// "Agu" / "Aug"
String shortMonth(int month) {
  final name = (AppLanguage.indonesian ? _monthsId : _monthsEn)[month - 1];
  return name.substring(0, 3);
}

/// Where the chosen language is remembered between launches.
abstract class LanguagePrefs {
  Future<String?> read();
  Future<void> write(String value);
}

class SecureLanguagePrefs implements LanguagePrefs {
  SecureLanguagePrefs({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'calora_language';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}

const _id = {
  // Navigation
  'Home': 'Beranda',
  'Catering': 'Katering',
  'Activity': 'Aktivitas',
  'Other': 'Lainnya',
  'Food photo': 'Foto makanan',

  // Home
  'Hello 👋': 'Halo 👋',
  'Hello, {name} 👋': 'Halo, {name} 👋',
  'Keep your nutrition on track today!': 'Semangat menjaga nutrisimu hari ini!',
  'Notifications': 'Notifikasi',
  'No notifications yet': 'Belum ada notifikasi',
  "Pull down to load today's data.": 'Tarik ke bawah untuk memuat data hari ini.',
  "TOMORROW'S CATERING STATUS": 'STATUS KATERING BESOK',
  'Calories left': 'Sisa kalori',
  'kcal over': 'kcal berlebih',
  'kcal left': 'kcal tersisa',
  'Carbs': 'Karbohidrat',
  'Fat': 'Lemak',
  'Sugar': 'Gula',
  'Sodium': 'Natrium',
  "TOMORROW'S MENU": 'MENU BESOK',
  'No menu yet': 'Belum ada menu',
  "Tomorrow's menu appears once a catering package is active.": 'Menu besok muncul setelah paket catering aktif.',
  'Lunch · ': 'Makan siang · ',
  'Carbs {n}g': 'Karbo {n}g',
  'Fat {n}g': 'Lemak {n}g',

  // Catering
  'CATERING': 'KATERING',
  'Swap tokens for weekly menu packages': 'Tukar token dengan paket menu mingguan',
  'MY TOKEN BALANCE': 'SISA TOKEN SAYA',
  'Tokens': 'Token',
  '{n} Tokens': '{n} Token',
  '7-day packages from 40 Tokens': 'Paket 7 hari mulai 40 Token',
  'ACTIVE SUBSCRIPTION': 'LANGGANAN AKTIF',
  'SUBSCRIPTION ENDED': 'LANGGANAN BERAKHIR',
  'Ends on': 'Berakhir pada',
  '{n} days left': 'Sisa {n} hari',
  'Redeem {n} Tokens': 'Tukarkan {n} Token',
  '7-DAY PACKAGE CATALOG': 'KATALOG PAKET 7 HARI',
  'AVAILABLE MENUS': 'MENU YANG TERSEDIA',
  'Loading menus…': 'Memuat menu…',
  'No active menus yet.': 'Belum ada menu aktif.',
  'BREAKFAST': 'SARAPAN',
  'LUNCH': 'MAKAN SIANG',
  'DINNER': 'MAKAN MALAM',
  'SNACK': 'CAMILAN',
  'Package 1': 'Paket 1',
  'Package 2': 'Paket 2',
  'Healthy Weight Loss': 'Turun Berat Badan Sehat',
  'High Protein Muscle Building': 'Tinggi Protein Bentuk Otot',
  'Save 4%': 'Hemat 4%',
  'Best value! 8% off': 'Paling Hemat! Diskon 8%',
  'BEST VALUE': 'PALING HEMAT',
  'TOP UP TOKENS': 'TOP UP TOKEN',
  'Tokens are redeemed for weekly menu packages. Bigger packs cost less per token.': 'Token dipakai untuk menukar paket menu mingguan. Paket lebih besar lebih hemat per token.',
  'Save {price}': 'Hemat {price}',
  'Balance after top up: {n} Tokens. Payment method: QRIS.': 'Saldo setelah top up: {n} Token. Metode bayar: QRIS.',
  'Pay {price}': 'Bayar {price}',
  'REDEEM TOKENS': 'TUKARKAN TOKEN',
  'Currently active until {date}.': 'Masa aktif saat ini sampai {date}.',
  'PACKAGE': 'PAKET',
  'DURATION': 'DURASI',
  '{n} kcal average per meal': '{n} kcal rata-rata per meal',
  '{n} Tokens/wk': '{n} Token/mgg',
  '1 week': '1 minggu',
  '{n} weeks': '{n} minggu',
  'Current token balance': 'Sisa Token Saat Ini',
  'Tokens needed': 'Token yang Dibutuhkan',
  'Balance after transaction': 'Sisa Setelah Transaksi',
  '{n} Tokens short': 'Kurang {n} Token',
  'Delivered to · Home': 'Dikirim ke · Rumah',
  'The new subscription ends on {date}. Change the address under Other. Not enough tokens; you will be taken to Top Up.':
      'Langganan baru berakhir pada {date}. Alamat diubah di Lainnya. Token belum cukup, Anda akan diarahkan ke Top Up.',
  'The new subscription ends on {date}. Change the address under Other. You have enough tokens for this.':
      'Langganan baru berakhir pada {date}. Alamat diubah di Lainnya. Token cukup untuk penukaran ini.',
  'Cancel': 'Batal',

  // Food
  'FOOD': 'MAKANAN',
  'Enter manually': 'Isi manual',
  'No meals yet. Use the camera button to log one.': 'Belum ada makanan. Pakai tombol kamera untuk mencatat.',
  'breakfast': 'sarapan',
  'lunch': 'makan siang',
  'dinner': 'makan malam',
  'snack': 'camilan',
  'Delete meal?': 'Hapus makanan ini?',
  'Keep': 'Jangan',
  'Delete': 'Hapus',

  // Log a meal
  'LOG A MEAL': 'CATAT MAKANAN',
  'Camera': 'Kamera',
  'Gallery': 'Galeri',
  'Meal': 'Makanan',
  'Category': 'Kategori',
  'Breakfast': 'Sarapan',
  'Lunch': 'Makan siang',
  'Dinner': 'Makan malam',
  'Snack': 'Camilan',
  'Calories': 'Kalori',
  'Carbs g': 'Karbohidrat g',
  'Fat g': 'Lemak g',
  'Sugar g': 'Gula g',
  'Sodium mg': 'Natrium mg',
  'Name and calories are required': 'Nama dan kalori wajib diisi',
  'Save meal': 'Simpan makanan',

  // Trends
  'TRENDS': 'TREN',
  'Weight kg': 'Berat kg',
  'Save weight': 'Simpan berat',
  'Weight must be between 30 and 350 kg': 'Berat harus antara 30 dan 350 kg',
  'Not enough weigh-ins for a trend': 'Data timbang belum cukup untuk tren',
  '{n} kg / week': '{n} kg / minggu',
  'Average {kcal} kcal · protein {protein} g': 'Rata-rata {kcal} kcal · protein {protein} g',
  'Logged {a} of {b} days · confidence {c}': 'Tercatat {a} dari {b} hari · keyakinan {c}',
  'LOW': 'RENDAH',
  'MEDIUM': 'SEDANG',
  'HIGH': 'TINGGI',
  'Activity energy {n} kcal/day': 'Energi aktivitas {n} kcal/hari',
  'Logging completeness {n}%': 'Kelengkapan catatan {n}%',

  // Workout
  'WORKOUT': 'LATIHAN',
  'SESSION': 'SESI',
  'Minutes': 'Menit',
  'Save session': 'Simpan sesi',
  'EXERCISE': 'GERAKAN',
  'Name': 'Nama',
  'Reps': 'Repetisi',
  'Save exercise': 'Simpan gerakan',
  'Enter the session length in minutes': 'Isi lama sesi dalam menit',
  'Enter an exercise name': 'Isi nama gerakan',
  'STRENGTH': 'KEKUATAN',
  '{n} min': '{n} mnt',

  // Profile
  'OTHER': 'LAINNYA',
  'Food log': 'Catatan makanan',
  'Trends': 'Tren',
  'APPEARANCE': 'TAMPILAN',
  'System': 'Sistem',
  'Light theme': 'Terang',
  'Dark theme': 'Gelap',
  'LANGUAGE': 'BAHASA',
  'PROFILE': 'PROFIL',
  'Height cm': 'Tinggi cm',
  'Age': 'Usia',
  'Sex': 'Jenis kelamin',
  'Goal': 'Tujuan',
  'Target weight kg': 'Berat target kg',
  'Rate kg per week': 'Laju kg per minggu',
  'Allergies': 'Alergi',
  'Disliked foods': 'Makanan yang tidak disukai',
  'Save profile': 'Simpan profil',
  'Profile saved': 'Profil disimpan',
  'Fill in weight, height, age, target, and rate': 'Isi berat, tinggi, usia, target, dan laju',
  'Check for updates': 'Periksa pembaruan',
  'Sign out': 'Keluar',
  'male': 'laki-laki',
  'female': 'perempuan',
  'sedentary': 'jarang bergerak',
  'light': 'ringan',
  'moderate': 'sedang',
  'active': 'aktif',
  'lose': 'turunkan berat',
  'maintain': 'pertahankan',
  'gain': 'naikkan berat',
  'none': 'tanpa preferensi',
  'pescatarian': 'pesketarian',

  // Sign-in
  'Email or username': 'Email atau username',
  'Show password': 'Tampilkan password',
  'Hide password': 'Sembunyikan password',
  'Forgot password?': 'Lupa Password?',
  'Reset password': 'Atur ulang password',
  '{feature} is not available yet': '{feature} belum tersedia',
  'Wrong username or password': 'Username atau password salah',
  'Sign in': 'Masuk',
  'Signing in…': 'Masuk…',
  'Continue as guest': 'Lanjut sebagai tamu',
  'Login with Google coming soon': 'Masuk dengan Google segera hadir',

  // Updates
  'Update available': 'Pembaruan tersedia',
  'Version {tag} is on GitHub. Install it now?': 'Versi {tag} tersedia di GitHub. Pasang sekarang?',
  'Later': 'Nanti',
  'Install': 'Pasang',
  'Downloading update': 'Mengunduh pembaruan',

  // Client and server messages
  'Sign in did not return a session': 'Masuk tidak mengembalikan sesi',
  'Image must be 5 MB or smaller': 'Gambar maksimal 5 MB',
  'Use a JPEG, PNG, or WebP photo': 'Gunakan foto JPEG, PNG, atau WebP',
  'Unexpected response': 'Respons tidak terduga',
  'Request failed': 'Permintaan gagal',
  'Authentication required': 'Silakan masuk terlebih dahulu',
  'Invalid credentials': 'Username atau password tidak valid',
  'Duplicate entry': 'Data sudah ada',
  'Meal name is required': 'Nama makanan wajib diisi',
  'Food entry not found': 'Catatan makanan tidak ditemukan',
  'Activity not found': 'Aktivitas tidak ditemukan',
  'Weight entry not found': 'Catatan berat tidak ditemukan',
  'Provide an image or a food description': 'Kirim foto atau deskripsi makanan',
  'Too many requests': 'Terlalu banyak permintaan',
  'Claude took too long to read the photo': 'Claude terlalu lama membaca foto',
  'Photo reader is busy; try again shortly': 'Pembaca foto sedang sibuk; coba lagi sebentar',
};
