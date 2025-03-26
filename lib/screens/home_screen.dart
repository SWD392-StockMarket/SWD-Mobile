// import 'package:flutter/material.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home Screen')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.pushNamed(context, '/details');
//           },
//           child: Text('Go to Details Screen'),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../widgets/gradient_container.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/footer_menu.dart';
import '../services/authservice.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return GradientContainer(scaffold:
        Scaffold(
      backgroundColor: Colors.transparent,
          appBar: GradientAppBar(
            title: 'FUStock',
            icon: Icons.account_circle,
            onIconPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => filterButton('Filter')),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => stockCard(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            color: Colors.purple,
            child: const Text('News', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
            ),
          ),
        ],
      ),
          bottomNavigationBar: ScrollableFooterMenu(buttons:
          [
            FooterButton(icon: Icons.home, label: "Home", onTap: () {Navigator.pushNamed(context, '/home');}),
            FooterButton(icon: Icons.playlist_add, label: "Watch List", onTap: () {Navigator.pushNamed(context, '/watchlist');}),
            FooterButton(icon: Icons.newspaper, label: "News", onTap: () {Navigator.pushNamed(context, '/news');}),
            FooterButton(icon: Icons.monetization_on, label: "Stock", onTap: () {Navigator.pushNamed(context, '/stock');}),
            FooterButton(icon: Icons.person, label: "Profile", onTap: () {Navigator.pushNamed(context, '/profile');}),
            FooterButton(icon: Icons.logout, label: "Logout", onTap: () {
              _authService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }),
          ]
          ),
    ));
  }

  Widget filterButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        onPressed: () {},
        child: Text(text),
      ),
    );
  }

  Widget stockCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Symbol', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('AAA'),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Icon(Icons.candlestick_chart, size: 30),
            SizedBox(width: 10),
            Icon(Icons.trending_up, size: 30),
          ],
        ),
      ),
    );
  }
}
