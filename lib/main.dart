import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Cart(cartProvider: CartProvider(), child: const UngDungSpaThuCung()));
}

class UngDungSpaThuCung extends StatefulWidget {
  const UngDungSpaThuCung({super.key});

  @override
  _UngDungSpaThuCungState createState() => _UngDungSpaThuCungState();
}

class _UngDungSpaThuCungState extends State<UngDungSpaThuCung> {
  final CartProvider _cartProvider = CartProvider();

  @override
  Widget build(BuildContext context) {
    return Cart(
      cartProvider: _cartProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spa Thú Cưng',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.lightBlueAccent,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
          ),
        ),
        home: const ManHinhDangNhap(),
      ),
    );
  }
}

class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({Key? key}) : super(key: key);

  @override
  _ManHinhDangNhapState createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _kiemTraDangNhap() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    bool success = await UserManager.loginUser(email, password);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ManHinhLoading()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email hoặc mật khẩu không đúng!"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://benhvienthuyanipet.com/wp-content/uploads/2021/12/petshop1.png',
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _kiemTraDangNhap,
              child: const Text(
                'Đăng Nhập',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(color: Colors.lightBlueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManHinhDangKy(),
                  ),
                );
              },
              child: const Text(
                'Đăng ký tài khoản',
                style: TextStyle(color: Colors.lightBlueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({Key? key}) : super(key: key);

  @override
  _ManHinhDangKyState createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ $message"), backgroundColor: Colors.red),
    );
  }

  /// Hiển thị thông báo thành công
  void _showSuccessMessage() {
    Fluttertoast.showToast(
      msg: "🎉 Đăng ký thành công!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
    ).hasMatch(email);
  }

  /// Xử lý đăng ký người dùng
  Future<void> _registerUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorMessage("⚠️ Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorMessage("⚠️ Email không hợp lệ!");
      return;
    }

    try {
      // Đăng ký người dùng
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Cập nhật tên người dùng
      await userCredential.user?.updateProfile(displayName: name);

      // Lưu thông tin người dùng vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'name': name, 'email': email});

      _showSuccessMessage();
      Navigator.pop(context);
    } catch (e) {
      _showErrorMessage("Đăng ký thất bại: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và Tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: _registerUser,
              child: const Text(
                'Đăng Ký',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ##############################################################################################

class ManHinhLoading extends StatefulWidget {
  const ManHinhLoading({super.key});

  @override
  _ManHinhLoadingState createState() => _ManHinhLoadingState();
}

class _ManHinhLoadingState extends State<ManHinhLoading> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManHinhChinh()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
            ),
            SizedBox(height: 20),
            Text('Đang tải...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// #############################################################################################

class UserManager {
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static auth.User? currentUser;

  // Đăng ký người dùng
  static Future<void> registerUser(String email, String password) async {
    try {
      auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      currentUser = userCredential.user; // Lưu thông tin người dùng hiện tại
    } catch (e) {
      print("Error registering user: $e");
      throw e; // Ném lỗi để xử lý ở nơi gọi
    }
  }

  // Đăng nhập người dùng
  static Future<bool> loginUser(String email, String password) async {
    try {
      auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      currentUser = userCredential.user; // Lưu thông tin người dùng hiện tại
      return true; // Đăng nhập thành công
    } catch (e) {
      print("Error logging in: $e");
      return false; // Đăng nhập thất bại
    }
  }

  // Đăng xuất người dùng
  static Future<void> logoutUser() async {
    await _auth.signOut();
    currentUser = null; // Đặt người dùng hiện tại thành null
  }
}

// ###################################################################################

class ManHinhChinh extends StatefulWidget {
  const ManHinhChinh({super.key});

  @override
  _ManHinhChinhState createState() => _ManHinhChinhState();
}

class _ManHinhChinhState extends State<ManHinhChinh> {
  int _mucDuocChon = 0;
  DateTime? selectedDate; // Biến để lưu ngày đã chọn

  static const List<Widget> _cacTrang = <Widget>[
    ManHinhDichVu(),
    ManHinhUuDai(),
    ManHinhGioHang(),
    ManHinhLichHen(), // Thêm màn hình lịch hẹn mới
    ManHinhHoTroKhachHang(),
    ManHinhCaiDat(),
  ];

  void _chonMuc(int index) {
    setState(() {
      _mucDuocChon = index;
    });
  }

  void _showDateDialog() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có ngày đặt lịch!')));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ngày Đặt Lịch'),
            content: Text(
              'Ngày bạn đã chọn: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                'https://benhvienthuyanipet.com/wp-content/uploads/2021/12/petshop1.png',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 30,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Spa Thú Cưng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _cacTrang[_mucDuocChon],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Dịch vụ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Ưu đãi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),

          BottomNavigationBarItem(
            // Thêm item mới cho lịch hẹn
            icon: Icon(Icons.calendar_today),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Hỗ trợ',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
        currentIndex: _mucDuocChon,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _chonMuc,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDateDialog,
        child: const Icon(Icons.notifications),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }
}

// #############################################################################################

class ManHinhDichVu extends StatelessWidget {
  const ManHinhDichVu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dichVuSpa = [
      {
        'ten': 'Tắm Spa',
        'moTa':
            'Dịch vụ tắm spa dành cho thú cưng giúp loại bỏ bụi bẩn, tế bào chết và mùi hôi trên cơ thể. '
            'Sử dụng sữa tắm chuyên dụng giúp làm mềm lông, giữ độ ẩm cho da và bảo vệ thú cưng khỏi các bệnh ngoài da. '
            'Quy trình gồm các bước: chải lông gỡ rối, làm ướt lông, massage với sữa tắm, xả sạch, sấy khô, xịt dưỡng và chải lông hoàn thiện. '
            'Dịch vụ phù hợp với mọi giống chó mèo, đặc biệt là những bé có bộ lông dài dễ bết dính.',
        'gia': '200,000 VND',
        'hinhAnh':
            'https://thucungshinpet.com/wp-content/uploads/2023/02/2.jpg',
      },
      {
        'ten': 'Tiêm Phòng',
        'moTa':
            'Tiêm phòng là biện pháp quan trọng giúp bảo vệ thú cưng khỏi các bệnh truyền nhiễm nguy hiểm như bệnh dại, Care, Parvo, Lepto, viêm gan truyền nhiễm... '
            'Dịch vụ bao gồm tư vấn lịch tiêm phòng theo độ tuổi và tình trạng sức khỏe của thú cưng. '
            'Quy trình tiêm an toàn, sử dụng vaccine chính hãng, có nguồn gốc rõ ràng. '
            'Thú cưng sẽ được kiểm tra sức khỏe trước khi tiêm để đảm bảo không có phản ứng phụ. '
            'Sau khi tiêm, nhân viên sẽ hướng dẫn cách chăm sóc và theo dõi tình trạng thú cưng.',
        'gia': '300,000 VND',
        'hinhAnh':
            'https://cdn.tgdd.vn/Files/2021/04/17/1344101/tiem-phong-dai-cho-cho-meo-va-nhung-dieu-chu-nuoi-can-phai-biet-202104171259416241.jpg',
      },
      {
        'ten': 'Cắt Tỉa Lông',
        'moTa':
            'Dịch vụ cắt tỉa lông giúp thú cưng trông gọn gàng, đáng yêu hơn. '
            'Chúng tôi sử dụng các dụng cụ cắt tỉa chuyên nghiệp, đảm bảo không gây tổn thương da của thú cưng. '
            'Có nhiều kiểu dáng cắt tỉa phù hợp với từng giống chó mèo, từ phong cách dễ thương đến phong cách sang trọng. '
            'Quy trình bao gồm: tắm sạch trước khi cắt, chải lông để gỡ rối, cắt tỉa theo yêu cầu, dặm lại và kiểm tra tổng thể. '
            'Ngoài ra, dịch vụ còn bao gồm vệ sinh tai, cắt móng và làm sạch vùng mắt.',
        'gia': '250,000 VND',
        'hinhAnh':
            'https://dailytongdo.com/wp-content/uploads/2024/03/cat-tia-tc.jpg',
      },
      {
        'ten': 'Khám Sức Khỏe',
        'moTa':
            'Dịch vụ khám sức khỏe tổng quát giúp phát hiện sớm các bệnh lý, đảm bảo thú cưng luôn trong tình trạng tốt nhất. '
            'Quy trình khám bao gồm kiểm tra thể trạng, cân nặng, da và lông, răng miệng, mắt, tai, hệ tiêu hóa, tim mạch và các chỉ số sinh hóa quan trọng. '
            'Bác sĩ sẽ tư vấn chế độ dinh dưỡng, tiêm phòng, tẩy giun và cách chăm sóc phù hợp. '
            'Nếu phát hiện bệnh lý, thú cưng sẽ được tư vấn điều trị kịp thời. '
            'Dịch vụ phù hợp với tất cả thú cưng, đặc biệt là những bé lớn tuổi hoặc có dấu hiệu bệnh lý cần theo dõi thường xuyên.',
        'gia': '400,000 VND',
        'hinhAnh':
            'https://benhvienthuyanipet.com/wp-content/uploads/2021/10/tu-van-kham-chua-benh-pet-3.jpg',
      },
      {
        'ten': 'Mua Thức Ăn',
        'moTa':
            'Cung cấp thức ăn chất lượng cao, giàu dinh dưỡng và phù hợp với từng giai đoạn phát triển của thú cưng. '
            'Sản phẩm bao gồm thức ăn hạt, pate, snack thưởng, và thức ăn tươi như thịt, cá, rau củ chế biến sẵn. '
            'Thức ăn đảm bảo không chứa chất bảo quản độc hại, hỗ trợ hệ tiêu hóa, giúp thú cưng phát triển khỏe mạnh, lông mượt, tăng sức đề kháng. '
            'Có nhiều dòng sản phẩm từ các thương hiệu nổi tiếng như Royal Canin, Pedigree, NutriSource, và nhiều hãng khác.',
        'gia': '100,000 VND',
        'hinhAnh':
            'https://petservicehcm.com/wp-content/uploads/2024/07/thuc-an-cho-thu-cung.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dịch Vụ Spa Thú Cưng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: dichVuSpa.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChiTietDichVu(dichVu: dichVuSpa[index]),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                shadowColor: Colors.teal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        dichVuSpa[index]['hinhAnh']!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dichVuSpa[index]['ten']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dichVuSpa[index]['moTa']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dichVuSpa[index]['gia']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChiTietDichVu extends StatelessWidget {
  final Map<String, String> dichVu;

  const ChiTietDichVu({super.key, required this.dichVu});

  @override
  Widget build(BuildContext context) {
    final cart = Cart.of(context); // Lấy Cart từ context
    final cartProvider = cart.cartProvider; // Lấy CartProvider từ Cart

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dichVu['ten']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  dichVu['hinhAnh']!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dichVu['ten']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dichVu['moTa']!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Giá: ${dichVu['gia']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Thêm sản phẩm vào giỏ hàng
                    cartProvider.addItem(dichVu); // Gọi addItem từ cartProvider
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bạn đã đặt dịch vụ: ${dichVu['ten']}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Xác nhận đặt dịch vụ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// #############################################################################################

class ManHinhHoTroKhachHang extends StatelessWidget {
  const ManHinhHoTroKhachHang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ Trợ Khách Hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.email, color: Colors.blueGrey),
              title: Text('Gửi Email Hỗ Trợ'),
              subtitle: Text('support@spathuccung.com'),
              //onTap: _launchEmail,
            ),
            ListTile(
              leading: Icon(Icons.facebook, color: Colors.blue),
              title: Text('Fanpage Facebook'),
              subtitle: Text('facebook.com/spathuccung'),
              //onTap: _launchFacebook,
            ),
            const Divider(),
            Expanded(child: ChatBotWidget()),
          ],
        ),
      ),
    );
  }
}

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({super.key});

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({'user': _controller.text});
      _messages.add({
        'bot': 'Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi sớm nhất có thể.',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message.keys.first == 'user';
              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.lightBlueAccent : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.values.first,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.lightBlueAccent),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class User {
  String name;
  String email;
  String password;

  User({required this.name, required this.email, required this.password});
}

class ManHinhUuDai extends StatelessWidget {
  const ManHinhUuDai({super.key});

  final List<Map<String, String>> uuDai = const [
    {
      'tieuDe': '🔥 Giảm ngay 20% dịch vụ tắm spa',
      'moTa':
          'Tận hưởng dịch vụ tắm spa cao cấp giúp thú cưng thư giãn, làm sạch lông, khử mùi hôi.',
      'hinhAnh': 'https://thucungshinpet.com/wp-content/uploads/2023/02/2.jpg',
      'thoiGian': '⏳ Hạn cuối: 31/03/2025',
    },
    {
      'tieuDe': '🎁 Mua 2 tặng 1 thức ăn',
      'moTa':
          'Mua 2 gói thức ăn bất kỳ, nhận ngay 1 gói miễn phí. Hàng chính hãng, dinh dưỡng cao!',
      'hinhAnh':
          'https://petservicehcm.com/wp-content/uploads/2024/07/thuc-an-cho-thu-cung.jpg',
      'thoiGian': '⏳ Hạn cuối: 15/04/2025',
    },
    {
      'tieuDe': '💉 Khám sức khỏe miễn phí',
      'moTa':
          'Nhận ngay một lần khám sức khỏe tổng quát miễn phí khi sử dụng bất kỳ dịch vụ nào.',
      'hinhAnh':
          'https://benhvienthuyanipet.com/wp-content/uploads/2021/10/tu-van-kham-chua-benh-pet-3.jpg',
      'thoiGian': '⏳ Hạn cuối: 30/04/2025',
    },
    {
      'tieuDe': '✂️ Giảm 15% cắt tỉa lông',
      'moTa':
          'Giúp thú cưng xinh xắn hơn với giá ưu đãi, giảm ngay 15% khi đặt lịch trước.',
      'hinhAnh':
          'https://dailytongdo.com/wp-content/uploads/2024/03/cat-tia-tc.jpg',
      'thoiGian': '⏳ Hạn cuối: 10/05/2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎉 Ưu Đãi Đặc Biệt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: uuDai.length,
        itemBuilder: (context, index) {
          final uuDaiItem = uuDai[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.network(
                      uuDaiItem['hinhAnh']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uuDaiItem['tieuDe']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          uuDaiItem['moTa']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              uuDaiItem['thoiGian']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              label: const Text('Xem chi tiết'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// #############################################################################################

class ManHinhCaiDat extends StatefulWidget {
  const ManHinhCaiDat({Key? key}) : super(key: key);

  @override
  _ManHinhCaiDatState createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài Đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blueGrey),
            title: Text(
              auth.FirebaseAuth.instance.currentUser?.displayName ??
                  "Người dùng",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              auth.FirebaseAuth.instance.currentUser?.email ?? "Chưa có email",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Đổi tên'),
            onTap: () => _doiTenNguoiDung(context),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Đổi Email'),
            onTap: () => _doiEmail(context),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Đổi mật khẩu'),
            onTap: () => _doiMatKhau(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
            title: const Text('About'),
            subtitle: const Text('Phiên bản 1.0.0\nNhà phát triển: QQTĐ Team'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Spa Thú Cưng',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Nhà phát triển: QQTĐ Team',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () => _dangXuat(context),
          ),
        ],
      ),
    );
  }

  // Hàm đổi tên người dùng
  void _doiTenNguoiDung(BuildContext context) {
    TextEditingController tenMoiController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Đổi tên"),
          content: TextField(
            controller: tenMoiController,
            decoration: const InputDecoration(
              labelText: "Nhập tên mới",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                if (tenMoiController.text.isNotEmpty) {
                  try {
                    await auth.FirebaseAuth.instance.currentUser?.updateProfile(
                      displayName: tenMoiController.text,
                    );
                    setState(() {}); // Cập nhật lại giao diện
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Tên đã được cập nhật thành: ${tenMoiController.text}",
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                  }
                }
              },
              child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Hàm đổi Email
  void _doiEmail(BuildContext context) {
    TextEditingController emailMoiController = TextEditingController();
    TextEditingController matKhauController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Đổi Email"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailMoiController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Nhập email mới",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: matKhauController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nhập mật khẩu",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                if (matKhauController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mật khẩu không được để trống"),
                    ),
                  );
                  return;
                } else if (emailMoiController.text.isEmpty ||
                    !emailMoiController.text.contains("@")) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email không hợp lệ")),
                  );
                  return;
                }

                try {
                  auth.User? user = auth.FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Xác thực lại người dùng trước khi đổi email
                    auth.AuthCredential credential = auth
                        .EmailAuthProvider.credential(
                      email: user.email!,
                      password: matKhauController.text,
                    );

                    await user.reauthenticateWithCredential(credential);

                    // Gửi email xác thực tới email mới
                    await user.verifyBeforeUpdateEmail(emailMoiController.text);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Một email xác nhận đã được gửi đến ${emailMoiController.text}. Vui lòng xác nhận trước khi cập nhật email.",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              },
              child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Hàm đổi mật khẩu
  void _doiMatKhau(BuildContext context) {
    TextEditingController matKhauCuController = TextEditingController();
    TextEditingController matKhauMoiController = TextEditingController();
    TextEditingController xacNhanMatKhauController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Đổi mật khẩu"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: matKhauCuController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu hiện tại",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: matKhauMoiController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu mới",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: xacNhanMatKhauController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Xác nhận mật khẩu mới",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                // Kiểm tra mật khẩu hiện tại
                if (matKhauCuController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mật khẩu hiện tại không được để trống"),
                    ),
                  );
                } else if (matKhauMoiController.text !=
                    xacNhanMatKhauController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mật khẩu xác nhận không khớp"),
                    ),
                  );
                } else {
                  try {
                    // Đăng nhập tạm thời để xác thực mật khẩu
                    UserCredential userCredential = await auth
                        .FirebaseAuth
                        .instance
                        .signInWithEmailAndPassword(
                          email: auth.FirebaseAuth.instance.currentUser!.email!,
                          password: matKhauCuController.text,
                        );

                    // Cập nhật mật khẩu
                    await userCredential.user?.updatePassword(
                      matKhauMoiController.text,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mật khẩu đã được cập nhật thành công"),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                  }
                }
              },
              child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Hàm đăng xuất
  void _dangXuat(BuildContext context) async {
    await auth.FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
      (route) => false,
    );
  }
}

// ##################################################################################

class ManHinhGioHang extends StatefulWidget {
  const ManHinhGioHang({super.key});

  @override
  _ManHinhGioHangState createState() => _ManHinhGioHangState();
}

class _ManHinhGioHangState extends State<ManHinhGioHang> {
  DateTime? selectedDate;
  late CartProvider cartProvider;
  late String userId;
  List<Map<String, dynamic>> appointmentHistory = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      cartProvider = Cart.of(context).cartProvider;
      userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user";
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      await loadCartFromFirestore(userId);
      await loadAppointmentHistory();
    } catch (e) {
      print("Error loading initial data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải dữ liệu: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> loadCartFromFirestore(String userId) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (doc.exists) {
        // Load cart items
        if (doc['cart'] != null) {
          List<dynamic> cartItems = doc['cart'];
          cartProvider.clear();
          for (var item in cartItems) {
            cartProvider.addItem(Map<String, String>.from(item));
          }
        }

        // Load selected date
        if (doc['selectedDate'] != null) {
          setState(() {
            selectedDate = DateTime.parse(doc['selectedDate']);
          });
        }
      }
    } catch (e) {
      print("Error loading cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải giỏ hàng: ${e.toString()}")),
      );
    }
  }

  Future<void> loadAppointmentHistory() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      setState(() {
        appointmentHistory =
            querySnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
      });
    } catch (e) {
      print("Error loading appointment history: $e");
    }
  }

  Future<void> saveCartToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // Save to appointments collection
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': userId,
        'userEmail': user?.email,
        'userName': user?.displayName,
        'items': cartProvider.items,
        'totalPrice': cartProvider.totalPrice(),
        'selectedDate': selectedDate?.toIso8601String(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user's cart
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'cart': cartProvider.items,
        'selectedDate': selectedDate?.toIso8601String(),
        'lastCartUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đặt lịch thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh data
      await loadAppointmentHistory();
    } catch (e) {
      print("Error saving cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đặt lịch: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ Hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        actions: [
          if (appointmentHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showAppointmentHistory(),
            ),
        ],
      ),
      body:
          cartProvider.items.isEmpty
              ? _buildEmptyCart()
              : Column(
                children: [
                  _buildDatePicker(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return _buildCartItem(item, index);
                      },
                    ),
                  ),
                  _buildTotalPrice(),
                ],
              ),
      bottomNavigationBar:
          cartProvider.items.isEmpty ? null : _buildOrderButton(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ManHinhChinh()),
              );
            },
            child: const Text('Quay lại trang chủ'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin đặt lịch',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDate == null
                            ? 'Chưa chọn ngày'
                            : 'Ngày đã chọn:',
                        style: TextStyle(
                          color:
                              selectedDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                      if (selectedDate != null)
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      selectedDate == null ? 'Chọn ngày' : 'Đổi ngày',
                    ),
                  ),
                ],
              ),
              if (selectedDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Giờ làm việc: 8:00 - 17:00',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orangeAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Widget _buildCartItem(Map<String, String> item, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item['hinhAnh']!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.pets, size: 40, color: Colors.grey);
            },
          ),
        ),
        title: Text(
          item['ten']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Giá: ${item['gia']}',
          style: const TextStyle(color: Colors.deepOrange),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              cartProvider.removeItem(index);
            });
            saveCartToFirestore();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xóa dịch vụ khỏi giỏ hàng'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalPrice() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.orangeAccent.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng cộng:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency(cartProvider.totalPrice()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (selectedDate != null)
                Text(
                  'Ngày đặt: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          if (selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng chọn ngày đặt lịch'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Xác nhận đặt lịch'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bạn có chắc chắn muốn đặt lịch với:'),
                      const SizedBox(height: 8),
                      Text(
                        'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng tiền: ${formatCurrency(cartProvider.totalPrice())}',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await saveCartToFirestore();
                        setState(() {
                          cartProvider.clear();
                          selectedDate = null;
                        });
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
          );
        },
        icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
        label: const Text(
          'ĐẶT LỊCH NGAY',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAppointmentHistory() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Lịch sử đặt lịch'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appointmentHistory.length,
                itemBuilder: (context, index) {
                  final appointment = appointmentHistory[index];
                  final date =
                      appointment['selectedDate'] != null
                          ? DateTime.parse(appointment['selectedDate'])
                          : null;
                  final items = appointment['items'] as List<dynamic>? ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (date != null)
                            Text(
                              'Ngày: ${DateFormat('dd/MM/yyyy').format(date)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            'Trạng thái: ${appointment['status'] ?? 'pending'}',
                            style: TextStyle(
                              color:
                                  (appointment['status'] == 'completed')
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Dịch vụ:'),
                          ...items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text('- ${item['ten']} (${item['gia']})'),
                            );
                          }).toList(),
                          const SizedBox(height: 4),
                          Text(
                            'Tổng tiền: ${formatCurrency(appointment['totalPrice'] ?? 0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }
}

class Cart extends InheritedWidget {
  final CartProvider cartProvider;

  const Cart({Key? key, required this.cartProvider, required Widget child})
    : super(key: key, child: child);

  static Cart of(BuildContext context) {
    final Cart? result = context.dependOnInheritedWidgetOfExactType<Cart>();
    assert(result != null, 'No Cart found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Cart oldWidget) {
    return oldWidget.cartProvider.items != cartProvider.items;
  }
}

class CartProvider {
  List<Map<String, String>> _items = [];

  List<Map<String, String>> get items => _items;

  void addItem(Map<String, String> item) {
    _items.add(item);
  }

  void clear() {
    _items.clear(); // Phương thức này sẽ xóa tất cả sản phẩm trong giỏ hàng
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  double totalPrice() {
    double total = 0.0;
    for (var item in _items) {
      // Giả sử giá được lưu dưới dạng chuỗi với định dạng "100,000 VND"
      String priceString = item['gia']!
          .replaceAll(',', '')
          .replaceAll(' VND', '');
      total += double.tryParse(priceString) ?? 0.0;
    }
    return total;
  }
}

String formatCurrency(double amount) {
  // Định dạng số tiền với dấu phẩy
  return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND';
}

class ManHinhLichHen extends StatefulWidget {
  const ManHinhLichHen({super.key});

  @override
  State<ManHinhLichHen> createState() => _ManHinhLichHenState();
}

class _ManHinhLichHenState extends State<ManHinhLichHen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      if (userId == null) return;

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      setState(() {
        appointments =
            querySnapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                ...data,
                'id': doc.id, // Thêm ID document để tiện thao tác
              };
            }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi tải lịch hẹn: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải lịch hẹn: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Hẹn Của Tôi'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có lịch hẹn nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManHinhDichVu(),
                    ),
                  ),
              child: const Text('Đặt lịch ngay'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final date =
        appointment['selectedDate'] != null
            ? DateTime.parse(appointment['selectedDate'])
            : null;
    final createdAt =
        appointment['createdAt'] != null
            ? (appointment['createdAt'] as Timestamp).toDate()
            : null;
    final items = List<Map<String, dynamic>>.from(appointment['items'] ?? []);
    final status = appointment['status'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với ID và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã #${appointment['id'].substring(0, 6)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'completed' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'completed' ? 'Hoàn thành' : 'Đang chờ',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            // Thông tin ngày
            if (date != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày hẹn: ${DateFormat('dd/MM/yyyy').format(date)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Thông tin đặt lịch
            if (createdAt != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Đặt lúc: ${DateFormat('HH:mm dd/MM/yyyy').format(createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Danh sách dịch vụ
            const Text(
              'Dịch vụ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.orange)),
                    Expanded(
                      child: Text(
                        '${item['ten']} (${item['gia']})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 16),

            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formatCurrency(appointment['totalPrice']?.toDouble() ?? 0),
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
